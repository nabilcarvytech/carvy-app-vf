import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';

/// Adresse postale résolue depuis des coordonnées GPS.
class ResolvedAddress {
  const ResolvedAddress({
    required this.fullAddress,
    this.street = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.postalCode = '',
    this.subLocality = '',
  });

  final String fullAddress;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String subLocality;
}

/// Reverse geocoding via le package [geocoding] (pas d'adresse codée en dur).
class GeocodingService {
  GeocodingService._();

  static Future<ResolvedAddress?> reverseGeocode(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isEmpty) return null;
      return _fromPlacemark(placemarks.first);
    } catch (e, st) {
      debugPrint('GeocodingService.reverseGeocode: $e\n$st');
      return null;
    }
  }

  static ResolvedAddress _fromPlacemark(Placemark p) {
    final streetParts = <String>[
      if ((p.subThoroughfare ?? '').trim().isNotEmpty) p.subThoroughfare!.trim(),
      if ((p.thoroughfare ?? '').trim().isNotEmpty) p.thoroughfare!.trim(),
    ];
    var streetLine = streetParts.join(' ').trim();
    if (streetLine.isEmpty && (p.street ?? '').trim().isNotEmpty) {
      streetLine = p.street!.trim();
    }

    final city = _firstNonEmpty([
      p.locality,
      p.subAdministrativeArea,
      p.administrativeArea,
    ]);
    final state = (p.administrativeArea ?? '').trim();
    final country = (p.country ?? '').trim();
    final postalCode = (p.postalCode ?? '').trim();
    final subLocality = (p.subLocality ?? '').trim();

    final fullAddress = _buildFullAddress(
      street: streetLine.isNotEmpty ? streetLine : (p.street ?? '').trim(),
      subLocality: subLocality,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
    );

    return ResolvedAddress(
      fullAddress: fullAddress,
      street: streetLine.isNotEmpty ? streetLine : (p.street ?? '').trim(),
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      subLocality: subLocality,
    );
  }

  static String _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return '';
  }

  static String _buildFullAddress({
    required String street,
    required String subLocality,
    required String city,
    required String state,
    required String postalCode,
    required String country,
  }) {
    final parts = <String>[
      if (street.isNotEmpty) street,
      if (subLocality.isNotEmpty && subLocality != city) subLocality,
      if (city.isNotEmpty) city,
      if (state.isNotEmpty && state != city) state,
      if (postalCode.isNotEmpty) postalCode,
      if (country.isNotEmpty) country,
    ];
    return parts.join(', ');
  }
}
