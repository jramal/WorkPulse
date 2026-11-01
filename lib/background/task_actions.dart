import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import '../domain/task_repository.dart';
import '../domain/task_rules.dart';

enum GeofenceStatus { active, noPermission, unavailable }

/// Kept clear of the ids used by break alarms and location alerts.
int _dateAlertId(int taskId) => 1000000000 + taskId;

/// What the UI calls to change tasks. The task is saved first; a failure to
/// set up its alerts can't lose it, and is reported back instead.
class TaskActions {
  TaskActions(this._tasks);

  static const _channel = MethodChannel('workpulse/geofences');

  final TaskRepository _tasks;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _supported => Platform.isAndroid;

  Future<GeofenceStatus> save(int? id, TasksCompanion values) async {
    final savedId = id ?? await _tasks.add(values);
    if (id != null) await _tasks.update(id, values);
    await _syncDateAlert(await _tasks.find(savedId));
    return syncGeofences();
  }

  Future<GeofenceStatus> setDone(int id, bool done) async {
    await _tasks.update(id, TasksCompanion(isDone: Value(done)));
    await _syncDateAlert(await _tasks.find(id));
    return syncGeofences();
  }

  Future<void> delete(int id) async {
    await _tasks.delete(id);
    try {
      await _cancelDateAlert(id);
    } catch (error) {
      debugPrint('Task date alert cancel failed: $error');
    }
    await syncGeofences();
  }

  /// Sends Android the current list, which it ignores if nothing has changed.
  /// Also runs each time the app opens, which picks up a permission just
  /// granted and recovers geofences Android dropped.
  Future<GeofenceStatus> syncGeofences() async {
    if (!_supported) return GeofenceStatus.active;
    try {
      final result = await _channel.invokeMethod<String>(
        'sync',
        geofencesJson(await _tasks.getAll()),
      );
      return switch (result) {
        'ok' => GeofenceStatus.active,
        'noPermission' => GeofenceStatus.noPermission,
        _ => GeofenceStatus.unavailable,
      };
    } catch (error) {
      debugPrint('Geofence sync failed: $error');
      return GeofenceStatus.unavailable;
    }
  }

  Future<void> _syncDateAlert(Task task) async {
    if (!_supported) return;
    try {
      await _cancelDateAlert(task.id);
      if (!needsDateAlert(task, DateTime.now())) return;
      await _ensureInitialized();
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final exact = await android?.canScheduleExactNotifications() ?? true;
      final notes = task.notes;
      await _plugin.zonedSchedule(
        id: _dateAlertId(task.id),
        scheduledDate: tz.TZDateTime.from(task.dueAt!, tz.UTC),
        title: task.title,
        body: notes == null || notes.isEmpty ? 'This task is due now.' : notes,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_due',
            'Task due dates',
            channelDescription: 'Alerts when a task reaches its date and time.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (error) {
      debugPrint('Task date alert failed: $error');
    }
  }

  Future<void> _cancelDateAlert(int taskId) async {
    if (!_supported) return;
    await _ensureInitialized();
    await _plugin.cancel(id: _dateAlertId(taskId));
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    _initialized = true;
  }
}
