import 'dart:math' as math;

import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Masque l'emplacement exact des véhicules / agences sur la carte.
class MapPrivacyHelper {
  MapPrivacyHelper._();

  /// Zoom max carte véhicules : quartier approximatif, pas la rue.
  static const double vehicleMapMaxZoom = 12.5;
  static const double vehicleMapInitialZoom = 12.0;

  static const double minOffsetMeters = 400;
  static const double maxOffsetMeters = 1200;
  static const double approximateZoneRadiusMeters = 800;

  /// Décalage stable (même véhicule → même position affichée).
  static LatLng obfuscateCoordinates(
    double latitude,
    double longitude,
    String seed,
  ) {
    final rnd = math.Random(seed.hashCode);
    final distanceMeters =
        minOffsetMeters + rnd.nextDouble() * (maxOffsetMeters - minOffsetMeters);
    final bearingDegrees = rnd.nextDouble() * 360;
    return _offsetCoordinate(
      latitude,
      longitude,
      distanceMeters,
      bearingDegrees,
    );
  }

  /// Libellé flou (ville / région), jamais l'adresse rue complète.
  static String approximateAddressLabel(dynamic item) {
    String read(String Function() getter) {
      try {
        final v = getter().trim();
        if (v.isEmpty || v.toLowerCase() == 'null') return '';
        return v;
      } catch (_) {
        return '';
      }
    }

    final city = read(() => '${item.city ?? ''}');
    final state = read(() {
      try {
        final region = '${item.stateRegion ?? ''}';
        if (region.isNotEmpty && region.toLowerCase() != 'null') return region;
      } catch (_) {}
      return '${item.state ?? ''}';
    });
    final country = read(() => '${item.country ?? ''}');

    final parts = <String>[
      if (city.isNotEmpty) city,
      if (state.isNotEmpty && state != city) state,
      if (country.isNotEmpty) country,
    ];
    if (parts.isNotEmpty) return parts.join(', ');
    return 'Approximate area';
  }

  static LatLngBounds boundsForPoints(
    Iterable<LatLng> points, {
    double paddingDegrees = 0.01,
  }) {
    final list = points.toList(growable: false);
    if (list.isEmpty) {
      return LatLngBounds(
        southwest: const LatLng(0, 0),
        northeast: const LatLng(0, 0),
      );
    }

    var minLat = list.first.latitude;
    var maxLat = list.first.latitude;
    var minLng = list.first.longitude;
    var maxLng = list.first.longitude;

    for (final point in list.skip(1)) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return LatLngBounds(
      southwest: LatLng(minLat - paddingDegrees, minLng - paddingDegrees),
      northeast: LatLng(maxLat + paddingDegrees, maxLng + paddingDegrees),
    );
  }

  static LatLng _offsetCoordinate(
    double latitude,
    double longitude,
    double distanceMeters,
    double bearingDegrees,
  ) {
    const earthRadius = 6378137.0;
    final bearing = bearingDegrees * math.pi / 180;
    final latRad = latitude * math.pi / 180;
    final lngRad = longitude * math.pi / 180;
    final angularDistance = distanceMeters / earthRadius;

    final newLatRad = math.asin(
      math.sin(latRad) * math.cos(angularDistance) +
          math.cos(latRad) *
              math.sin(angularDistance) *
              math.cos(bearing),
    );
    final newLngRad = lngRad +
        math.atan2(
          math.sin(bearing) * math.sin(angularDistance) * math.cos(latRad),
          math.cos(angularDistance) - math.sin(latRad) * math.sin(newLatRad),
        );

    return LatLng(
      newLatRad * 180 / math.pi,
      newLngRad * 180 / math.pi,
    );
  }
}
