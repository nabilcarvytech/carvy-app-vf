import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:carvy/api/config.dart';

class OneSignalService {
  static Future<void> initialize() async {
    if (kIsWeb) return;

    try {
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(Config.oneSiginalAppid);
      await OneSignal.Notifications.requestPermission(true);
      debugPrint('✅ [OneSignalService] Initialisation OneSignal terminée');
    } catch (e) {
      debugPrint('❌ [OneSignalService] Erreur initialisation OneSignal: $e');
    }
  }
}
