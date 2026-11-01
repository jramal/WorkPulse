import 'dart:async';

import 'package:flutter/material.dart';

import 'app_services.dart';
import 'background/tracking_service.dart';
import 'theme/app_theme.dart';
import 'ui/app_shell.dart';

class WorkPulseApp extends StatefulWidget {
  const WorkPulseApp({super.key, this.services});

  /// Overridable for tests, so each test gets its own (in-memory) database
  /// instead of racing on the same on-disk file.
  final AppServices? services;

  @override
  State<WorkPulseApp> createState() => _WorkPulseAppState();
}

class _WorkPulseAppState extends State<WorkPulseApp> {
  late final AppServices _services = widget.services ?? AppServices();
  late final TrackingServiceController _trackingService =
      TrackingServiceController(_services);
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _trackingService.start();
    unawaited(_services.taskActions.syncGeofences());
    // Coming back from Android settings is how location permission arrives.
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(_services.taskActions.syncGeofences()),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _trackingService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppServicesScope(
      services: _services,
      child: MaterialApp(
        title: 'WorkPulse',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        home: const AppShell(),
      ),
    );
  }
}
