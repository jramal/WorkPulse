import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/database.dart';
import '../domain/break_type_repository.dart';
import '../domain/tracking_engine.dart';
import 'break_alarms.dart';
import 'teams_delivery.dart';

/// What the UI and the notification buttons call to change state. The tracking
/// record commits first, then alarms and Teams follow; neither can undo or
/// block it (NFR-5).
class TrackingActions {
  TrackingActions({
    required this._engine,
    required this._breakTypes,
    required this._alarms,
    required this._teams,
  });

  final TrackingEngine _engine;
  final BreakTypeRepository _breakTypes;
  final BreakAlarmScheduler _alarms;
  final TeamsSender _teams;

  Future<void> startWork() => _engine.startWork().then(_afterTransition);

  Future<void> startBreak(int breakTypeId) =>
      _engine.startBreak(breakTypeId).then(_afterTransition);

  Future<void> resumeWork() => _engine.resumeWork().then(_afterTransition);

  Future<void> endWork() => _engine.endWork().then(_afterTransition);

  Future<void> _afterTransition(TrackingTransition? transition) async {
    if (transition == null) return;
    try {
      await _syncAlarms(transition.closed, transition.opened);
    } catch (error) {
      debugPrint('Break alarm update failed: $error');
    }
    unawaited(_teams.flush());
  }

  Future<void> _syncAlarms(Activity? closed, Activity? opened) async {
    if (closed?.kind == ActivityKind.breakActivity) {
      await _alarms.cancel(closed!.id);
    }
    final breakTypeId = opened?.breakTypeId;
    if (breakTypeId == null) return;
    final type = await _breakTypes.find(breakTypeId);
    if (type != null) await _alarms.schedule(opened!, type);
  }
}
