import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

enum ActivityKind { work, breakActivity }

enum AlarmSound { notification, alarm, ringtone }

enum AlarmAlertStyle { headsUp, quiet }

enum ReminderBehaviour { once, repeat }

class BreakTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get description => text().nullable()();
  IntColumn get colorValue => integer().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get alarmEnabled => boolean().withDefault(const Constant(false))();
  IntColumn get expectedDurationMinutes =>
      integer().withDefault(const Constant(15))();
  TextColumn get alarmSound => textEnum<AlarmSound>().withDefault(
    Constant(AlarmSound.notification.name),
  )();
  BoolColumn get vibrationEnabled =>
      boolean().withDefault(const Constant(true))();
  TextColumn get alertStyle => textEnum<AlarmAlertStyle>().withDefault(
    Constant(AlarmAlertStyle.headsUp.name),
  )();
  TextColumn get reminderBehaviour => textEnum<ReminderBehaviour>().withDefault(
    Constant(ReminderBehaviour.once.name),
  )();
  IntColumn get repeatIntervalMinutes =>
      integer().withDefault(const Constant(5))();
  // Minutes after the break starts, e.g. "5,10,15"; see domain/break_alerts.dart.
  TextColumn get midBreakAlarmMinutes =>
      text().withDefault(const Constant(''))();
}

class Activities extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get kind => textEnum<ActivityKind>()();
  IntColumn get breakTypeId =>
      integer().nullable().references(BreakTypes, #id)();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime().nullable()();
  IntColumn get durationSeconds => integer().nullable()();
  // Local calendar date (yyyy-MM-dd) the activity is grouped under; see CRS AQ-2.
  TextColumn get dayKey => text()();
  // The target in force when this was recorded, so editing the target later
  // doesn't rewrite how past days scored (FR-3.3). Null on pre-v2 rows.
  IntColumn get targetMinutes => integer().nullable()();
}

class AppSettings extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  IntColumn get dailyTargetMinutes =>
      integer().withDefault(const Constant(480))();
  IntColumn get allowedBreakMinutes =>
      integer().withDefault(const Constant(60))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Task')
class Tasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().withLength(min: 1, max: 120)();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get dueAt => dateTime().nullable()();
  TextColumn get locationName => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  IntColumn get radiusMeters => integer().nullable()();
  BoolColumn get isDone => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DriftDatabase(tables: [BreakTypes, Activities, AppSettings, Tasks])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor})
    : super(
        executor ??
            driftDatabase(
              name: 'workpulse',
              native: DriftNativeOptions(
                // The UI, the background service and retry jobs run in separate
                // Flutter engines, so each holds its own connection to this
                // file; WAL plus a busy timeout stops "database is locked".
                setup: (db) {
                  db.execute('PRAGMA journal_mode = WAL;');
                  db.execute('PRAGMA busy_timeout = 5000;');
                },
              ),
            ),
      );

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaults(this);
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(breakTypes, breakTypes.alarmEnabled);
        await m.addColumn(breakTypes, breakTypes.expectedDurationMinutes);
        await m.addColumn(breakTypes, breakTypes.alarmSound);
        await m.addColumn(breakTypes, breakTypes.vibrationEnabled);
        await m.addColumn(breakTypes, breakTypes.alertStyle);
        await m.addColumn(breakTypes, breakTypes.reminderBehaviour);
        await m.addColumn(breakTypes, breakTypes.repeatIntervalMinutes);
        await m.addColumn(activities, activities.targetMinutes);
      }
      if (from < 3) {
        await m.addColumn(breakTypes, breakTypes.midBreakAlarmMinutes);
      }
      if (from < 4) {
        // Removes the retired Teams feature, including stored webhook URLs.
        // Those tables and columns only ever existed from version 2 onwards.
        if (from >= 2) {
          await customStatement('DROP TABLE IF EXISTS teams_deliveries');
          await customStatement('DROP TABLE IF EXISTS teams_trigger_configs');
          await customStatement(
            'ALTER TABLE app_settings DROP COLUMN teams_default_destination',
          );
          await customStatement(
            'ALTER TABLE app_settings DROP COLUMN teams_enabled',
          );
        }
        await m.createTable(tasks);
      }
    },
  );

  static Future<void> _seedDefaults(AppDatabase db) async {
    await db
        .into(db.appSettings)
        .insert(
          const AppSettingsCompanion(id: Value(0)),
          mode: InsertMode.insertOrIgnore,
        );
    for (final name in const [
      'Tea Break',
      'Lunch Break',
      'Personal Break',
      'Other',
    ]) {
      await db
          .into(db.breakTypes)
          .insert(
            BreakTypesCompanion.insert(
              name: name,
              isDefault: const Value(true),
            ),
          );
    }
  }
}
