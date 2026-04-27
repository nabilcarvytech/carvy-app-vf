import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:carvy/service/onesignal_service.dart';
import 'package:carvy/work_space.dart';

class AuthService {
  static Future<void> initializeAuthenticatedSessionFromStorage() async {
    if (kIsWeb) return;

    final String? authToken = _readAuthToken();
    final String? userId = _readStoredUserId();

    if (authToken == null || authToken.isEmpty || userId == null || userId.isEmpty) {
      debugPrint('ℹ️ [AuthService] No authenticated user found for OneSignal sync');
      return;
    }

    await _loginToOneSignal(userId);
    await OneSignalService.forceUpdatePlayerId();
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
    await OneSignalService.forceUpdatePlayerId();
  }

  static Future<void> _loginToOneSignal(String userId) async {
    try {
      await OneSignal.login(userId);
      debugPrint('✅ [AuthService] OneSignal login ok userId=$userId');
    } catch (e) {
      debugPrint('❌ [AuthService] OneSignal login failed userId=$userId: $e');
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
}
