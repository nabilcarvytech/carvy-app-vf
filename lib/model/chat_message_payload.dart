/// Message chat aligné sur le backend Node.js / Socket.IO.
class ChatMessagePayload {
  ChatMessagePayload({
    this.id,
    this.conversationId,
    required this.senderId,
    required this.text,
    this.timestampMs,
    this.attachment,
    this.seen = false,
    this.pending = false,
  });

  final String? id;
  final String? conversationId;
  final String senderId;
  final String text;
  final int? timestampMs;
  final Map<String, dynamic>? attachment;
  final bool seen;
  /// Message affiché avant confirmation serveur (UI optimiste).
  final bool pending;

  factory ChatMessagePayload.fromJson(Map<String, dynamic> json) {
    final attachment = json['attachment'];
    Map<String, dynamic>? attMap;
    if (attachment is Map) {
      attMap = Map<String, dynamic>.from(attachment);
    }

    return ChatMessagePayload(
      id: json['_id']?.toString() ??
          json['id']?.toString() ??
          json['messageId']?.toString(),
      conversationId: json['conversationId']?.toString() ??
          json['conversation_id']?.toString(),
      senderId: (json['senderId'] ??
              json['sender_id'] ??
              json['fromUserId'] ??
              '')
          .toString(),
      text: (json['text'] ??
              json['message'] ??
              json['content'] ??
              json['body'] ??
              '')
          .toString(),
      timestampMs: _parseTimestamp(json),
      attachment: attMap,
      seen: json['seen'] == true ||
          json['seen'] == 1 ||
          json['seen'] == '1',
      pending: json['_pending'] == true,
    );
  }

  static int? _parseTimestamp(Map<String, dynamic> json) {
    final t = json['timestamp'] ?? json['createdAt'] ?? json['created_at'];
    if (t == null) return null;
    if (t is int) return _normalizeEpochMs(t);
    if (t is num) return _normalizeEpochMs(t.toInt());
    final s = t.toString();
    final asInt = int.tryParse(s);
    if (asInt != null) return _normalizeEpochMs(asInt);
    try {
      return DateTime.parse(s).millisecondsSinceEpoch;
    } catch (_) {
      return null;
    }
  }

  /// Secondes Unix vs millisecondes.
  static int _normalizeEpochMs(int v) {
    if (v < 10000000000) return v * 1000;
    return v;
  }

  /// Compatibilité avec les widgets existants (_buildSenderMessage / _buildReceiverMessage).
  Map<String, dynamic> toLegacyMap() {
    final att = Map<String, dynamic>.from(attachment ?? {});
    if (!att.containsKey('image')) {
      att['image'] = '';
    }
    return <String, dynamic>{
      'message': text,
      'senderId': senderId,
      'timestamp': timestampMs ?? DateTime.now().millisecondsSinceEpoch,
      'seen': seen,
      'attachment': att,
    };
  }
}
