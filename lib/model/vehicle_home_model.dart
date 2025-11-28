
import 'make_type_model.dart';

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
      makes: (json['makes'] as List?)
          ?.map((i) => Makes.fromJson(i))
          .toList(),
    );
  }
}

class ItemType {
  int? id;
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
      id: json['id'],
      name: json['name'],
      description: json['description'],
      status: json['status'],
      image: json['image'],
    );
  }
}



class ItemsData {
  int? id;
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
   });
  set wishlistSetter(bool value) {
    isInWishlist = value;
  }
  factory ItemsData.fromJson(Map<String, dynamic> json) {
    return ItemsData(
      id: json['id'],
      name: json['name'],
      itemRating: json['item_rating'],
      mobile: json['mobile'],
      personAllowed: json['person_allowed'],
      address: json['address'],
      stateRegion: json['state_region'],
      city: json['city'],
      zipPostalCode: json['zip_postal_code'],
      price: json['price'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      status: json['status'],
      itemTypeId: json['item_type_id'],
      image: json['image'],
      itemInfo: json['item_info'],
      isInWishlist: json['is_in_wishlist'],
      itemType: json['item_type'],
      distance: json['distance'],
    );
  }

  static fromItem(item) {}
}

class ItemInfo {
  dynamic serviceType;
  List<dynamic>? rules;
  dynamic vehicleType;
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

  ItemInfo({
    this.serviceType,
    this.rules,
    this.vehicleType,
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
  });

  factory ItemInfo.fromJson(Map<String, dynamic> json) {
    return ItemInfo(
      serviceType: json['service_type'],
      rules: List<String>.from(json['rules'] ?? []),
      vehicleType: json['vehicleType'],
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
      cancellationReasonTitle: json['cancellation_reason_title'],
      cancellationReasonDescription:
          (json['cancellation_reason_description'] is List)
              ? List<String>.from(json['cancellation_reason_description'] ?? [])
              : (json['cancellation_reason_description'] is String)
                  ? [json['cancellation_reason_description']]
                  : [],

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
    );
  }
}
class Feature {
  int? id;
  String? name;
  String? imageUrl;

  Feature({
    this.id,
    this.name,
    this.imageUrl,
  });

  factory Feature.fromJson(Map<String, dynamic> json) {
    return Feature(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
    );
  }
}


class Location {
  int? id;
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
      id: json['id'],
      cityName: json['city_name'],
      description: json['description'],
      image: json['image'],
      latitude: json['latitude'],
      countryCode: json['country_code'],
      longitude: json['longitude'],
    );
  }
}


