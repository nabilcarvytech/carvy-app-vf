import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/work_space.dart';

class OneSignalService {
  static bool _observerAttached = false;
  static String? _lastSentPlayerId;

  static Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(Config.oneSiginalAppid);
      await OneSignal.Notifications.requestPermission(true);
      _attachPushSubscriptionObserver();
      debugPrint('✅ [OneSignalService] Initialisation OneSignal terminée');
    } catch (e) {
      debugPrint('❌ [OneSignalService] Erreur initialisation OneSignal: $e');
    }
  }

  static void _attachPushSubscriptionObserver() {
    if (_observerAttached) return;
    OneSignal.User.pushSubscription.addObserver((state) {
      final String? newId = state.current.id;
      if (newId != null && newId.isNotEmpty) {
        debugPrint('✅ [ONESIGNAL] ID généré dynamiquement : $newId');
        updateServerPlayerId(newId);
      }
    });
    _observerAttached = true;
  }

  /// Sync immédiate, sans attente/retry: si l'ID est déjà disponible on l'envoie.
  static Future<void> forceUpdatePlayerId() async {
    if (kIsWeb) return;
    final String? currentId = OneSignal.User.pushSubscription.id;
    if (currentId == null || currentId.isEmpty) {
      debugPrint('ℹ️ [NOTIF_SYNC] ID OneSignal non prêt, observer en attente');
      return;
    }
    await updateServerPlayerId(currentId);
  }

  static Future<void> updateServerPlayerId(String id) async {
    if (kIsWeb) return;

    try {
      if (_lastSentPlayerId == id) {
        debugPrint('ℹ️ [NOTIF_SYNC] ID déjà synchronisé, skip: $id');
        return;
      }
      final String? authToken = _readAuthToken();
      if (authToken == null || authToken.isEmpty) {
        debugPrint('🚀 [NOTIF_SYNC] Skip: token utilisateur absent');
        return;
      }

      token = authToken;
      debugPrint('🚀 [NOTIF_SYNC] Tentative d\'envoi OneSignal ID...');

      await httpPost(
        Config.updateOneSignalId,
        {
          'player_id': id,
          'oneSignalPlayerId': id,
        },
      );

      oneSiginalplayerid = id;
      GetStorage().write('oneSiginalplayerid', id);
      _lastSentPlayerId = id;
      debugPrint('✅ [NOTIF_SYNC] ID envoyé au serveur : $id');
    } catch (e) {
      debugPrint('❌ [NOTIF_SYNC] Échec de synchronisation OneSignal: $e');
    }
  }

  static String? _readAuthToken() {
    final String? storedToken = GetStorage().read('token');
    if (storedToken != null && storedToken.isNotEmpty) return storedToken;
    if (token.isNotEmpty) return token;
    return null;
  }
}
