import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';

enum ActivityKind { work, breakActivity }

enum AlarmSound { notification, alarm, ringtone }

enum AlarmAlertStyle { headsUp, quiet }

enum ReminderBehaviour { once, repeat }

enum TeamsTrigger { startWork, resumeWork, endWork, breakStart, breakEnd }

enum DeliveryStatus { queued, sending, sent, failed }

class BreakTypes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  TextColumn get description => text().nullable()();
  IntColumn get colorValue => integer().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
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
  BoolColumn get teamsEnabled => boolean().withDefault(const Constant(false))();
  TextColumn get teamsDefaultDestination => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TeamsTriggerConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get trigger => textEnum<TeamsTrigger>()();
  IntColumn get breakTypeId =>
      integer().nullable().references(BreakTypes, #id)();
  BoolColumn get enabled => boolean().withDefault(const Constant(false))();
  TextColumn get messageTemplate => text().withDefault(const Constant(''))();
  // Overrides AppSettings.teamsDefaultDestination when set.
  TextColumn get destination => text().nullable()();
}

@DataClassName('TeamsDelivery')
class TeamsDeliveries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();
  IntColumn get activityId => integer().nullable().references(Activities, #id)();
  TextColumn get message => text()();
  TextColumn get destination => text()();
  TextColumn get status => textEnum<DeliveryStatus>()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  DateTimeColumn get nextAttemptAt => dateTime()();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(
  tables: [
    BreakTypes,
    Activities,
    AppSettings,
    TeamsTriggerConfigs,
    TeamsDeliveries,
  ],
)
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
  int get schemaVersion => 3;

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
        await m.addColumn(appSettings, appSettings.teamsEnabled);
        await m.addColumn(appSettings, appSettings.teamsDefaultDestination);
        await m.createTable(teamsTriggerConfigs);
        await m.createTable(teamsDeliveries);
      }
      if (from < 3) {
        await m.addColumn(breakTypes, breakTypes.midBreakAlarmMinutes);
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
            BreakTypesCompanion.insert(name: name, isDefault: const Value(true)),
          );
    }
  }
}
