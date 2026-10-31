import 'package:flutter/material.dart';

import '../../app_services.dart';
import '../../data/database.dart';
import '../../domain/teams_template.dart';
import '../../domain/time_format.dart';
import '../../theme/app_theme.dart';
import '../widgets/setting_tile.dart';

TeamsTriggerConfig? _findConfig(
  List<TeamsTriggerConfig> configs,
  TeamsTrigger trigger,
  int? breakTypeId,
) {
  for (final config in configs) {
    if (config.trigger == trigger && config.breakTypeId == breakTypeId) {
      return config;
    }
  }
  return null;
}

/// Global switch, default destination and every trigger (FR-4.1, FR-4.2).
class TeamsSettingsScreen extends StatefulWidget {
  const TeamsSettingsScreen({super.key});

  @override
  State<TeamsSettingsScreen> createState() => _TeamsSettingsScreenState();
}

class _TeamsSettingsScreenState extends State<TeamsSettingsScreen> {
  final TextEditingController _url = TextEditingController();
  Stream<AppSetting>? _settings;
  Stream<List<BreakType>>? _types;
  bool _urlLoaded = false;
  bool _testing = false;
  String? _urlError;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final services = AppServicesScope.of(context);
    _settings ??= services.tracking.watchSettings();
    _types ??= services.breakTypes.watchActive();
  }

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  Future<void> _saveUrl() async {
    final url = _url.text.trim();
    if (url.isNotEmpty && !isValidWebhookUrl(url)) {
      setState(() => _urlError = 'Enter a full https:// webhook URL');
      return;
    }
    setState(() => _urlError = null);
    await AppServicesScope.of(context).teams.setDefaultDestination(url);
    if (!mounted) return;
    // Clears the field from focus history too, so coming back from a pushed
    // screen doesn't reopen the keyboard.
    FocusManager.instance.primaryFocus?.unfocus();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Webhook URL saved.')));
  }

  Future<void> _sendTest() async {
    final url = _url.text.trim();
    if (!isValidWebhookUrl(url)) {
      setState(() => _urlError = 'Enter a full https:// webhook URL');
      return;
    }
    // The result snackbar would otherwise sit on top of the buttons.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _urlError = null;
      _testing = true;
    });
    final error = await AppServicesScope.of(context).teamsSender.sendTest(url);
    if (!mounted) return;
    setState(() => _testing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error == null ? 'Teams accepted the test message.' : 'Failed: $error',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = AppServicesScope.of(context);
    const gap = SizedBox(height: AppSpacing.md - 4);
    return Scaffold(
      appBar: AppBar(title: const Text('Microsoft Teams')),
      body: StreamBuilder<AppSetting>(
        stream: _settings,
        builder: (context, settingsSnapshot) {
          final settings = settingsSnapshot.data;
          if (settings == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!_urlLoaded) {
            _url.text = settings.teamsDefaultDestination ?? '';
            _urlLoaded = true;
          }
          return StreamBuilder<List<BreakType>>(
            stream: _types,
            builder: (context, typesSnapshot) {
              final types = typesSnapshot.data ?? const <BreakType>[];
              return ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Card(
                    child: SwitchListTile(
                      key: const Key('teams-enabled-switch'),
                      title: const Text('Send Teams messages'),
                      subtitle: const Text(
                        'Only triggers you turn on below will send anything.',
                      ),
                      value: settings.teamsEnabled,
                      onChanged: services.teams.setEnabled,
                    ),
                  ),
                  const SectionLabel('Default destination'),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'In Teams, open a channel or chat, choose Workflows, '
                            'add "Post to a channel when a webhook request is '
                            'received", and paste its URL here. Anyone with this '
                            'URL can post there, so keep it private.',
                          ),
                          const SizedBox(height: AppSpacing.md - 4),
                          TextField(
                            key: const Key('teams-default-url'),
                            controller: _url,
                            keyboardType: TextInputType.url,
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: 'Webhook URL',
                              errorText: _urlError,
                              errorMaxLines: 2,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md - 4),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _testing ? null : _sendTest,
                                  child: Text(_testing ? 'Sending…' : 'Send test'),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md - 4),
                              Expanded(
                                child: FilledButton(
                                  key: const Key('save-teams-url-button'),
                                  onPressed: _saveUrl,
                                  child: const Text('Save'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SectionLabel('Work messages'),
                  const TeamsTriggerTile(trigger: TeamsTrigger.startWork),
                  gap,
                  const TeamsTriggerTile(trigger: TeamsTrigger.resumeWork),
                  gap,
                  const TeamsTriggerTile(trigger: TeamsTrigger.endWork),
                  const SectionLabel('Break messages'),
                  for (final type in types) ...[
                    TeamsTriggerTile(
                      trigger: TeamsTrigger.breakStart,
                      breakTypeId: type.id,
                      breakName: type.name,
                    ),
                    gap,
                    TeamsTriggerTile(
                      trigger: TeamsTrigger.breakEnd,
                      breakTypeId: type.id,
                      breakName: type.name,
                    ),
                    gap,
                  ],
                  const SectionLabel('History'),
                  SettingTile(
                    icon: Icons.receipt_long_rounded,
                    color: AppAccents.remaining,
                    title: 'Delivery log',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const TeamsDeliveryLogScreen(),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// One trigger's name and whether it will actually send (TR-7).
class TeamsTriggerTile extends StatefulWidget {
  const TeamsTriggerTile({
    super.key,
    required this.trigger,
    this.breakTypeId,
    this.breakName,
  });

  final TeamsTrigger trigger;
  final int? breakTypeId;
  final String? breakName;

  @override
  State<TeamsTriggerTile> createState() => _TeamsTriggerTileState();
}

class _TeamsTriggerTileState extends State<TeamsTriggerTile> {
  Stream<List<TeamsTriggerConfig>>? _configs;
  Stream<AppSetting>? _settings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final services = AppServicesScope.of(context);
    _configs ??= services.teams.watchConfigs();
    _settings ??= services.tracking.watchSettings();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<TeamsTriggerConfig>>(
      stream: _configs,
      builder: (context, configsSnapshot) {
        return StreamBuilder<AppSetting>(
          stream: _settings,
          builder: (context, settingsSnapshot) {
            final settings = settingsSnapshot.data;
            final config = _findConfig(
              configsSnapshot.data ?? const [],
              widget.trigger,
              widget.breakTypeId,
            );
            final String status;
            if (config == null || !config.enabled) {
              status = 'Off';
            } else if (settings == null) {
              status = '';
            } else {
              status = teamsBlockedReason(config, settings) ?? 'On';
            }
            return SettingTile(
              icon: Icons.send_rounded,
              color: status == 'On'
                  ? AppAccents.productive
                  : Theme.of(context).colorScheme.onSurfaceVariant,
              title: teamsTriggerLabel(widget.trigger, widget.breakName),
              subtitle: status,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => TeamsTriggerEditorScreen(
                    trigger: widget.trigger,
                    breakTypeId: widget.breakTypeId,
                    breakName: widget.breakName,
                    existing: config,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// Enable, message template and destination for one trigger (FR-4.2 to FR-4.4).
class TeamsTriggerEditorScreen extends StatefulWidget {
  const TeamsTriggerEditorScreen({
    super.key,
    required this.trigger,
    this.breakTypeId,
    this.breakName,
    this.existing,
  });

  final TeamsTrigger trigger;
  final int? breakTypeId;
  final String? breakName;
  final TeamsTriggerConfig? existing;

  @override
  State<TeamsTriggerEditorScreen> createState() =>
      _TeamsTriggerEditorScreenState();
}

class _TeamsTriggerEditorScreenState extends State<TeamsTriggerEditorScreen> {
  late bool _enabled = widget.existing?.enabled ?? false;
  late final TextEditingController _template = TextEditingController(
    text: widget.existing?.messageTemplate.isNotEmpty ?? false
        ? widget.existing!.messageTemplate
        : defaultTeamsTemplate(widget.trigger),
  );
  late final TextEditingController _destination = TextEditingController(
    text: widget.existing?.destination ?? '',
  );
  String? _destinationError;

  @override
  void dispose() {
    _template.dispose();
    _destination.dispose();
    super.dispose();
  }

  void _insertPlaceholder(String name) {
    final text = _template.text;
    final selection = _template.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final token = '{$name}';
    _template.value = TextEditingValue(
      text: text.replaceRange(start, end, token),
      selection: TextSelection.collapsed(offset: start + token.length),
    );
  }

  Future<void> _save() async {
    final destination = _destination.text.trim();
    if (destination.isNotEmpty && !isValidWebhookUrl(destination)) {
      setState(() => _destinationError = 'Enter a full https:// webhook URL');
      return;
    }
    await AppServicesScope.of(context).teams.saveConfig(
      trigger: widget.trigger,
      breakTypeId: widget.breakTypeId,
      enabled: _enabled,
      template: _template.text.trim(),
      destination: destination,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(teamsTriggerLabel(widget.trigger, widget.breakName)),
        actions: [
          TextButton(
            key: const Key('save-trigger-button'),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Card(
            child: SwitchListTile(
              key: const Key('trigger-enabled-switch'),
              title: const Text('Send this message'),
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
            ),
          ),
          const SectionLabel('Message'),
          TextField(
            key: const Key('trigger-template'),
            controller: _template,
            minLines: 3,
            maxLines: 8,
            decoration: const InputDecoration(alignLabelWithHint: true),
          ),
          const SizedBox(height: AppSpacing.md - 4),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              for (final entry in teamsPlaceholders.entries)
                Tooltip(
                  message: entry.value,
                  child: ActionChip(
                    label: Text('{${entry.key}}'),
                    onPressed: () => _insertPlaceholder(entry.key),
                  ),
                ),
            ],
          ),
          const SectionLabel('Destination'),
          TextField(
            key: const Key('trigger-destination'),
            controller: _destination,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Webhook URL',
              helperText: 'Leave empty to use the default destination.',
              errorText: _destinationError,
            ),
          ),
        ],
      ),
    );
  }
}

/// Past send attempts, for troubleshooting.
class TeamsDeliveryLogScreen extends StatefulWidget {
  const TeamsDeliveryLogScreen({super.key});

  @override
  State<TeamsDeliveryLogScreen> createState() => _TeamsDeliveryLogScreenState();
}

class _TeamsDeliveryLogScreenState extends State<TeamsDeliveryLogScreen> {
  Stream<List<TeamsDelivery>>? _deliveries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _deliveries ??= AppServicesScope.of(context).teams.watchDeliveries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery log')),
      body: StreamBuilder<List<TeamsDelivery>>(
        stream: _deliveries,
        builder: (context, snapshot) {
          final deliveries = snapshot.data ?? const <TeamsDelivery>[];
          if (deliveries.isEmpty) {
            return const Center(child: Text('No messages yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: deliveries.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.md - 4),
            itemBuilder: (context, index) {
              final delivery = deliveries[index];
              final (icon, color, status) = switch (delivery.status) {
                DeliveryStatus.sent => (
                  Icons.check_rounded,
                  AppAccents.productive,
                  'Sent',
                ),
                DeliveryStatus.failed => (
                  Icons.error_outline_rounded,
                  AppAccents.warning,
                  'Failed',
                ),
                DeliveryStatus.queued || DeliveryStatus.sending => (
                  Icons.schedule_rounded,
                  AppAccents.breaks,
                  'Waiting to send',
                ),
              };
              final error = delivery.lastError;
              return Card(
                child: ListTile(
                  leading: IconBadge(icon: icon, color: color),
                  title: Text(delivery.label),
                  isThreeLine: true,
                  subtitle: Text(
                    '$status · ${formatClock(delivery.createdAt)}'
                    '${error == null ? '' : ' · $error'}\n${delivery.message}',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
