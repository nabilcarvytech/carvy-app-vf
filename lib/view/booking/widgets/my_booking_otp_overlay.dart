import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/booking_record_controller.dart';
import 'package:carvy/utils/extension.dart';
import 'package:carvy/utils/navigation_guard.dart';
import 'package:carvy/utils/render_debug.dart';

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
    if (Get.isRegistered<BookingController>()) {
      Get.find<BookingController>().attachOtpOverlay();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (Get.isRegistered<BookingController>()) {
      Get.find<BookingController>().detachOtpOverlay();
    }
    super.dispose();
  }

  bool _isActive(BuildContext context) =>
      !_disposed && mounted && context.mounted && NavigationGuard.allowsReactiveUi();

  @override
  Widget build(BuildContext context) {
    if (!_isActive(context)) return const SizedBox.shrink();

    return FutureBuilder<void>(
      future: _deferFuture,
      builder: (context, snapshot) {
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
            renderDebugLog('GetBuilder avec ID: otp (otpOverlay)');
            if (!_isActive(context)) return const SizedBox.shrink();
            if (bookingController.isClosed) return const SizedBox.shrink();
            if (!bookingController.otpOverlayOpen) {
              return const SizedBox.shrink();
            }

            final bookingId = bookingController.otpOverlayBookingId;
            if (bookingId.isEmpty) return const SizedBox.shrink();

            dynamic matchedBooking;
            for (final booking in widget.bookingRecordController.bookingsList) {
              if (booking.id?.toString() == bookingId) {
                matchedBooking = booking;
                break;
              }
            }
            final canOpenOtp =
                (matchedBooking?.status as String?)?.isConfirmed == true;

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!_isActive(context)) return;
              if (canOpenOtp) {
                widget.onShowOtp(context, bookingId);
              }
              if (Get.isRegistered<BookingController>() &&
                  !Get.find<BookingController>().isClosed) {
                Get.find<BookingController>().dismissOtpOverlay();
              }
            });

            return const SizedBox.shrink();
          },
        );
      },
    );
  }
}
