import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/utils/onesignal_sync_helper.dart';
import 'package:carvy/work_space.dart';

class AuthService {
  static const String _subscriptionIdKey = 'onesignal_subscription_id';
  static const String _subscriptionOptedInKey = 'onesignal_subscription_opted_in';

  static bool _subscriptionObserverAttached = false;
  static OnPushSubscriptionChangeObserver? _subscriptionObserver;

  static Future<void> initializeAuthenticatedSessionFromStorage() async {
    if (kIsWeb) return;

    final String? authToken = _readAuthToken();
    final String? userId = _readStoredUserId();

    if (authToken == null || authToken.isEmpty || userId == null || userId.isEmpty) {
      debugPrint('ℹ️ [AuthService] No authenticated user found for OneSignal sync');
      return;
    }

    await _loginToOneSignal(userId);
    await syncOneSignalSubscription(force: false, authToken: authToken);
    _attachSubscriptionObserver();
  }

  static Future<void> handleAuthenticatedUser({
    required String authToken,
    required dynamic userId,
  }) async {
    if (kIsWeb) return;

    final String normalizedUserId = userId.toString();
    if (authToken.isEmpty || normalizedUserId.isEmpty) {
      return;
    }

    await _loginToOneSignal(normalizedUserId);
    await syncOneSignalSubscription(force: true, authToken: authToken);
    _attachSubscriptionObserver();
  }

  static Future<void> syncOneSignalSubscription({
    bool force = false,
    String? authToken,
  }) async {
    if (kIsWeb) return;

    final String? resolvedToken = authToken ?? _readAuthToken();
    if (resolvedToken == null || resolvedToken.isEmpty) {
      debugPrint('⚠️ [AuthService] Missing auth token, skip OneSignal sync');
      return;
    }

    token = resolvedToken;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? currentSubscriptionId = await _readCurrentSubscriptionId();
    final bool optedIn = OneSignal.User.pushSubscription.optedIn ?? false;

    final String? lastStoredSubscriptionId = prefs.getString(_subscriptionIdKey);
    final bool? lastStoredOptedIn = prefs.getBool(_subscriptionOptedInKey);

    final String playerIdForBackend =
        optedIn ? (currentSubscriptionId ?? '') : '';

    final bool subscriptionChanged =
        currentSubscriptionId != lastStoredSubscriptionId;
    final bool optedInChanged = lastStoredOptedIn != optedIn;
    final bool shouldSync =
        force || subscriptionChanged || optedInChanged || lastStoredSubscriptionId == null;

    if (!shouldSync) {
      debugPrint('ℹ️ [AuthService] OneSignal subscription already synced');
      return;
    }

    final String fcmToken = await _readFcmToken();

    try {
      final dynamic res = await httpPost(
        Config.fcmUpdate,
        {
          'fcm': fcmToken,
          'player_id': playerIdForBackend,
        },
      );

      if (res is Map && res['_invalidOneSignalPlayerId'] == true) {
        oneSignalPushLog(
          'sync_subscription_invalid_player',
          res['_httpStatusCode'] is int ? res['_httpStatusCode'] as int : null,
          userId: _readStoredUserId(),
          detail: 'clearing_local_registration',
        );
        await clearInvalidPlayerRegistrationCache();
        return;
      }

      oneSiginalplayerid = playerIdForBackend;
      GetStorage().write('oneSiginalplayerid', playerIdForBackend);
      await prefs.setString(_subscriptionIdKey, currentSubscriptionId ?? '');
      await prefs.setBool(_subscriptionOptedInKey, optedIn);

      oneSignalPushLog(
        'sync_subscription_ok',
        res is Map && res['_httpStatusCode'] is int
            ? res['_httpStatusCode'] as int
            : null,
        userId: _readStoredUserId(),
        detail: 'optedIn=$optedIn',
      );
    } catch (e, st) {
      oneSignalPushLog(
        'sync_subscription_exception',
        null,
        userId: _readStoredUserId(),
        detail: e.toString(),
      );
      debugPrint('❌ [AuthService] Failed to sync OneSignal subscription: $e\n$st');
    }
  }

  static void _attachSubscriptionObserver() {
    if (_subscriptionObserverAttached) return;

    _subscriptionObserver = (OSPushSubscriptionChangedState state) {
      debugPrint(
        '🔄 [AuthService] OneSignal subscription changed: '
        '${state.previous.id} -> ${state.current.id}, '
        'optedIn=${state.current.optedIn}',
      );
      unawaited(syncOneSignalSubscription(force: true));
    };

    OneSignal.User.pushSubscription.addObserver(_subscriptionObserver!);
    _subscriptionObserverAttached = true;
  }

  static Future<void> _loginToOneSignal(String userId) async {
    try {
      await OneSignal.login(userId);
      oneSignalPushLog('onesignal_sdk_login', null, userId: userId, detail: 'ok');
    } catch (e) {
      oneSignalPushLog(
        'onesignal_sdk_login',
        null,
        userId: userId,
        detail: e.toString(),
      );
    }
  }

  /// Après `invalid_player_ids` côté serveur : vide le cache local pour forcer une resync au prochain cold start / login.
  static Future<void> clearInvalidPlayerRegistrationCache() async {
    if (kIsWeb) return;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove(_subscriptionIdKey);
      await prefs.remove(_subscriptionOptedInKey);
      GetStorage().remove('oneSiginalplayerid');
      oneSiginalplayerid = '';
    } catch (e) {
      oneSignalPushLog('clear_local_player_cache', null, detail: e.toString());
    }
  }

  static String? _readAuthToken() {
    final String? storedToken = GetStorage().read('token');
    if (storedToken != null && storedToken.isNotEmpty) {
      return storedToken;
    }

    final dynamic rawUserData = GetStorage().read('user_data');
    if (rawUserData is String && rawUserData.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(rawUserData);
        final dynamic userToken = decoded['data']?['token'];
        if (userToken != null && userToken.toString().isNotEmpty) {
          return userToken.toString();
        }
      } catch (_) {}
    }

    if (token.isNotEmpty) {
      return token;
    }
    return null;
  }

  static String? _readStoredUserId() {
    final dynamic storedUserId = GetStorage().read('userIdGlobal');
    if (storedUserId != null && storedUserId.toString().isNotEmpty) {
      return storedUserId.toString();
    }

    final dynamic rawUserData = GetStorage().read('user_data');
    if (rawUserData is String && rawUserData.isNotEmpty) {
      try {
        final dynamic decoded = jsonDecode(rawUserData);
        final dynamic id = decoded['data']?['id'];
        if (id != null) {
          return id.toString();
        }
      } catch (_) {}
    }

    if (userId != null && userId.toString().isNotEmpty) {
      return userId.toString();
    }

    return null;
  }

  static Future<String?> _readCurrentSubscriptionId() async {
    String? subscriptionId = OneSignal.User.pushSubscription.id;

    for (int attempt = 0;
        (subscriptionId == null || subscriptionId.isEmpty) && attempt < 5;
        attempt++) {
      await Future.delayed(const Duration(seconds: 1));
      subscriptionId = OneSignal.User.pushSubscription.id;
    }

    return subscriptionId;
  }

  static Future<String> _readFcmToken() async {
    try {
      return await FirebaseMessaging.instance.getToken() ?? '';
    } catch (_) {
      return '';
    }
  }
}
