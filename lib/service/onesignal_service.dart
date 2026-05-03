import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/work_space.dart';

class OneSignalService {
  /// UUID OneSignal attendu (aligné sur la console + `Config.oneSiginalAppid`).
  static const String kExpectedOneSignalAppId =
      '849877b4-f438-495e-8ccd-62f016aaa09c';

  static bool _observerAttached = false;
  static String? _lastSentPlayerId;

  /// Déconnecte l’utilisateur externe, désinscrit le push puis ré-inscrit pour
  /// limiter la réutilisation d’un ancien Player ID (ex. compte banni côté OneSignal).
  /// À appeler **après** `OneSignal.initialize` (requis par le SDK).
  static Future<void> _forceDisconnectAndRefreshPushSubscription() async {
    final String? idBefore = OneSignal.User.pushSubscription.id;
    print('🔄 [OS_RESET] --- Déconnexion forcée (logout + optOut → optIn) ---');
    print('🔄 [OS_RESET] Player ID SDK avant reset: "$idBefore"');

    _lastSentPlayerId = null;
    try {
      GetStorage().remove('oneSiginalplayerid');
    } catch (_) {}
    oneSiginalplayerid = '';

    try {
      await OneSignal.logout();
      print('✅ [OS_RESET] OneSignal.logout() OK');
    } catch (e) {
      print('⚠️ [OS_RESET] OneSignal.logout() : $e');
    }

    try {
      await OneSignal.User.pushSubscription.optOut();
      print('✅ [OS_RESET] pushSubscription.optOut() OK');
    } catch (e) {
      print('⚠️ [OS_RESET] pushSubscription.optOut() : $e');
    }

    await Future.delayed(const Duration(milliseconds: 900));
    print(
        '🔄 [OS_RESET] Player ID après logout/optOut: "${OneSignal.User.pushSubscription.id}"');

    try {
      await OneSignal.User.pushSubscription.optIn();
      print('✅ [OS_RESET] pushSubscription.optIn() OK');
    } catch (e) {
      print('⚠️ [OS_RESET] pushSubscription.optIn() : $e');
    }

    await Future.delayed(const Duration(milliseconds: 600));
    final String? idAfter = OneSignal.User.pushSubscription.id;
    print('🟢 [OS_NEW_ID] Player ID courant après optIn: "$idAfter"');
    if (idAfter != null &&
        idAfter.isNotEmpty &&
        idAfter != idBefore &&
        idBefore != null &&
        idBefore.isNotEmpty) {
      print(
          '🟢 [OS_NEW_ID] L’ID a changé par rapport au cache pré-reset (nouvel abonnement probable).');
    } else if (idAfter == idBefore &&
        idBefore != null &&
        idBefore.isNotEmpty) {
      print(
          '⚠️ [OS_NEW_ID] Même Player ID qu’avant reset — délai natif ou cache appareil ; surveiller invalid_player_ids côté API.');
    }
  }

  /// Audit UUID App ID : espaces, longueur, caractères invisibles — juste avant le SDK.
  static void logAppIdConfigDiagnostic({String source = 'DIAG_CONFIG'}) {
    final String raw = Config.oneSiginalAppid;
    final String trimmed = raw.trim();
    debugPrint('🚨 [$source] — Audit App ID avant OneSignal.initialize');
    debugPrint('🚨 [$source] longueur=${raw.length} | trim() == raw: ${trimmed == raw}');
    debugPrint('🚨 [$source] valeur (guillemets pour espaces visibles): "$raw"');
    if (trimmed != raw) {
      debugPrint(
          '🚨 [$source] ⚠ espaces en tête/queue — après trim (len=${trimmed.length}): "$trimmed"');
    }
    final List<int> suspicious = raw.codeUnits
        .where((c) => c < 0x20 || c == 0x7F)
        .toSet()
        .toList()
      ..sort();
    if (suspicious.isNotEmpty) {
      debugPrint(
          '🚨 [$source] ⚠ codeUnits suspects (contrôle / non imprimable): $suspicious');
    }
    debugPrint('🚨 [$source] codeUnits complets: ${raw.codeUnits}');
  }

  static Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      logAppIdConfigDiagnostic(source: 'DIAG_SERVICE_CONFIG');

      final String appId = Config.oneSiginalAppid;
      if (appId != kExpectedOneSignalAppId) {
        debugPrint(
            '⚠️ [OS_INIT] Config.oneSiginalAppid != référence attendue — valeur: "$appId"');
      }
      print('🔔 [OS_INIT] OneSignal.initialize( appId="$appId" )');
      OneSignal.initialize(appId);

      // Reset avant l’observateur : évite d’envoyer un ancien Player ID banni à l’API.
      await _forceDisconnectAndRefreshPushSubscription();

      _attachPushSubscriptionObserver();
      await OneSignal.Notifications.requestPermission(true);
      final String? idPostPerm = OneSignal.User.pushSubscription.id;
      print('🟢 [OS_NEW_ID] Player ID après requestPermission: "$idPostPerm"');
      if (idPostPerm != null && idPostPerm.isNotEmpty) {
        print(
            '🟢 [OS_NEW_ID] Sync immédiate post-init avec l’ID SDK courant (endpoint).');
        await updateServerPlayerId(idPostPerm);
      }

      debugPrint('✅ [OneSignalService] Initialisation OneSignal terminée');
    } catch (e) {
      debugPrint('❌ [OneSignalService] Erreur initialisation OneSignal: $e');
    }
  }

  static void _attachPushSubscriptionObserver() {
    if (_observerAttached) return;
    OneSignal.User.pushSubscription.addObserver((state) {
      print(
          "🚨 [DIAG_FCM] Token Google (FCM): ${state.current.token}"); // Si vide, Google Play Services échoue.
      print(
          "🚨 [DIAG_ONESIGNAL] Player ID: ${state.current.id}"); // Si vide mais token présent, config OneSignal web erronée.
      print("🚨 [DIAG_PERM] Opted In: ${state.current.optedIn}");

      final String? newId = state.current.id;
      if (newId != null && newId.isNotEmpty) {
        print('🟢 [OS_NEW_ID] Observer → Player ID actuel pour sync backend: "$newId"');
        debugPrint('✅ [ONESIGNAL] ID généré dynamiquement : $newId');
        updateServerPlayerId(newId);
      }
    });
    _observerAttached = true;
  }

  /// Sync immédiate, sans attente/retry: si l'ID est déjà disponible on l'envoie.
  static Future<void> forceUpdatePlayerId() async {
    if (kIsWeb) return;
    String? currentId = OneSignal.User.pushSubscription.id;
    if (currentId == null || currentId.isEmpty) {
      print("⚠️ ID non disponible, vérification des permissions...");
      await OneSignal.Notifications.requestPermission(true);
      await Future.delayed(const Duration(seconds: 2));
      currentId = OneSignal.User.pushSubscription.id;
      if (currentId == null || currentId.isEmpty) {
        debugPrint('ℹ️ [NOTIF_SYNC] ID OneSignal non prêt, observer en attente');
        return;
      }
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
      print(
          '🟢 [OS_ENDPOINT] POST ${Config.baseurl}${Config.updateOneSignalId} — body player_id / onesignal_id = "$id"');

      final dynamic apiResponse = await httpPost(
        Config.updateOneSignalId,
        {
          'onesignal_id': id,
          'player_id': id,
          'oneSignalPlayerId': id,
        },
      );
      debugPrint('📥 [DEBUG_SYNC] Réponse API (${Config.updateOneSignalId}): $apiResponse');

      oneSiginalplayerid = id;
      GetStorage().write('oneSiginalplayerid', id);
      _lastSentPlayerId = id;
      print("📲 OneSignal ID synchronisé : $id");
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
