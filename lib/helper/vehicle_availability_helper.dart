import 'dart:convert';

import 'package:carvy/helper/city_name_helper.dart';
import 'package:carvy/model/items_model.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:get/get.dart';

/// Type de disponibilité pour une ville recherchée (ex. Marrakech).
class VehicleAvailabilityType {
  static const String local = 'local';
  static const String delivery = 'delivery';
  /// Hors zone : ne doit apparaître ni en sur place ni en livraison pour la ville cherchée.
  static const String excluded = 'excluded';

  static String? normalize(dynamic raw) {
    final v = raw?.toString().trim().toLowerCase() ?? '';
    if (v == local || v == 'on_site' || v == 'based' || v == 'base') {
      return local;
    }
    if (v == delivery || v == 'livraison' || v == 'doorstep') {
      return delivery;
    }
    if (v == excluded || v == 'out_of_area' || v == 'unknown') {
      return excluded;
    }
    return null;
  }
}

/// Résout `local` vs `delivery` depuis le flag API ou, à défaut, city / deliveryLocations.
class VehicleAvailabilityHelper {
  VehicleAvailabilityHelper._();

  static bool citiesMatch(String? a, String? b) =>
      CityNameHelper.citiesMatch(a, b);

  static String? readItemCity(dynamic item) {
    if (item is Items) return item.city?.trim();
    if (item is ItemsData) return item.city?.trim();
    try {
      return item.city?.toString().trim();
    } catch (_) {
      return null;
    }
  }

  static dynamic readItemInfo(dynamic item) {
    if (item is Items) return item.itemInfo;
    if (item is ItemsData) return item.itemInfo;
    try {
      return item.itemInfo;
    } catch (_) {
      return null;
    }
  }

  /// Véhicule basé dans [searchedCity] (doit apparaître sur place, pas en livraison).
  static bool isBasedInSearchedCity(dynamic item, String searchedCity) {
    final city = searchedCity.trim();
    if (city.isEmpty) return false;
    final itemCity = readItemCity(item);
    if (itemCity == null || itemCity.isEmpty) return false;
    return citiesMatch(itemCity, city);
  }

  /// Marque un item comme disponible sur place (réaffectation depuis delivery_items).
  static void markAsOnSite(dynamic item) {
    if (item is Items) {
      item.availabilityType = VehicleAvailabilityType.local;
      item.isDelivery = false;
      return;
    }
    if (item is ItemsData) {
      item.availabilityType = VehicleAvailabilityType.local;
      item.isDelivery = false;
      return;
    }
    try {
      item.availabilityType = VehicleAvailabilityType.local;
      item.isDelivery = false;
    } catch (_) {}
  }

  static String? _itemId(dynamic item) {
    if (item is Items) return item.id;
    if (item is ItemsData) return item.id;
    try {
      return item.id?.toString();
    } catch (_) {
      return null;
    }
  }

  static bool _listContainsItem(List<dynamic> list, dynamic item) {
    final id = _itemId(item);
    if (id != null && id.isNotEmpty) {
      return list.any((e) => _itemId(e) == id);
    }
    return list.contains(item);
  }

  /// Déplace les véhicules locaux mal classés dans `delivery_items` vers [onSiteList].
  static void reassignLocalDeliveryItemsToOnSite({
    required List<dynamic> onSiteList,
    required List<dynamic> deliveryList,
    required String searchedCity,
  }) {
    final city = searchedCity.trim();
    if (city.isEmpty || deliveryList.isEmpty) return;

    final toMove = deliveryList
        .where((item) => isBasedInSearchedCity(item, city))
        .toList(growable: false);

    for (final item in toMove) {
      deliveryList.remove(item);
      markAsOnSite(item);
      if (!_listContainsItem(onSiteList, item)) {
        onSiteList.add(item);
      }
    }
  }

  /// Marque un item comme livraison (réaffectation depuis on_site voisin).
  static void markAsDelivery(dynamic item) {
    if (item is Items) {
      item.availabilityType = VehicleAvailabilityType.delivery;
      item.isDelivery = true;
      return;
    }
    if (item is ItemsData) {
      item.availabilityType = VehicleAvailabilityType.delivery;
      item.isDelivery = true;
      return;
    }
    try {
      item.availabilityType = VehicleAvailabilityType.delivery;
      item.isDelivery = true;
    } catch (_) {}
  }

  /// Déplace vers la livraison les véhicules hors ville (ex. Salé quand on cherche Rabat).
  static void reclassifyNonLocalOnSiteToDelivery({
    required List<dynamic> onSiteList,
    required List<dynamic> deliveryList,
    required String searchedCity,
  }) {
    final city = searchedCity.trim();
    if (city.isEmpty || onSiteList.isEmpty) return;

    final toMove = onSiteList
        .where((item) => !isBasedInSearchedCity(item, city))
        .toList(growable: false);

    for (final item in toMove) {
      onSiteList.remove(item);
      markAsDelivery(item);
      if (!_listContainsItem(deliveryList, item)) {
        deliveryList.add(item);
      }
    }
  }

  /// Véhicule éligible à la section « sur place » pour [searchedCity].
  static bool belongsInOnSiteSection(dynamic item, String searchedCity) {
    final city = searchedCity.trim();
    if (city.isEmpty) return true;

    final type = readType(item);
    if (type == VehicleAvailabilityType.excluded) return false;
    if (type == VehicleAvailabilityType.delivery) return false;

    return isBasedInSearchedCity(item, city);
  }

  static bool hasDeliveryLocations(dynamic itemInfo) {
    final info = _itemInfoMap(itemInfo);
    if (info == null) return false;
    final locs = info['deliveryLocations'];
    return locs is List && locs.isNotEmpty;
  }

  /// Véhicule éligible à la section livraison pour [searchedCity].
  static bool belongsInDeliverySection(
    dynamic item,
    String searchedCity, {
    bool lenientWithoutDeliveryMetadata = false,
  }) {
    final city = searchedCity.trim();
    if (city.isEmpty) return readType(item) == VehicleAvailabilityType.delivery;

    final type = readType(item);
    if (type == VehicleAvailabilityType.excluded) return false;

    // Basés dans la ville recherchée → section sur place (réaffectés avant ce filtre).
    if (isBasedInSearchedCity(item, city)) return false;

    final itemInfo = readItemInfo(item);
    final hasDeliveryMeta = hasDeliveryLocations(itemInfo);

    if (type == VehicleAvailabilityType.delivery) {
      if (!hasDeliveryMeta) {
        // Bucket API delivery sans métadonnées : conserver (expand_location_delivery).
        return true;
      }
      if (lenientWithoutDeliveryMetadata) {
        // Fail-safe : faire confiance au bucket API si le filtrage strict vide tout.
        return true;
      }
      return deliversToCity(itemInfo, city);
    }

    if (!hasDeliveryMeta) return false;
    return deliversToCity(itemInfo, city);
  }

  static void _filterOnSiteList(List<dynamic> onSiteList, String city) {
    onSiteList.removeWhere((item) => !belongsInOnSiteSection(item, city));
  }

  static void _filterDeliveryList(
    List<dynamic> deliveryList,
    String city, {
    required bool lenientWithoutDeliveryMetadata,
  }) {
    deliveryList.removeWhere(
      (item) => !belongsInDeliverySection(
        item,
        city,
        lenientWithoutDeliveryMetadata: lenientWithoutDeliveryMetadata,
      ),
    );
  }

  /// Retire les entrées incohérentes après réponse API.
  static void sanitizeResultLists({
    required List<dynamic> onSiteList,
    required List<dynamic> deliveryList,
    required String searchedCity,
  }) {
    final city = searchedCity.trim();
    if (city.isEmpty) return;

    final initialCount = onSiteList.length + deliveryList.length;
    if (initialCount == 0) return;

    final snapshotOnSite = List<dynamic>.from(onSiteList);
    final snapshotDelivery = List<dynamic>.from(deliveryList);

    reassignLocalDeliveryItemsToOnSite(
      onSiteList: onSiteList,
      deliveryList: deliveryList,
      searchedCity: city,
    );
    reclassifyNonLocalOnSiteToDelivery(
      onSiteList: onSiteList,
      deliveryList: deliveryList,
      searchedCity: city,
    );
    _filterOnSiteList(onSiteList, city);
    _filterDeliveryList(
      deliveryList,
      city,
      lenientWithoutDeliveryMetadata: false,
    );

    // Fail-safe : ne jamais vider totalement si l'API avait renvoyé des items.
    if (onSiteList.isEmpty &&
        deliveryList.isEmpty &&
        initialCount > 0) {
      onSiteList
        ..clear()
        ..addAll(snapshotOnSite);
      deliveryList
        ..clear()
        ..addAll(snapshotDelivery);

      reassignLocalDeliveryItemsToOnSite(
        onSiteList: onSiteList,
        deliveryList: deliveryList,
        searchedCity: city,
      );
      reclassifyNonLocalOnSiteToDelivery(
        onSiteList: onSiteList,
        deliveryList: deliveryList,
        searchedCity: city,
      );
      _filterOnSiteList(onSiteList, city);
      _filterDeliveryList(
        deliveryList,
        city,
        lenientWithoutDeliveryMetadata: true,
      );

      // Dernier recours : réaffectation + reclassement, filtre sur place strict.
      if (onSiteList.isEmpty && deliveryList.isEmpty) {
        onSiteList
          ..clear()
          ..addAll(snapshotOnSite);
        deliveryList
          ..clear()
          ..addAll(snapshotDelivery);
        reassignLocalDeliveryItemsToOnSite(
          onSiteList: onSiteList,
          deliveryList: deliveryList,
          searchedCity: city,
        );
        reclassifyNonLocalOnSiteToDelivery(
          onSiteList: onSiteList,
          deliveryList: deliveryList,
          searchedCity: city,
        );
        _filterOnSiteList(onSiteList, city);
        _filterDeliveryList(
          deliveryList,
          city,
          lenientWithoutDeliveryMetadata: true,
        );
      }
    }
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
    return VehicleAvailabilityType.excluded;
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
      if (item.availabilityType == VehicleAvailabilityType.excluded) {
        return VehicleAvailabilityType.excluded;
      }
      if (item.isDelivery == true) return VehicleAvailabilityType.delivery;
      return item.availabilityType;
    }
    if (item is ItemsData) {
      if (item.availabilityType == VehicleAvailabilityType.excluded) {
        return VehicleAvailabilityType.excluded;
      }
      if (item.isDelivery == true) return VehicleAvailabilityType.delivery;
      return item.availabilityType;
    }
    try {
      if (item.availabilityType?.toString() ==
          VehicleAvailabilityType.excluded) {
        return VehicleAvailabilityType.excluded;
      }
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
