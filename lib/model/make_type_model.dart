class CarMakes {
  int? status;
  String? message;
  Data? data;
  String? error;

  CarMakes({this.status, this.message, this.data, this.error});

  CarMakes.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null && json['data'] is Map<String, dynamic>
        ? Data.fromJson(json['data'])
        : null;
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
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
  List<Makes>? makes;

  Data({this.makes});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['makes'] != null) {
      makes = <Makes>[];
      json['makes'].forEach((v) {
        makes!.add(Makes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (makes != null) {
      data['makes'] = makes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Makes {
  String? id;
  String? makeName;
  String? description;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? deletedAt;
  String? image;
  String? imageUrl;
  List<dynamic>? media;

  Makes({
    this.id,
    this.makeName,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.image,
    this.imageUrl,
    this.media,
  });

  Makes.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString() ?? json['_id']?.toString();
    makeName = json['name'];
    description = json['description'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    deletedAt = json['deleted_at'];
    imageUrl = json['imageURL'];

    final dynamic imageValue = json['image'];
    image = imageValue is String || imageValue == null ? imageValue : '';

    if (json['media'] != null) {
      media = <dynamic>[];
      json['media'].forEach((v) {
        media!.add(v);
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['name'] = makeName;
    data['description'] = description;
    data['status'] = status;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['deleted_at'] = deletedAt;
    data['image'] = image;
    data['imageURL'] = imageUrl;
    if (media != null) {
      data['media'] = media!;
    }
    return data;
  }
}
