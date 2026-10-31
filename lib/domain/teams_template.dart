import '../data/database.dart';

/// Placeholders a message template can use, with what each one inserts.
const Map<String, String> teamsPlaceholders = {
  'startTime': 'When this activity started',
  'endTime': 'When this activity ended',
  'duration': 'How long this activity lasted',
  'breakType': 'Break type name',
  'date': "Today's date",
  'worked': 'Total worked today',
  'break': 'Total break today',
  'target': 'Daily target',
  'remaining': 'Remaining to target',
  'overtime': 'Overtime today',
  'expectedFinish': 'Expected finish time',
};

/// Unknown placeholders are left as typed, so a typo is visible in Teams
/// rather than silently vanishing.
String renderTeamsTemplate(String template, Map<String, String> values) {
  return template.replaceAllMapped(
    RegExp(r'\{(\w+)\}'),
    (match) => values[match[1]] ?? match[0]!,
  );
}

bool isValidWebhookUrl(String? url) {
  if (url == null) return false;
  final uri = Uri.tryParse(url.trim());
  return uri != null && uri.isScheme('https') && uri.host.isNotEmpty;
}

String? effectiveDestination(TeamsTriggerConfig config, AppSetting settings) {
  final own = config.destination?.trim();
  if (own != null && own.isNotEmpty) return own;
  return settings.teamsDefaultDestination?.trim();
}

/// The hard send rule (FR-4.6, TR-7). Null means the message may be sent;
/// otherwise it is the reason it won't be, phrased for the settings screen.
String? teamsBlockedReason(TeamsTriggerConfig config, AppSetting settings) {
  if (!settings.teamsEnabled) return 'Teams messaging is turned off';
  if (!config.enabled) return 'This trigger is turned off';
  if (config.messageTemplate.trim().isEmpty) return 'Message is empty';
  if (!isValidWebhookUrl(effectiveDestination(config, settings))) {
    return 'No valid webhook URL';
  }
  return null;
}

String teamsTriggerLabel(TeamsTrigger trigger, String? breakName) {
  return switch (trigger) {
    TeamsTrigger.startWork => 'Start work',
    TeamsTrigger.resumeWork => 'Resume work',
    TeamsTrigger.endWork => 'End work',
    TeamsTrigger.breakStart => '${breakName ?? 'Break'} started',
    TeamsTrigger.breakEnd => '${breakName ?? 'Break'} ended',
  };
}

String defaultTeamsTemplate(TeamsTrigger trigger) {
  return switch (trigger) {
    TeamsTrigger.startWork => 'Starting work at {startTime}.',
    TeamsTrigger.resumeWork => 'Back at work at {startTime}.',
    TeamsTrigger.endWork =>
      'Logging off at {endTime}. Worked {worked}, break {break}.',
    TeamsTrigger.breakStart => 'Taking a {breakType} at {startTime}.',
    TeamsTrigger.breakEnd => 'Back from {breakType} after {duration}.',
  };
}
