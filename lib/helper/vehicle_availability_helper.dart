import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:carvy/helper/city_name_helper.dart';
import 'package:carvy/helper/mongo_id_helper.dart';
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

  static const String _logTag = '[FLUTTER SEARCH]';

  static String _itemLabel(dynamic item) {
    final id = _itemId(item) ?? '?';
    String? name;
    if (item is Items) {
      name = item.name;
    } else if (item is ItemsData) {
      name = item.name;
    } else {
      try {
        name = item.name?.toString();
      } catch (_) {}
    }
    return '${name ?? '?'} (id=$id)';
  }

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

  static String? readVehicleLocationId(dynamic item) {
    if (item is Items) return MongoIdHelper.normalize(item.vehicleLocationId);
    if (item is ItemsData) {
      return MongoIdHelper.normalize(item.vehicleLocationId);
    }
    try {
      return MongoIdHelper.normalize(item.vehicleLocationId?.toString());
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

  /// Véhicule basé dans la zone recherchée (ObjectId prioritaire, puis nom).
  static bool isBasedInSearchedCity(
    dynamic item,
    String searchedCity, {
    String? searchedLocationId,
    bool logDecision = false,
  }) {
    final label = logDecision ? _itemLabel(item) : null;
    final locationId = MongoIdHelper.normalize(searchedLocationId);
    if (locationId != null) {
      final itemLocationId = readVehicleLocationId(item);
      if (itemLocationId != null) {
        final match = MongoIdHelper.idsEqual(itemLocationId, locationId);
        if (logDecision) {
          debugPrint(
            '$_logTag LOCAL item=$label match=$match '
            'via=vehicleLocationId itemFk=$itemLocationId searchFk=$locationId',
          );
        }
        return match;
      }
      if (logDecision) {
        debugPrint(
          '$_logTag LOCAL item=$label — no vehicleLocationId on item, '
          'fallback to city text',
        );
      }
    }

    final city = searchedCity.trim();
    if (city.isEmpty) {
      if (logDecision) {
        debugPrint('$_logTag LOCAL item=$label match=false (empty search city)');
      }
      return false;
    }
    final itemCity = readItemCity(item);
    if (itemCity == null || itemCity.isEmpty) {
      if (logDecision) {
        debugPrint('$_logTag LOCAL item=$label match=false (empty item.city)');
      }
      return false;
    }
    final textMatch = citiesMatch(itemCity, city);
    if (logDecision) {
      debugPrint(
        '$_logTag LOCAL item=$label match=$textMatch '
        'via=cityText itemCity="$itemCity" searchCity="$city"',
      );
    }
    return textMatch;
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
    String? searchedLocationId,
  }) {
    final city = searchedCity.trim();
    if (city.isEmpty &&
        MongoIdHelper.normalize(searchedLocationId) == null) {
      return;
    }
    if (deliveryList.isEmpty) return;

    final toMove = deliveryList
        .where(
          (item) => isBasedInSearchedCity(
            item,
            city,
            searchedLocationId: searchedLocationId,
          ),
        )
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

  /// Déplace vers la livraison les véhicules hors zone (ex. Salé quand on cherche Rabat).
  static void reclassifyNonLocalOnSiteToDelivery({
    required List<dynamic> onSiteList,
    required List<dynamic> deliveryList,
    required String searchedCity,
    String? searchedLocationId,
  }) {
    final city = searchedCity.trim();
    if (city.isEmpty &&
        MongoIdHelper.normalize(searchedLocationId) == null) {
      return;
    }
    if (onSiteList.isEmpty) return;

    final toMove = onSiteList
        .where(
          (item) => !isBasedInSearchedCity(
            item,
            city,
            searchedLocationId: searchedLocationId,
          ),
        )
        .toList(growable: false);

    for (final item in toMove) {
      onSiteList.remove(item);
      markAsDelivery(item);
      if (!_listContainsItem(deliveryList, item)) {
        deliveryList.add(item);
      }
    }
  }

  /// Véhicule éligible à la section « sur place » pour la zone recherchée.
  static bool belongsInOnSiteSection(
    dynamic item,
    String searchedCity, {
    String? searchedLocationId,
    bool logDecision = false,
  }) {
    final city = searchedCity.trim();
    if (city.isEmpty &&
        MongoIdHelper.normalize(searchedLocationId) == null) {
      if (logDecision) {
        debugPrint(
          '$_logTag ON_SITE item=${_itemLabel(item)} keep=true (no search filter)',
        );
      }
      return true;
    }

    final type = readType(item);
    if (type == VehicleAvailabilityType.excluded) {
      if (logDecision) {
        debugPrint(
          '$_logTag ON_SITE item=${_itemLabel(item)} keep=false (excluded type)',
        );
      }
      return false;
    }
    if (type == VehicleAvailabilityType.delivery) {
      if (logDecision) {
        debugPrint(
          '$_logTag ON_SITE item=${_itemLabel(item)} keep=false (delivery type)',
        );
      }
      return false;
    }

    final localMatch = isBasedInSearchedCity(
      item,
      city,
      searchedLocationId: searchedLocationId,
      logDecision: logDecision,
    );
    if (logDecision) {
      debugPrint(
        '$_logTag ON_SITE item=${_itemLabel(item)} keep=$localMatch',
      );
    }
    return localMatch;
  }

  static bool hasDeliveryLocations(dynamic itemInfo) {
    final info = _itemInfoMap(itemInfo);
    if (info == null) return false;
    final locs = info['deliveryLocations'];
    return locs is List && locs.isNotEmpty;
  }

  /// Véhicule éligible à la section livraison pour la zone recherchée.
  static bool belongsInDeliverySection(
    dynamic item,
    String searchedCity, {
    String? searchedLocationId,
    bool lenientWithoutDeliveryMetadata = false,
    bool logDecision = false,
  }) {
    final label = logDecision ? _itemLabel(item) : null;
    final city = searchedCity.trim();
    final locationId = MongoIdHelper.normalize(searchedLocationId);
    if (city.isEmpty && locationId == null) {
      final keep = readType(item) == VehicleAvailabilityType.delivery;
      if (logDecision) {
        debugPrint('$_logTag DELIVERY item=$label keep=$keep (no search filter)');
      }
      return keep;
    }

    final type = readType(item);
    if (type == VehicleAvailabilityType.excluded) {
      if (logDecision) {
        debugPrint('$_logTag DELIVERY item=$label keep=false (excluded type)');
      }
      return false;
    }

    if (isBasedInSearchedCity(
      item,
      city,
      searchedLocationId: searchedLocationId,
      logDecision: false,
    )) {
      if (logDecision) {
        debugPrint(
          '$_logTag DELIVERY item=$label keep=false (vehicle is local to search zone)',
        );
      }
      return false;
    }

    final itemInfo = readItemInfo(item);
    final hasDeliveryMeta = hasDeliveryLocations(itemInfo);

    if (type == VehicleAvailabilityType.delivery) {
      if (!hasDeliveryMeta) {
        if (logDecision) {
          debugPrint(
            '$_logTag DELIVERY item=$label keep=true (delivery bucket, no metadata)',
          );
        }
        return true;
      }
      if (lenientWithoutDeliveryMetadata) {
        if (logDecision) {
          debugPrint(
            '$_logTag DELIVERY item=$label keep=true (lenient mode, trust API bucket)',
          );
        }
        return true;
      }
      final keep = deliversToSearchedArea(
        itemInfo,
        searchedCity: city,
        searchedLocationId: locationId,
        debugItemLabel: label,
        logDecision: logDecision,
      );
      if (logDecision) {
        debugPrint('$_logTag DELIVERY item=$label keep=$keep (strict delivery FK/text)');
      }
      return keep;
    }

    if (!hasDeliveryMeta) {
      if (logDecision) {
        debugPrint('$_logTag DELIVERY item=$label keep=false (no delivery metadata)');
      }
      return false;
    }
    final keep = deliversToSearchedArea(
      itemInfo,
      searchedCity: city,
      searchedLocationId: locationId,
      debugItemLabel: label,
      logDecision: logDecision,
    );
    if (logDecision) {
      debugPrint('$_logTag DELIVERY item=$label keep=$keep (delivery metadata check)');
    }
    return keep;
  }

  static void _filterOnSiteList(
    List<dynamic> onSiteList,
    String city, {
    String? searchedLocationId,
  }) {
    onSiteList.removeWhere(
      (item) => !belongsInOnSiteSection(
        item,
        city,
        searchedLocationId: searchedLocationId,
        logDecision: true,
      ),
    );
  }

  static void _filterDeliveryList(
    List<dynamic> deliveryList,
    String city, {
    String? searchedLocationId,
    required bool lenientWithoutDeliveryMetadata,
  }) {
    deliveryList.removeWhere(
      (item) => !belongsInDeliverySection(
        item,
        city,
        searchedLocationId: searchedLocationId,
        lenientWithoutDeliveryMetadata: lenientWithoutDeliveryMetadata,
        logDecision: true,
      ),
    );
  }

  /// Retire les entrées incohérentes après réponse API.
  static void sanitizeResultLists({
    required List<dynamic> onSiteList,
    required List<dynamic> deliveryList,
    required String searchedCity,
    String? searchedLocationId,
  }) {
    final city = searchedCity.trim();
    final locationId = MongoIdHelper.normalize(searchedLocationId);
    if (city.isEmpty && locationId == null) {
      debugPrint(
        '$_logTag sanitizeResultLists skipped — no searchedCity or searchedLocationId',
      );
      return;
    }

    final initialOnSite = onSiteList.length;
    final initialDelivery = deliveryList.length;
    final initialCount = initialOnSite + initialDelivery;
    if (initialCount == 0) {
      debugPrint(
        '$_logTag sanitizeResultLists skipped — API lists empty '
        '(searchedCity="$city" searchedLocationId=${locationId ?? "(null)"})',
      );
      return;
    }

    debugPrint(
      '$_logTag sanitizeResultLists START\n'
      '   searchedCity        = "$city"\n'
      '   searchedLocationId  = ${locationId ?? "(null)"}\n'
      '   on_site_items (in)  = $initialOnSite\n'
      '   delivery_items (in) = $initialDelivery',
    );

    final snapshotOnSite = List<dynamic>.from(onSiteList);
    final snapshotDelivery = List<dynamic>.from(deliveryList);

    reassignLocalDeliveryItemsToOnSite(
      onSiteList: onSiteList,
      deliveryList: deliveryList,
      searchedCity: city,
      searchedLocationId: locationId,
    );
    reclassifyNonLocalOnSiteToDelivery(
      onSiteList: onSiteList,
      deliveryList: deliveryList,
      searchedCity: city,
      searchedLocationId: locationId,
    );
    _filterOnSiteList(
      onSiteList,
      city,
      searchedLocationId: locationId,
    );
    _filterDeliveryList(
      deliveryList,
      city,
      searchedLocationId: locationId,
      lenientWithoutDeliveryMetadata: false,
    );

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
        searchedLocationId: locationId,
      );
      reclassifyNonLocalOnSiteToDelivery(
        onSiteList: onSiteList,
        deliveryList: deliveryList,
        searchedCity: city,
        searchedLocationId: locationId,
      );
      _filterOnSiteList(
        onSiteList,
        city,
        searchedLocationId: locationId,
      );
      _filterDeliveryList(
        deliveryList,
        city,
        searchedLocationId: locationId,
        lenientWithoutDeliveryMetadata: true,
      );

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
          searchedLocationId: locationId,
        );
        reclassifyNonLocalOnSiteToDelivery(
          onSiteList: onSiteList,
          deliveryList: deliveryList,
          searchedCity: city,
          searchedLocationId: locationId,
        );
        _filterOnSiteList(
          onSiteList,
          city,
          searchedLocationId: locationId,
        );
        _filterDeliveryList(
          deliveryList,
          city,
          searchedLocationId: locationId,
          lenientWithoutDeliveryMetadata: true,
        );
      }
    }

    debugPrint(
      '$_logTag sanitizeResultLists END\n'
      '   on_site_items (out)  = ${onSiteList.length} '
      '(removed ${initialOnSite - onSiteList.length})\n'
      '   delivery_items (out) = ${deliveryList.length} '
      '(removed ${initialDelivery - deliveryList.length})',
    );
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

  static bool deliversToSearchedArea(
    dynamic itemInfo, {
    required String searchedCity,
    String? searchedLocationId,
    String? debugItemLabel,
    bool logDecision = false,
  }) {
    final locationId = MongoIdHelper.normalize(searchedLocationId);
    final city = searchedCity.trim();
    if (locationId == null && city.isEmpty) {
      if (logDecision) {
        debugPrint(
          '$_logTag DELIVERY_FK item=${debugItemLabel ?? "?"} match=false '
          '(no search city or locationId)',
        );
      }
      return false;
    }

    final info = _itemInfoMap(itemInfo);
    if (info == null) {
      if (logDecision) {
        debugPrint(
          '$_logTag DELIVERY_FK item=${debugItemLabel ?? "?"} match=false '
          '(itemInfo unparseable)',
        );
      }
      return false;
    }
    final locs = info['deliveryLocations'];
    if (locs is! List || locs.isEmpty) {
      if (logDecision) {
        debugPrint(
          '$_logTag DELIVERY_FK item=${debugItemLabel ?? "?"} match=false '
          '(no deliveryLocations)',
        );
      }
      return false;
    }

    for (final loc in locs) {
      if (locationId != null && loc is Map) {
        final refId = MongoIdHelper.extractRefId(loc['location']);
        if (refId != null && MongoIdHelper.idsEqual(refId, locationId)) {
          if (logDecision) {
            debugPrint(
              '$_logTag DELIVERY_FK item=${debugItemLabel ?? "?"} match=true '
              'via=deliveryLocationObjectId ref=$refId searchFk=$locationId',
            );
          }
          return true;
        }
      }

      if (city.isEmpty) continue;

      final label = CityNameHelper.deliveryLocationLabel(loc);
      if (citiesMatch(label, city)) {
        if (logDecision) {
          debugPrint(
            '$_logTag DELIVERY_FK item=${debugItemLabel ?? "?"} match=true '
            'via=cityText label="$label" searchCity="$city"',
          );
        }
        return true;
      }
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
          if (citiesMatch(c, city)) {
            if (logDecision) {
              debugPrint(
                '$_logTag DELIVERY_FK item=${debugItemLabel ?? "?"} match=true '
                'via=cityText candidate="$c" searchCity="$city"',
              );
            }
            return true;
          }
        }
      }
    }
    if (logDecision) {
      debugPrint(
        '$_logTag DELIVERY_FK item=${debugItemLabel ?? "?"} match=false '
        '(no delivery zone matched searchFk=$locationId searchCity="$city")',
      );
    }
    return false;
  }

  /// Compat — ancien nom conservé pour les appels texte-only.
  static bool deliversToCity(dynamic itemInfo, String searchedCity) {
    return deliversToSearchedArea(
      itemInfo,
      searchedCity: searchedCity,
    );
  }

  static String _resolveAvailability({
    dynamic apiType,
    String? itemCity,
    dynamic itemInfo,
    String? itemLocationId,
    required String searchedCity,
    String? searchedLocationId,
  }) {
    final fromApi = VehicleAvailabilityType.normalize(apiType);
    if (fromApi != null) return fromApi;

    final city = searchedCity.trim();
    final locationId = MongoIdHelper.normalize(searchedLocationId);
    if (city.isEmpty && locationId == null) {
      return VehicleAvailabilityType.local;
    }

    if (locationId != null &&
        itemLocationId != null &&
        MongoIdHelper.idsEqual(itemLocationId, locationId)) {
      return VehicleAvailabilityType.local;
    }

    if (citiesMatch(itemCity, city)) {
      return VehicleAvailabilityType.local;
    }
    if (deliversToSearchedArea(
      itemInfo,
      searchedCity: city,
      searchedLocationId: locationId,
    )) {
      return VehicleAvailabilityType.delivery;
    }
    return VehicleAvailabilityType.excluded;
  }

  static void _setAvailabilityType(dynamic item, String type) {
    if (item is Items) {
      item.availabilityType = type;
      return;
    }
    if (item is ItemsData) {
      item.availabilityType = type;
      return;
    }
    try {
      item.availabilityType = type;
    } catch (_) {}
  }

  static void applyToItem(
    dynamic item, {
    required String searchedCity,
    String? searchedLocationId,
  }) {
    dynamic apiType;
    String? itemCity;
    dynamic itemInfo;
    try {
      apiType = item.availabilityType;
      itemCity = readItemCity(item);
      itemInfo = readItemInfo(item);
    } catch (_) {
      return;
    }

    final resolved = _resolveAvailability(
      apiType: apiType,
      itemCity: itemCity,
      itemInfo: itemInfo,
      itemLocationId: readVehicleLocationId(item),
      searchedCity: searchedCity,
      searchedLocationId: searchedLocationId,
    );
    _setAvailabilityType(item, resolved);
  }

  static void applyToList(
    List? items, {
    required String searchedCity,
    String? searchedLocationId,
  }) {
    if (items == null || items.isEmpty) return;
    for (final item in items) {
      applyToItem(
        item,
        searchedCity: searchedCity,
        searchedLocationId: searchedLocationId,
      );
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
