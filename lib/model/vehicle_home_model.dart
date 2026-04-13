import 'make_type_model.dart';
import 'items_model.dart' show resolveMinRentalDaysForSearchItem;

class HomeDataModel {
  int? status;
  String? message;
  Data? data;
  String? error;
  HomeDataModel({
    this.status,
    this.message,
    this.data,
    this.error,
  });
  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
      error: json['error'],
    );
  }
}

class Data {
  List<ItemType>? itemTypes;
  List<ItemsData>? nearbyItems;
  List<ItemsData>? featuredItems;
  List<ItemsData>? mostViewedItems;
  List<ItemsData>? newArrivalItems;
  List<Location>? locations;
  List<Makes>? makes;

  Data({
    this.itemTypes,
    this.nearbyItems,
    this.featuredItems,
    this.mostViewedItems,
    this.newArrivalItems,
    this.locations,
    this.makes,
  });
  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      itemTypes: (json['itemTypes'] as List?)
          ?.map((i) => ItemType.fromJson(i))
          .toList(),
      nearbyItems: (json['nearby_items'] as List?)
          ?.map((i) => ItemsData.fromJson(i))
          .toList(),
      featuredItems: (json['featured_items'] as List?)
          ?.map((i) => ItemsData.fromJson(i))
          .toList(),
      mostViewedItems: (json['most_viewed_items'] as List?)
          ?.map((i) => ItemsData.fromJson(i))
          .toList(),
      newArrivalItems: (json['new_arrival_items'] as List?)
          ?.map((i) => ItemsData.fromJson(i))
          .toList(),
      locations: (json['locations'] as List?)
          ?.map((i) => Location.fromJson(i))
          .toList(),
      makes: (json['makes'] as List?)?.map((i) => Makes.fromJson(i)).toList(),
    );
  }
}

class ItemType {
  String? id;
  String? name;
  String? description;
  String? status;
  String? image;
  ItemType({
    this.id,
    this.name,
    this.description,
    this.status,
    this.image,
  });
  factory ItemType.fromJson(Map<String, dynamic> json) {
    return ItemType(
      // Gérer MongoDB _id en priorité, puis id standard
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name'],
      description: json['description'],
      status: json['status'],
      image: json['image'],
    );
  }
}

class ItemsData {
  String? id;
  String? name;
  String? itemRating;
  String? mobile;
  String? personAllowed;
  String? address;
  String? stateRegion;
  String? city;
  String? zipPostalCode;
  String? price;
  String? latitude;
  String? longitude;
  String? status;
  String? itemTypeId;
  String? image;
  String? itemInfo;
  bool? isInWishlist;
  String? itemType;
  String? distance;
  /// Aligné sur [Items.parsedMinRentalDays] pour la pagination des recherches.
  int parsedMinRentalDays;
  ItemsData({
    this.id,
    this.name,
    this.itemRating,
    this.mobile,
    this.personAllowed,
    this.address,
    this.stateRegion,
    this.city,
    this.zipPostalCode,
    this.price,
    this.latitude,
    this.longitude,
    this.status,
    this.itemTypeId,
    this.image,
    this.itemInfo,
    this.isInWishlist,
    this.itemType,
    this.distance,
    this.parsedMinRentalDays = 1,
  });
  set wishlistSetter(bool value) {
    isInWishlist = value;
  }

  factory ItemsData.fromJson(Map<String, dynamic> json) {
    // Logs supprimés pour optimiser le parsing de 22+ véhicules
    final dynamic vehicleLocation = json['vehicleLocation'];
    final dynamic legacyLocation = json['location'];

    // Adresse / ville : racine en priorité, puis anciens schémas
    final dynamic rawAddress = json['address'] ??
        (vehicleLocation is Map ? vehicleLocation['address'] : null) ??
        (legacyLocation is Map ? legacyLocation['address'] : null);

    final dynamic rawCity = json['city'] ??
        (vehicleLocation is Map ? vehicleLocation['cityName'] : null) ??
        (legacyLocation is Map ? legacyLocation['city'] : null);

    // Coordonnées
    final dynamic rawLat = json['latitude'] ??
        (vehicleLocation is Map ? vehicleLocation['latitude'] : null) ??
        (legacyLocation is Map && legacyLocation['coordinates'] is List
            ? (legacyLocation['coordinates'] as List).length > 1
                ? (legacyLocation['coordinates'] as List)[1]
                : null
            : null);
    final dynamic rawLng = json['longitude'] ??
        (vehicleLocation is Map ? vehicleLocation['longitude'] : null) ??
        (legacyLocation is Map && legacyLocation['coordinates'] is List
            ? (legacyLocation['coordinates'] as List).isNotEmpty
                ? (legacyLocation['coordinates'] as List)[0]
                : null
            : null);

    return ItemsData(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name'],
      itemRating: json['item_rating'],
      mobile: json['mobile'],
      personAllowed: json['person_allowed'],
      address: rawAddress?.toString(),
      stateRegion: json['state_region'],
      city: rawCity?.toString(),
      zipPostalCode: json['zip_postal_code'],
      price: json['price'],
      latitude: rawLat?.toString(),
      longitude: rawLng?.toString(),
      status: json['status'],
      itemTypeId: json['item_type_id']?.toString(),
      image: json['image'],
      itemInfo: json['item_info'],
      isInWishlist: json['is_in_wishlist'],
      itemType: json['item_type'],
      distance: json['distance'],
      parsedMinRentalDays: resolveMinRentalDaysForSearchItem(json),
    );
  }

  static fromItem(item) {}
}

/// Fonction helper pour parser cancellationReasonDescription qui peut être :
/// - null
/// - String
/// - List<String>
/// - List<Map> (objets avec des propriétés comme 'description', 'text', 'reason', etc.)
List<dynamic> _parseCancellationReasonDescription(dynamic jsonValue) {
  if (jsonValue == null) {
    return [];
  }
  
  // Si c'est une String, la convertir en List avec un seul élément
  if (jsonValue is String) {
    return jsonValue.isEmpty ? [] : [jsonValue];
  }
  
  // Si c'est une List
  if (jsonValue is List) {
    if (jsonValue.isEmpty) {
      return [];
    }
    
    // Vérifier le type du premier élément pour déterminer le format
    final firstElement = jsonValue.first;
    
    // Si c'est déjà une List de Strings, retourner directement
    if (firstElement is String) {
      return List<String>.from(jsonValue);
    }
    
    // Si c'est une List d'objets (Map), extraire les textes
    if (firstElement is Map) {
      return jsonValue.map<dynamic>((item) {
        // Essayer différentes clés communes pour extraire le texte
        if (item is Map) {
          return item['description']?.toString() ?? 
                 item['text']?.toString() ?? 
                 item['reason']?.toString() ?? 
                 item['content']?.toString() ??
                 item['message']?.toString() ??
                 item.toString();
        }
        return item.toString();
      }).toList();
    }
    
    // Sinon, convertir chaque élément en String
    return jsonValue.map<dynamic>((item) => item.toString()).toList();
  }
  
  // Si c'est un autre type, le convertir en String et le mettre dans une List
  return [jsonValue.toString()];
}

class ItemInfo {
  dynamic serviceType;
  List<dynamic>? rules;
  dynamic vehicleType;
  final String? type;
  final List<String>? categoryList;
  final String? customModelName;
  dynamic makeType;
  dynamic model;
  dynamic year;
  dynamic transmission;
  dynamic odometer;
  dynamic description;
  dynamic platNumber;
  dynamic minRentalDays;
  dynamic insuranceCoverage;
  dynamic ageRistriction;
  dynamic smokingStatus;
  dynamic internationalTravel;
  dynamic isVerified;
  dynamic isFeatured;
  dynamic bookingPoliciesId;
  dynamic weeklyDiscount;
  dynamic weeklyDiscountType;
  dynamic monthlyDiscount;
  dynamic monthlyDiscountType;
  dynamic cancellationReasonTitle;
  dynamic cancellationReason; // Clé JSON: 'cancellation_reason'
  List<dynamic>? cancellationReasonDescription;
  List<Feature>? featuresData;
  dynamic hostId;
  dynamic hostFirstName;
  dynamic hostLastName;
  dynamic hostEmail;
  dynamic fuelType;
  dynamic seatCapicity;
  dynamic hostPhone;
  dynamic hostPlayerId;
  dynamic hostProfileImage;
  List<dynamic>? galleryImageUrls;
  List<dynamic>? reviewData;
  dynamic totalReviews;
  dynamic doorStepPrice;
  List<dynamic>? deliveryLocations;
  dynamic weeklyDiscountValue;
  dynamic monthlyDiscountValue;
  bool? hasDiscounts;
  ItemInfoPriceDetails? priceDetails;

  ItemInfo({
    this.serviceType,
    this.rules,
    this.vehicleType,
    this.type,
    this.categoryList,
    this.customModelName,
    this.makeType,
    this.model,
    this.year,
    this.transmission,
    this.odometer,
    this.description,
    this.platNumber,
    this.internationalTravel,
    this.smokingStatus,
    this.insuranceCoverage,
    this.ageRistriction,
    this.minRentalDays,
    this.isVerified,
    this.isFeatured,
    this.seatCapicity,
    this.fuelType,
    this.bookingPoliciesId,
    this.weeklyDiscount,
    this.weeklyDiscountType,
    this.monthlyDiscount,
    this.monthlyDiscountType,
    this.cancellationReasonTitle,
    this.cancellationReason,
    this.cancellationReasonDescription,
    this.featuresData,
    this.hostId,
    this.hostFirstName,
    this.hostLastName,
    this.hostEmail,
    this.hostPhone,
    this.hostPlayerId,
    this.hostProfileImage,
    this.galleryImageUrls,
    this.reviewData,
    this.totalReviews,
    this.doorStepPrice,
    this.deliveryLocations,
    this.weeklyDiscountValue,
    this.monthlyDiscountValue,
    this.hasDiscounts,
    this.priceDetails,
  });

  factory ItemInfo.fromJson(Map<String, dynamic> json) {
    // Gérer le type avec plusieurs fallbacks pour éviter null
    final typeValue = json['type']?.toString() ?? 
                      json['vehicleType']?.toString() ?? 
                      json['item_type']?.toString() ?? 
                      'CAR';
    // Log supprimé pour optimiser le parsing de 21+ véhicules
    return ItemInfo(
      serviceType: json['service_type'],
      rules: List<String>.from(json['rules'] ?? []),
      vehicleType: json['vehicleType']?.toString() ?? json['item_type']?.toString() ?? 'CAR',
      type: typeValue,
      customModelName: json['customModelName']?.toString(),
      categoryList: json['categoryList'] != null
          ? List<String>.from(json['categoryList'])
          : <String>[],
      makeType: json['make_type'],
      model: json['model'],
      year: json['year'],
      transmission: json['transmission'],
      odometer: json['odometer'],
      description: json['description'],
      platNumber: json['license_plate'],
      smokingStatus: json['smoking_status'],
      insuranceCoverage: json['insurance_coverage'],
      internationalTravel: json['international_travel_status'],
      ageRistriction: json['min_age'],
      minRentalDays: json['min_rental_days'],
      isVerified: json['is_verified'],
      isFeatured: json['is_featured'],
      fuelType: json['fuel_type'],
      seatCapicity: json['number_of_seats'],
      bookingPoliciesId: json['booking_policies_id'],
      weeklyDiscount: json['weekly_discount'],
      weeklyDiscountType: json['weekly_discount_type'],
      monthlyDiscount: json['monthly_discount'],
      monthlyDiscountType: json['monthly_discount_type'],
      cancellationReasonTitle: json['cancellation_reason_title'] ?? json['cancellation_reason'],
      cancellationReason: json['cancellation_reason'], // Mapper la clé JSON 'cancellation_reason'
      cancellationReasonDescription: _parseCancellationReasonDescription(
          json['cancellation_reason_description']),
      featuresData: (json['features_data'] as List<dynamic>?)
          ?.map((featureJson) => Feature.fromJson(featureJson))
          .toList(),
      hostId: json['host_id'],
      hostFirstName: json['host_first_name'],
      hostLastName: json['host_last_name'],
      hostEmail: json['host_email'],
      hostPhone: json['host_phone'],
      hostPlayerId: json['host_player_id'],
      hostProfileImage: json['host_profile_image'],
      galleryImageUrls: List<String>.from(json['gallery_image_urls'] ?? []),
      reviewData: json['review_data'],
      totalReviews: json['total_reviews'],
      doorStepPrice: json['doorStep_price'],
      deliveryLocations: (json['deliveryLocations'] as List<dynamic>?) ?? [],
      weeklyDiscountValue: json['weekly_discount_value'],
      monthlyDiscountValue: json['monthly_discount_value'],
      hasDiscounts: json['has_discounts'] is bool
          ? json['has_discounts']
          : json['has_discounts']?.toString().toLowerCase() == 'true',
      priceDetails: json['price_details'] is Map<String, dynamic>
          ? ItemInfoPriceDetails.fromJson(json['price_details'])
          : null,
    );
  }

  // Nom du modèle en String
  String? get modelName => model?.toString();

  // Getter d'affichage pour l'UI
  String get displayModelName {
    final String base = modelName?.trim() ?? '';
    if (base.toLowerCase() == 'autre' &&
        customModelName != null &&
        customModelName!.trim().isNotEmpty) {
      return customModelName!.trim();
    }
    return base;
  }

  bool get isSmokingAllowed {
    return smokingStatus == true ||
        smokingStatus == "true" ||
        smokingStatus == "1" ||
        smokingStatus == 1;
  }

  bool get isInternationalTravelAllowed {
    return internationalTravel == true ||
        internationalTravel == "true" ||
        internationalTravel == "1" ||
        internationalTravel == 1;
  }
}

class ItemInfoPriceDetails {
  final dynamic originalDailyPrice;
  final dynamic discountedDailyPriceWeekly;
  final dynamic discountedDailyPriceMonthly;

  ItemInfoPriceDetails({
    this.originalDailyPrice,
    this.discountedDailyPriceWeekly,
    this.discountedDailyPriceMonthly,
  });

  factory ItemInfoPriceDetails.fromJson(Map<String, dynamic> json) {
    return ItemInfoPriceDetails(
      originalDailyPrice: json['original_daily_price'],
      discountedDailyPriceWeekly: json['discounted_daily_price_weekly'],
      discountedDailyPriceMonthly: json['discounted_daily_price_monthly'],
    );
  }
}

class Feature {
  String? id;
  String? name;
  String? imageUrl;

  Feature({
    this.id,
    this.name,
    this.imageUrl,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }
}

class Location {
  String? id;
  String? cityName;
  String? description;
  String? image;
  String? latitude;
  String? countryCode;
  String? longitude;

  Location({
    this.id,
    this.cityName,
    this.description,
    this.image,
    this.latitude,
    this.countryCode,
    this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id']?.toString() ?? json['_id']?.toString(),
      cityName: json['city_name'],
      description: json['description'],
      image: json['image'],
      latitude: json['latitude'],
      countryCode: json['country_code'],
      longitude: json['longitude'],
    );
  }
}
