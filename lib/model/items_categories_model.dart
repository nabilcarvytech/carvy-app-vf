class ItemsCategories {
  int? status;
  String? message;
  Data? data;
  String? error;

  ItemsCategories({this.status, this.message, this.data, this.error});

  ItemsCategories.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['error'] = error;
    return data;
  }
}

class Data {
  List<Items>? items;
  List<Brands>? brands;
  List<Categories>? categories;
  OtherInfo? otherInfo;
  int? offset;
  int? limit;

  Data({this.items, this.brands, this.categories, this.otherInfo, this.offset, this.limit});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['items'] != null) {
      items = <Items>[];
      json['items'].forEach((v) {
        items!.add(Items.fromJson(v));
      });
    }
    if (json['brands'] != null) {
      brands = <Brands>[];
      json['brands'].forEach((v) {
        brands!.add(Brands.fromJson(v));
      });
    }
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
      });
    }
    otherInfo = json['otherInfo'] != null ? OtherInfo.fromJson(json['otherInfo']) : null;
    offset = json['offset'];
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (items != null) {
      data['items'] = items!.map((v) => v.toJson()).toList();
    }
    if (brands != null) {
      data['brands'] = brands!.map((v) => v.toJson()).toList();
    }
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    if (otherInfo != null) {
      data['otherInfo'] = otherInfo!.toJson();
    }
    data['offset'] = offset;
    data['limit'] = limit;
    return data;
  }
}

class Items {
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
  bool? isInWishlist;
  String? itemType;
  String? itemInfo;

  Items({
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
    this.isInWishlist,
    this.itemType,
    this.itemInfo,
  });

  Items.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    itemRating = json['item_rating'];
    mobile = json['mobile'];
    personAllowed = json['person_allowed'];
    address = json['address'];
    stateRegion = json['state_region'];
    city = json['city'];
    zipPostalCode = json['zip_postal_code'];
    price = json['price'];
    latitude = json['latitude'];
    longitude = json['longitude'];
    status = json['status'];
    itemTypeId = json['item_type_id'];
    image = json['image'];
    isInWishlist = json['is_in_wishlist'];
    itemType = json['item_type'];
    itemInfo = json['item_info'];
  }
  set c(bool value) {
    isInWishlist = value;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = name;
    data['item_rating'] = itemRating;
    data['mobile'] = mobile;
    data['person_allowed'] = personAllowed;
    data['address'] = address;
    data['state_region'] = stateRegion;
    data['city'] = city;
    data['zip_postal_code'] = zipPostalCode;
    data['price'] = price;
    data['latitude'] = latitude;
    data['longitude'] = longitude;
    data['status'] = status;
    data['item_type_id'] = itemTypeId;
    data['image'] = image;
    data['is_in_wishlist'] = isInWishlist;
    data['item_type'] = itemType;
    data['item_info'] = itemInfo;
    return data;
  }
}

class Brands {
  int? id;
  String? name;
  String? brandimage;

  Brands({this.id, this.name, this.brandimage});

  Brands.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    brandimage = json['brandimage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['brandimage'] = brandimage;
    return data;
  }
}

class Categories {
  int? id;
  String? name;
  String? image;

  Categories({this.id, this.name, this.image});

  Categories.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['image'] = image;
    return data;
  }
}

class OtherInfo {
  String? title;

  OtherInfo({this.title});

  OtherInfo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['title'] = title;
    return data;
  }
}
