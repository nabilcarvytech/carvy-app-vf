import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/render_debug.dart';

/// Coque de cellule : aucun rendu lourd avant la fin de la frame de montage.
class SafeBookingListItemShell extends StatefulWidget {
  final Widget child;

  const SafeBookingListItemShell({super.key, required this.child});

  @override
  State<SafeBookingListItemShell> createState() =>
      _SafeBookingListItemShellState();
}

class _SafeBookingListItemShellState extends State<SafeBookingListItemShell> {
  bool _frameReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _frameReady = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();
    if (!_frameReady) {
      renderDebugLog('SafeBookingListItemShell.build', 'placeholder (frame pending)');
      return const SizedBox(height: 8);
    }
    return widget.child;
  }
}

/// Obx strictement local : monté après [Future.delayed(Duration.zero)]
/// pour éviter les rebuilds pendant l'attachement du TabController (STEP 10b).
class DeferredLocalObx extends StatefulWidget {
  final Widget Function() builder;
  final String? debugLabel;

  const DeferredLocalObx({
    super.key,
    required this.builder,
    this.debugLabel,
  });

  @override
  State<DeferredLocalObx> createState() => _DeferredLocalObxState();
}

class _DeferredLocalObxState extends State<DeferredLocalObx> {
  late final Future<void> _deferFuture;

  @override
  void initState() {
    super.initState();
    _deferFuture = Future<void>.delayed(Duration.zero);
  }

  @override
  Widget build(BuildContext context) {
    if (!context.mounted) return const SizedBox.shrink();
    return FutureBuilder<void>(
      future: _deferFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        if (!context.mounted) return const SizedBox.shrink();
        final label = widget.debugLabel ?? widget.runtimeType.toString();
        return Obx(() {
          renderDebugLog('Construisant Obx dans: $label');
          return widget.builder();
        });
      },
    );
  }
}

/// Image véhicule pour cartes réservation — sans logs, sans rebuild parasite.
Widget bookingListVehicleImage(String? image) {
  if (image == null || image.isEmpty || image == 'N/A') {
    return const Center(
      child: Icon(Icons.directions_car, color: Colors.grey, size: 40),
    );
  }

  final url = Config.getFullImageUrl(image);
  return CachedNetworkImage(
    imageUrl: url,
    fit: BoxFit.cover,
    placeholder: (_, __) => Container(
      color: grey5,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    ),
    errorWidget: (_, __, ___) => const Center(
      child: Icon(Icons.directions_car, color: Colors.grey, size: 40),
    ),
  );
}
