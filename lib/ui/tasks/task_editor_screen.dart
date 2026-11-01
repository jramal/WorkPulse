import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app_services.dart';
import '../../background/task_actions.dart';
import '../../data/database.dart';
import '../../domain/task_rules.dart';
import '../../theme/app_theme.dart';
import '../widgets/setting_tile.dart';
import 'location_picker_screen.dart';

class TaskEditorScreen extends StatefulWidget {
  const TaskEditorScreen({super.key, this.existing});

  final Task? existing;

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  late final TextEditingController _title = TextEditingController(
    text: widget.existing?.title ?? '',
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.existing?.notes ?? '',
  );
  late DateTime? _dueAt = widget.existing?.dueAt;
  late PickedLocation? _location = _initialLocation();
  String? _titleError;
  bool _saving = false;

  PickedLocation? _initialLocation() {
    final task = widget.existing;
    if (task == null || !hasLocation(task)) return null;
    return PickedLocation(
      name: task.locationName ?? '',
      latitude: task.latitude!,
      longitude: task.longitude!,
      radiusMeters: task.radiusMeters!,
    );
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final now = DateTime.now();
    final initial = _dueAt ?? now.add(const Duration(hours: 1));
    final date = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(now) ? now : initial,
      firstDate: now,
      lastDate: now.add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) return;
    final picked = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    if (picked.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Choose a future time.')));
      return;
    }
    setState(() => _dueAt = picked);
  }

  Future<void> _pickLocation() async {
    // Otherwise the keyboard reopens on the title when this screen returns.
    FocusManager.instance.primaryFocus?.unfocus();
    final picked = await Navigator.of(context).push<PickedLocation>(
      MaterialPageRoute(
        builder: (_) => LocationPickerScreen(initial: _location),
      ),
    );
    if (picked != null) setState(() => _location = picked);
  }

  /// Android 11+ only grants "all the time" from its settings page, and only
  /// after "while in use", so the user needs to know why they're being sent.
  Future<void> _requestAlertPermissions() async {
    if (!Platform.isAndroid) return;
    if (_dueAt != null || _location != null) {
      await Permission.notification.request();
    }
    if (_location == null || !mounted) return;
    if (await Permission.locationAlways.isGranted) return;
    if (!await Permission.locationWhenInUse.request().isGranted || !mounted) {
      return;
    }
    final proceed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Allow location all the time'),
        content: const Text(
          'To alert you on arrival while the app is closed, WorkPulse needs '
          'location access "All the time". It is only used to check your task '
          'areas. On the next screen, choose "Allow all the time".',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (proceed == true) await Permission.locationAlways.request();
  }

  /// Permission prompts make saving slow, and a second tap must not add the
  /// task twice.
  Future<void> _save() async {
    if (_saving) return;
    _saving = true;
    try {
      await _saveTask();
    } finally {
      _saving = false;
    }
  }

  Future<void> _saveTask() async {
    final title = _title.text.trim();
    if (title.isEmpty) {
      setState(() => _titleError = 'Enter a title');
      return;
    }
    final notes = _notes.text.trim();
    final location = _location;
    final actions = AppServicesScope.of(context).taskActions;
    final messenger = ScaffoldMessenger.of(context);
    await _requestAlertPermissions();
    final status = await actions.save(
      widget.existing?.id,
      TasksCompanion(
        title: Value(title),
        notes: Value(notes.isEmpty ? null : notes),
        dueAt: Value(_dueAt),
        locationName: Value(location?.name),
        latitude: Value(location?.latitude),
        longitude: Value(location?.longitude),
        radiusMeters: Value(location?.radiusMeters),
      ),
    );
    if (location != null && status == GeofenceStatus.unavailable) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Location alerts could not start. Check that Location is on.',
          ),
        ),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final task = widget.existing!;
    final actions = AppServicesScope.of(context).taskActions;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete ${task.title}?'),
        content: const Text('This also removes its alerts.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('confirm-delete-task'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await actions.delete(task.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final due = _dueAt;
    final location = _location;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New task' : 'Edit task'),
        actions: [
          if (widget.existing != null)
            IconButton(
              tooltip: 'Delete task',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _delete,
            ),
          TextButton(
            key: const Key('save-task-button'),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          TextField(
            key: const Key('task-title'),
            controller: _title,
            maxLength: 120,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              labelText: 'Title',
              errorText: _titleError,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _notes,
            minLines: 2,
            maxLines: 5,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Notes',
              alignLabelWithHint: true,
            ),
          ),
          const SectionLabel('Alerts'),
          _AlertRow(
            key: const Key('task-date-row'),
            icon: Icons.schedule_rounded,
            color: AppAccents.worked,
            title: 'Date and time',
            value: due == null
                ? 'Not set'
                : DateFormat.yMMMd().add_jm().format(due),
            onTap: _pickDateTime,
            onClear: due == null ? null : () => setState(() => _dueAt = null),
          ),
          const SizedBox(height: AppSpacing.md - 4),
          _AlertRow(
            key: const Key('task-location-row'),
            icon: Icons.place_rounded,
            color: AppAccents.breaks,
            title: 'Location',
            value: location == null
                ? 'Not set'
                : '${location.name} · within '
                      '${formatRadius(location.radiusMeters)}',
            onTap: _pickLocation,
            onClear: location == null
                ? null
                : () => setState(() => _location = null),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Each alert works on its own. Arrival alerts can be delayed, '
            'sometimes by several minutes, and fire again each time you arrive '
            'until the task is done.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  const _AlertRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.onTap,
    this.onClear,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: IconBadge(icon: icon, color: color),
        title: Text(title),
        subtitle: Text(value),
        trailing: onClear == null
            ? const Icon(Icons.chevron_right_rounded)
            : IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.close_rounded),
                onPressed: onClear,
              ),
        onTap: onTap,
      ),
    );
  }
}
