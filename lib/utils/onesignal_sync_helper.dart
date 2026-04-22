import 'package:flutter/foundation.dart';

/// Logs concis pour le flux push / fcm-update (status, user court, action).
void oneSignalPushLog(
  String action,
  int? httpStatus, {
  String? userId,
  String? detail,
}) {
  final String uid = _shortUserId(userId);
  final String extra = detail != null && detail.isNotEmpty ? ' | $detail' : '';
  debugPrint('[push] action=$action | http=$httpStatus | user=$uid$extra');
}

String _shortUserId(String? userId) {
  if (userId == null || userId.isEmpty) return '-';
  final t = userId.trim();
  if (t.length <= 6) return t;
  return '…${t.substring(t.length - 6)}';
}

/// Détecte une réponse serveur indiquant un player OneSignal invalide
/// (à aligner avec le backend Node / Laravel qui propage l’erreur OneSignal).
///
/// Formats reconnus (non exhaustif) :
/// - Corps texte contenant `invalid_player_id` (couvre `invalid_player_ids`)
/// - JSON : `code` / `error` / `message` / `ResponseMsg` contenant la même clé
/// - JSON : clé `invalid_player_ids` présente (liste ou bool)
bool responseIndicatesInvalidOneSignalPlayer({
  required dynamic decodedBody,
  required int httpStatus,
  required String rawBody,
}) {
  final String lower = rawBody.toLowerCase();
  if (lower.contains('invalid_player_id')) {
    return true;
  }

  if (decodedBody is! Map) return false;
  final map = Map<String, dynamic>.from(decodedBody);

  bool strHas(dynamic v) =>
      v != null && v.toString().toLowerCase().contains('invalid_player_id');

  if (strHas(map['error'])) return true;
  if (strHas(map['message'])) return true;
  if (strHas(map['ResponseMsg'])) return true;
  if (strHas(map['code'])) return true;

  final dynamic inv = map['invalid_player_ids'];
  if (inv != null) {
    if (inv is List && inv.isNotEmpty) return true;
    if (inv is bool && inv) return true;
    if (inv is String && inv.isNotEmpty) return true;
  }

  final dynamic errs = map['errors'];
  if (errs != null && errs.toString().toLowerCase().contains('invalid_player_id')) {
    return true;
  }

  // Certaines API renvoient 200 avec success: false
  if (map['success'] == false && strHas(map['errors'] ?? map['message'])) {
    return true;
  }

  return false;
}

/// Ajoute des clés internes pour les appelants ([_invalidOneSignalPlayerId], [_httpStatusCode]).
void augmentFcmUpdateResponseIfNeeded({
  required String path,
  required String fcmUpdatePath,
  required dynamic responseData,
  required int httpStatus,
  required String rawBody,
}) {
  if (path != fcmUpdatePath || responseData is! Map) return;
  final map = responseData as Map<String, dynamic>;
  map['_httpStatusCode'] = httpStatus;
  if (responseIndicatesInvalidOneSignalPlayer(
        decodedBody: map,
        httpStatus: httpStatus,
        rawBody: rawBody,
      )) {
    map['_invalidOneSignalPlayerId'] = true;
  }
}
