class CategoryModel {
  int? status;
  Message? message;
  String? data;
  String? error;

  CategoryModel({int? status, Message? message, String? data, String? error}) {
    if (status != null) {
      this.status = status;
    }
    if (message != null) {
      this.message = message;
    }
    if (data != null) {
      this.data = data;
    }
    if (error != null) {
      this.error = error;
    }
  }

  CategoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'] != null ? Message.fromJson(json['message']) : null;
    data = json['data'];
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (message != null) {
      data['message'] = message!.toJson();
    }
    data['data'] = this.data;
    data['error'] = error;
    return data;
  }
}

class Message {
  List<Categories>? categories;

  Message({List<Categories>? categories}) {
    if (categories != null) {
      this.categories = categories;
    }
  }

  Message.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(Categories.fromJson(v));
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

class Categories {
  int? id;
  String? name;
  String? image;

  Categories({int? id, String? name, String? image}) {
    if (id != null) {
      this.id = id;
    }
    if (name != null) {
      this.name = name;
    }
    if (image != null) {
      this.image = image;
    }
  }

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
