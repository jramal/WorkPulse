import 'package:flutter/material.dart';

import '../../app_services.dart';
import '../../data/database.dart';
import '../../domain/time_format.dart';
import '../../theme/app_theme.dart';
import '../widgets/duration_picker.dart';
import '../widgets/setting_tile.dart';
import 'break_types_screen.dart';
import 'teams_settings_screen.dart';

/// Daily target + allowed break duration (FR-2.7), with links into break type
/// management (FR-1.6) and Teams automation (FR-4.x).
class TrackingSettingsScreen extends StatefulWidget {
  const TrackingSettingsScreen({super.key});

  @override
  State<TrackingSettingsScreen> createState() => _TrackingSettingsScreenState();
}

class _TrackingSettingsScreenState extends State<TrackingSettingsScreen> {
  Stream<AppSetting>? _settings;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _settings ??= AppServicesScope.of(context).tracking.watchSettings();
  }

  @override
  Widget build(BuildContext context) {
    final tracking = AppServicesScope.of(context).tracking;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: StreamBuilder<AppSetting>(
        stream: _settings,
        builder: (context, snapshot) {
          final settings = snapshot.data;
          if (settings == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final target = Duration(minutes: settings.dailyTargetMinutes);
          final allowed = Duration(minutes: settings.allowedBreakMinutes);
          const gap = SizedBox(height: AppSpacing.md - 4);
          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            children: [
              const SectionLabel('Tracking'),
              SettingTile(
                key: const Key('daily-target-setting'),
                icon: Icons.flag_rounded,
                color: AppAccents.worked,
                title: 'Daily working target',
                value: formatHoursMinutes(target),
                onTap: () async {
                  final picked = await showDurationPicker(
                    context,
                    title: 'Daily working target',
                    initial: target,
                    allowZero: false,
                  );
                  if (picked != null) await tracking.updateDailyTarget(picked);
                },
              ),
              gap,
              SettingTile(
                key: const Key('allowed-break-setting'),
                icon: Icons.coffee_rounded,
                color: AppAccents.breaks,
                title: 'Allowed break time',
                value: formatHoursMinutes(allowed),
                onTap: () async {
                  final picked = await showDurationPicker(
                    context,
                    title: 'Allowed break time',
                    initial: allowed,
                    allowZero: true,
                  );
                  if (picked != null) await tracking.updateAllowedBreak(picked);
                },
              ),
              gap,
              SettingTile(
                icon: Icons.category_rounded,
                color: AppAccents.remaining,
                title: 'Break types',
                subtitle: 'Names, alarms and reminders',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const BreakTypesScreen(),
                  ),
                ),
              ),
              const SectionLabel('Automation'),
              SettingTile(
                key: const Key('teams-setting'),
                icon: Icons.groups_rounded,
                color: AppAccents.productive,
                title: 'Microsoft Teams',
                subtitle: settings.teamsEnabled ? 'On' : 'Off',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const TeamsSettingsScreen(),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
