import 'dart:convert';

import 'package:drift/drift.dart'
    show DatabaseConnection, Value, driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:workpulse/app.dart';
import 'package:workpulse/app_services.dart';
import 'package:workpulse/data/database.dart';
import 'package:workpulse/domain/task_repository.dart';
import 'package:workpulse/domain/task_rules.dart';

Task _task({
  int id = 1,
  String title = 'Buy milk',
  DateTime? dueAt,
  bool isDone = false,
  bool withLocation = false,
  int radiusMeters = 2000,
}) => Task(
  id: id,
  title: title,
  dueAt: dueAt,
  isDone: isDone,
  createdAt: DateTime(2026),
  locationName: withLocation ? 'Office' : null,
  latitude: withLocation ? 8.5 : null,
  longitude: withLocation ? 76.9 : null,
  radiusMeters: withLocation ? radiusMeters : null,
);

void main() {
  setUpAll(() => driftRuntimeOptions.dontWarnAboutMultipleDatabases = true);

  group('radius', () {
    test('displays in metres or kilometres', () {
      expect(formatRadius(500), '500 m');
      expect(formatRadius(1000), '1 km');
      expect(formatRadius(2000), '2 km');
      expect(formatRadius(1500), '1.5 km');
    });

    test('custom values accept kilometres within the limits', () {
      expect(parseRadiusKm('2'), 2000);
      expect(parseRadiusKm(' 1.5 '), 1500);
      expect(parseRadiusKm('0.1'), 100);
      expect(parseRadiusKm('50'), 50000);
    });

    test('custom values reject anything outside the limits', () {
      expect(parseRadiusKm('0.05'), isNull);
      expect(parseRadiusKm('51'), isNull);
      expect(parseRadiusKm('-1'), isNull);
      expect(parseRadiusKm('far'), isNull);
    });
  });

  group('which tasks alert', () {
    final now = DateTime(2026, 1, 1, 12);

    test('a future date on an open task alerts', () {
      expect(needsDateAlert(_task(dueAt: DateTime(2026, 1, 2)), now), isTrue);
    });

    test('a past date, no date, or a finished task does not', () {
      expect(needsDateAlert(_task(dueAt: DateTime(2025)), now), isFalse);
      expect(needsDateAlert(_task(), now), isFalse);
      expect(
        needsDateAlert(_task(dueAt: DateTime(2026, 1, 2), isDone: true), now),
        isFalse,
      );
    });

    test('only open tasks with a location are watched', () {
      final areas = jsonDecode(
        geofencesJson([
          _task(id: 1, withLocation: true),
          _task(id: 2),
          _task(id: 3, withLocation: true, isDone: true),
        ]),
      ) as List;
      expect(areas.map((a) => a['id']), [1]);
      expect(areas.single['radiusMeters'], 2000);
      expect(areas.single['message'], 'You are within 2 km of Office.');
    });

    test('a date and a location are independent', () {
      final both = _task(dueAt: DateTime(2026, 1, 2), withLocation: true);
      expect(needsDateAlert(both, now), isTrue);
      expect(jsonDecode(geofencesJson([both])) as List, hasLength(1));
    });

    test('never exceeds Android\'s limit, keeping the newest', () {
      final areas = jsonDecode(
        geofencesJson([
          for (var id = 1; id <= 120; id++) _task(id: id, withLocation: true),
        ]),
      ) as List;
      expect(areas, hasLength(maxActiveGeofences));
      expect(areas.first['id'], 120);
      expect(areas.last['id'], 21);
    });
  });

  group('task storage', () {
    late AppDatabase db;
    late TaskRepository tasks;

    setUp(() {
      db = AppDatabase(executor: NativeDatabase.memory());
      tasks = TaskRepository(db);
    });

    tearDown(() => db.close());

    test('adds, edits, and deletes', () async {
      final id = await tasks.add(TasksCompanion.insert(title: 'Call home'));
      expect((await tasks.find(id)).title, 'Call home');

      await tasks.update(id, const TasksCompanion(title: Value('Call office')));
      expect((await tasks.find(id)).title, 'Call office');

      await tasks.delete(id);
      expect(await tasks.getAll(), isEmpty);
    });

    test('a date and location can be cleared', () async {
      final id = await tasks.add(
        TasksCompanion.insert(
          title: 'Call',
          dueAt: Value(DateTime(2027)),
          latitude: const Value(1),
          longitude: const Value(2),
          radiusMeters: const Value(1000),
        ),
      );
      await tasks.update(
        id,
        const TasksCompanion(
          dueAt: Value(null),
          latitude: Value(null),
          longitude: Value(null),
          radiusMeters: Value(null),
        ),
      );
      final task = await tasks.find(id);
      expect(task.dueAt, isNull);
      expect(hasLocation(task), isFalse);
    });

    test('lists open tasks first, then soonest due', () async {
      final done = await tasks.add(
        TasksCompanion.insert(title: 'done', isDone: const Value(true)),
      );
      final none = await tasks.add(TasksCompanion.insert(title: 'no date'));
      final later = await tasks.add(
        TasksCompanion.insert(title: 'later', dueAt: Value(DateTime(2028))),
      );
      final soon = await tasks.add(
        TasksCompanion.insert(title: 'soon', dueAt: Value(DateTime(2027))),
      );

      expect((await tasks.getAll()).map((t) => t.id), [
        soon,
        later,
        none,
        done,
      ]);
    });
  });

  test('upgrading removes Teams data and keeps tracking data', () async {
    final db = AppDatabase(
      executor: NativeDatabase.memory(
        setup: (raw) {
          raw.execute(
            'CREATE TABLE break_types (id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'name TEXT NOT NULL, description TEXT, color_value INTEGER, '
            'is_default INTEGER NOT NULL DEFAULT 0, '
            'is_active INTEGER NOT NULL DEFAULT 1, '
            'created_at INTEGER NOT NULL DEFAULT 0, '
            'alarm_enabled INTEGER NOT NULL DEFAULT 0, '
            'expected_duration_minutes INTEGER NOT NULL DEFAULT 15, '
            "alarm_sound TEXT NOT NULL DEFAULT 'notification', "
            'vibration_enabled INTEGER NOT NULL DEFAULT 1, '
            "alert_style TEXT NOT NULL DEFAULT 'headsUp', "
            "reminder_behaviour TEXT NOT NULL DEFAULT 'once', "
            'repeat_interval_minutes INTEGER NOT NULL DEFAULT 5, '
            "mid_break_alarm_minutes TEXT NOT NULL DEFAULT '');",
          );
          raw.execute(
            'CREATE TABLE activities (id INTEGER PRIMARY KEY AUTOINCREMENT, '
            'kind TEXT NOT NULL, break_type_id INTEGER, '
            'start_time INTEGER NOT NULL, end_time INTEGER, '
            'duration_seconds INTEGER, day_key TEXT NOT NULL, '
            'target_minutes INTEGER);',
          );
          raw.execute(
            'CREATE TABLE app_settings (id INTEGER NOT NULL DEFAULT 0 PRIMARY KEY, '
            'daily_target_minutes INTEGER NOT NULL DEFAULT 480, '
            'allowed_break_minutes INTEGER NOT NULL DEFAULT 60, '
            'teams_enabled INTEGER NOT NULL DEFAULT 0, '
            'teams_default_destination TEXT);',
          );
          raw.execute(
            'CREATE TABLE teams_trigger_configs (id INTEGER PRIMARY KEY);',
          );
          raw.execute(
            'CREATE TABLE teams_deliveries (id INTEGER PRIMARY KEY);',
          );
          raw.execute(
            "INSERT INTO activities (kind, start_time, day_key) "
            "VALUES ('work', 1000, '2026-10-31');",
          );
          raw.execute(
            'INSERT INTO app_settings (id, daily_target_minutes, '
            "teams_enabled, teams_default_destination) "
            "VALUES (0, 450, 1, 'https://example.com/secret');",
          );
          raw.execute('PRAGMA user_version = 3;');
        },
      ),
    );
    addTearDown(db.close);

    expect((await db.select(db.activities).get()).single.dayKey, '2026-10-31');
    expect(
      (await db.select(db.appSettings).getSingle()).dailyTargetMinutes,
      450,
    );
    expect(await db.select(db.tasks).get(), isEmpty);

    final tables = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name LIKE 'teams%'",
        )
        .get();
    expect(tables, isEmpty);
    final columns = await db
        .customSelect('PRAGMA table_info(app_settings)')
        .get();
    expect(
      columns.map((c) => c.read<String>('name')),
      isNot(contains('teams_default_destination')),
    );
  });

  testWidgets('a task can be created from the Tasks tab', (tester) async {
    final services = AppServices(
      database: AppDatabase(
        executor: DatabaseConnection(
          NativeDatabase.memory(),
          closeStreamsSynchronously: true,
        ),
      ),
    );
    await tester.pumpWidget(WorkPulseApp(services: services));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.text('Tasks'));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Tasks you add will appear here.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add-task-button')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Date and time'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);

    await tester.tap(find.byKey(const Key('save-task-button')));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Enter a title'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('task-title')), 'Call home');
    await tester.tap(find.byKey(const Key('save-task-button')));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Call home'), findsOneWidget);
  });
}
