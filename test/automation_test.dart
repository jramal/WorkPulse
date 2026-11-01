import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workpulse/background/tracking_notification.dart';
import 'package:workpulse/data/database.dart';
import 'package:workpulse/domain/break_alerts.dart';
import 'package:workpulse/domain/break_type_repository.dart';
import 'package:workpulse/domain/time_format.dart';
import 'package:workpulse/domain/tracking_engine.dart';

void main() {
  late AppDatabase db;
  late TrackingEngine engine;
  late BreakTypeRepository breakTypes;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    engine = TrackingEngine(db);
    breakTypes = BreakTypeRepository(db);
  });

  tearDown(() => db.close());

  Future<int> teaBreak() async =>
      (await breakTypes.watchActive().first).first.id;

  group('migration', () {
    test('v1 data survives the upgrade to the latest version', () async {
      final old = AppDatabase(
        executor: NativeDatabase.memory(
          setup: (raw) {
            raw.execute(
              'CREATE TABLE break_types (id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'name TEXT NOT NULL, description TEXT, color_value INTEGER, '
              'is_default INTEGER NOT NULL DEFAULT 0, '
              'is_active INTEGER NOT NULL DEFAULT 1, '
              'created_at INTEGER NOT NULL DEFAULT 0);',
            );
            raw.execute(
              'CREATE TABLE activities (id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'kind TEXT NOT NULL, break_type_id INTEGER, '
              'start_time INTEGER NOT NULL, end_time INTEGER, '
              'duration_seconds INTEGER, day_key TEXT NOT NULL);',
            );
            raw.execute(
              'CREATE TABLE app_settings (id INTEGER NOT NULL DEFAULT 0 PRIMARY KEY, '
              'daily_target_minutes INTEGER NOT NULL DEFAULT 480, '
              'allowed_break_minutes INTEGER NOT NULL DEFAULT 60);',
            );
            raw.execute("INSERT INTO break_types (name) VALUES ('Tea Break');");
            raw.execute(
              'INSERT INTO activities (kind, start_time, day_key) '
              "VALUES ('work', 1000, '2026-01-01');",
            );
            raw.execute(
              'INSERT INTO app_settings (id, daily_target_minutes) VALUES (0, 450);',
            );
            raw.execute('PRAGMA user_version = 1;');
          },
        ),
      );
      addTearDown(old.close);

      final type = (await old.select(old.breakTypes).get()).single;
      expect(type.name, 'Tea Break');
      expect(type.alarmEnabled, isFalse);
      expect(type.expectedDurationMinutes, 15);
      expect(type.midBreakAlarmMinutes, isEmpty);

      final activity = (await old.select(old.activities).get()).single;
      expect(activity.dayKey, '2026-01-01');
      expect(activity.targetMinutes, isNull);

      final settings = await old.select(old.appSettings).getSingle();
      expect(settings.dailyTargetMinutes, 450);
      expect(await old.select(old.tasks).get(), isEmpty);
    });
  });

  group('state machine guards', () {
    test('a stale notification tap changes nothing', () async {
      final id = await teaBreak();
      expect(await engine.resumeWork(), isNull);
      expect(await engine.endWork(), isNull);
      expect(await engine.startBreak(id), isNull);

      await engine.startWork();
      expect(await engine.resumeWork(), isNull);
      expect(await engine.startWork(), isNull);

      await engine.startBreak(id);
      expect(await engine.startBreak(id), isNull);
      expect(await engine.startWork(), isNull);

      expect((await db.select(db.activities).get()).length, 2);
    });

    test('a transition reports what it closed and opened', () async {
      final id = await teaBreak();
      final started = await engine.startWork();
      expect(started!.closed, isNull);
      expect(started.opened!.kind, ActivityKind.work);

      final onBreak = await engine.startBreak(id);
      expect(onBreak!.closed!.id, started.opened!.id);
      expect(onBreak.closed!.endTime, isNotNull);
      expect(onBreak.opened!.breakTypeId, id);

      final ended = await engine.endWork();
      expect(ended!.closed!.id, onBreak.opened!.id);
      expect(ended.opened, isNull);
    });

    test('new activities record the target in force', () async {
      await engine.updateDailyTarget(const Duration(hours: 6));
      final started = await engine.startWork();
      expect(started!.opened!.targetMinutes, 360);
    });
  });

  group('break alarm timing (FR-11.3, FR-11.5)', () {
    Future<BreakType> configuredType(BreakTypesCompanion values) async {
      final id = await teaBreak();
      await breakTypes.update(id, values);
      return (await breakTypes.find(id))!;
    }

    Activity breakAt(DateTime start, int typeId) => Activity(
      id: 7,
      kind: ActivityKind.breakActivity,
      breakTypeId: typeId,
      startTime: start,
      dayKey: dayKeyFor(start),
    );

    final start = DateTime(2026, 1, 1, 10);

    test('off by default', () async {
      final type = (await breakTypes.watchActive().first).first;
      expect(type.alarmEnabled, isFalse);
      expect(breakAlerts(breakAt(start, type.id), type), isEmpty);
    });

    test('once fires at the expected duration', () async {
      final type = await configuredType(
        const BreakTypesCompanion(
          alarmEnabled: Value(true),
          expectedDurationMinutes: Value(20),
        ),
      );
      final alerts = breakAlerts(breakAt(start, type.id), type);
      expect(alerts.map((a) => a.time), [DateTime(2026, 1, 1, 10, 20)]);
      expect(alerts.single.title, '${type.name} is over');
    });

    test('repeat fires at each interval, within a limit', () async {
      final type = await configuredType(
        const BreakTypesCompanion(
          alarmEnabled: Value(true),
          expectedDurationMinutes: Value(10),
          reminderBehaviour: Value(ReminderBehaviour.repeat),
          repeatIntervalMinutes: Value(5),
        ),
      );
      final times = breakAlerts(
        breakAt(start, type.id),
        type,
      ).map((a) => a.time).toList();
      expect(times.take(3), [
        DateTime(2026, 1, 1, 10, 10),
        DateTime(2026, 1, 1, 10, 15),
        DateTime(2026, 1, 1, 10, 20),
      ]);
      expect(times, hasLength(13));
    });

    test(
      'alarms ring at set times during a 1-hour break, then at its end',
      () async {
        final type = await configuredType(
          const BreakTypesCompanion(
            alarmEnabled: Value(true),
            expectedDurationMinutes: Value(60),
            midBreakAlarmMinutes: Value('15,5,10'),
          ),
        );
        final alerts = breakAlerts(breakAt(start, type.id), type);
        expect(alerts.map((a) => a.time), [
          DateTime(2026, 1, 1, 10, 5),
          DateTime(2026, 1, 1, 10, 10),
          DateTime(2026, 1, 1, 10, 15),
          DateTime(2026, 1, 1, 11),
        ]);
        expect(alerts.first.title, '5m into ${type.name}');
        expect(alerts.first.body, '55m left of your 1h break.');
        expect(alerts.last.title, '${type.name} is over');
      },
    );

    test('alarms past the break length are skipped', () async {
      final type = await configuredType(
        const BreakTypesCompanion(
          alarmEnabled: Value(true),
          expectedDurationMinutes: Value(10),
          midBreakAlarmMinutes: Value('5,10,30'),
        ),
      );
      expect(breakAlerts(breakAt(start, type.id), type).map((a) => a.time), [
        DateTime(2026, 1, 1, 10, 5),
        DateTime(2026, 1, 1, 10, 10),
      ]);
    });

    test('alarm times are cleaned up when read', () {
      expect(parseMidBreakAlarms(''), isEmpty);
      expect(parseMidBreakAlarms('15, 5,x,0,5'), [5, 15]);
      expect(encodeMidBreakAlarms([5, 10]), '5,10');
    });

    test('a break can never need more ids than cancellation covers', () async {
      final type = await configuredType(
        BreakTypesCompanion(
          alarmEnabled: const Value(true),
          expectedDurationMinutes: const Value(600),
          reminderBehaviour: const Value(ReminderBehaviour.repeat),
          midBreakAlarmMinutes: Value(
            encodeMidBreakAlarms(List.generate(30, (i) => i + 1)),
          ),
        ),
      );
      expect(
        breakAlerts(breakAt(start, type.id), type).length,
        lessThanOrEqualTo(maxBreakAlerts),
      );
    });
  });

  group('break type deletion (NFR-6)', () {
    test('an unused type is removed', () async {
      final id = await teaBreak();
      expect(await breakTypes.delete(id), isFalse);
      expect(await breakTypes.find(id), isNull);
    });

    test('a used type is archived', () async {
      final id = await teaBreak();
      await engine.startWork();
      await engine.startBreak(id);

      expect(await breakTypes.delete(id), isTrue);
      expect((await breakTypes.find(id))!.isActive, isFalse);
    });

    test('names are unique, ignoring case and spaces', () async {
      expect(await breakTypes.isNameTaken(' tea break '), isTrue);
      expect(await breakTypes.isNameTaken('Walk'), isFalse);
      final id = await teaBreak();
      expect(await breakTypes.isNameTaken('Tea Break', exceptId: id), isFalse);
    });
  });

  group('notification buttons (FR-12.4)', () {
    Activity open(ActivityKind kind) => Activity(
      id: 1,
      kind: kind,
      startTime: DateTime(2026),
      dayKey: '2026-01-01',
    );

    test('working offers the first two break types and End', () async {
      final types = await breakTypes.watchActive().first;
      final buttons = trackingButtons(
        open: open(ActivityKind.work),
        activeBreakTypes: types,
      );
      expect(buttons.map((b) => b.label), [
        'Tea Break',
        'Lunch Break',
        'End work',
      ]);
      expect(breakTypeIdFromButton(buttons.first.id), types.first.id);
      expect(breakTypeIdFromButton(buttons.last.id), isNull);
    });

    test('on break offers Resume and End', () {
      final buttons = trackingButtons(
        open: open(ActivityKind.breakActivity),
        activeBreakTypes: const [],
      );
      expect(buttons.map((b) => b.id), [resumeButtonId, endButtonId]);
    });
  });

  test('single activities keep their seconds until they reach an hour', () {
    expect(formatElapsed(const Duration(seconds: 5)), '5s');
    expect(formatElapsed(const Duration(minutes: 1, seconds: 56)), '1m 56s');
    expect(formatElapsed(const Duration(hours: 1, minutes: 5)), '1h 5m');
  });
}
