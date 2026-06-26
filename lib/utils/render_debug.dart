import 'package:flutter/foundation.dart';

/// Logs de diagnostic pour tracer le dernier rebuild avant `_dependents.isEmpty`.
/// Filtrer la console : `🔍 [DEBUG RENDER]`
void renderDebugLog(String source, [String? detail]) {
  if (!kDebugMode) return;
  if (detail != null && detail.isNotEmpty) {
    debugPrint('🔍 [DEBUG RENDER] $source — $detail');
  } else {
    debugPrint('🔍 [DEBUG RENDER] $source');
  }
}
