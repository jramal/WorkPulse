import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'app.dart';

void main() {
  FlutterForegroundTask.initCommunicationPort();
  runApp(const WorkPulseApp());
}
