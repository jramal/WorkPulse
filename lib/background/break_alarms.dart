import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../data/database.dart';
import '../domain/break_alerts.dart';

/// Each activity owns a block of notification ids, so ending a break can
/// cancel its whole series without storing anything (FR-11.6, TR-11).
int _notificationId(int activityId, int index) => activityId * 100 + index;

class BreakAlarmScheduler {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Scheduled notifications only exist on the phone platforms.
  bool get _supported => Platform.isAndroid || Platform.isIOS;

  Future<void> schedule(Activity breakActivity, BreakType type) async {
    if (!_supported) return;
    final alerts = breakAlerts(breakActivity, type);
    if (alerts.isEmpty) return;
    await _ensureInitialized();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final exact = await android?.canScheduleExactNotifications() ?? true;
    for (final (index, alert) in alerts.indexed) {
      await _plugin.zonedSchedule(
        id: _notificationId(breakActivity.id, index),
        scheduledDate: tz.TZDateTime.from(alert.time, tz.UTC),
        title: alert.title,
        body: alert.body,
        notificationDetails: _details(type),
        androidScheduleMode: exact
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancel(int activityId) async {
    if (!_supported) return;
    await _ensureInitialized();
    for (var i = 0; i < maxBreakAlerts; i++) {
      await _plugin.cancel(id: _notificationId(activityId, i));
    }
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
    _initialized = true;
  }

  // Android fixes sound and vibration per channel when it's first created, so
  // each combination of settings needs its own channel.
  NotificationDetails _details(BreakType type) {
    final quiet = type.alertStyle == AlarmAlertStyle.quiet;
    final vibrate = type.vibrationEnabled && !quiet;
    final (soundName, soundUri, usage) = switch (type.alarmSound) {
      AlarmSound.notification => (
        'Notification tone',
        'content://settings/system/notification_sound',
        AudioAttributesUsage.notification,
      ),
      AlarmSound.alarm => (
        'Alarm tone',
        'content://settings/system/alarm_alert',
        AudioAttributesUsage.alarm,
      ),
      AlarmSound.ringtone => (
        'Ringtone',
        'content://settings/system/ringtone',
        AudioAttributesUsage.notificationRingtone,
      ),
    };
    final channelId = quiet
        ? 'break_alarm_quiet'
        : 'break_alarm_${type.alarmSound.name}_${vibrate ? 'vibrate' : 'still'}';
    final channelName = quiet
        ? 'Break alarms (quiet)'
        : 'Break alarms ($soundName${vibrate ? ', vibrate' : ''})';
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'Tells you when a break has run its expected time.',
        importance: quiet ? Importance.low : Importance.high,
        priority: quiet ? Priority.low : Priority.high,
        playSound: !quiet,
        sound: quiet ? null : UriAndroidNotificationSound(soundUri),
        audioAttributesUsage: usage,
        enableVibration: vibrate,
        category: AndroidNotificationCategory.alarm,
      ),
      iOS: DarwinNotificationDetails(presentSound: !quiet),
    );
  }
}
