import 'package:drift/drift.dart';
import 'package:intl/intl.dart';

import '../data/database.dart';
import 'teams_template.dart';
import 'time_format.dart';
import 'tracking_engine.dart';

class TeamsRepository {
  TeamsRepository(this._db);

  final AppDatabase _db;

  Stream<List<TeamsTriggerConfig>> watchConfigs() {
    return _db.select(_db.teamsTriggerConfigs).watch();
  }

  Stream<List<TeamsDelivery>> watchDeliveries() {
    return (_db.select(_db.teamsDeliveries)..orderBy([
          (d) => OrderingTerm.desc(d.createdAt),
          (d) => OrderingTerm.desc(d.id),
        ]))
        .watch();
  }

  Future<void> setEnabled(bool enabled) => _writeSettings(
    AppSettingsCompanion(teamsEnabled: Value(enabled)),
  );

  Future<void> setDefaultDestination(String? url) => _writeSettings(
    AppSettingsCompanion(teamsDefaultDestination: Value(_blankToNull(url))),
  );

  Future<void> saveConfig({
    required TeamsTrigger trigger,
    int? breakTypeId,
    required bool enabled,
    required String template,
    String? destination,
  }) async {
    final existing = await _config(trigger, breakTypeId);
    final values = TeamsTriggerConfigsCompanion(
      trigger: Value(trigger),
      breakTypeId: Value(breakTypeId),
      enabled: Value(enabled),
      messageTemplate: Value(template),
      destination: Value(_blankToNull(destination)),
    );
    if (existing == null) {
      await _db.into(_db.teamsTriggerConfigs).insert(values);
    } else {
      await (_db.update(
        _db.teamsTriggerConfigs,
      )..where((c) => c.id.equals(existing.id))).write(values);
    }
  }

  /// Queues one message if [trigger] may send (FR-4.6). Runs inside the
  /// transition's transaction, so an activity change produces its message
  /// exactly once, even if the app dies right afterwards (TR-6).
  Future<void> enqueue({
    required TeamsTrigger trigger,
    required Activity activity,
    required AppSetting settings,
    required DailySummary summary,
    required DateTime now,
  }) async {
    final config = await _config(trigger, activity.breakTypeId);
    if (config == null || teamsBlockedReason(config, settings) != null) return;

    final breakName = await _breakName(activity.breakTypeId);
    final end = activity.endTime;
    final finish = summary.expectedFinish;
    final message = renderTeamsTemplate(config.messageTemplate, {
      'startTime': formatClock(activity.startTime),
      'endTime': end == null ? '' : formatClock(end),
      'duration': formatHoursMinutes(
        (end ?? now).difference(activity.startTime),
      ),
      'breakType': breakName ?? '',
      'date': DateFormat.yMMMd().format(now),
      'worked': formatHoursMinutes(summary.totalWorked),
      'break': formatHoursMinutes(summary.totalBreak),
      'target': formatHoursMinutes(summary.target),
      'remaining': formatHoursMinutes(summary.remaining),
      'overtime': formatHoursMinutes(summary.overtime),
      'expectedFinish': finish == null ? '' : formatClock(finish),
    });

    await _db
        .into(_db.teamsDeliveries)
        .insert(
          TeamsDeliveriesCompanion.insert(
            label: teamsTriggerLabel(trigger, breakName),
            activityId: Value(activity.id),
            message: message,
            destination: effectiveDestination(config, settings)!,
            status: DeliveryStatus.queued,
            nextAttemptAt: now,
            createdAt: now,
          ),
        );
  }

  Future<TeamsTriggerConfig?> _config(TeamsTrigger trigger, int? breakTypeId) {
    // Only break triggers belong to a break type; resuming after a break and
    // ending the day during one still use the single global trigger.
    final isBreakTrigger =
        trigger == TeamsTrigger.breakStart || trigger == TeamsTrigger.breakEnd;
    return (_db.select(_db.teamsTriggerConfigs)
          ..where((c) => c.trigger.equalsValue(trigger))
          ..where(
            (c) => isBreakTrigger
                ? c.breakTypeId.equalsNullable(breakTypeId)
                : c.breakTypeId.isNull(),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<String?> _breakName(int? breakTypeId) async {
    if (breakTypeId == null) return null;
    final type = await (_db.select(
      _db.breakTypes,
    )..where((t) => t.id.equals(breakTypeId))).getSingleOrNull();
    return type?.name;
  }

  Future<void> _writeSettings(AppSettingsCompanion changes) {
    return (_db.update(
      _db.appSettings,
    )..where((s) => s.id.equals(0))).write(changes);
  }

  String? _blankToNull(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }
}
