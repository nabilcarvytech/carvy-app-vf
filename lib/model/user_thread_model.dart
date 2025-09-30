class UserThreadModel {
  int? status;
  String? message;
  Data? data;
  String? error;

  UserThreadModel({this.status, this.message, this.data, this.error});

  UserThreadModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    error = json['error'];
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
      'error': error,
    };
  }
}

class Data {
  List<Threads> threads = [];

  Data({List<Threads>? threads}) {
    if (threads != null) {
      this.threads = threads;
    }
  }

  Data.fromJson(Map<String, dynamic> json) {
    if (json['threads'] != null) {
      threads = List<Threads>.from(json['threads'].map((v) => Threads.fromJson(v)));
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'threads': threads.map((v) => v.toJson()).toList(),
    };
  }
}

class Threads {
  int? id;
  String? userId;
  String? threadId;
  String? threadStatus;
  String? title;
  String? description;
  String? createdAt;
  String? updatedAt;

  Threads({
    this.id,
    this.userId,
    this.threadId,
    this.threadStatus,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  Threads.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    threadId = json['thread_id'];
    threadStatus = json['thread_status'];
    title = json['title'];
    description = json['description'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'thread_id': threadId,
      'thread_status': threadStatus,
      'title': title,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
