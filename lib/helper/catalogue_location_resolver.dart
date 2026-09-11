import 'dart:math';

import 'package:carvy/helper/city_name_helper.dart';
import 'package:carvy/helper/mongo_id_helper.dart';
import 'package:carvy/model/vehicle_home_model.dart';

/// Maps free-text / GPS coordinates to a catalogue [Location] ObjectId.
class CatalogueLocationResolver {
  CatalogueLocationResolver._();

  static const double maxMatchKm = 50.0;

  static String? resolveId({
    required List<Location>? catalogue,
    String? cityName,
    double? latitude,
    double? longitude,
  }) {
    if (catalogue == null || catalogue.isEmpty) return null;

    final city = cityName?.trim() ?? '';
    if (city.isNotEmpty) {
      for (final loc in catalogue) {
        if (!CityNameHelper.citiesMatch(loc.cityName, city)) continue;
        final id = MongoIdHelper.normalize(loc.id);
        if (id != null) return id;
      }
    }

    if (latitude == null || longitude == null) return null;

    Location? nearest;
    var nearestKm = double.infinity;

    for (final loc in catalogue) {
      final id = MongoIdHelper.normalize(loc.id);
      if (id == null) continue;

      final lat = double.tryParse(loc.latitude ?? '');
      final lng = double.tryParse(loc.longitude ?? '');
      if (lat == null || lng == null) continue;

      final km = _haversineKm(latitude, longitude, lat, lng);
      if (km < nearestKm) {
        nearestKm = km;
        nearest = loc;
      }
    }

    if (nearest != null && nearestKm <= maxMatchKm) {
      return MongoIdHelper.normalize(nearest.id);
    }

    return null;
  }

  static double _haversineKm(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double deg) => deg * pi / 180.0;
}
