import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/controller/booking_controller.dart';
import '../../controller/booking_record_controller.dart';
import '../../customwidget/project_color.dart';
import '../../utils/extension.dart';
import '../../utils/common_widget.dart';
import '../../utils/navigation_guard.dart';
import '../../utils/payment_flow_debug.dart';
import '../../utils/safe_rebuild.dart';
import 'package:carvy/view/booking/widgets/booking_tab_list_body.dart';
import 'package:carvy/view/booking/widgets/safe_booking_list_helpers.dart';

class MyUpCommingTrip extends StatefulWidget {
  final bool fromPropBooking;
  final int tabIndex;
  final int initialTabIndex;

  const MyUpCommingTrip({
    super.key,
    required this.fromPropBooking,
    this.tabIndex = 0,
    this.initialTabIndex = 0,
  });

  @override
  State<MyUpCommingTrip> createState() => _MyUpCommingTripState();
}

class _MyUpCommingTripState extends State<MyUpCommingTrip> {
  final BookingRecordController bookingRecordController = Get.find();
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || NavigationGuard.isNavigating) return;
        final skip = bookingRecordController.shouldSkipInitialFetch(
          'upcoming',
          isActiveTab: widget.tabIndex == widget.initialTabIndex,
        );
        paymentFlowLog('STEP 14 — MyUpCommingTrip postFrame',
            'tabIndex=${widget.tabIndex}, initialTab=${widget.initialTabIndex}, skipFetch=$skip, listLen=${bookingRecordController.bookingsList.length}, isLoading=${bookingRecordController.isLoading.value}');
        if (skip) return;
        getData();
      });
    });
  }

  getData() async {
    paymentFlowLog('STEP 15 — getBookingRecord(upcoming) START');
    await bookingRecordController.getBookingRecord(
      type: 'upcoming',
      offset: 0,
    );
    paymentFlowLog('STEP 16 — getBookingRecord(upcoming) END',
        'count=${bookingRecordController.bookingsList.length}');

    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

  onLoading() async {
    await bookingRecordController.getBookingRecord(
      type: 'upcoming',
      offset: bookingRecordController.offset,
    );
    refreshController.loadComplete();
  }

  onRefresh() {
    bookingRecordController.resetList();
    getData();
  }

  stateSetter(fn) => setState(() {});

  void onItemCancelled(int index) {
    bookingRecordController.removeBooking(index);
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      body: Stack(
        children: [
          SmartRefresher(
            controller: refreshController,
            onRefresh: onRefresh,
            onLoading: onLoading,
            enablePullUp: bookingRecordController.offset == -1 ? false : true,
            child: BookingTabListBody(
              controller: bookingRecordController,
              fromPropBooking: widget.fromPropBooking,
              listType: 'UpComing',
              btnText: 'Cancel',
              emptyMessage: 'No Upcoming Booking Available'.tr,
              stateSetter: stateSetter,
              onItemCancelled: onItemCancelled,
            ),
          ),
          DeferredLocalObx(
            builder: () {
              if (!Get.isRegistered<BookingController>() ||
                  Get.find<BookingController>().isClosed) {
                return const SizedBox.shrink();
              }
              final bookingController = Get.find<BookingController>();
              if (!bookingController.openOtpAfterImageSubmit.value) {
                return const SizedBox.shrink();
              }
              final bookingId = bookingController.currentBookingIdForOtp.value;
              dynamic matchedBooking;
              for (final booking in bookingRecordController.bookingsList) {
                if (booking.id?.toString() == bookingId) {
                  matchedBooking = booking;
                  break;
                }
              }
              final canOpenOtp =
                  (matchedBooking?.status as String?)?.isConfirmed == true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!context.mounted) return;
                if (canOpenOtp) {
                  CommonWidgets.showOtpBottomSheet(context, bookingId);
                }
                if (Get.isRegistered<BookingController>() &&
                    !Get.find<BookingController>().isClosed) {
                  bookingController.openOtpAfterImageSubmit.value = false;
                }
              });
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
