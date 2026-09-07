import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/booking_record_controller.dart';
import 'package:carvy/utils/extension.dart';
import 'package:carvy/utils/navigation_guard.dart';
import 'package:carvy/utils/render_debug.dart';
import 'package:carvy/utils/black_screen_debug.dart';

/// Overlay OTP post-upload — GetBuilder manuel (pas d'Obx) + délai 100 ms.
class MyBookingOtpOverlay extends StatefulWidget {
  final BookingRecordController bookingRecordController;
  final void Function(BuildContext context, String bookingId) onShowOtp;

  const MyBookingOtpOverlay({
    super.key,
    required this.bookingRecordController,
    required this.onShowOtp,
  });

  @override
  State<MyBookingOtpOverlay> createState() => _MyBookingOtpOverlayState();
}

class _MyBookingOtpOverlayState extends State<MyBookingOtpOverlay> {
  late final Future<void> _deferFuture;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _deferFuture = Future<void>.delayed(const Duration(milliseconds: 100));
    blackScreenLog('OtpOverlay initState');
    if (Get.isRegistered<BookingController>()) {
      Get.find<BookingController>().attachOtpOverlay();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    blackScreenLog('OtpOverlay dispose');
    if (Get.isRegistered<BookingController>()) {
      Get.find<BookingController>().detachOtpOverlay();
    }
    super.dispose();
  }

  bool _isActive(BuildContext context) =>
      !_disposed &&
      mounted &&
      context.mounted &&
      NavigationGuard.allowsReactiveUi();

  @override
  Widget build(BuildContext context) {
    try {
      if (!_isActive(context)) {
        blackScreenLog('OtpOverlay build → shrink (inactive)', {
          'disposed': _disposed,
          'mounted': mounted,
          'allowsReactiveUi': NavigationGuard.allowsReactiveUi(),
          'isNavigating': NavigationGuard.isNavigating,
        });
        return const SizedBox.shrink();
      }

      return FutureBuilder<void>(
        future: _deferFuture,
        builder: (context, snapshot) {
          try {
            if (snapshot.connectionState != ConnectionState.done) {
              return const SizedBox.shrink();
            }
            if (!_isActive(context)) return const SizedBox.shrink();
            if (!Get.isRegistered<BookingController>()) {
              return const SizedBox.shrink();
            }

            return GetBuilder<BookingController>(
              id: BookingController.otpOverlayId,
              builder: (bookingController) {
                try {
                  renderDebugLog('GetBuilder avec ID: otp (otpOverlay)');
                  blackScreenLog('OtpOverlay GetBuilder rebuild', {
                    'otpOverlayOpen': bookingController.otpOverlayOpen,
                    'otpOverlayBookingId':
                        bookingController.otpOverlayBookingId,
                    'isClosed': bookingController.isClosed,
                  });
                  if (!_isActive(context)) return const SizedBox.shrink();
                  if (bookingController.isClosed) {
                    return const SizedBox.shrink();
                  }
                  if (!bookingController.otpOverlayOpen) {
                    return const SizedBox.shrink();
                  }

                  final bookingId = bookingController.otpOverlayBookingId;
                  if (bookingId.isEmpty) return const SizedBox.shrink();

                  dynamic matchedBooking;
                  for (final booking
                      in widget.bookingRecordController.bookingsList) {
                    if (booking.id?.toString() == bookingId) {
                      matchedBooking = booking;
                      break;
                    }
                  }
                  final canOpenOtp =
                      (matchedBooking?.status as String?)?.isConfirmed == true;

                  blackScreenLog('OtpOverlay scheduling onShowOtp', {
                    'bookingId': bookingId,
                    'matched': matchedBooking != null,
                    'canOpenOtp': canOpenOtp,
                    'listLen':
                        widget.bookingRecordController.bookingsList.length,
                  });

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!_isActive(context)) {
                      blackScreenLog(
                        'OtpOverlay onShowOtp aborted',
                        'inactive after frame',
                      );
                      return;
                    }
                    try {
                      if (canOpenOtp) {
                        blackScreenLog(
                          'OtpOverlay onShowOtp INVOKED',
                          bookingId,
                        );
                        widget.onShowOtp(context, bookingId);
                      } else {
                        blackScreenLog(
                          'OtpOverlay onShowOtp skipped',
                          'canOpenOtp=false bookingId=$bookingId',
                        );
                      }
                      if (Get.isRegistered<BookingController>() &&
                          !Get.find<BookingController>().isClosed) {
                        Get.find<BookingController>().dismissOtpOverlay();
                      }
                    } catch (e, st) {
                      blackScreenCatch('OtpOverlay.onShowOtp', e, st, extra: {
                        'bookingId': bookingId,
                        'canOpenOtp': canOpenOtp,
                      });
                    }
                  });

                  return const SizedBox.shrink();
                } catch (e, st) {
                  blackScreenCatch('OtpOverlay.GetBuilder', e, st);
                  return const SizedBox.shrink();
                }
              },
            );
          } catch (e, st) {
            blackScreenCatch('OtpOverlay.FutureBuilder', e, st);
            return const SizedBox.shrink();
          }
        },
      );
    } catch (e, st) {
      blackScreenCatch('OtpOverlay.build', e, st);
      return const SizedBox.shrink();
    }
  }
}
