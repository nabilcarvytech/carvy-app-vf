class ReplyThreadsModel {
  int? status;
  String? message;
  ReplyData? data;
  String? error;

  ReplyThreadsModel({this.status, this.message, this.data, this.error});

  ReplyThreadsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? ReplyData.fromJson(json['data']) : null;
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

class ReplyData {
  List<ReplyThreadsData>? replyThreadsData;

  ReplyData({this.replyThreadsData});

  ReplyData.fromJson(Map<String, dynamic> json) {
    if (json['replyThreads'] != null) {
      replyThreadsData = <ReplyThreadsData>[];
      json['replyThreads'].forEach((v) {
        replyThreadsData!.add(ReplyThreadsData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (replyThreadsData != null) {
      data['replyThreads'] = replyThreadsData!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class ReplyThreadsData {
  int? id;
  String? threadId;
  String? userId;
  String? isAdminReply;
  String? message;
  String? createdAt;
  String? updatedAt;
  String? replyStatus;

  ReplyThreadsData({
    this.id,
    this.threadId,
    this.userId,
    this.isAdminReply,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.replyStatus,
  });

  ReplyThreadsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    threadId = json['thread_id'];
    userId = json['user_id'];
    isAdminReply = json['is_admin_reply'];
    message = json['message'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    replyStatus = json['reply_status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['thread_id'] = threadId;
    data['user_id'] = userId;
    data['is_admin_reply'] = isAdminReply;
    data['message'] = message;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['reply_status'] = replyStatus;
    return data;
  }
}
