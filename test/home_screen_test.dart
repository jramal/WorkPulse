import 'package:drift/drift.dart' show DatabaseConnection, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workpulse/app.dart';
import 'package:workpulse/app_services.dart';
import 'package:workpulse/data/database.dart';
import 'package:workpulse/ui/home/home_screen.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  // Synchronous stream teardown leaves no drift timer behind at the end of a
  // widget test.
  final services = AppServices(
    database: AppDatabase(
      executor: DatabaseConnection(
        NativeDatabase.memory(),
        closeStreamsSynchronously: true,
      ),
    ),
  );
  await tester.pumpWidget(WorkPulseApp(services: services));
  await _settle(tester);
}

// The dashboard ticks every second, so pumpAndSettle() would never return.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

String _finishText(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const Key('expected-finish'))).data!;

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  testWidgets('has no finish time until work starts', (tester) async {
    await _pumpApp(tester);

    expect(find.text('Not started'), findsOneWidget);
    expect(_finishText(tester), '--:--');
    expect(find.byKey(const Key('start-work-button')), findsOneWidget);
  });

  testWidgets('starting work shows a finish time and the Working actions', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.byKey(const Key('start-work-button')));
    await _settle(tester);

    expect(find.text('Working'), findsOneWidget);
    expect(_finishText(tester), isNot('--:--'));
    expect(find.byKey(const Key('break-button')), findsOneWidget);
    expect(find.byKey(const Key('end-work-button')), findsOneWidget);
  });

  testWidgets('ending the day shows when it finished', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.byKey(const Key('start-work-button')));
    await _settle(tester);
    await tester.tap(find.byKey(const Key('end-work-button')));
    await _settle(tester);

    expect(find.text('Day complete'), findsOneWidget);
    expect(find.text('Finished at'), findsOneWidget);
    expect(find.text('Start work again'), findsOneWidget);
  });

  for (final (name, size) in const [
    ('small phone', Size(320, 568)),
    ('landscape', Size(800, 360)),
    ('tall phone', Size(412, 915)),
  ]) {
    testWidgets('dashboard fits a $name without scrolling', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _pumpApp(tester);

      await tester.tap(find.byKey(const Key('start-work-button')));
      await _settle(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Remaining'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(HomeScreen),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );
    });
  }

  testWidgets('History lists the day and opens its activity log', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('History'));
    await _settle(tester);
    expect(find.text('Days you track will appear here.'), findsOneWidget);

    await tester.tap(find.text('Home'));
    await _settle(tester);
    await tester.tap(find.byKey(const Key('start-work-button')));
    await _settle(tester);
    await tester.tap(find.text('History'));
    await _settle(tester);
    expect(find.text('Today'), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Work'), findsOneWidget);
  });

  testWidgets('Settings reaches the Teams screen and a trigger editor', (
    tester,
  ) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Settings'));
    await _settle(tester);
    expect(find.text('Daily working target'), findsOneWidget);
    expect(find.text('8h'), findsOneWidget);

    await tester.tap(find.byKey(const Key('teams-setting')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Send Teams messages'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Resume work'),
      find.byType(ListView).last,
      const Offset(0, -200),
    );
    await tester.ensureVisible(find.text('Resume work'));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Resume work'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Send this message'), findsOneWidget);
    expect(find.text('Back at work at {startTime}.'), findsOneWidget);
  });

  testWidgets('a new break type can set up its alarm', (tester) async {
    await _pumpApp(tester);

    await tester.tap(find.text('Settings'));
    await _settle(tester);
    await tester.tap(find.text('Break types'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byTooltip('Add break type'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Expected break duration'), findsNothing);
    expect(
      find.text('Save this break type to set its Teams messages.'),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const Key('alarm-enabled-switch')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Expected break duration'), findsOneWidget);

    final addAlarm = find.byKey(const Key('add-mid-break-alarm'));
    await tester.ensureVisible(addAlarm);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(addAlarm);
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('save-duration-button')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.widgetWithText(InputChip, '5m'), findsOneWidget);
  });
}
