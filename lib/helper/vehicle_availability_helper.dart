import 'dart:convert';

import 'package:carvy/helper/city_name_helper.dart';
import 'package:carvy/model/items_model.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:get/get.dart';

/// Type de disponibilité pour une ville recherchée (ex. Marrakech).
class VehicleAvailabilityType {
  static const String local = 'local';
  static const String delivery = 'delivery';

  static String? normalize(dynamic raw) {
    final v = raw?.toString().trim().toLowerCase() ?? '';
    if (v == local || v == 'on_site' || v == 'based' || v == 'base') {
      return local;
    }
    if (v == delivery || v == 'livraison' || v == 'doorstep') {
      return delivery;
    }
    return null;
  }
}

/// Résout `local` vs `delivery` depuis le flag API ou, à défaut, city / deliveryLocations.
class VehicleAvailabilityHelper {
  VehicleAvailabilityHelper._();

  static String _norm(String input) {
    return input
        .trim()
        .toLowerCase()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a');
  }

  static bool citiesMatch(String? a, String? b) {
    final left = (a ?? '').trim();
    final right = (b ?? '').trim();
    if (left.isEmpty || right.isEmpty) return false;
    final na = _norm(left);
    final nb = _norm(right);
    if (na == nb) return true;
    final ka = CityNameHelper.translationKeyForCity(left);
    final kb = CityNameHelper.translationKeyForCity(right);
    if (ka != null && ka == kb) return true;
    return na.contains(nb) || nb.contains(na);
  }

  static Map<String, dynamic>? _itemInfoMap(dynamic itemInfo) {
    if (itemInfo is Map<String, dynamic>) return itemInfo;
    if (itemInfo is Map) return Map<String, dynamic>.from(itemInfo);
    if (itemInfo is String && itemInfo.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(itemInfo);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  static bool deliversToCity(dynamic itemInfo, String searchedCity) {
    if (searchedCity.trim().isEmpty) return false;
    final info = _itemInfoMap(itemInfo);
    if (info == null) return false;
    final locs = info['deliveryLocations'];
    if (locs is! List || locs.isEmpty) return false;

    for (final loc in locs) {
      final label = CityNameHelper.deliveryLocationLabel(loc);
      if (citiesMatch(label, searchedCity)) return true;
      if (loc is Map) {
        final candidates = <String?>[
          loc['locationName']?.toString(),
          loc['name']?.toString(),
          loc['city']?.toString(),
          loc['cityName']?.toString(),
          if (loc['location'] is Map)
            (loc['location'] as Map)['cityName']?.toString(),
          if (loc['location'] is Map)
            (loc['location'] as Map)['city_name']?.toString(),
        ];
        for (final c in candidates) {
          if (citiesMatch(c, searchedCity)) return true;
        }
      }
    }
    return false;
  }

  /// Priorité : flag API → basé dans la ville → livraison vers la ville → local.
  static String resolve({
    dynamic apiType,
    String? itemCity,
    dynamic itemInfo,
    required String searchedCity,
  }) {
    final fromApi = VehicleAvailabilityType.normalize(apiType);
    if (fromApi != null) return fromApi;

    final city = searchedCity.trim();
    if (city.isEmpty) return VehicleAvailabilityType.local;

    if (citiesMatch(itemCity, city)) {
      return VehicleAvailabilityType.local;
    }
    if (deliversToCity(itemInfo, city)) {
      return VehicleAvailabilityType.delivery;
    }
    return VehicleAvailabilityType.local;
  }

  static void applyToItem(dynamic item, {required String searchedCity}) {
    if (item is Items) {
      item.availabilityType = resolve(
        apiType: item.availabilityType,
        itemCity: item.city,
        itemInfo: item.itemInfo,
        searchedCity: searchedCity,
      );
      return;
    }
    if (item is ItemsData) {
      item.availabilityType = resolve(
        apiType: item.availabilityType,
        itemCity: item.city,
        itemInfo: item.itemInfo,
        searchedCity: searchedCity,
      );
    }
  }

  static void applyToList(List? items, {required String searchedCity}) {
    if (items == null || items.isEmpty) return;
    for (final item in items) {
      applyToItem(item, searchedCity: searchedCity);
    }
  }

  static String? readType(dynamic item) {
    if (item is Items) {
      if (item.isDelivery == true) return VehicleAvailabilityType.delivery;
      return item.availabilityType;
    }
    if (item is ItemsData) {
      if (item.isDelivery == true) return VehicleAvailabilityType.delivery;
      return item.availabilityType;
    }
    try {
      if (item.isDelivery == true) return VehicleAvailabilityType.delivery;
      return item.availabilityType?.toString();
    } catch (_) {
      return null;
    }
  }

  static String localSectionTitle() => 'availability_on_site_section'.tr;

  static String deliverySectionTitle(String city) {
    final label = CityNameHelper.displayName(city);
    if (label.isEmpty || label == '-') {
      return 'availability_delivery_section_generic'.tr;
    }
    return 'availability_delivery_section'.trParams({'city': label});
  }

  static String localBadgeLabel() => 'availability_on_site_badge'.tr;

  static String deliveryBadgeLabel(String city) {
    final label = CityNameHelper.displayName(city);
    if (label.isEmpty || label == '-') {
      return 'availability_delivery_badge_generic'.tr;
    }
    return 'availability_delivery_badge'.trParams({'city': label});
  }
}
