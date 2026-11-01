import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/task_rules.dart';
import '../../theme/app_theme.dart';

class PickedLocation {
  const PickedLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  final String name;
  final double latitude;
  final double longitude;
  final int radiusMeters;
}

/// Pan the map under the fixed pin to choose a place, and see the alert area.
class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key, this.initial});

  final PickedLocation? initial;

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  static const _fallbackCenter = LatLng(20.59, 78.96);

  final MapController _map = MapController();
  late final TextEditingController _name = TextEditingController(
    text: widget.initial?.name ?? '',
  );
  late LatLng _center = widget.initial == null
      ? _fallbackCenter
      : LatLng(widget.initial!.latitude, widget.initial!.longitude);
  late int _radius = widget.initial?.radiusMeters ?? defaultRadiusMeters;
  bool _locating = false;
  String? _nameError;

  @override
  void initState() {
    super.initState();
    if (widget.initial == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _goToCurrent());
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _map.dispose();
    super.dispose();
  }

  /// A zoom that keeps the whole alert circle on screen.
  double _zoomFor(int radius, double latitude) {
    const metersPerPixelAtZoom0 = 156543.0;
    const circlePixels = 110.0;
    final scale = math.cos(latitude * math.pi / 180) * metersPerPixelAtZoom0;
    return math.log(scale * circlePixels / radius) / math.ln2;
  }

  Future<void> _goToCurrent() async {
    setState(() => _locating = true);
    try {
      if (!await Permission.locationWhenInUse.request().isGranted) {
        _showMessage('Allow location access to use your current location.');
        return;
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      if (!mounted) return;
      final here = LatLng(position.latitude, position.longitude);
      setState(() => _center = here);
      _map.move(here, _zoomFor(_radius, here.latitude));
    } catch (_) {
      _showMessage('Could not get your location. Check that Location is on.');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _setRadius(int meters) {
    setState(() => _radius = meters);
    _map.move(_center, _zoomFor(meters, _center.latitude));
  }

  Future<void> _customRadius() async {
    final meters = await showDialog<int>(
      context: context,
      builder: (_) => _CustomRadiusDialog(current: _radius),
    );
    if (meters != null) _setRadius(meters);
  }

  void _confirm() {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = 'Name this place');
      return;
    }
    Navigator.of(context).pop(
      PickedLocation(
        name: name,
        latitude: _center.latitude,
        longitude: _center.longitude,
        radiusMeters: _radius,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final isCustom = !radiusChoicesMeters.contains(_radius);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose location'),
        actions: [
          TextButton(
            key: const Key('confirm-location-button'),
            onPressed: _confirm,
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                FlutterMap(
                  mapController: _map,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: widget.initial == null
                        ? 4
                        : _zoomFor(_radius, _center.latitude),
                    onPositionChanged: (camera, _) {
                      setState(() => _center = camera.center);
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.akhiljr.workpulse',
                    ),
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: _center,
                          radius: _radius.toDouble(),
                          useRadiusInMeter: true,
                          color: accent.withValues(alpha: 0.18),
                          borderColor: accent,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                    const SimpleAttributionWidget(
                      source: Text('OpenStreetMap contributors'),
                    ),
                  ],
                ),
                // Lifted so the pin's tip, not its middle, marks the centre.
                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.place_rounded, size: 40, color: accent),
                  ),
                ),
                Positioned(
                  right: AppSpacing.md,
                  top: AppSpacing.md,
                  child: FloatingActionButton.small(
                    heroTag: null,
                    tooltip: 'Use my current location',
                    onPressed: _locating ? null : _goToCurrent,
                    child: _locating
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    key: const Key('location-name'),
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Place name',
                      errorText: _nameError,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Alert me within',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.sm,
                    children: [
                      for (final meters in radiusChoicesMeters)
                        ChoiceChip(
                          label: Text(formatRadius(meters)),
                          selected: _radius == meters,
                          onSelected: (_) => _setRadius(meters),
                        ),
                      ChoiceChip(
                        key: const Key('custom-radius-chip'),
                        label: Text(
                          isCustom ? formatRadius(_radius) : 'Custom',
                        ),
                        selected: isCustom,
                        onSelected: (_) => _customRadius(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomRadiusDialog extends StatefulWidget {
  const _CustomRadiusDialog({required this.current});

  final int current;

  @override
  State<_CustomRadiusDialog> createState() => _CustomRadiusDialogState();
}

class _CustomRadiusDialogState extends State<_CustomRadiusDialog> {
  late final TextEditingController _km = TextEditingController(
    text: (widget.current / 1000).toString(),
  );
  String? _error;

  @override
  void dispose() {
    _km.dispose();
    super.dispose();
  }

  void _save() {
    final meters = parseRadiusKm(_km.text);
    if (meters == null) {
      setState(() {
        _error =
            'Enter ${minRadiusMeters / 1000} to ${maxRadiusMeters ~/ 1000} km';
      });
      return;
    }
    Navigator.of(context).pop(meters);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Custom radius'),
      content: TextField(
        key: const Key('custom-radius-km'),
        controller: _km,
        autofocus: true,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: 'Kilometres', errorText: _error),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
