class SubCategoryModel {
  List<Subcategories>? _subcategories;

  SubCategoryModel({List<Subcategories>? subcategories}) {
    if (subcategories != null) {
       _subcategories = subcategories;
    }
  }

  List<Subcategories>? get subcategories => _subcategories;
  set subcategories(List<Subcategories>? subcategories) =>
      _subcategories = subcategories;

  SubCategoryModel.fromJson(Map<String, dynamic> json) {
    if (json['subcategories'] != null) {
      _subcategories = <Subcategories>[];
      json['subcategories'].forEach((v) {
        _subcategories!.add(   Subcategories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =    <String, dynamic>{};
    if ( _subcategories != null) {
      data['subcategories'] =
           _subcategories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Subcategories {
  int? _id;
  String? _name;

  Subcategories({int? id, String? name}) {
    if (id != null) {
       _id = id;
    }
    if (name != null) {
       _name = name;
    }
  }

  int? get id => _id;
  set id(int? id) => _id = id;
  String? get name => _name;
  set modelName(String? modelName) => _name = modelName;

  Subcategories.fromJson(Map<String, dynamic> json) {
    _id = json['id'];
    _name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =    <String, dynamic>{};
    data['id'] =  _id;
    data['name'] = name;

    return data;
  }
}
