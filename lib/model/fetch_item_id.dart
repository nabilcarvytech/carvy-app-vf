
class FetchItemId {
  int? status;
  String? message;
  InsertItemHost? insertItemHost;
  String? error;

  FetchItemId(
      { status,  message,  insertItemHost,  error});

  FetchItemId.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    insertItemHost = json['data'] != null
        ?    InsertItemHost.fromJson(json['data'])
        : null;
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =    <String, dynamic>{};
    data['status'] =  status;
    data['message'] =  message;
    if ( insertItemHost != null) {
      data['data'] =  insertItemHost!.toJson();
    }
    data['error'] =  error;
    return data;
  }
}

class InsertItemHost {
  String? title;
  String? description;
  int? id;
  InsertItemHost({
    this.title,
    this.description,
    this.id,
  });

  InsertItemHost.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    description = json['description'];

    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data =    <String, dynamic>{};

    data['title'] = title;
    data['description'] = description;

    data['id'] = id;

    return data;
  }
}
