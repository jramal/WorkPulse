import 'package:intl/intl.dart';

/// "5:15 PM".
String formatClock(DateTime time) => DateFormat.jm().format(time);

/// "8h 15m", "8h" or "15m".
String formatHoursMinutes(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  if (hours == 0) return '${minutes}m';
  if (minutes == 0) return '${hours}h';
  return '${hours}h ${minutes}m';
}

/// For a single activity, where whole minutes would misstate a short one:
/// "1h 5m", "1m 56s" or "5s".
String formatElapsed(Duration duration) {
  if (duration.inHours > 0) return formatHoursMinutes(duration);
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds.remainder(60);
  return minutes == 0 ? '${seconds}s' : '${minutes}m ${seconds}s';
}
