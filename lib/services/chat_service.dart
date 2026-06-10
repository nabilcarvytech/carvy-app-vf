import 'package:carvy/api/config.dart';
import 'package:carvy/helper/http_service.dart';

class ChatService {
  /// POST `/api/chat/get-or-create` — retourne `conversationId` (Mongo) et `compositeId`.
  static Future<Map<String, dynamic>> getOrCreateConversation(
    String bookingId,
  ) async {
    final response = await httpPostAdmin(
      Config.getOrCreateChat,
      {'bookingId': bookingId},
    );
    if (response is Map) {
      return Map<String, dynamic>.from(response);
    }
    return {'error': 'Invalid response', 'raw': response};
  }

  /// Extrait l'ObjectId Mongo de la conversation depuis la réponse get-or-create.
  static String? extractConversationId(Map<String, dynamic> response) {
    if (response['error'] != null &&
        response['conversationId'] == null &&
        response['data'] == null) {
      return null;
    }

    final data = response['data'];
    if (data is Map) {
      for (final key in [
        'conversationId',
        'conversation_id',
        '_id',
        'mongoId',
        'id',
      ]) {
        final v = data[key]?.toString().trim() ?? '';
        if (v.isNotEmpty) return v;
      }
    }

    for (final key in ['conversationId', 'conversation_id']) {
      final v = response[key]?.toString().trim() ?? '';
      if (v.isNotEmpty) return v;
    }
    return null;
  }

  /// Extrait le compositeId (legacy / diagnostic) si présent.
  static String? extractCompositeId(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map) {
      for (final key in ['compositeId', 'composite_id', 'roomId', 'room_id']) {
        final v = data[key]?.toString().trim() ?? '';
        if (v.isNotEmpty) return v;
      }
    }
    for (final key in ['compositeId', 'composite_id']) {
      final v = response[key]?.toString().trim() ?? '';
      if (v.isNotEmpty) return v;
    }
    return null;
  }
}
