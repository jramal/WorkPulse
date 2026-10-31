import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:workmanager/workmanager.dart';

import '../data/database.dart';

const _retryTask = 'teams-delivery-retry';
const _maxServerAttempts = 8;
const _giveUpAfter = Duration(hours: 24);
const _offlineRetry = Duration(minutes: 5);
const _requestTimeout = Duration(seconds: 15);
const _staleClaim = Duration(minutes: 2);
const _keepLogFor = Duration(days: 30);

/// Retries queued messages once there's a network, even with the app closed
/// (TR-5).
@pragma('vm:entry-point')
void teamsRetryDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final db = AppDatabase();
    try {
      await TeamsSender(db).flush();
    } finally {
      await db.close();
    }
    return true;
  });
}

Future<void> _scheduleRetry(Duration delay) async {
  if (!Platform.isAndroid) return;
  await Workmanager().initialize(teamsRetryDispatcher);
  await Workmanager().registerOneOffTask(
    _retryTask,
    _retryTask,
    initialDelay: delay,
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}

enum _SendOutcome { sent, rejected, serverError, unreachable }

/// Sends queued messages over HTTPS. Several engines may run this at once, so
/// each message is claimed with a conditional update before it's sent.
class TeamsSender {
  TeamsSender(
    this._db, {
    http.Client? client,
    Future<void> Function(Duration delay) scheduleRetry = _scheduleRetry,
  }) : _client = client ?? http.Client(),
       _scheduleRetryFn = scheduleRetry;

  final AppDatabase _db;
  final http.Client _client;
  final Future<void> Function(Duration delay) _scheduleRetryFn;
  bool _flushing = false;

  Future<void> flush() async {
    if (_flushing) return;
    _flushing = true;
    try {
      await _releaseStaleClaims();
      final now = DateTime.now();
      final due = await (_db.select(_db.teamsDeliveries)
            ..where(
              (d) =>
                  d.status.equalsValue(DeliveryStatus.queued) &
                  d.nextAttemptAt.isSmallerOrEqualValue(now),
            )
            ..orderBy([
              (d) => OrderingTerm.asc(d.createdAt),
              (d) => OrderingTerm.asc(d.id),
            ]))
          .get();
      for (final delivery in due) {
        if (await _claim(delivery)) await _attempt(delivery);
      }
      await _pruneLog();
      await _scheduleNextRetry();
    } catch (error) {
      debugPrint('Teams delivery pass failed: $error');
    } finally {
      _flushing = false;
    }
  }

  /// Returns an error description, or null if Teams accepted the message.
  Future<String?> sendTest(String url) async {
    try {
      final outcome = await _post(
        url,
        'WorkPulse test message: this webhook is working.',
      );
      return outcome == _SendOutcome.sent ? null : _lastError;
    } catch (error) {
      return error.toString();
    }
  }

  String? _lastError;

  Future<void> _releaseStaleClaims() {
    // A claim this old means the engine that made it died mid-send.
    final cutoff = DateTime.now().subtract(_staleClaim);
    return (_db.update(_db.teamsDeliveries)..where(
          (d) =>
              d.status.equalsValue(DeliveryStatus.sending) &
              d.lastAttemptAt.isSmallerThanValue(cutoff),
        ))
        .write(
          const TeamsDeliveriesCompanion(
            status: Value(DeliveryStatus.queued),
          ),
        );
  }

  Future<bool> _claim(TeamsDelivery delivery) async {
    final claimed =
        await (_db.update(_db.teamsDeliveries)..where(
              (d) =>
                  d.id.equals(delivery.id) &
                  d.status.equalsValue(DeliveryStatus.queued),
            ))
            .write(
              TeamsDeliveriesCompanion(
                status: const Value(DeliveryStatus.sending),
                lastAttemptAt: Value(DateTime.now()),
              ),
            );
    return claimed == 1;
  }

  Future<void> _attempt(TeamsDelivery delivery) async {
    final outcome = await _post(delivery.destination, delivery.message);
    final now = DateTime.now();
    final attempts = delivery.attempts + 1;
    final expired = now.difference(delivery.createdAt) >= _giveUpAfter;

    final DeliveryStatus status;
    var nextAttempt = now;
    switch (outcome) {
      case _SendOutcome.sent:
        status = DeliveryStatus.sent;
      case _SendOutcome.rejected:
        status = DeliveryStatus.failed;
      case _SendOutcome.serverError:
        final gaveUp = attempts >= _maxServerAttempts || expired;
        status = gaveUp ? DeliveryStatus.failed : DeliveryStatus.queued;
        nextAttempt = now.add(Duration(minutes: _backoffMinutes(attempts)));
      case _SendOutcome.unreachable:
        // Being offline says nothing about the message, so it only gives up
        // once it's too old to still be useful.
        status = expired ? DeliveryStatus.failed : DeliveryStatus.queued;
        nextAttempt = now.add(_offlineRetry);
    }

    await (_db.update(
      _db.teamsDeliveries,
    )..where((d) => d.id.equals(delivery.id))).write(
      TeamsDeliveriesCompanion(
        status: Value(status),
        attempts: Value(outcome == _SendOutcome.unreachable
            ? delivery.attempts
            : attempts),
        nextAttemptAt: Value(nextAttempt),
        lastError: Value(outcome == _SendOutcome.sent ? null : _lastError),
      ),
    );
  }

  int _backoffMinutes(int attempts) {
    final minutes = 1 << attempts;
    return minutes > 60 ? 60 : minutes;
  }

  // Errors record only the status or failure type: the webhook URL contains a
  // signature and mustn't be copied into the log (TR-9).
  Future<_SendOutcome> _post(String url, String message) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(_adaptiveCard(message)),
          )
          .timeout(_requestTimeout);
      final code = response.statusCode;
      _lastError = 'HTTP $code';
      if (code >= 200 && code < 300) {
        _lastError = null;
        return _SendOutcome.sent;
      }
      final retryable = code >= 500 || code == 408 || code == 429;
      return retryable ? _SendOutcome.serverError : _SendOutcome.rejected;
    } on TimeoutException {
      _lastError = 'Timed out';
      return _SendOutcome.unreachable;
    } on SocketException {
      _lastError = 'No connection';
      return _SendOutcome.unreachable;
    } on http.ClientException {
      _lastError = 'No connection';
      return _SendOutcome.unreachable;
    } on FormatException {
      _lastError = 'Invalid webhook URL';
      return _SendOutcome.rejected;
    }
  }

  // The format Teams' "Post to a channel when a webhook request is received"
  // workflow expects.
  Map<String, Object?> _adaptiveCard(String message) => {
    'type': 'message',
    'attachments': [
      {
        'contentType': 'application/vnd.microsoft.card.adaptive',
        'contentUrl': null,
        'content': {
          r'$schema': 'http://adaptivecards.io/schemas/adaptive-card.json',
          'type': 'AdaptiveCard',
          'version': '1.2',
          'body': [
            {'type': 'TextBlock', 'text': message, 'wrap': true},
          ],
        },
      },
    ],
  };

  Future<void> _pruneLog() {
    final cutoff = DateTime.now().subtract(_keepLogFor);
    return (_db.delete(_db.teamsDeliveries)..where(
          (d) =>
              d.status.isNotInValues([
                DeliveryStatus.queued,
                DeliveryStatus.sending,
              ]) &
              d.createdAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }

  Future<void> _scheduleNextRetry() async {
    final next = await (_db.select(_db.teamsDeliveries)
          ..where((d) => d.status.equalsValue(DeliveryStatus.queued))
          ..orderBy([(d) => OrderingTerm.asc(d.nextAttemptAt)])
          ..limit(1))
        .getSingleOrNull();
    if (next == null) return;
    final delay = next.nextAttemptAt.difference(DateTime.now());
    await _scheduleRetryFn(delay.isNegative ? Duration.zero : delay);
  }
}
