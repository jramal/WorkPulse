import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../app_services.dart';
import '../../data/database.dart';
import '../../domain/break_alerts.dart';
import '../../domain/time_format.dart';
import '../../theme/app_theme.dart';
import '../widgets/duration_picker.dart';
import '../widgets/setting_tile.dart';

/// Add, edit and delete break types (FR-1.6/FR-1.7).
class BreakTypesScreen extends StatefulWidget {
  const BreakTypesScreen({super.key});

  @override
  State<BreakTypesScreen> createState() => _BreakTypesScreenState();
}

class _BreakTypesScreenState extends State<BreakTypesScreen> {
  Stream<List<BreakType>>? _types;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _types ??= AppServicesScope.of(context).breakTypes.watchAll();
  }

  void _openEditor([BreakType? type]) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BreakTypeEditorScreen(existing: type),
      ),
    );
  }

  Future<void> _confirmDelete(BreakType type) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${type.name}?'),
        content: const Text(
          'If it was used on past days it stays in your history, but you '
          "won't be able to pick it any more.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('confirm-delete-button'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await AppServicesScope.of(context).breakTypes.delete(type.id);
  }

  @override
  Widget build(BuildContext context) {
    final repository = AppServicesScope.of(context).breakTypes;
    return Scaffold(
      appBar: AppBar(title: const Text('Break types')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add break type',
        onPressed: _openEditor,
        child: const Icon(Icons.add_rounded),
      ),
      body: StreamBuilder<List<BreakType>>(
        stream: _types,
        builder: (context, snapshot) {
          final types = snapshot.data ?? const [];
          if (types.isEmpty) {
            return const Center(child: Text('No break types yet.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: types.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.md - 4),
            itemBuilder: (context, index) {
              final type = types[index];
              return Card(
                child: ListTile(
                  leading: IconBadge(
                    icon: Icons.coffee_rounded,
                    color: type.isActive
                        ? AppAccents.breaks
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  title: Text(type.name),
                  subtitle: Text(_subtitle(type)),
                  onTap: () => _openEditor(type),
                  trailing: type.isActive
                      ? IconButton(
                          tooltip: 'Delete',
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () => _confirmDelete(type),
                        )
                      : IconButton(
                          tooltip: 'Restore',
                          icon: const Icon(Icons.unarchive_outlined),
                          onPressed: () => repository.restore(type.id),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _subtitle(BreakType type) {
    if (!type.isActive) return 'Deleted, kept for history';
    if (!type.alarmEnabled) return 'No alarm';
    final minutes = Duration(minutes: type.expectedDurationMinutes);
    final during = parseMidBreakAlarms(type.midBreakAlarmMinutes)
        .where((minute) => minute < type.expectedDurationMinutes)
        .length;
    final end = 'Alarm after ${formatHoursMinutes(minutes)}';
    return during == 0 ? end : '$end, $during during the break';
  }
}

/// Name and alarm settings (FR-11.1) for one break type.
class BreakTypeEditorScreen extends StatefulWidget {
  const BreakTypeEditorScreen({super.key, this.existing});

  final BreakType? existing;

  @override
  State<BreakTypeEditorScreen> createState() => _BreakTypeEditorScreenState();
}

class _BreakTypeEditorScreenState extends State<BreakTypeEditorScreen> {
  static const _intervals = [1, 2, 5, 10, 15, 30];

  late final TextEditingController _name = TextEditingController(
    text: widget.existing?.name ?? '',
  );
  late bool _alarmEnabled = widget.existing?.alarmEnabled ?? false;
  late int _expectedMinutes = widget.existing?.expectedDurationMinutes ?? 15;
  late AlarmSound _sound =
      widget.existing?.alarmSound ?? AlarmSound.notification;
  late bool _vibrate = widget.existing?.vibrationEnabled ?? true;
  late AlarmAlertStyle _style =
      widget.existing?.alertStyle ?? AlarmAlertStyle.headsUp;
  late ReminderBehaviour _reminder =
      widget.existing?.reminderBehaviour ?? ReminderBehaviour.once;
  late int _interval = widget.existing?.repeatIntervalMinutes ?? 5;
  late List<int> _midBreakAlarms = parseMidBreakAlarms(
    widget.existing?.midBreakAlarmMinutes ?? '',
  );
  String? _nameError;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final repository = AppServicesScope.of(context).breakTypes;
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Enter a name');
      return;
    }
    final id = widget.existing?.id;
    if (await repository.isNameTaken(name, exceptId: id)) {
      setState(() => _nameError = 'A break type with this name already exists');
      return;
    }
    final values = BreakTypesCompanion(
      name: Value(name),
      alarmEnabled: Value(_alarmEnabled),
      expectedDurationMinutes: Value(_expectedMinutes),
      alarmSound: Value(_sound),
      vibrationEnabled: Value(_vibrate),
      alertStyle: Value(_style),
      reminderBehaviour: Value(_reminder),
      repeatIntervalMinutes: Value(_interval),
      midBreakAlarmMinutes: Value(encodeMidBreakAlarms(_midBreakAlarms)),
    );
    if (id != null) {
      await repository.update(id, values);
    } else {
      await repository.add(values);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? 'New break type' : 'Edit break type',
        ),
        actions: [
          TextButton(
            key: const Key('save-break-type-button'),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextField(
            key: const Key('break-type-name'),
            controller: _name,
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Name',
              errorText: _nameError,
            ),
          ),
          const SectionLabel('Alarm'),
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  key: const Key('alarm-enabled-switch'),
                  title: const Text('Alarm when break time is up'),
                  value: _alarmEnabled,
                  onChanged: (value) => setState(() => _alarmEnabled = value),
                ),
                if (_alarmEnabled) ..._alarmOptions(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addMidBreakAlarm() async {
    final picked = await showDurationPicker(
      context,
      title: 'Alarm after the break starts',
      initial: const Duration(minutes: 5),
      allowZero: false,
    );
    if (picked == null || !mounted) return;
    if (picked.inMinutes >= _expectedMinutes) {
      final length = formatHoursMinutes(Duration(minutes: _expectedMinutes));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Choose a time within the $length break.')),
      );
      return;
    }
    setState(() {
      _midBreakAlarms = parseMidBreakAlarms(
        encodeMidBreakAlarms([..._midBreakAlarms, picked.inMinutes]),
      );
    });
  }

  List<Widget> _alarmOptions() {
    return [
      ListTile(
        title: const Text('Expected break duration'),
        trailing: Text(
          formatHoursMinutes(Duration(minutes: _expectedMinutes)),
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        onTap: () async {
          final picked = await showDurationPicker(
            context,
            title: 'Expected break duration',
            initial: Duration(minutes: _expectedMinutes),
            allowZero: false,
          );
          if (picked != null) {
            setState(() {
              _expectedMinutes = picked.inMinutes;
              // Alarms past the new length could never ring.
              _midBreakAlarms = _midBreakAlarms
                  .where((minute) => minute < _expectedMinutes)
                  .toList();
            });
          }
        },
      ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alarms during the break'),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Rings this long after the break starts.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              children: [
                for (final minute in _midBreakAlarms)
                  InputChip(
                    label: Text(formatHoursMinutes(Duration(minutes: minute))),
                    onDeleted: () =>
                        setState(() => _midBreakAlarms.remove(minute)),
                  ),
                if (_midBreakAlarms.length < maxMidBreakAlarms)
                  ActionChip(
                    key: const Key('add-mid-break-alarm'),
                    avatar: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Add alarm'),
                    onPressed: _addMidBreakAlarm,
                  ),
              ],
            ),
          ],
        ),
      ),
      _OptionRow(
        label: 'Notification',
        child: SegmentedButton<AlarmAlertStyle>(
          segments: const [
            ButtonSegment(
              value: AlarmAlertStyle.headsUp,
              label: Text('Pop up'),
            ),
            ButtonSegment(value: AlarmAlertStyle.quiet, label: Text('Quiet')),
          ],
          selected: {_style},
          onSelectionChanged: (value) => setState(() => _style = value.single),
        ),
      ),
      if (_style == AlarmAlertStyle.headsUp) ...[
        _OptionRow(
          label: 'Sound',
          child: DropdownButton<AlarmSound>(
            value: _sound,
            underline: const SizedBox.shrink(),
            items: const [
              DropdownMenuItem(
                value: AlarmSound.notification,
                child: Text('Notification tone'),
              ),
              DropdownMenuItem(
                value: AlarmSound.alarm,
                child: Text('Alarm tone'),
              ),
              DropdownMenuItem(
                value: AlarmSound.ringtone,
                child: Text('Ringtone'),
              ),
            ],
            onChanged: (value) => setState(() => _sound = value!),
          ),
        ),
        SwitchListTile(
          title: const Text('Vibrate'),
          value: _vibrate,
          onChanged: (value) => setState(() => _vibrate = value),
        ),
      ],
      _OptionRow(
        label: 'Reminder',
        child: SegmentedButton<ReminderBehaviour>(
          segments: const [
            ButtonSegment(value: ReminderBehaviour.once, label: Text('Once')),
            ButtonSegment(
              value: ReminderBehaviour.repeat,
              label: Text('Repeat'),
            ),
          ],
          selected: {_reminder},
          onSelectionChanged: (value) =>
              setState(() => _reminder = value.single),
        ),
      ),
      if (_reminder == ReminderBehaviour.repeat)
        _OptionRow(
          label: 'Repeat every',
          child: DropdownButton<int>(
            value: _intervals.contains(_interval) ? _interval : 5,
            underline: const SizedBox.shrink(),
            items: [
              for (final minutes in _intervals)
                DropdownMenuItem(value: minutes, child: Text('$minutes min')),
            ],
            onChanged: (value) => setState(() => _interval = value!),
          ),
        ),
    ];
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}
