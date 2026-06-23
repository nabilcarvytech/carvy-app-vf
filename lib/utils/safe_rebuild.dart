import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

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
