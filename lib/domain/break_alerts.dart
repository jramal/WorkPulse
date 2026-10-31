import '../data/database.dart';
import 'time_format.dart';

const maxMidBreakAlarms = 10;
const _maxRepeats = 12;

/// The most alerts one break can schedule, which is also how many
/// notification ids a break's cancellation has to cover.
const maxBreakAlerts = maxMidBreakAlarms + 1 + _maxRepeats;

class BreakAlert {
  const BreakAlert({
    required this.time,
    required this.title,
    required this.body,
  });

  final DateTime time;
  final String title;
  final String body;
}

/// Minutes after a break starts, stored on the break type as "5,10,15".
List<int> parseMidBreakAlarms(String stored) {
  final minutes = stored
      .split(',')
      .map((part) => int.tryParse(part.trim()))
      .whereType<int>()
      .where((minute) => minute > 0)
      .toSet()
      .toList();
  return minutes..sort();
}

String encodeMidBreakAlarms(Iterable<int> minutes) => minutes.join(',');

/// Every alert a break should raise, in order (FR-11.3, FR-11.5). Alarms set
/// at or past the expected duration are skipped: the duration may have been
/// shortened after they were added, and the end alarm already covers that time.
List<BreakAlert> breakAlerts(Activity breakActivity, BreakType type) {
  if (!type.alarmEnabled) return const [];
  final start = breakActivity.startTime;
  final expected = Duration(minutes: type.expectedDurationMinutes);
  final total = formatHoursMinutes(expected);

  final alerts = <BreakAlert>[
    for (final minute
        in parseMidBreakAlarms(type.midBreakAlarmMinutes)
            .where((minute) => minute < type.expectedDurationMinutes)
            .take(maxMidBreakAlarms))
      BreakAlert(
        time: start.add(Duration(minutes: minute)),
        title:
            '${formatHoursMinutes(Duration(minutes: minute))} into ${type.name}',
        body:
            '${formatHoursMinutes(expected - Duration(minutes: minute))} left '
            'of your $total break.',
      ),
  ];

  final end = start.add(expected);
  final repeats = type.reminderBehaviour == ReminderBehaviour.repeat
      ? _maxRepeats
      : 0;
  for (var i = 0; i <= repeats; i++) {
    alerts.add(
      BreakAlert(
        time: end.add(Duration(minutes: type.repeatIntervalMinutes * i)),
        title: '${type.name} is over',
        body: 'Your $total break is up. Tap to get back to work.',
      ),
    );
  }
  return alerts;
}
