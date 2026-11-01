import 'package:flutter/cupertino.dart'
    show CupertinoTimerPicker, CupertinoTimerPickerMode;
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Bottom sheet for choosing hours and minutes. Returns null if dismissed.
Future<Duration?> showDurationPicker(
  BuildContext context, {
  required String title,
  required Duration initial,
  required bool allowZero,
}) {
  return showModalBottomSheet<Duration>(
    context: context,
    // Otherwise the sheet is capped at 9/16 of the screen, which on a small
    // phone is too short for the wheel and the Save button.
    isScrollControlled: true,
    builder: (_) => _DurationPickerSheet(
      title: title,
      initial: initial,
      allowZero: allowZero,
    ),
  );
}

class _DurationPickerSheet extends StatefulWidget {
  const _DurationPickerSheet({
    required this.title,
    required this.initial,
    required this.allowZero,
  });

  final String title;
  final Duration initial;
  final bool allowZero;

  @override
  State<_DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<_DurationPickerSheet> {
  late Duration _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    final canSave = widget.allowZero || _value > Duration.zero;
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.title,
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: widget.initial,
              backgroundColor: Colors.transparent,
              onTimerDurationChanged: (value) => setState(() => _value = value),
            ),
            const SizedBox(height: AppSpacing.md - 4),
            FilledButton(
              key: const Key('save-duration-button'),
              onPressed: canSave
                  ? () => Navigator.of(context).pop(_value)
                  : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
