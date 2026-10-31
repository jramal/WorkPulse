import 'package:drift/drift.dart';

import '../data/database.dart';
import 'teams_repository.dart';

/// Today's totals, derived at read time (CRS Section 8 — nothing here is
/// stored). [now] is folded in so an in-progress activity contributes its
/// provisional elapsed time (FR-2.6).
class DailySummary {
  const DailySummary({
    required this.totalWorked,
    required this.totalBreak,
    required this.target,
    required this.allowedBreak,
    this.startedAt,
    this.expectedFinish,
    this.finishedAt,
  });

  final Duration totalWorked;
  final Duration totalBreak;
  final Duration target;
  final Duration allowedBreak;

  /// When the day's first work segment began.
  final DateTime? startedAt;

  /// When the target will be met if work continues without another break.
  /// Only set while an activity is open; in the past once the target is met.
  final DateTime? expectedFinish;

  /// When the day's last activity ended. Only set while nothing is open.
  final DateTime? finishedAt;

  Duration get remaining =>
      totalWorked >= target ? Duration.zero : target - totalWorked;
  Duration get overtime =>
      totalWorked > target ? totalWorked - target : Duration.zero;
  bool get breakExceeded => totalBreak > allowedBreak;
  double get progress => target <= Duration.zero
      ? 1
      : (totalWorked.inSeconds / target.inSeconds).clamp(0.0, 1.0);
}

/// What a state change did: at most one activity closed and one opened.
class TrackingTransition {
  const TrackingTransition({this.closed, this.opened});

  final Activity? closed;
  final Activity? opened;
}

String dayKeyFor(DateTime time) {
  final local = time.toLocal();
  final y = local.year.toString().padLeft(4, '0');
  final m = local.month.toString().padLeft(2, '0');
  final d = local.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

/// Implements the work/break state machine (CRS FR-1.x) and the
/// productive-hours calculations (FR-2.x) on top of the local database.
/// Every transition writes a timestamp first; nothing here depends on an
/// in-memory counter, so elapsed time stays correct across restarts
/// (NFR-3/NFR-4).
class TrackingEngine {
  TrackingEngine(this._db) : _teams = TeamsRepository(_db);

  final AppDatabase _db;
  final TeamsRepository _teams;

  /// The single activity with no end time, if any (FR-1.8: at most one).
  Stream<Activity?> watchOpenActivity() {
    return (_db.select(_db.activities)
          ..where((a) => a.endTime.isNull())
          ..orderBy([(a) => OrderingTerm.desc(a.startTime)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<Activity>> watchActivitiesForDay(String dayKey) {
    return (_db.select(_db.activities)
          ..where((a) => a.dayKey.equals(dayKey))
          ..orderBy([(a) => OrderingTerm.asc(a.startTime)]))
        .watch();
  }

  /// Every recorded activity, oldest first within each day, newest day first.
  Stream<List<Activity>> watchAllActivities() {
    return (_db.select(_db.activities)..orderBy([
          (a) => OrderingTerm.desc(a.dayKey),
          (a) => OrderingTerm.asc(a.startTime),
        ]))
        .watch();
  }

  Stream<AppSetting> watchSettings() {
    return (_db.select(
      _db.appSettings,
    )..where((s) => s.id.equals(0))).watchSingle();
  }

  // Each returns null, changing nothing, when the current state doesn't allow
  // it: a notification button can be tapped after the app already moved on.

  Future<TrackingTransition?> startWork() => _transition(
    allowedFrom: (open) => open == null,
    opens: ActivityKind.work,
  );

  Future<TrackingTransition?> startBreak(int breakTypeId) => _transition(
    allowedFrom: (open) => open?.kind == ActivityKind.work,
    opens: ActivityKind.breakActivity,
    breakTypeId: breakTypeId,
  );

  Future<TrackingTransition?> resumeWork() => _transition(
    allowedFrom: (open) => open?.kind == ActivityKind.breakActivity,
    opens: ActivityKind.work,
  );

  Future<TrackingTransition?> endWork() =>
      _transition(allowedFrom: (open) => open != null);

  Future<TrackingTransition?> _transition({
    required bool Function(Activity? open) allowedFrom,
    ActivityKind? opens,
    int? breakTypeId,
  }) {
    return _db.transaction(() async {
      // Takes the write lock up front. Upgrading a read snapshot to a write
      // later would fail immediately, ignoring busy_timeout, if another engine
      // had committed in between.
      await _db.customStatement('UPDATE app_settings SET id = id WHERE 0');

      final open = await (_db.select(_db.activities)
            ..where((a) => a.endTime.isNull())
            ..limit(1))
          .getSingleOrNull();
      if (!allowedFrom(open)) return null;

      final now = DateTime.now();
      final settings = await (_db.select(
        _db.appSettings,
      )..where((s) => s.id.equals(0))).getSingle();
      final closed = open == null ? null : await _close(open, now);
      final opened = opens == null
          ? null
          : await _db
                .into(_db.activities)
                .insertReturning(
                  ActivitiesCompanion.insert(
                    kind: opens,
                    breakTypeId: Value(breakTypeId),
                    startTime: now,
                    dayKey: dayKeyFor(now),
                    targetMinutes: Value(settings.dailyTargetMinutes),
                  ),
                );
      await _enqueueTeamsMessages(closed, opened, settings, now);
      return TrackingTransition(closed: closed, opened: opened);
    });
  }

  Future<Activity> _close(Activity open, DateTime endTime) async {
    final duration = endTime.difference(open.startTime).inSeconds;
    final rows =
        await (_db.update(
          _db.activities,
        )..where((a) => a.id.equals(open.id))).writeReturning(
          ActivitiesCompanion(
            endTime: Value(endTime),
            durationSeconds: Value(duration < 0 ? 0 : duration),
          ),
        );
    return rows.single;
  }

  Future<void> _enqueueTeamsMessages(
    Activity? closed,
    Activity? opened,
    AppSetting settings,
    DateTime now,
  ) async {
    final today = await (_db.select(
      _db.activities,
    )..where((a) => a.dayKey.equals(dayKeyFor(now)))).get();
    final summary = summarize(activities: today, settings: settings, now: now);

    Future<void> send(TeamsTrigger trigger, Activity activity) {
      return _teams.enqueue(
        trigger: trigger,
        activity: activity,
        settings: settings,
        summary: summary,
        now: now,
      );
    }

    final endedBreak = closed?.kind == ActivityKind.breakActivity;
    if (endedBreak) await send(TeamsTrigger.breakEnd, closed!);
    if (opened == null) {
      await send(TeamsTrigger.endWork, closed!);
    } else if (opened.kind == ActivityKind.breakActivity) {
      await send(TeamsTrigger.breakStart, opened);
    } else {
      await send(
        endedBreak ? TeamsTrigger.resumeWork : TeamsTrigger.startWork,
        opened,
      );
    }
  }

  /// FR-2.1–2.6: sums the given activities, counting an open one's elapsed
  /// time up to [now] as provisional.
  DailySummary summarize({
    required List<Activity> activities,
    required AppSetting settings,
    required DateTime now,
  }) {
    var worked = Duration.zero;
    var breaks = Duration.zero;
    var hasOpen = false;
    DateTime? startedAt;
    DateTime? lastEnd;
    for (final activity in activities) {
      final end = activity.endTime ?? now;
      final elapsed = end.difference(activity.startTime);
      final clamped = elapsed.isNegative ? Duration.zero : elapsed;
      if (activity.kind == ActivityKind.work) {
        worked += clamped;
        if (startedAt == null || activity.startTime.isBefore(startedAt)) {
          startedAt = activity.startTime;
        }
      } else {
        breaks += clamped;
      }
      if (activity.endTime == null) {
        hasOpen = true;
      } else if (lastEnd == null || end.isAfter(lastEnd)) {
        lastEnd = end;
      }
    }
    final target = Duration(minutes: settings.dailyTargetMinutes);
    return DailySummary(
      totalWorked: worked,
      totalBreak: breaks,
      target: target,
      allowedBreak: Duration(minutes: settings.allowedBreakMinutes),
      startedAt: startedAt,
      // Remaining work from now: every minute spent on a break, or away after
      // ending the day, pushes this later, while working leaves it unchanged.
      expectedFinish: hasOpen ? now.add(target - worked) : null,
      finishedAt: hasOpen ? null : lastEnd,
    );
  }

  Future<void> updateDailyTarget(Duration target) {
    return _writeSettings(
      AppSettingsCompanion(dailyTargetMinutes: Value(target.inMinutes)),
    );
  }

  Future<void> updateAllowedBreak(Duration allowed) {
    return _writeSettings(
      AppSettingsCompanion(allowedBreakMinutes: Value(allowed.inMinutes)),
    );
  }

  Future<void> _writeSettings(AppSettingsCompanion changes) {
    return (_db.update(
      _db.appSettings,
    )..where((s) => s.id.equals(0))).write(changes);
  }
}
