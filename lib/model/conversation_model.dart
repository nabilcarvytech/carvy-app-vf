/// Élément de liste inbox (GET /api/chat/inbox).
class ConversationModel {
  ConversationModel({
    required this.conversationId,
    this.bookingId,
    this.mongoId,
    this.buyerId,
    this.sellerId,
    this.vehicleTitle,
    this.city,
    required this.itemName,
    required this.lastMessage,
    required this.fromName,
    this.imageUrl = '',
    this.bookingStatus = '',
    required this.timestampMs,
    this.recipientId,
    this.playerId,
    this.unreadCount = 0,
    this.unread = false,
  });

  final String conversationId;
  final String? bookingId;
  /// Identifiant MongoDB (_id) de la conversation si fourni par l'API.
  final String? mongoId;
  final String? buyerId;
  final String? sellerId;
  final String? vehicleTitle;
  final String? city;
  final String itemName;
  final String lastMessage;
  final String fromName;
  final String imageUrl;
  final String bookingStatus;
  final int timestampMs;
  /// ID de l’interlocuteur (pour [ConversationScreen.reciverId]).
  final String? recipientId;
  final String? playerId;
  /// Nombre de messages non lus.
  ///
  /// Peut être renvoyé par l’API sous différentes clés (ex: `unread_count`).
  final int unreadCount;
  final bool unread;

  List<String> get participants {
    final b = (buyerId ?? '').trim();
    final s = (sellerId ?? '').trim();
    if (b.isNotEmpty && s.isNotEmpty) {
      return [b, s];
    }
    final cid = conversationId.trim();
    final parts = cid.split('_').where((p) => p.trim().isNotEmpty).toList();
    if (parts.length >= 3) {
      return [parts[0], parts[2]];
    }
    if (b.isNotEmpty) return [b, ''];
    if (s.isNotEmpty) return ['', s];
    return ['', ''];
  }

  factory ConversationModel.fromJson(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final unreadCountRaw = json['unreadCount'] ?? json['unread_count'];
    final parsedUnreadCount = () {
      if (unreadCountRaw == null) {
        // Fallback : backend qui renvoie plutôt un bool `unread` / `hasUnread`.
        final boolUnread = json['unread'] == true ||
            json['unread'] == 1 ||
            json['hasUnread'] == true;
        return boolUnread ? 1 : 0;
      }
      final asStr = unreadCountRaw.toString();
      final n = int.tryParse(asStr);
      if (n != null) return n;
      if (asStr == 'true') return 1;
      return 0;
    }();

    try {
      final ts = _parseTs(
        json['timestamp'] ??
            json['updatedAt'] ??
            json['updated_at'] ??
            json['lastMessageAt'] ??
            json['last_message_at'],
      );
      
      final _lastMessageRaw = json['lastMessage'] ?? json['lastMessageText'] ?? json['last_message_text'] ?? json['message'] ?? json['last_message'] ?? json['preview'];
      String _parsedLastMessage = '';
      if (_lastMessageRaw != null) {
        if (_lastMessageRaw is Map) {
          _parsedLastMessage = (_lastMessageRaw['text'] ?? _lastMessageRaw['message'] ?? '').toString();
        } else {
          _parsedLastMessage = _lastMessageRaw.toString();
        }
      }

      return ConversationModel(
        conversationId: json['conversationId']?.toString() ?? json['conversation_id']?.toString() ?? json['roomId']?.toString() ?? json['room_id']?.toString() ?? json['id']?.toString() ?? '',
        bookingId: json['bookingId']?.toString() ?? json['booking_id']?.toString(),
        mongoId: json['_id']?.toString() ?? json['mongoId']?.toString() ?? json['conversationMongoId']?.toString(),
        buyerId: json['buyerId']?.toString() ?? json['buyer_id']?.toString() ?? json['userid']?.toString() ?? json['user_id']?.toString() ?? json['userId']?.toString(),
        sellerId: json['sellerId']?.toString() ?? json['seller_id']?.toString() ?? json['hostId']?.toString() ?? json['host_id']?.toString() ?? json['ownerId']?.toString() ?? json['owner_id']?.toString(),
        vehicleTitle: json['vehicleTitle']?.toString() ?? json['vehicle_title']?.toString() ?? json['title']?.toString(),
        city: json['city']?.toString(),
        itemName: json['itemName']?.toString() ?? json['item_title']?.toString() ?? json['title']?.toString() ?? json['propTitle']?.toString() ?? 'Sans titre',
        lastMessage: _parsedLastMessage,
        fromName: json['from']?.toString() ?? json['fromName']?.toString() ?? json['peerName']?.toString() ?? json['hostName']?.toString() ?? 'Inconnu',
        imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString() ?? json['propImg']?.toString() ?? '',
        bookingStatus: json['bookingStatus']?.toString() ?? json['booking_status']?.toString() ?? '',
        timestampMs: ts,
        recipientId: _parsePeerId(json, currentUserId),
        playerId: json['playerId']?.toString() ?? json['peerPlayerId']?.toString() ?? json['playerid_user2']?.toString() ?? json['playeridUser2']?.toString(),
        unreadCount: parsedUnreadCount,
        unread: parsedUnreadCount > 0,
      );
    } catch (e, st) {
      print('ERROR MAPPING ConversationModel: $e');
      print(st);
      rethrow;
    }
  }

  static String? _parsePeerId(Map<String, dynamic> json, String uid) {
    final a = json['recipientId']?.toString() ?? json['receiverId']?.toString();
    final b = json['senderId']?.toString() ?? json['sender_id']?.toString();
    final peer = json['peerId']?.toString() ??
        json['peer_id']?.toString() ??
        json['otherUserId']?.toString();
    if (peer != null && peer.isNotEmpty && peer != uid) return peer;
    if (a != null && a.isNotEmpty && a != uid) return a;
    if (b != null && b.isNotEmpty && b != uid) return b;
    final h = json['hostId']?.toString() ?? json['host_id']?.toString();
    if (h != null && h.isNotEmpty && h != uid) return h;
    return null;
  }

  static int _parseTs(dynamic t) {
    if (t == null) return DateTime.now().millisecondsSinceEpoch;
    if (t is int) return _norm(t);
    if (t is num) return _norm(t.toInt());
    final s = t.toString();
    final n = int.tryParse(s);
    if (n != null) return _norm(n);
    try {
      return DateTime.parse(s).millisecondsSinceEpoch;
    } catch (_) {
      return DateTime.now().millisecondsSinceEpoch;
    }
  }

  static int _norm(int v) {
    if (v < 10000000000) return v * 1000;
    return v;
  }

  ConversationModel copyWith({
    String? lastMessage,
    int? timestampMs,
    int? unreadCount,
    bool? unread,
  }) {
    final nextUnreadCount = unreadCount ??
        (() {
          if (unread == null) return this.unreadCount;
          if (unread == true) return this.unreadCount > 0 ? this.unreadCount : 1;
          return 0;
        })();
    final nextUnread = unreadCount != null ? nextUnreadCount > 0 : (unread ?? this.unread);

    return ConversationModel(
      conversationId: conversationId,
      bookingId: bookingId,
      mongoId: mongoId,
      buyerId: buyerId,
      sellerId: sellerId,
      vehicleTitle: vehicleTitle,
      city: city,
      itemName: itemName,
      lastMessage: lastMessage ?? this.lastMessage,
      fromName: fromName,
      imageUrl: imageUrl,
      bookingStatus: bookingStatus,
      timestampMs: timestampMs ?? this.timestampMs,
      recipientId: recipientId,
      playerId: playerId,
      unreadCount: nextUnreadCount,
      unread: nextUnread,
    );
  }
}
