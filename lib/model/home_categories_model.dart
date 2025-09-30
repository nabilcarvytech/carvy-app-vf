class HomeCategories {
  int? status;
  Message? message;
  String? data;
  String? error;

  HomeCategories({ status,  message,  data,  error});

  HomeCategories.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message =
        json['message'] != null ? Message.fromJson(json['message']) : null;
    data = json['data'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (message != null) {
      data['message'] = message!.toJson();
    }
    data['data'] =  data;
    data['error'] = error;
    return data;
  }
}

class Message {
  List<CategoriesHome>? categories;

  Message({ categories});

  Message.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <CategoriesHome>[];
      json['categories'].forEach((v) {
        categories!.add(CategoriesHome.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (categories != null) {
      data['categories'] = categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CategoriesHome {
  int? id;
  String? name;
  String? image;

  CategoriesHome({ id,  name,  image});

  CategoriesHome.fromJson(Map<String, dynamic> json) {
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

