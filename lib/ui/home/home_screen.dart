import 'dart:async';

import 'package:flutter/material.dart';

import '../../app_services.dart';
import '../../data/database.dart';
import '../../domain/time_format.dart';
import '../../domain/tracking_engine.dart';
import '../../theme/app_theme.dart';
import 'break_picker_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Timer _ticker;
  DateTime _now = DateTime.now();

  // Held across rebuilds: a new stream instance on each tick would make every
  // StreamBuilder resubscribe, and re-query the database, once a second.
  AppServices? _services;
  late Stream<Activity?> _open;
  late Stream<AppSetting> _settings;
  late Stream<List<Activity>> _today;
  late String _todayKey;

  @override
  void initState() {
    super.initState();
    // Live-updating totals (FR-2.6); the stored data never depends on this
    // timer, so a missed tick never loses accuracy (NFR-4).
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_services != null) return;
    final services = AppServicesScope.of(context);
    _services = services;
    _open = services.tracking.watchOpenActivity();
    _settings = services.tracking.watchSettings();
    _watchToday(services);
  }

  void _watchToday(AppServices services) {
    _todayKey = dayKeyFor(_now);
    _today = services.tracking.watchActivitiesForDay(_todayKey);
  }

  void _tick() {
    setState(() {
      _now = DateTime.now();
      if (dayKeyFor(_now) != _todayKey) _watchToday(_services!);
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final services = _services!;
    return StreamBuilder<Activity?>(
      stream: _open,
      builder: (context, openSnapshot) {
        final open = openSnapshot.data;
        return StreamBuilder<List<Activity>>(
          stream: _today,
          builder: (context, todaySnapshot) {
            return StreamBuilder<AppSetting>(
              stream: _settings,
              builder: (context, settingsSnapshot) {
                final settings = settingsSnapshot.data;
                return Scaffold(
                  appBar: AppBar(title: const Text('WorkPulse')),
                  body: settings == null
                      ? const Center(child: CircularProgressIndicator())
                      : _Dashboard(
                          open: open,
                          summary: services.tracking.summarize(
                            activities: todaySnapshot.data ?? const [],
                            settings: settings,
                            now: _now,
                          ),
                        ),
                  bottomNavigationBar: settings == null
                      ? null
                      : _ActionBar(
                          open: open,
                          hasWorkedToday:
                              todaySnapshot.data?.isNotEmpty ?? false,
                          services: services,
                        ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.open, required this.summary});

  static const double _minHeight = 460;

  final Activity? open;
  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        // The dashboard never scrolls: the large tile absorbs spare height,
        // and on a screen too short for even its minimum, everything shrinks.
        child: LayoutBuilder(
          builder: (context, box) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: box.maxWidth,
                height: box.maxHeight < _minHeight ? _minHeight : box.maxHeight,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _FinishTimeTile(open: open, summary: summary),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _StatRow(summary: summary),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The dashboard's large tile: when the daily target will be met, moving later
/// with every minute of break.
class _FinishTimeTile extends StatelessWidget {
  const _FinishTimeTile({required this.open, required this.summary});

  final Activity? open;
  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final content = _content();
    final textTheme = Theme.of(context).textTheme;
    const white = Colors.white;
    final soft = white.withValues(alpha: 0.85);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: content.gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: content.gradient.first.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const Positioned(top: -56, right: -40, child: _Orb(size: 180)),
          const Positioned(bottom: -72, right: 56, child: _Orb(size: 140)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, box) => FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: box.maxWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StateChip(icon: content.icon, label: content.state),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        content.caption,
                        style: textTheme.titleMedium?.copyWith(color: soft),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          content.time,
                          key: const Key('expected-finish'),
                          style: const TextStyle(
                            color: white,
                            fontSize: 60,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -2,
                            height: 1.1,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        content.detail,
                        style: textTheme.bodyMedium?.copyWith(color: soft),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: summary.progress,
                          minHeight: 8,
                          color: white,
                          backgroundColor: white.withValues(alpha: 0.25),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        '${formatHoursMinutes(summary.totalWorked)} of '
                        '${formatHoursMinutes(summary.target)} target',
                        style: textTheme.bodySmall?.copyWith(color: soft),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _TileContent _content() {
    final finish = summary.expectedFinish;
    final finished = summary.finishedAt;
    if (open == null && finished != null) {
      return _TileContent(
        gradient: AppGradients.finished,
        icon: Icons.check_circle_rounded,
        state: 'Day complete',
        caption: 'Finished at',
        time: formatClock(finished),
        detail: 'Break ${formatHoursMinutes(summary.totalBreak)}',
      );
    }
    if (open == null || finish == null) {
      return const _TileContent(
        gradient: AppGradients.idle,
        icon: Icons.wb_sunny_rounded,
        state: 'Not started',
        caption: 'Expected finish',
        time: '--:--',
        detail: 'Start work to see your finish time',
      );
    }
    final isWorking = open!.kind == ActivityKind.work;
    final reached = summary.overtime > Duration.zero;
    final started = summary.startedAt;
    final breaks = summary.totalBreak;
    return _TileContent(
      gradient: isWorking ? AppGradients.working : AppGradients.onBreak,
      icon: isWorking ? Icons.bolt_rounded : Icons.coffee_rounded,
      state: isWorking ? 'Working' : 'On break',
      caption: reached ? 'Target reached at' : 'Expected finish',
      time: formatClock(finish),
      detail: [
        if (started != null) 'Started ${formatClock(started)}',
        if (breaks.inMinutes > 0) '+${formatHoursMinutes(breaks)} break',
        if (reached) '${formatHoursMinutes(summary.overtime)} overtime',
      ].join(' · '),
    );
  }
}

class _TileContent {
  const _TileContent({
    required this.gradient,
    required this.icon,
    required this.state,
    required this.caption,
    required this.time,
    required this.detail,
  });

  final List<Color> gradient;
  final IconData icon;
  final String state;
  final String caption;
  final String time;
  final String detail;
}

class _Orb extends StatelessWidget {
  const _Orb({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.08),
      ),
    );
  }
}

class _StateChip extends StatelessWidget {
  const _StateChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md - 4,
        vertical: AppSpacing.xs + 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: AppSpacing.xs + 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.summary});

  final DailySummary summary;

  @override
  Widget build(BuildContext context) {
    final overtime = summary.overtime > Duration.zero;
    final allowed = formatHoursMinutes(summary.allowedBreak);
    final divider = VerticalDivider(
      width: 1,
      indent: AppSpacing.xs,
      endIndent: AppSpacing.xs,
      color: Theme.of(context).colorScheme.outlineVariant,
    );
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: _Stat(label: 'Worked', value: summary.totalWorked),
              ),
              divider,
              Expanded(
                child: _Stat(
                  label: summary.breakExceeded
                      ? 'Over $allowed break'
                      : 'Break of $allowed',
                  value: summary.totalBreak,
                  valueColor: summary.breakExceeded ? AppAccents.warning : null,
                ),
              ),
              divider,
              Expanded(
                child: _Stat(
                  label: overtime ? 'Overtime' : 'Remaining',
                  value: overtime ? summary.overtime : summary.remaining,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.valueColor});

  final String label;
  final Duration value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatHoursMinutes(value),
              maxLines: 1,
              style: theme.textTheme.titleLarge?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.open,
    required this.hasWorkedToday,
    required this.services,
  });

  final Activity? open;
  final bool hasWorkedToday;
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: _buttons(context),
          ),
        ),
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    if (open == null) {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          key: const Key('start-work-button'),
          onPressed: services.actions.startWork,
          icon: const Icon(Icons.play_arrow_rounded),
          label: Text(hasWorkedToday ? 'Start work again' : 'Start work'),
        ),
      );
    }
    final isWorking = open!.kind == ActivityKind.work;
    return Row(
      children: [
        Expanded(
          child: isWorking
              ? FilledButton.icon(
                  key: const Key('break-button'),
                  onPressed: () => _startBreak(context),
                  icon: const Icon(Icons.coffee_rounded),
                  label: const Text('Break'),
                )
              : FilledButton.icon(
                  key: const Key('resume-button'),
                  onPressed: services.actions.resumeWork,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Resume'),
                ),
        ),
        const SizedBox(width: AppSpacing.md - 4),
        Expanded(
          child: OutlinedButton.icon(
            key: const Key('end-work-button'),
            onPressed: services.actions.endWork,
            icon: const Icon(Icons.stop_rounded),
            label: const Text('End work'),
          ),
        ),
      ],
    );
  }

  Future<void> _startBreak(BuildContext context) async {
    final types = await services.breakTypes.watchActive().first;
    if (!context.mounted) return;
    final breakTypeId = await showBreakPicker(context, types);
    if (breakTypeId != null) {
      await services.actions.startBreak(breakTypeId);
    }
  }
}
