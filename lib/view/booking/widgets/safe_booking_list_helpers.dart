import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:pinput/pinput.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/model/booking_model.dart';
import 'package:carvy/utils/extension.dart';
import 'package:carvy/utils/render_debug.dart';
import 'package:carvy/utils/theme_style.dart';

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

/// Bouton Drop OTP — montage séquentiel (50 ms × index) pour éviter 10 Obx simultanés au STEP 10b.
class MyBookingDropoffOtpAction extends StatefulWidget {
  final int cellIndex;
  final String listType;
  final Bookings booking;
  final BookingController bookingController;
  final StateSetter onStateUpdate;

  const MyBookingDropoffOtpAction({
    super.key,
    required this.cellIndex,
    required this.listType,
    required this.booking,
    required this.bookingController,
    required this.onStateUpdate,
  });

  @override
  State<MyBookingDropoffOtpAction> createState() =>
      _MyBookingDropoffOtpActionState();
}

class _MyBookingDropoffOtpActionState extends State<MyBookingDropoffOtpAction> {
  late final Future<void> _deferFuture;

  @override
  void initState() {
    super.initState();
    _deferFuture = Future<void>.delayed(
      Duration(milliseconds: 50 * widget.cellIndex),
    );
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

        return Obx(() {
          renderDebugLog(
            'Construisant Obx dans: myBookingList/dropoffOtp[${widget.cellIndex}]',
          );
          final controller = widget.bookingController;
          if (controller.dropoffshowHise.value) {
            return const SizedBox.shrink();
          }
          if (widget.listType != 'Previous' ||
              widget.booking.isItemReturned != 0 ||
              widget.booking.status.isConfirmed != true) {
            return const SizedBox.shrink();
          }

          return Expanded(
            flex: 1,
            child: InkWell(
              onTap: () => _openDropoffOtpSheet(context),
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  height: 49,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 10,
                    top: 0,
                    bottom: 0,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: vehicalThemColor,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    color: vehicalThemColor,
                  ),
                  child: Text(
                    'Drop OTP?'.tr,
                    style: boldstyle(context).copyWith(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  void _openDropoffOtpSheet(BuildContext context) {
    final controller = widget.bookingController;
    showModalBottomSheet<String>(
      isScrollControlled: true,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setBottomSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Enter OTP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Enter the Dropoff OTP given by the vendor.'.tr,
                      style: regular02.copyWith(
                        color: vehicalThemColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Pinput(
                      length: 4,
                      controller: controller.dropOtpController,
                      keyboardType: TextInputType.number,
                      mainAxisAlignment: MainAxisAlignment.center,
                      defaultPinTheme: PinTheme(
                        width: 50,
                        height: 50,
                        textStyle: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: vehicalThemColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CustomsButtons(
                      text: 'Submit',
                      backgroundColor: vehicalThemColor,
                      onPressed: () {
                        if (controller.dropOtpController.text.isEmpty) {
                          showErrorToastMessage('Please fill the OTP');
                          return;
                        }
                        controller
                            .updateItemDeliverStatus(
                          bookingId: widget.booking.id.toString(),
                        )
                            .then((value) {
                          if (value == 'yes') {
                            Navigator.pop(context);
                          } else {
                            setBottomSheetState(() {});
                          }
                        }).catchError((error) {
                          debugPrint('Error in OTP verification: $error');
                          showErrorToastMessage('OTP verification failed.');
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    widget.onStateUpdate(() {});
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
