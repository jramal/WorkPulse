import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import '../app_services.dart';
import '../data/database.dart';
import '../domain/tracking_engine.dart';
import 'tracking_notification.dart';

const _refreshCommand = 'refresh';
const _stateChangedEvent = 'stateChanged';
const _serviceId = 256;

@pragma('vm:entry-point')
void trackingServiceEntryPoint() {
  FlutterForegroundTask.setTaskHandler(_TrackingTaskHandler());
}

/// Runs in the foreground service's own engine, which outlives the app UI.
class _TrackingTaskHandler extends TaskHandler {
  final AppServices _services = AppServices();

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) => _refresh();

  @override
  void onRepeatEvent(DateTime timestamp) => unawaited(_refresh());

  @override
  void onReceiveData(Object data) {
    if (data == _refreshCommand) unawaited(_refresh());
  }

  @override
  void onNotificationButtonPressed(String id) => unawaited(_handleButton(id));

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) =>
      _services.database.close();

  Future<void> _handleButton(String id) async {
    try {
      final actions = _services.actions;
      final breakTypeId = breakTypeIdFromButton(id);
      if (breakTypeId != null) {
        await actions.startBreak(breakTypeId);
      } else if (id == resumeButtonId) {
        await actions.resumeWork();
      } else if (id == endButtonId) {
        await actions.endWork();
      }
      FlutterForegroundTask.sendDataToMain(_stateChangedEvent);
    } catch (error) {
      debugPrint('Notification action failed: $error');
    }
    await _refresh();
  }

  Future<void> _refresh() async {
    try {
      final tracking = _services.tracking;
      final open = await tracking.watchOpenActivity().first;
      if (open == null) {
        await FlutterForegroundTask.stopService();
        return;
      }
      final now = DateTime.now();
      final activities = await tracking
          .watchActivitiesForDay(dayKeyFor(now))
          .first;
      final settings = await tracking.watchSettings().first;
      final content = describeTracking(
        open: open,
        summary: tracking.summarize(
          activities: activities,
          settings: settings,
          now: now,
        ),
      );
      final buttons = trackingButtons(
        open: open,
        activeBreakTypes: await _services.breakTypes.watchActive().first,
      );
      await FlutterForegroundTask.updateService(
        notificationTitle: content.title,
        notificationText: content.text,
        notificationButtons: [
          for (final button in buttons)
            NotificationButton(id: button.id, text: button.label),
        ],
      );
    } catch (error) {
      // The notification stays stale until the next tick; tracking is unaffected.
      debugPrint('Tracking notification refresh failed: $error');
    }
  }
}

/// Keeps the foreground service running exactly while an activity is open,
/// including when the app is reopened with a day already in progress.
class TrackingServiceController {
  TrackingServiceController(this._services);

  final AppServices _services;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  AppLifecycleListener? _lifecycle;
  Future<void> _syncQueue = Future.value();

  void start() {
    // iOS has no equivalent long-running service; see CRS AQ-8.
    if (!Platform.isAndroid) return;
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'work_tracking',
        channelName: 'Work tracking',
        channelDescription: 'Shows your current activity and finish time.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(60000),
        autoRunOnBoot: true,
        // Times come from stored timestamps, so holding the CPU awake all day
        // would only spend battery on keeping the text fresh during deep sleep.
        allowWakeLock: false,
      ),
    );
    FlutterForegroundTask.addTaskDataCallback(_onTaskData);
    final tracking = _services.tracking;
    _subscriptions
      ..add(tracking.watchOpenActivity().listen(_enqueueSync))
      ..add(tracking.watchSettings().listen((_) => _requestRefresh()))
      ..add(
        _services.breakTypes.watchActive().listen((_) => _requestRefresh()),
      );
    // Android refuses to start a foreground service while the app is behind
    // the lock screen or in the background, so each return to the foreground
    // has to try again; nothing else would until the activity next changes.
    _lifecycle = AppLifecycleListener(onResume: () => unawaited(_resync()));
  }

  void dispose() {
    _lifecycle?.dispose();
    FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
  }

  Future<void> _resync() async {
    _enqueueSync(await _services.tracking.watchOpenActivity().first);
  }

  // One at a time, so a resume landing mid-start can't request a second start.
  void _enqueueSync(Activity? open) {
    _syncQueue = _syncQueue.then((_) => _sync(open));
  }

  void _requestRefresh() {
    FlutterForegroundTask.sendDataToTask(_refreshCommand);
  }

  // A notification button changed the database through the service's own
  // connection, which this engine's query streams can't see by themselves.
  void _onTaskData(Object data) {
    if (data != _stateChangedEvent) return;
    final db = _services.database;
    db.markTablesUpdated({db.activities});
  }

  Future<void> _sync(Activity? open) async {
    try {
      final running = await FlutterForegroundTask.isRunningService;
      if (open == null) {
        if (running) await FlutterForegroundTask.stopService();
      } else if (running) {
        _requestRefresh();
      } else {
        await _ensureNotificationPermission();
        final result = await FlutterForegroundTask.startService(
          serviceId: _serviceId,
          serviceTypes: const [ForegroundServiceTypes.specialUse],
          notificationTitle: 'WorkPulse',
          notificationText: 'Tracking your work day',
          callback: trackingServiceEntryPoint,
        );
        if (result is ServiceRequestFailure) {
          debugPrint('Tracking service failed to start: ${result.error}');
        }
      }
    } catch (error) {
      // Tracking itself is already saved; only the notification is affected.
      debugPrint('Tracking service sync failed: $error');
    }
  }

  Future<void> _ensureNotificationPermission() async {
    final permission =
        await FlutterForegroundTask.checkNotificationPermission();
    if (permission != NotificationPermission.granted) {
      await FlutterForegroundTask.requestNotificationPermission();
    }
  }
}
