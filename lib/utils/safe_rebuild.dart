import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:carvy/utils/navigation_guard.dart';
import 'package:carvy/utils/render_debug.dart';

/// Exécute [action] après la fin de la frame courante (hors phase build).
void runAfterFirstFrame(VoidCallback action) {
  WidgetsBinding.instance.addPostFrameCallback((_) => action());
}

/// Lance [action] après la première frame.
void runAfterFirstFrameAsync(Future<void> Function() action) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    action();
  });
}

bool _isDuringBuildPhase() {
  final phase = SchedulerBinding.instance.schedulerPhase;
  return phase == SchedulerPhase.midFrameMicrotasks ||
      phase == SchedulerPhase.persistentCallbacks;
}

/// Obx protégé : vérifie [isActive] à chaque rebuild.
class SafeObx extends StatelessWidget {
  final bool Function() isActive;
  final Widget Function() builder;
  final String? spyName;
  /// Bloque tout rebuild Obx pendant [NavigationGuard.isNavigating].
  final bool guardNavigation;

  const SafeObx({
    super.key,
    required this.isActive,
    required this.builder,
    this.spyName,
    this.guardNavigation = false,
  });

  bool _isFullyActive() {
    if (guardNavigation && !NavigationGuard.allowsReactiveUi()) return false;
    return isActive();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isFullyActive()) {
      return const SizedBox.shrink();
    }
    return DebugObx(
      spyName: spyName ?? 'SafeObx',
      builder: () {
        if (!_isFullyActive()) {
          return const SizedBox.shrink();
        }
        return builder();
      },
    );
  }
}

/// Obx protégé par [BuildContext.mounted] — évite les rebuilds sur routes en démontage.
class MountedSafeObx extends StatelessWidget {
  final Widget Function() builder;
  final String? spyName;

  const MountedSafeObx({
    super.key,
    required this.builder,
    this.spyName,
  });

  @override
  Widget build(BuildContext context) {
    return DebugObx(
      spyName: spyName ?? 'MountedSafeObx',
      builder: () {
        if (!context.mounted) return const SizedBox.shrink();
        return builder();
      },
    );
  }
}

/// Extensions GetX : évite `markNeedsBuild() called during build`.
extension SafeGetxUpdate on GetxController {
  void safeUpdate([List<Object>? ids, bool condition = true]) {
    if (!condition || isClosed) return;
    if (_isDuringBuildPhase()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) update(ids, condition);
      });
      return;
    }
    update(ids, condition);
  }
}
