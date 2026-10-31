import '../data/database.dart';
import '../domain/time_format.dart';
import '../domain/tracking_engine.dart';

const resumeButtonId = 'resume';
const endButtonId = 'end';
const _breakButtonPrefix = 'break:';

// Android shows at most three notification buttons, and End always takes one.
const _maxBreakButtons = 2;

/// The status-bar text for the current activity (CRS FR-12.2/FR-12.3).
({String title, String text}) describeTracking({
  required Activity open,
  required DailySummary summary,
}) {
  final state = open.kind == ActivityKind.work ? 'Working' : 'On break';
  final finish = summary.expectedFinish;
  final String title;
  if (finish == null) {
    title = state;
  } else if (summary.overtime > Duration.zero) {
    title = '$state · target reached at ${formatClock(finish)}';
  } else {
    title = '$state · finish by ${formatClock(finish)}';
  }
  final worked = formatHoursMinutes(summary.totalWorked);
  final breaks = formatHoursMinutes(summary.totalBreak);
  return (title: title, text: 'Worked $worked · Break $breaks');
}

/// Quick actions for the current state (FR-12.4), as (id, label) pairs. Other
/// break types are one tap away: tapping the notification opens the app.
List<({String id, String label})> trackingButtons({
  required Activity open,
  required List<BreakType> activeBreakTypes,
}) {
  return [
    if (open.kind == ActivityKind.work)
      for (final type in activeBreakTypes.take(_maxBreakButtons))
        (id: '$_breakButtonPrefix${type.id}', label: type.name)
    else
      (id: resumeButtonId, label: 'Resume'),
    (id: endButtonId, label: 'End work'),
  ];
}

int? breakTypeIdFromButton(String buttonId) {
  if (!buttonId.startsWith(_breakButtonPrefix)) return null;
  return int.tryParse(buttonId.substring(_breakButtonPrefix.length));
}
