import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

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

/// Obx « espion » : logue [spyName] à chaque rebuild GetX.
class DebugObx extends StatelessWidget {
  final String spyName;
  final Widget Function() builder;

  const DebugObx({
    super.key,
    required this.spyName,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      renderDebugLog('Construisant Obx dans: $spyName');
      return builder();
    });
  }
}

/// GetBuilder « espion » : logue [id] à chaque rebuild contrôleur.
class DebugGetBuilder<T extends GetxController> extends StatelessWidget {
  final String id;
  final T controller;
  final Widget Function(T c) builder;

  const DebugGetBuilder({
    super.key,
    required this.id,
    required this.controller,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<T>(
      id: id,
      init: controller,
      builder: (c) {
        renderDebugLog('GetBuilder avec ID: $id');
        return builder(c);
      },
    );
  }
}
