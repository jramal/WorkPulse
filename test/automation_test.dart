import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:workpulse/background/teams_delivery.dart';
import 'package:workpulse/background/tracking_notification.dart';
import 'package:workpulse/data/database.dart';
import 'package:workpulse/domain/break_alerts.dart';
import 'package:workpulse/domain/break_type_repository.dart';
import 'package:workpulse/domain/teams_repository.dart';
import 'package:workpulse/domain/teams_template.dart';
import 'package:workpulse/domain/time_format.dart';
import 'package:workpulse/domain/tracking_engine.dart';

const _url = 'https://example.com/webhook?sig=secret';

void main() {
  late AppDatabase db;
  late TrackingEngine engine;
  late TeamsRepository teams;
  late BreakTypeRepository breakTypes;

  setUp(() {
    db = AppDatabase(executor: NativeDatabase.memory());
    engine = TrackingEngine(db);
    teams = TeamsRepository(db);
    breakTypes = BreakTypeRepository(db);
  });

  tearDown(() => db.close());

  Future<List<TeamsDelivery>> deliveries() =>
      db.select(db.teamsDeliveries).get();

  Future<void> turnOnTeams() async {
    await teams.setEnabled(true);
    await teams.setDefaultDestination(_url);
  }

  Future<int> teaBreak() async =>
      (await breakTypes.watchActive().first).first.id;

  group('migration', () {
    test('v1 data survives the upgrade to v2', () async {
      final old = AppDatabase(
        executor: NativeDatabase.memory(
          setup: (raw) {
            raw.execute(
              'CREATE TABLE break_types (id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'name TEXT NOT NULL, description TEXT, color_value INTEGER, '
              'is_default INTEGER NOT NULL DEFAULT 0, '
              'is_active INTEGER NOT NULL DEFAULT 1, '
              'created_at INTEGER NOT NULL DEFAULT 0);',
            );
            raw.execute(
              'CREATE TABLE activities (id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'kind TEXT NOT NULL, break_type_id INTEGER, '
              'start_time INTEGER NOT NULL, end_time INTEGER, '
              'duration_seconds INTEGER, day_key TEXT NOT NULL);',
            );
            raw.execute(
              'CREATE TABLE app_settings (id INTEGER NOT NULL DEFAULT 0 PRIMARY KEY, '
              'daily_target_minutes INTEGER NOT NULL DEFAULT 480, '
              'allowed_break_minutes INTEGER NOT NULL DEFAULT 60);',
            );
            raw.execute("INSERT INTO break_types (name) VALUES ('Tea Break');");
            raw.execute(
              'INSERT INTO activities (kind, start_time, day_key) '
              "VALUES ('work', 1000, '2026-01-01');",
            );
            raw.execute(
              'INSERT INTO app_settings (id, daily_target_minutes) VALUES (0, 450);',
            );
            raw.execute('PRAGMA user_version = 1;');
          },
        ),
      );
      addTearDown(old.close);

      final type = (await old.select(old.breakTypes).get()).single;
      expect(type.name, 'Tea Break');
      expect(type.alarmEnabled, isFalse);
      expect(type.expectedDurationMinutes, 15);
      expect(type.midBreakAlarmMinutes, isEmpty);

      final activity = (await old.select(old.activities).get()).single;
      expect(activity.dayKey, '2026-01-01');
      expect(activity.targetMinutes, isNull);

      final settings = await old.select(old.appSettings).getSingle();
      expect(settings.dailyTargetMinutes, 450);
      expect(settings.teamsEnabled, isFalse);

      expect(await old.select(old.teamsDeliveries).get(), isEmpty);
    });
  });

  group('state machine guards', () {
    test('a stale notification tap changes nothing', () async {
      final id = await teaBreak();
      expect(await engine.resumeWork(), isNull);
      expect(await engine.endWork(), isNull);
      expect(await engine.startBreak(id), isNull);

      await engine.startWork();
      expect(await engine.resumeWork(), isNull);
      expect(await engine.startWork(), isNull);

      await engine.startBreak(id);
      expect(await engine.startBreak(id), isNull);
      expect(await engine.startWork(), isNull);

      expect((await db.select(db.activities).get()).length, 2);
    });

    test('a transition reports what it closed and opened', () async {
      final id = await teaBreak();
      final started = await engine.startWork();
      expect(started!.closed, isNull);
      expect(started.opened!.kind, ActivityKind.work);

      final onBreak = await engine.startBreak(id);
      expect(onBreak!.closed!.id, started.opened!.id);
      expect(onBreak.closed!.endTime, isNotNull);
      expect(onBreak.opened!.breakTypeId, id);

      final ended = await engine.endWork();
      expect(ended!.closed!.id, onBreak.opened!.id);
      expect(ended.opened, isNull);
    });

    test('new activities record the target in force', () async {
      await engine.updateDailyTarget(const Duration(hours: 6));
      final started = await engine.startWork();
      expect(started!.opened!.targetMinutes, 360);
    });
  });

  group('Teams send rule (FR-4.6)', () {
    Future<void> saveStart({bool enabled = true, String template = 'Hi'}) =>
        teams.saveConfig(
          trigger: TeamsTrigger.startWork,
          enabled: enabled,
          template: template,
        );

    test('nothing is queued by default', () async {
      await engine.startWork();
      expect(await deliveries(), isEmpty);
    });

    test('nothing is queued with the global switch off', () async {
      await teams.setDefaultDestination(_url);
      await saveStart();
      await engine.startWork();
      expect(await deliveries(), isEmpty);
    });

    test('nothing is queued with the trigger off', () async {
      await turnOnTeams();
      await saveStart(enabled: false);
      await engine.startWork();
      expect(await deliveries(), isEmpty);
    });

    test('nothing is queued with an empty message', () async {
      await turnOnTeams();
      await saveStart(template: '   ');
      await engine.startWork();
      expect(await deliveries(), isEmpty);
    });

    test('nothing is queued without a valid https destination', () async {
      await teams.setEnabled(true);
      await saveStart();
      await engine.startWork();
      expect(await deliveries(), isEmpty);

      await engine.endWork();
      await teams.setDefaultDestination('http://example.com/insecure');
      await engine.startWork();
      expect(await deliveries(), isEmpty);
    });

    test('a fully configured trigger queues exactly one message', () async {
      await turnOnTeams();
      await saveStart(template: 'Started {date} with target {target}');
      await engine.startWork();
      await engine.startWork();

      final queued = await deliveries();
      expect(queued, hasLength(1));
      expect(queued.single.status, DeliveryStatus.queued);
      expect(queued.single.destination, _url);
      expect(queued.single.message, contains('with target 8h'));
      expect(queued.single.message, isNot(contains('{')));
    });

    test('a trigger destination overrides the default', () async {
      await turnOnTeams();
      await teams.saveConfig(
        trigger: TeamsTrigger.startWork,
        enabled: true,
        template: 'Hi',
        destination: 'https://example.com/other',
      );
      await engine.startWork();
      expect(
        (await deliveries()).single.destination,
        'https://example.com/other',
      );
    });

    test('each break type is configured independently (FR-4.5)', () async {
      await turnOnTeams();
      final types = await breakTypes.watchActive().first;
      await teams.saveConfig(
        trigger: TeamsTrigger.breakStart,
        breakTypeId: types[0].id,
        enabled: true,
        template: '{breakType} now',
      );
      await engine.startWork();
      await engine.startBreak(types[1].id);
      expect(await deliveries(), isEmpty);

      await engine.resumeWork();
      await engine.startBreak(types[0].id);
      expect((await deliveries()).single.message, '${types[0].name} now');
    });

    test('a new break type sends nothing until configured', () async {
      await turnOnTeams();
      final id = await breakTypes.add(BreakTypesCompanion.insert(name: 'Walk'));
      await engine.startWork();
      await engine.startBreak(id);
      expect(await deliveries(), isEmpty);
    });

    test('resuming fires break-end and resume, in that order', () async {
      await turnOnTeams();
      final id = await teaBreak();
      await teams.saveConfig(
        trigger: TeamsTrigger.breakEnd,
        breakTypeId: id,
        enabled: true,
        template: 'break over',
      );
      await teams.saveConfig(
        trigger: TeamsTrigger.resumeWork,
        enabled: true,
        template: 'resumed',
      );
      await engine.startWork();
      await engine.startBreak(id);
      await engine.resumeWork();
      expect((await deliveries()).map((d) => d.message), [
        'break over',
        'resumed',
      ]);
    });

    test('ending the day sends a summary, even from a break', () async {
      await turnOnTeams();
      final id = await teaBreak();
      await teams.saveConfig(
        trigger: TeamsTrigger.endWork,
        enabled: true,
        template: 'Bye. Worked {worked}, break {break}.',
      );
      await engine.startWork();
      await engine.startBreak(id);
      await engine.endWork();
      expect((await deliveries()).single.message, 'Bye. Worked 0m, break 0m.');
    });
  });

  group('Teams delivery (TR-5, TR-6)', () {
    late List<http.Request> requests;
    late List<Duration> retries;

    TeamsSender sender(Future<http.Response> Function() respond) => TeamsSender(
      db,
      client: MockClient((request) {
        requests.add(request);
        return respond();
      }),
      scheduleRetry: (delay) async => retries.add(delay),
    );

    setUp(() async {
      requests = [];
      retries = [];
      await turnOnTeams();
      await teams.saveConfig(
        trigger: TeamsTrigger.startWork,
        enabled: true,
        template: 'Started',
      );
      await engine.startWork();
    });

    test('success posts an Adaptive Card and is never sent twice', () async {
      final teamsSender = sender(() async => http.Response('', 202));
      await teamsSender.flush();
      await teamsSender.flush();

      expect(requests, hasLength(1));
      expect(requests.single.url.toString(), _url);
      final body = jsonDecode(requests.single.body) as Map<String, dynamic>;
      final content = (body['attachments'] as List).single['content'];
      expect((content['body'] as List).single['text'], 'Started');

      expect((await deliveries()).single.status, DeliveryStatus.sent);
      expect(retries, isEmpty);
    });

    test('a rejected webhook fails without retrying', () async {
      await sender(() async => http.Response('', 404)).flush();
      final delivery = (await deliveries()).single;
      expect(delivery.status, DeliveryStatus.failed);
      expect(delivery.lastError, 'HTTP 404');
      expect(retries, isEmpty);
    });

    test('a server error retries later with backoff', () async {
      await sender(() async => http.Response('', 503)).flush();
      final delivery = (await deliveries()).single;
      expect(delivery.status, DeliveryStatus.queued);
      expect(delivery.attempts, 1);
      expect(delivery.nextAttemptAt.isAfter(DateTime.now()), isTrue);
      expect(retries, hasLength(1));
    });

    test('server errors give up after the attempt limit', () async {
      final teamsSender = sender(() async => http.Response('', 500));
      for (var i = 0; i < 8; i++) {
        await db
            .update(db.teamsDeliveries)
            .write(
              TeamsDeliveriesCompanion(nextAttemptAt: Value(DateTime(2020))),
            );
        await teamsSender.flush();
      }
      expect((await deliveries()).single.status, DeliveryStatus.failed);
    });

    test('being offline keeps the message without using up attempts', () async {
      await sender(() async => throw http.ClientException('offline')).flush();
      final delivery = (await deliveries()).single;
      expect(delivery.status, DeliveryStatus.queued);
      expect(delivery.attempts, 0);
      expect(delivery.lastError, 'No connection');
      expect(retries, hasLength(1));
    });

    test('a message too old to be useful stops retrying', () async {
      await db
          .update(db.teamsDeliveries)
          .write(
            TeamsDeliveriesCompanion(
              createdAt: Value(
                DateTime.now().subtract(const Duration(hours: 25)),
              ),
            ),
          );
      await sender(() async => throw http.ClientException('offline')).flush();
      expect((await deliveries()).single.status, DeliveryStatus.failed);
    });

    test('a message claimed by another engine is left alone', () async {
      await db
          .update(db.teamsDeliveries)
          .write(
            TeamsDeliveriesCompanion(
              status: const Value(DeliveryStatus.sending),
              lastAttemptAt: Value(DateTime.now()),
            ),
          );
      await sender(() async => http.Response('', 202)).flush();
      expect(requests, isEmpty);
    });

    test('a claim abandoned by a dead engine is picked up again', () async {
      await db
          .update(db.teamsDeliveries)
          .write(
            TeamsDeliveriesCompanion(
              status: const Value(DeliveryStatus.sending),
              lastAttemptAt: Value(
                DateTime.now().subtract(const Duration(minutes: 3)),
              ),
            ),
          );
      await sender(() async => http.Response('', 202)).flush();
      expect((await deliveries()).single.status, DeliveryStatus.sent);
    });

    test('errors never record the webhook URL', () async {
      await sender(
        () async => throw http.ClientException('failed: $_url'),
      ).flush();
      expect((await deliveries()).single.lastError, isNot(contains('secret')));
    });
  });

  group('break alarm timing (FR-11.3, FR-11.5)', () {
    Future<BreakType> configuredType(BreakTypesCompanion values) async {
      final id = await teaBreak();
      await breakTypes.update(id, values);
      return (await breakTypes.find(id))!;
    }

    Activity breakAt(DateTime start, int typeId) => Activity(
      id: 7,
      kind: ActivityKind.breakActivity,
      breakTypeId: typeId,
      startTime: start,
      dayKey: dayKeyFor(start),
    );

    final start = DateTime(2026, 1, 1, 10);

    test('off by default', () async {
      final type = (await breakTypes.watchActive().first).first;
      expect(type.alarmEnabled, isFalse);
      expect(breakAlerts(breakAt(start, type.id), type), isEmpty);
    });

    test('once fires at the expected duration', () async {
      final type = await configuredType(
        const BreakTypesCompanion(
          alarmEnabled: Value(true),
          expectedDurationMinutes: Value(20),
        ),
      );
      final alerts = breakAlerts(breakAt(start, type.id), type);
      expect(alerts.map((a) => a.time), [DateTime(2026, 1, 1, 10, 20)]);
      expect(alerts.single.title, '${type.name} is over');
    });

    test('repeat fires at each interval, within a limit', () async {
      final type = await configuredType(
        const BreakTypesCompanion(
          alarmEnabled: Value(true),
          expectedDurationMinutes: Value(10),
          reminderBehaviour: Value(ReminderBehaviour.repeat),
          repeatIntervalMinutes: Value(5),
        ),
      );
      final times = breakAlerts(
        breakAt(start, type.id),
        type,
      ).map((a) => a.time).toList();
      expect(times.take(3), [
        DateTime(2026, 1, 1, 10, 10),
        DateTime(2026, 1, 1, 10, 15),
        DateTime(2026, 1, 1, 10, 20),
      ]);
      expect(times, hasLength(13));
    });

    test('alarms ring at set times during a 1-hour break, then at its end', () async {
      final type = await configuredType(
        const BreakTypesCompanion(
          alarmEnabled: Value(true),
          expectedDurationMinutes: Value(60),
          midBreakAlarmMinutes: Value('15,5,10'),
        ),
      );
      final alerts = breakAlerts(breakAt(start, type.id), type);
      expect(alerts.map((a) => a.time), [
        DateTime(2026, 1, 1, 10, 5),
        DateTime(2026, 1, 1, 10, 10),
        DateTime(2026, 1, 1, 10, 15),
        DateTime(2026, 1, 1, 11),
      ]);
      expect(alerts.first.title, '5m into ${type.name}');
      expect(alerts.first.body, '55m left of your 1h break.');
      expect(alerts.last.title, '${type.name} is over');
    });

    test('alarms past the break length are skipped', () async {
      final type = await configuredType(
        const BreakTypesCompanion(
          alarmEnabled: Value(true),
          expectedDurationMinutes: Value(10),
          midBreakAlarmMinutes: Value('5,10,30'),
        ),
      );
      expect(breakAlerts(breakAt(start, type.id), type).map((a) => a.time), [
        DateTime(2026, 1, 1, 10, 5),
        DateTime(2026, 1, 1, 10, 10),
      ]);
    });

    test('alarm times are cleaned up when read', () {
      expect(parseMidBreakAlarms(''), isEmpty);
      expect(parseMidBreakAlarms('15, 5,x,0,5'), [5, 15]);
      expect(encodeMidBreakAlarms([5, 10]), '5,10');
    });

    test('a break can never need more ids than cancellation covers', () async {
      final type = await configuredType(
        BreakTypesCompanion(
          alarmEnabled: const Value(true),
          expectedDurationMinutes: const Value(600),
          reminderBehaviour: const Value(ReminderBehaviour.repeat),
          midBreakAlarmMinutes: Value(
            encodeMidBreakAlarms(List.generate(30, (i) => i + 1)),
          ),
        ),
      );
      expect(
        breakAlerts(breakAt(start, type.id), type).length,
        lessThanOrEqualTo(maxBreakAlerts),
      );
    });
  });

  group('break type deletion (NFR-6)', () {
    test('an unused type is removed along with its Teams settings', () async {
      final id = await teaBreak();
      await teams.saveConfig(
        trigger: TeamsTrigger.breakStart,
        breakTypeId: id,
        enabled: true,
        template: 'x',
      );
      expect(await breakTypes.delete(id), isFalse);
      expect(await breakTypes.find(id), isNull);
      expect(await db.select(db.teamsTriggerConfigs).get(), isEmpty);
    });

    test('a used type is archived, and its automation is disabled', () async {
      final id = await teaBreak();
      await teams.saveConfig(
        trigger: TeamsTrigger.breakStart,
        breakTypeId: id,
        enabled: true,
        template: 'x',
      );
      await engine.startWork();
      await engine.startBreak(id);

      expect(await breakTypes.delete(id), isTrue);
      expect((await breakTypes.find(id))!.isActive, isFalse);
      final config = await db.select(db.teamsTriggerConfigs).getSingle();
      expect(config.enabled, isFalse);
    });

    test('names are unique, ignoring case and spaces', () async {
      expect(await breakTypes.isNameTaken(' tea break '), isTrue);
      expect(await breakTypes.isNameTaken('Walk'), isFalse);
      final id = await teaBreak();
      expect(await breakTypes.isNameTaken('Tea Break', exceptId: id), isFalse);
    });
  });

  group('notification buttons (FR-12.4)', () {
    Activity open(ActivityKind kind) => Activity(
      id: 1,
      kind: kind,
      startTime: DateTime(2026),
      dayKey: '2026-01-01',
    );

    test('working offers the first two break types and End', () async {
      final types = await breakTypes.watchActive().first;
      final buttons = trackingButtons(
        open: open(ActivityKind.work),
        activeBreakTypes: types,
      );
      expect(buttons.map((b) => b.label), [
        'Tea Break',
        'Lunch Break',
        'End work',
      ]);
      expect(breakTypeIdFromButton(buttons.first.id), types.first.id);
      expect(breakTypeIdFromButton(buttons.last.id), isNull);
    });

    test('on break offers Resume and End', () {
      final buttons = trackingButtons(
        open: open(ActivityKind.breakActivity),
        activeBreakTypes: const [],
      );
      expect(buttons.map((b) => b.id), [resumeButtonId, endButtonId]);
    });
  });

  test('single activities keep their seconds until they reach an hour', () {
    expect(formatElapsed(const Duration(seconds: 5)), '5s');
    expect(formatElapsed(const Duration(minutes: 1, seconds: 56)), '1m 56s');
    expect(formatElapsed(const Duration(hours: 1, minutes: 5)), '1h 5m');
  });

  group('template rendering', () {
    test('leaves unknown placeholders visible', () {
      expect(
        renderTeamsTemplate('{worked} {typo}', {'worked': '1h'}),
        '1h {typo}',
      );
    });

    test('webhook URLs must be https with a host', () {
      expect(isValidWebhookUrl(_url), isTrue);
      expect(isValidWebhookUrl('http://example.com'), isFalse);
      expect(isValidWebhookUrl('https://'), isFalse);
      expect(isValidWebhookUrl('nonsense'), isFalse);
      expect(isValidWebhookUrl(null), isFalse);
    });
  });
}
