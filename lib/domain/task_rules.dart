import 'dart:convert';

import '../data/database.dart';

const defaultRadiusMeters = 1000;
const radiusChoicesMeters = [200, 500, 1000, 2000, 5000];

/// Android recommends at least 100 m, as location is rarely more accurate.
const minRadiusMeters = 100;
const maxRadiusMeters = 50000;

/// Android's limit per app.
const maxActiveGeofences = 100;

/// "500 m", "1 km" or "1.5 km".
String formatRadius(int meters) {
  if (meters < 1000) return '$meters m';
  final km = meters / 1000;
  return km == km.roundToDouble()
      ? '${km.round()} km'
      : '${km.toStringAsFixed(1)} km';
}

/// Metres from a custom value typed in kilometres; null if it isn't usable.
int? parseRadiusKm(String text) {
  final km = double.tryParse(text.trim());
  if (km == null) return null;
  final meters = (km * 1000).round();
  if (meters < minRadiusMeters || meters > maxRadiusMeters) return null;
  return meters;
}

bool hasLocation(Task task) =>
    task.latitude != null &&
    task.longitude != null &&
    task.radiusMeters != null;

/// A finished task, or one whose time has passed, has nothing left to alert.
bool needsDateAlert(Task task, DateTime now) {
  final due = task.dueAt;
  return !task.isDone && due != null && due.isAfter(now);
}

/// The areas to watch, as sent to Android. Newest tasks win if there are more
/// than Android allows.
String geofencesJson(List<Task> tasks) {
  final active = tasks.where((t) => !t.isDone && hasLocation(t)).toList()
    ..sort((a, b) => b.id.compareTo(a.id));
  return jsonEncode([
    for (final task in active.take(maxActiveGeofences))
      {
        'id': task.id,
        'title': task.title,
        'message': _arrivalMessage(task),
        'latitude': task.latitude,
        'longitude': task.longitude,
        'radiusMeters': task.radiusMeters,
      },
  ]);
}

String _arrivalMessage(Task task) {
  final distance = formatRadius(task.radiusMeters!);
  final place = task.locationName;
  return place == null || place.isEmpty
      ? 'You are within $distance of this task.'
      : 'You are within $distance of $place.';
}
