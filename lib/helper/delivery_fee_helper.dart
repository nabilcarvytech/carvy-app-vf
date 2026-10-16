import 'package:carvy/helper/city_name_helper.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:get_storage/get_storage.dart';

/// Zone de livraison d'un véhicule (`location` + `price`).
class DeliveryZoneOption {
  const DeliveryZoneOption({
    required this.key,
    required this.cityLabel,
    required this.price,
    this.matchLabel = '',
  });

  final String key;
  final String cityLabel;
  final double price;
  final String matchLabel;

  bool get isFree => price <= 0;

  String get matchingText {
    final raw = matchLabel.trim();
    return raw.isNotEmpty ? raw : cityLabel;
  }
}

/// Matching ville client ↔ `deliveryLocations` du véhicule.
class DeliveryFeeHelper {
  DeliveryFeeHelper._();

  static const String pickupKey = '';

  static List<dynamic> rawLocationsFromItem(ItemInfo? item) {
    if (item == null) return const [];
    final locs = item.deliveryLocations;
    if (locs is List && locs.isNotEmpty) return locs;
    return const [];
  }

  static List<DeliveryZoneOption> parseZones(dynamic deliveryLocations) {
    if (deliveryLocations is! List) return const [];
    final out = <DeliveryZoneOption>[];
    for (var i = 0; i < deliveryLocations.length; i++) {
      final item = deliveryLocations[i];
      Map<String, dynamic> map;
      if (item is Map) {
        map = Map<String, dynamic>.from(item);
      } else if (item is String && item.trim().isNotEmpty) {
        map = <String, dynamic>{'location': item.trim()};
      } else {
        continue;
      }
      final rawName = _rawCityName(map);
      final label = CityNameHelper.deliveryLocationLabel(map);
      if (label == '-' && _locationId(map).isEmpty && rawName.isEmpty) {
        continue;
      }
      final cityLabel = (label == '-' || label.trim().isEmpty)
          ? (rawName.isNotEmpty ? rawName : _locationId(map))
          : label;
      final key = _locationId(map).isNotEmpty
          ? _locationId(map)
          : 'zone_$i:${CityNameHelper.canonicalMatchToken(cityLabel)}';
      out.add(
        DeliveryZoneOption(
          key: key,
          cityLabel: cityLabel,
          matchLabel: rawName.isNotEmpty ? rawName : cityLabel,
          price: parsePrice(map),
        ),
      );
    }
    return out;
  }

  static double parsePrice(Map<String, dynamic> loc) {
    if (loc['isFreeDelivery'] == true) return 0;
    final raw = loc['price'];
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '') ?? 0;
  }

  static String _locationId(Map<String, dynamic> loc) {
    final location = loc['location'];
    if (location is String && location.trim().isNotEmpty) {
      return location.trim();
    }
    if (location is Map) {
      final id = location['_id'] ?? location['id'];
      if (id != null && id.toString().trim().isNotEmpty) {
        return id.toString().trim();
      }
    }
    final locationId = loc['locationId']?.toString().trim() ?? '';
    return locationId;
  }

  static String _rawCityName(Map<String, dynamic> loc) {
    final location = loc['location'];
    final candidates = <String?>[
      loc['locationName']?.toString(),
      loc['cityName']?.toString(),
      loc['city_name']?.toString(),
      loc['name']?.toString(),
      loc['city']?.toString(),
      if (location is Map)
        location['cityName']?.toString() ??
            location['city_name']?.toString() ??
            location['name']?.toString() ??
            location['cityNameFr']?.toString(),
    ];
    for (final c in candidates) {
      final cleaned = sanitizeCity(c);
      if (cleaned.isNotEmpty && !_looksLikeObjectId(cleaned)) return cleaned;
    }
    return '';
  }

  static bool _looksLikeObjectId(String value) =>
      RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(value.trim());

  /// Enlève BOM / espaces insécables / marques bidi, puis trim.
  static String sanitizeCity(String? raw) {
    if (raw == null) return '';
    return raw
        .replaceAll('\u00A0', ' ')
        .replaceAll(RegExp(r'[\u200B-\u200F\u202A-\u202E\u2060\u2066-\u2069\uFEFF]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _normalizeCity(String? raw) =>
      sanitizeCity(raw).toLowerCase();

  static bool _citiesEqual(String? a, String? b) {
    final na = _normalizeCity(a);
    final nb = _normalizeCity(b);
    if (na.isEmpty || nb.isEmpty) return false;
    if (na == nb) return true;
    if (CityNameHelper.citiesMatch(sanitizeCity(a), sanitizeCity(b))) {
      return true;
    }
    final ta = CityNameHelper.canonicalMatchToken(sanitizeCity(a));
    final tb = CityNameHelper.canonicalMatchToken(sanitizeCity(b));
    return ta.isNotEmpty && tb.isNotEmpty && ta == tb;
  }

  static String catalogueNameForId(String id, List<dynamic> catalogue) {
    final needle = id.trim().toLowerCase();
    if (needle.isEmpty) return '';
    for (final loc in catalogue) {
      var locId = '';
      var name = '';
      if (loc is Map) {
        locId = (loc['_id'] ?? loc['id'] ?? loc['locationId'] ?? '')
            .toString();
        name = (loc['cityName'] ??
                loc['city_name'] ??
                loc['name'] ??
                loc['title'] ??
                '')
            .toString();
      } else {
        try {
          locId = (loc.id ?? '').toString();
          name = (loc.cityName ?? loc.name ?? '').toString();
        } catch (_) {}
      }
      if (locId.trim().toLowerCase() == needle) {
        return sanitizeCity(name);
      }
    }
    return '';
  }

  static DeliveryZoneOption? matchZone(
    List<DeliveryZoneOption> zones,
    String? userCity, {
    List<dynamic> catalogue = const [],
  }) {
    final city = sanitizeCity(userCity);
    if (city.isEmpty || zones.isEmpty) return null;
    for (final zone in zones) {
      final catName = catalogueNameForId(zone.key, catalogue);
      if (_citiesEqual(zone.matchingText, city) ||
          _citiesEqual(zone.cityLabel, city) ||
          (catName.isNotEmpty && _citiesEqual(catName, city))) {
        return zone;
      }
    }
    if (catalogue.isNotEmpty) {
      for (final loc in catalogue) {
        var locId = '';
        var name = '';
        if (loc is Map) {
          locId = (loc['_id'] ?? loc['id'] ?? '').toString();
          name = (loc['cityName'] ?? loc['city_name'] ?? loc['name'] ?? '')
              .toString();
        }
        if (locId.isEmpty || !_citiesEqual(name, city)) continue;
        for (final zone in zones) {
          if (zone.key.trim().toLowerCase() == locId.trim().toLowerCase()) {
            return zone;
          }
        }
      }
    }
    return null;
  }

  /// Champ `city` brut uniquement — pas d'inférence depuis l'adresse.
  static String cityFromAddressFields({
    String? city,
    String? fullAddress,
  }) {
    return sanitizeCity(city);
  }

  static Map<String, dynamic>? _storedDoorStepMap() {
    try {
      final raw = GetStorage().read('customerAddress');
      if (raw is! Map) return null;
      final map = Map<String, dynamic>.from(raw);
      final data = map['data'];
      if (data is Map) {
        final nested = data['door_step_address'] ?? data['doorStepAddress'];
        if (nested is Map) {
          return Map<String, dynamic>.from(nested);
        }
      }
      final top = map['door_step_address'] ?? map['doorStepAddress'];
      if (top is Map) return Map<String, dynamic>.from(top);
    } catch (_) {}
    return null;
  }

  static String cityFromStoredCustomerAddress() {
    final door = _storedDoorStepMap();
    if (door == null) return '';
    final fromField = cityFromAddressFields(
      city: door['city']?.toString() ?? door['cityName']?.toString(),
    );
    if (fromField.isNotEmpty) return fromField;
    final full =
        (door['full_address'] ?? door['fullAddress'])?.toString() ?? '';
    final token = CityNameHelper.extractKnownCityToken(full);
    if (token != null && token.isNotEmpty) return token;
    return CityNameHelper.extractCityDisplayName(full);
  }

  static String fullAddressFromStoredCustomerAddress() {
    final door = _storedDoorStepMap();
    if (door == null) return '';
    final full = (door['full_address'] ?? door['fullAddress'])?.toString().trim() ??
        '';
    if (full.isNotEmpty) return full;
    return cityFromStoredCustomerAddress();
  }
}
