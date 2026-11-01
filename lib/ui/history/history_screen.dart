import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../app_services.dart';
import '../../data/database.dart';
import '../../domain/time_format.dart';
import '../../domain/tracking_engine.dart';
import '../../theme/app_theme.dart';

/// Scores a day against the target in force at the time, not today's (FR-3.3).
DailySummary _summarizeDay(
  TrackingEngine tracking,
  List<Activity> activities,
  AppSetting settings,
) {
  final recorded = activities.isEmpty ? null : activities.first.targetMinutes;
  return tracking.summarize(
    activities: activities,
    settings: settings.copyWith(
      dailyTargetMinutes: recorded ?? settings.dailyTargetMinutes,
    ),
    now: DateTime.now(),
  );
}

DateTime _parseDay(String dayKey) => DateTime.parse(dayKey);

/// Past days, newest first (FR-3.1, FR-3.4).
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Stream<List<Activity>>? _activities;
  Stream<AppSetting>? _settings;
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    // Today's row counts time in progress, so it needs to keep moving.
    _ticker = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() {}),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tracking = AppServicesScope.of(context).tracking;
    _activities ??= tracking.watchAllActivities();
    _settings ??= tracking.watchSettings();
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  Future<void> _pickDay(List<String> recordedDays) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: recordedDays.isEmpty ? now : _parseDay(recordedDays.last),
      lastDate: now,
    );
    if (picked != null && mounted) _openDay(dayKeyFor(picked));
  }

  void _openDay(String dayKey) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => DayDetailScreen(dayKey: dayKey)),
    );
  }

  Future<void> _deleteDay(
    String dayKey,
    List<Activity> activities,
    DailySummary summary,
  ) async {
    final tracking = AppServicesScope.of(context).tracking;
    final messenger = ScaffoldMessenger.of(context);
    const stillTracking = SnackBar(
      content: Text('End work before deleting this day.'),
    );
    if (activities.any((a) => a.endTime == null)) {
      messenger.showSnackBar(stillTracking);
      return;
    }
    final title = _dayTitle(dayKey);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this day?'),
        content: Text(
          '$title: worked ${formatHoursMinutes(summary.totalWorked)}, '
          'break ${formatHoursMinutes(summary.totalBreak)}. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('confirm-delete-day'),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final deleted = await tracking.deleteDay(dayKey);
    messenger.showSnackBar(
      deleted ? SnackBar(content: Text('$title deleted.')) : stillTracking,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tracking = AppServicesScope.of(context).tracking;
    return StreamBuilder<List<Activity>>(
      stream: _activities,
      builder: (context, activitiesSnapshot) {
        return StreamBuilder<AppSetting>(
          stream: _settings,
          builder: (context, settingsSnapshot) {
            final settings = settingsSnapshot.data;
            final days = <String, List<Activity>>{};
            for (final activity
                in activitiesSnapshot.data ?? const <Activity>[]) {
              (days[activity.dayKey] ??= []).add(activity);
            }
            final keys = days.keys.toList();
            return Scaffold(
              appBar: AppBar(
                title: const Text('History'),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: IconButton.filledTonal(
                      tooltip: 'Go to a date',
                      icon: const Icon(Icons.calendar_month_rounded),
                      onPressed: () => _pickDay(keys),
                    ),
                  ),
                ],
              ),
              body: settings == null
                  ? const Center(child: CircularProgressIndicator())
                  : keys.isEmpty
                  ? const _EmptyState(
                      icon: Icons.history_rounded,
                      message: 'Days you track will appear here.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      itemCount: keys.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.md - 4),
                      itemBuilder: (context, index) {
                        final key = keys[index];
                        final summary = _summarizeDay(
                          tracking,
                          days[key]!,
                          settings,
                        );
                        return _DayTile(
                          dayKey: key,
                          summary: summary,
                          onTap: () => _openDay(key),
                          onDelete: () => _deleteDay(key, days[key]!, summary),
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }
}

String _dayTitle(String dayKey) {
  final day = _parseDay(dayKey);
  final now = DateTime.now();
  if (dayKey == dayKeyFor(now)) return 'Today';
  if (dayKey == dayKeyFor(DateTime(now.year, now.month, now.day - 1))) {
    return 'Yesterday';
  }
  return DateFormat.yMMMEd().format(day);
}

class _DayTile extends StatelessWidget {
  const _DayTile({
    required this.dayKey,
    required this.summary,
    required this.onTap,
    required this.onDelete,
  });

  final String dayKey;
  final DailySummary summary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quiet = theme.colorScheme.onSurfaceVariant;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _dayTitle(dayKey),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _TargetBadge(summary: summary),
                  IconButton(
                    key: Key('delete-day-$dayKey'),
                    tooltip: 'Delete this day',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Worked ${formatHoursMinutes(summary.totalWorked)} · '
                'Break ${formatHoursMinutes(summary.totalBreak)}',
                style: theme.textTheme.bodyMedium?.copyWith(color: quiet),
              ),
              const SizedBox(height: AppSpacing.md - 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: summary.progress,
                  minHeight: 6,
                  color:
                      summary.overtime > Duration.zero ||
                          summary.remaining == Duration.zero
                      ? AppAccents.productive
                      : AppAccents.worked,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TargetBadge extends StatelessWidget {
  const _TargetBadge({required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final met = summary.remaining == Duration.zero;
    final color = met ? AppAccents.productive : AppAccents.breaks;
    final label = summary.overtime > Duration.zero
        ? '+${formatHoursMinutes(summary.overtime)}'
        : met
        ? 'Target met'
        : '${formatHoursMinutes(summary.remaining)} short';
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm + 2,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium
            ?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final quiet = Theme.of(context).colorScheme.onSurfaceVariant;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: quiet),
            const SizedBox(height: AppSpacing.md),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

/// One day's summary and activity log, read-only (FR-3.2, FR-3.3, FR-3.5).
class DayDetailScreen extends StatefulWidget {
  const DayDetailScreen({super.key, required this.dayKey});

  final String dayKey;

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  Stream<List<Activity>>? _activities;
  Stream<AppSetting>? _settings;
  Stream<List<BreakType>>? _breakTypes;
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();
    // An activity in progress keeps counting while this screen is open.
    _ticker = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final services = AppServicesScope.of(context);
    _activities ??= services.tracking.watchActivitiesForDay(widget.dayKey);
    _settings ??= services.tracking.watchSettings();
    _breakTypes ??= services.breakTypes.watchAll();
  }

  @override
  Widget build(BuildContext context) {
    final tracking = AppServicesScope.of(context).tracking;
    return Scaffold(
      appBar: AppBar(title: Text(_dayTitle(widget.dayKey))),
      body: StreamBuilder<List<Activity>>(
        stream: _activities,
        builder: (context, activitiesSnapshot) {
          return StreamBuilder<AppSetting>(
            stream: _settings,
            builder: (context, settingsSnapshot) {
              return StreamBuilder<List<BreakType>>(
                stream: _breakTypes,
                builder: (context, typesSnapshot) {
                  final settings = settingsSnapshot.data;
                  final activities = activitiesSnapshot.data;
                  if (settings == null || activities == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (activities.isEmpty) {
                    return const _EmptyState(
                      icon: Icons.event_busy_rounded,
                      message: 'Nothing was tracked on this day.',
                    );
                  }
                  return _DayBody(
                    activities: activities,
                    summary: _summarizeDay(tracking, activities, settings),
                    breakNames: {
                      for (final type
                          in typesSnapshot.data ?? const <BreakType>[])
                        type.id: type.name,
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _DayBody extends StatelessWidget {
  const _DayBody({
    required this.activities,
    required this.summary,
    required this.breakNames,
  });

  final List<Activity> activities;
  final DailySummary summary;
  final Map<int, String> breakNames;

  String _label(Activity activity) => activity.kind == ActivityKind.work
      ? 'Work'
      : breakNames[activity.breakTypeId] ?? 'Break';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    final byType = <String, Duration>{};
    for (final activity in activities) {
      if (activity.kind != ActivityKind.breakActivity) continue;
      final name = _label(activity);
      byType[name] =
          (byType[name] ?? Duration.zero) +
          (activity.endTime ?? now).difference(activity.startTime);
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                _Row('Worked', formatHoursMinutes(summary.totalWorked)),
                _Row('Break', formatHoursMinutes(summary.totalBreak)),
                for (final entry in byType.entries)
                  _Row(
                    '   ${entry.key}',
                    formatHoursMinutes(entry.value),
                    quiet: true,
                  ),
                _Row('Target', formatHoursMinutes(summary.target)),
                if (summary.overtime > Duration.zero)
                  _Row('Overtime', formatHoursMinutes(summary.overtime))
                else
                  _Row('Remaining', formatHoursMinutes(summary.remaining)),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.xs,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            'Activity',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              for (final activity in activities)
                ListTile(
                  leading: IconBadge(
                    icon: activity.kind == ActivityKind.work
                        ? Icons.work_rounded
                        : Icons.coffee_rounded,
                    color: activity.kind == ActivityKind.work
                        ? AppAccents.worked
                        : AppAccents.breaks,
                  ),
                  title: Text(_label(activity)),
                  subtitle: Text(
                    '${formatClock(activity.startTime)} – '
                    '${activity.endTime == null ? 'now' : formatClock(activity.endTime!)}',
                  ),
                  trailing: Text(
                    formatElapsed(
                      (activity.endTime ?? now).difference(activity.startTime),
                    ),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.quiet = false});

  final String label;
  final String value;
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = quiet ? theme.colorScheme.onSurfaceVariant : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: quiet ? FontWeight.w400 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
