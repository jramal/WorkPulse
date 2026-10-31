import 'package:flutter/widgets.dart';

import 'background/break_alarms.dart';
import 'background/teams_delivery.dart';
import 'background/tracking_actions.dart';
import 'data/database.dart';
import 'domain/break_type_repository.dart';
import 'domain/teams_repository.dart';
import 'domain/tracking_engine.dart';

/// Bundles the app's singletons, built on one database connection. The
/// background service builds its own set in its own engine.
class AppServices {
  AppServices._(this.database, this.tracking, this.breakTypes, this.teamsSender)
    : teams = TeamsRepository(database),
      actions = TrackingActions(
        engine: tracking,
        breakTypes: breakTypes,
        alarms: BreakAlarmScheduler(),
        teams: teamsSender,
      );

  factory AppServices({AppDatabase? database}) {
    final db = database ?? AppDatabase();
    return AppServices._(
      db,
      TrackingEngine(db),
      BreakTypeRepository(db),
      TeamsSender(db),
    );
  }

  final AppDatabase database;
  final TrackingEngine tracking;
  final BreakTypeRepository breakTypes;
  final TeamsRepository teams;
  final TeamsSender teamsSender;
  final TrackingActions actions;
}

class AppServicesScope extends InheritedWidget {
  const AppServicesScope({
    super.key,
    required this.services,
    required super.child,
  });

  final AppServices services;

  static AppServices of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppServicesScope>();
    assert(scope != null, 'No AppServicesScope found in context');
    return scope!.services;
  }

  @override
  bool updateShouldNotify(AppServicesScope oldWidget) =>
      services != oldWidget.services;
}
