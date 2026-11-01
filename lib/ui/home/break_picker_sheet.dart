import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../theme/app_theme.dart';

/// Bottom sheet listing active break types (FR-1.2): tapping one starts
/// that break.
Future<int?> showBreakPicker(BuildContext context, List<BreakType> types) {
  return showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start a break',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.sm),
              if (types.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text('No break types yet. Add one in Settings.'),
                )
              else
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final type in types)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const IconBadge(
                            icon: Icons.coffee_rounded,
                            color: AppAccents.breaks,
                          ),
                          title: Text(type.name),
                          onTap: () => Navigator.of(context).pop(type.id),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
