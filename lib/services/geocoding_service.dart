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
    this.name = '',
    this.suggestedLabel = 'Home',
  });

  final String fullAddress;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String subLocality;
  final String name;
  /// Libellé intelligent (Maison, Bureau, Aéroport, etc.).
  final String suggestedLabel;
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

    final name = (p.name ?? '').trim();
    return ResolvedAddress(
      fullAddress: fullAddress,
      street: streetLine.isNotEmpty ? streetLine : (p.street ?? '').trim(),
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      subLocality: subLocality,
      name: name,
      suggestedLabel: suggestAddressLabel('$name $fullAddress'),
    );
  }

  /// Déduit un libellé de lieu à partir du texte d'adresse / du nom du lieu.
  static String suggestAddressLabel(String context) {
    final lower = context.toLowerCase();
    if (_containsAny(lower, [
      'airport',
      'aéroport',
      'aeroport',
      'aeropuerto',
    ])) {
      return 'Airport';
    }
    if (_containsAny(lower, [
      'hotel',
      'hôtel',
      'motel',
      'resort',
      'hostel',
    ])) {
      return 'Hotel';
    }
    if (_containsAny(lower, [
      'office',
      'bureau',
      'business',
      'cowork',
      'co-working',
      'empresa',
    ])) {
      return 'Office';
    }
    if (_containsAny(lower, [
      'station',
      'gare',
      'train station',
      'railway',
    ])) {
      return 'Station';
    }
    if (_containsAny(lower, [
      'hospital',
      'hôpital',
      'hopital',
      'clinic',
      'clinique',
    ])) {
      return 'Hospital';
    }
    if (_containsAny(lower, [
      'mall',
      'shopping',
      'centre commercial',
      'centro comercial',
    ])) {
      return 'Shopping';
    }
    if (_containsAny(lower, [
      'university',
      'université',
      'universite',
      'campus',
      'school',
      'école',
      'ecole',
    ])) {
      return 'School';
    }
    return 'Home';
  }

  static bool _containsAny(String haystack, List<String> needles) {
    for (final n in needles) {
      if (haystack.contains(n)) return true;
    }
    return false;
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
