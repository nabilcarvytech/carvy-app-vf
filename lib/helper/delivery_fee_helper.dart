import 'package:carvy/helper/city_name_helper.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:get_storage/get_storage.dart';

/// Zone de livraison d'un véhicule (`location` + `price`).
class DeliveryZoneOption {
  const DeliveryZoneOption({
    required this.key,
    required this.cityLabel,
    required this.price,
  });

  final String key;
  final String cityLabel;
  final double price;

  bool get isFree => price <= 0;
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
      if (item is! Map) continue;
      final map = Map<String, dynamic>.from(item);
      final label = CityNameHelper.deliveryLocationLabel(map);
      if (label == '-' && _locationId(map).isEmpty) continue;
      final cityLabel = label == '-' ? _locationId(map) : label;
      final key = _locationId(map).isNotEmpty
          ? _locationId(map)
          : 'zone_$i:${CityNameHelper.canonicalMatchToken(cityLabel)}';
      out.add(
        DeliveryZoneOption(
          key: key,
          cityLabel: cityLabel,
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

  static String _normalizeCity(String? raw) =>
      (raw ?? '').trim().toLowerCase();

  static DeliveryZoneOption? matchZone(
    List<DeliveryZoneOption> zones,
    String? userCity,
  ) {
    final city = _normalizeCity(userCity);
    if (city.isEmpty || zones.isEmpty) return null;
    for (final zone in zones) {
      if (_normalizeCity(zone.cityLabel) == city) {
        return zone;
      }
    }
    return null;
  }

  /// Champ `city` brut uniquement — pas d'inférence depuis l'adresse.
  static String cityFromAddressFields({
    String? city,
    String? fullAddress,
  }) {
    return (city ?? '').trim();
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
    return cityFromAddressFields(
      city: door['city']?.toString() ?? door['cityName']?.toString(),
    );
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
