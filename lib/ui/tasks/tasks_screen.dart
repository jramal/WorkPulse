import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app_services.dart';
import '../../data/database.dart';
import '../../domain/task_rules.dart';
import '../../theme/app_theme.dart';
import 'task_editor_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  Stream<List<Task>>? _tasks;
  late final AppLifecycleListener _lifecycle;
  bool _backgroundLocationMissing = false;

  @override
  void initState() {
    super.initState();
    _checkBackgroundLocation();
    // The permission is granted in Android settings, outside the app.
    _lifecycle = AppLifecycleListener(onResume: _checkBackgroundLocation);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _tasks ??= AppServicesScope.of(context).tasks.watchAll();
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  Future<void> _checkBackgroundLocation() async {
    if (!Platform.isAndroid) return;
    final granted = await Permission.locationAlways.isGranted;
    if (mounted) setState(() => _backgroundLocationMissing = !granted);
  }

  Future<void> _openEditor([Task? task]) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => TaskEditorScreen(existing: task)),
    );
    await _checkBackgroundLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      floatingActionButton: FloatingActionButton(
        key: const Key('add-task-button'),
        tooltip: 'Add task',
        onPressed: _openEditor,
        child: const Icon(Icons.add_rounded),
      ),
      body: StreamBuilder<List<Task>>(
        stream: _tasks,
        builder: (context, snapshot) {
          final tasks = snapshot.data ?? const <Task>[];
          final watchesLocation = tasks.any((t) => !t.isDone && hasLocation(t));
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              96,
            ),
            children: [
              if (watchesLocation && _backgroundLocationMissing) ...[
                const _LocationWarning(),
                const SizedBox(height: AppSpacing.md - 4),
              ],
              if (tasks.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 96),
                  child: Center(child: Text('Tasks you add will appear here.')),
                ),
              for (final task in tasks) ...[
                _TaskTile(task: task, onTap: () => _openEditor(task)),
                const SizedBox(height: AppSpacing.md - 4),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _LocationWarning extends StatelessWidget {
  const _LocationWarning();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const IconBadge(
          icon: Icons.location_off_rounded,
          color: AppAccents.warning,
        ),
        title: const Text('Location alerts are off'),
        subtitle: const Text(
          'Set location access to "Allow all the time" to be alerted on arrival.',
        ),
        onTap: openAppSettings,
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.onTap});

  final Task task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quiet = theme.colorScheme.onSurfaceVariant;
    final due = task.dueAt;
    final overdue = !task.isDone && due != null && due.isBefore(DateTime.now());
    final actions = AppServicesScope.of(context).taskActions;
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.xs,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.xs,
        ),
        leading: Checkbox(
          shape: const CircleBorder(),
          value: task.isDone,
          onChanged: (done) => actions.setDone(task.id, done ?? false),
        ),
        title: Text(
          task.title,
          style: task.isDone
              ? TextStyle(color: quiet, decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: due == null && !hasLocation(task)
            ? null
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (due != null)
                    _Detail(
                      icon: Icons.schedule_rounded,
                      text: DateFormat.yMMMd().add_jm().format(due),
                      color: overdue ? AppAccents.warning : quiet,
                    ),
                  if (hasLocation(task))
                    _Detail(
                      icon: Icons.place_rounded,
                      text:
                          '${task.locationName} · '
                          '${formatRadius(task.radiusMeters!)}',
                      color: quiet,
                    ),
                ],
              ),
        onTap: onTap,
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: color),
            ),
          ),
        ],
      ),
    );
  }
}
