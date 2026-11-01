import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workpulse/background/tracking_notification.dart';
import 'package:workpulse/data/database.dart';
import 'package:workpulse/domain/tracking_engine.dart';

void main() {
  late AppDatabase db;
  late TrackingEngine engine;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    engine = TrackingEngine(db);
  });

  tearDown(() => db.close());

  test(
    'starting work creates a single open Working activity (FR-1.1)',
    () async {
      await engine.startWork();
      final open = await engine.watchOpenActivity().first;
      expect(open, isNotNull);
      expect(open!.kind, ActivityKind.work);
      expect(open.endTime, isNull);
    },
  );

  test(
    'starting a second activity while one is open is a no-op (FR-1.8)',
    () async {
      await engine.startWork();
      final firstOpenId = (await engine.watchOpenActivity().first)!.id;
      await engine.startWork();
      final stillOpenId = (await engine.watchOpenActivity().first)!.id;
      expect(stillOpenId, firstOpenId);
    },
  );

  test('starting a break closes the open Working activity (FR-1.2)', () async {
    final breakTypeId = await db
        .into(db.breakTypes)
        .insert(BreakTypesCompanion.insert(name: 'Tea Break'));

    await engine.startWork();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await engine.startBreak(breakTypeId);

    final open = await engine.watchOpenActivity().first;
    expect(open!.kind, ActivityKind.breakActivity);
    expect(open.breakTypeId, breakTypeId);

    final today = await engine
        .watchActivitiesForDay(dayKeyFor(DateTime.now()))
        .first;
    final workEntry = today.firstWhere((a) => a.kind == ActivityKind.work);
    expect(workEntry.endTime, isNotNull);
    expect(workEntry.durationSeconds, isNotNull);
  });

  test('resuming work closes the break and reopens Working (FR-1.3)', () async {
    final breakTypeId = await db
        .into(db.breakTypes)
        .insert(BreakTypesCompanion.insert(name: 'Tea Break'));
    await engine.startWork();
    await engine.startBreak(breakTypeId);

    await engine.resumeWork();

    final open = await engine.watchOpenActivity().first;
    expect(open!.kind, ActivityKind.work);
  });

  test(
    'ending work closes whatever is open and leaves nothing open (FR-1.4)',
    () async {
      await engine.startWork();
      await engine.endWork();

      final open = await engine.watchOpenActivity().first;
      expect(open, isNull);
    },
  );

  test('summarize sums worked/break time and computes remaining vs overtime (FR-2.1-2.5)', () {
    final settings = AppSetting(
      id: 0,
      dailyTargetMinutes: 480,
      allowedBreakMinutes: 60,
      teamsEnabled: false,
    );
    final now = DateTime(2026, 1, 1, 12);
    final activities = [
      Activity(
        id: 1,
        kind: ActivityKind.work,
        breakTypeId: null,
        startTime: now.subtract(const Duration(hours: 3)),
        endTime: now.subtract(const Duration(hours: 2)),
        durationSeconds: 3600,
        dayKey: dayKeyFor(now),
      ),
      Activity(
        id: 2,
        kind: ActivityKind.breakActivity,
        breakTypeId: 1,
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 45)),
        durationSeconds: 900,
        dayKey: dayKeyFor(now),
      ),
      // Still open: counts provisionally up to `now` (FR-2.6).
      Activity(
        id: 3,
        kind: ActivityKind.work,
        breakTypeId: null,
        startTime: now.subtract(const Duration(hours: 1)),
        endTime: null,
        durationSeconds: null,
        dayKey: dayKeyFor(now),
      ),
    ];

    final summary = engine.summarize(
      activities: activities,
      settings: settings,
      now: now,
    );

    expect(summary.totalWorked, const Duration(hours: 2)); // 3600s + 1h open
    expect(summary.totalBreak, const Duration(minutes: 15));
    expect(summary.remaining, const Duration(hours: 6));
    expect(summary.overtime, Duration.zero);
  });

  group('deleting a day', () {
    Future<int> addFinished(String dayKey) {
      return db
          .into(db.activities)
          .insert(
            ActivitiesCompanion.insert(
              kind: ActivityKind.work,
              startTime: DateTime(2026, 1, 5, 9),
              endTime: Value(DateTime(2026, 1, 5, 17)),
              dayKey: dayKey,
            ),
          );
    }

    test('removes only that day', () async {
      await addFinished('2026-01-05');
      await addFinished('2026-01-05');
      final kept = await addFinished('2026-01-06');

      expect(await engine.deleteDay('2026-01-05'), isTrue);

      final left = await db.select(db.activities).get();
      expect(left.map((a) => a.id), [kept]);
    });

    test('refuses a day still being tracked and changes nothing', () async {
      await engine.startWork();
      final today = dayKeyFor(DateTime.now());
      await engine.endWork();
      await engine.startWork();

      expect(await engine.deleteDay(today), isFalse);

      expect(await db.select(db.activities).get(), hasLength(2));
      expect(await engine.watchOpenActivity().first, isNotNull);
    });

    test('keeps a queued Teams message, unlinked from the day', () async {
      final activityId = await addFinished('2026-01-05');
      await db
          .into(db.teamsDeliveries)
          .insert(
            TeamsDeliveriesCompanion.insert(
              label: 'End of day',
              activityId: Value(activityId),
              message: 'Done',
              destination: 'https://example.com/hook',
              status: DeliveryStatus.queued,
              nextAttemptAt: DateTime(2026, 1, 5, 17),
              createdAt: DateTime(2026, 1, 5, 17),
            ),
          );

      expect(await engine.deleteDay('2026-01-05'), isTrue);

      final delivery = await db.select(db.teamsDeliveries).getSingle();
      expect(delivery.activityId, isNull);
      expect(delivery.status, DeliveryStatus.queued);
    });

    test('a day with no records is simply nothing to delete', () async {
      expect(await engine.deleteDay('2026-01-05'), isTrue);
    });
  });

  group('expected finish', () {
    final settings = AppSetting(
      id: 0,
      dailyTargetMinutes: 480,
      allowedBreakMinutes: 60,
      teamsEnabled: false,
    );

    Activity activity(
      int id,
      ActivityKind kind,
      DateTime start, [
      DateTime? end,
    ]) => Activity(
      id: id,
      kind: kind,
      breakTypeId: kind == ActivityKind.work ? null : 1,
      startTime: start,
      endTime: end,
      durationSeconds: null,
      dayKey: dayKeyFor(start),
    );

    DailySummary summarize(List<Activity> activities, DateTime now) =>
        engine.summarize(activities: activities, settings: settings, now: now);

    final nine = DateTime(2026, 1, 1, 9);

    test('is start plus target while working, and holds steady', () {
      final activities = [activity(1, ActivityKind.work, nine)];
      final fivePm = DateTime(2026, 1, 1, 17);

      expect(summarize(activities, nine).expectedFinish, fivePm);
      expect(
        summarize(activities, DateTime(2026, 1, 1, 11, 37)).expectedFinish,
        fivePm,
      );
    });

    test('moves later minute by minute during a break', () {
      final tenAm = DateTime(2026, 1, 1, 10);
      final activities = [
        activity(1, ActivityKind.work, nine, tenAm),
        activity(2, ActivityKind.breakActivity, tenAm),
      ];

      expect(
        summarize(
          activities,
          tenAm.add(const Duration(minutes: 5)),
        ).expectedFinish,
        DateTime(2026, 1, 1, 17, 5),
      );
    });

    test('stays pushed back by a 15-minute break after resuming', () {
      final tenAm = DateTime(2026, 1, 1, 10);
      final resumed = DateTime(2026, 1, 1, 10, 15);
      final activities = [
        activity(1, ActivityKind.work, nine, tenAm),
        activity(2, ActivityKind.breakActivity, tenAm, resumed),
        activity(3, ActivityKind.work, resumed),
      ];

      expect(
        summarize(activities, DateTime(2026, 1, 1, 13)).expectedFinish,
        DateTime(2026, 1, 1, 17, 15),
      );
    });

    test('reports when the target was met once in overtime', () {
      final activities = [activity(1, ActivityKind.work, nine)];

      expect(
        summarize(activities, DateTime(2026, 1, 1, 18)).expectedFinish,
        DateTime(2026, 1, 1, 17),
      );
    });

    test('gives way to the finish time once the day has ended', () {
      final end = DateTime(2026, 1, 1, 16);
      final summary = summarize([
        activity(1, ActivityKind.work, nine, end),
      ], DateTime(2026, 1, 1, 20));

      expect(summary.expectedFinish, isNull);
      expect(summary.finishedAt, end);
    });

    test('is unknown before work starts', () {
      final summary = summarize(const [], nine);

      expect(summary.expectedFinish, isNull);
      expect(summary.finishedAt, isNull);
    });

    test('notification shows the state, finish time and totals', () {
      final tenAm = DateTime(2026, 1, 1, 10);
      final onBreak = activity(2, ActivityKind.breakActivity, tenAm);
      final content = describeTracking(
        open: onBreak,
        summary: summarize([
          activity(1, ActivityKind.work, nine, tenAm),
          onBreak,
        ], DateTime(2026, 1, 1, 10, 15)),
      );

      expect(
        content.title.replaceAll(' ', ' '),
        'On break · finish by 5:15 PM',
      );
      expect(content.text, 'Worked 1h · Break 15m');
    });
  });

  test('settings updates are saved in whole minutes (FR-2.7)', () async {
    await engine.updateDailyTarget(const Duration(hours: 7, minutes: 30));
    await engine.updateAllowedBreak(const Duration(hours: 1, minutes: 15));

    final settings = await engine.watchSettings().first;
    expect(settings.dailyTargetMinutes, 450);
    expect(settings.allowedBreakMinutes, 75);
  });

  test('overtime is worked time beyond the daily target (FR-2.5)', () {
    final settings = AppSetting(
      id: 0,
      dailyTargetMinutes: 60,
      allowedBreakMinutes: 60,
      teamsEnabled: false,
    );
    final now = DateTime(2026, 1, 1, 12);
    final activities = [
      Activity(
        id: 1,
        kind: ActivityKind.work,
        breakTypeId: null,
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now,
        durationSeconds: 7200,
        dayKey: dayKeyFor(now),
      ),
    ];

    final summary = engine.summarize(
      activities: activities,
      settings: settings,
      now: now,
    );

    expect(summary.remaining, Duration.zero);
    expect(summary.overtime, const Duration(hours: 1));
  });
}
