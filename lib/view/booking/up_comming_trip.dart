import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/controller/booking_controller.dart';
import '../../controller/booking_record_controller.dart';
import '../../customwidget/data_not_found.dart';
import '../../customwidget/project_color.dart';
import '../../utils/extension.dart';
import '../../utils/common_widget.dart';
import '../../utils/safe_rebuild.dart';

class MyUpCommingTrip extends StatefulWidget {
  final bool fromPropBooking;

  const MyUpCommingTrip({
    super.key,
    required this.fromPropBooking,
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
    runAfterFirstFrame(() {
      if (!mounted) return;
      if (bookingRecordController.shouldSkipInitialFetch('upcoming')) return;
      getData();
    });
  }

  getData() async {
    await bookingRecordController.getBookingRecord(
      type: "upcoming",
      offset: 0,
    );

    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

  onLoading() async {
    // Pour la pagination, utiliser l'offset actuel du controller
    await bookingRecordController.getBookingRecord(
      type: "upcoming",
      offset: bookingRecordController.offset, // Utiliser l'offset pour la pagination
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
    refreshController.dispose(); // Dispose the RefreshController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      body: Stack(
        children: [
          SafeBookingRecordObx(
            builder: () => SmartRefresher(
                controller: refreshController,
                onRefresh: onRefresh,
                onLoading: onLoading,
                enablePullUp:
                    bookingRecordController.offset == -1 ? false : true,
                child: bookingRecordController.isLoading.value
                    ? myBookingScreenShimmer()
                    : bookingRecordController.bookingsList.isEmpty
                        ? Center(
                            child: buildNoDataWidget(
                              context,
                              "No Upcoming Booking Available".tr,
                            ),
                          )
                        : myBookingListWidget(
                            bookingRecordController.bookingsList,
                            "Cancel",
                            stateSetter,
                            widget.fromPropBooking,
                            "UpComing",
                            onItemCancelled,
                          ),
              ),
          ),
          SafeBookingRecordObx(builder: () {
            if (!Get.isRegistered<BookingController>() ||
                Get.find<BookingController>().isClosed) {
              return const SizedBox.shrink();
            }
            final bookingController = Get.find<BookingController>();
            if (bookingController.openOtpAfterImageSubmit.value) {
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
                if (canOpenOtp) {
                  CommonWidgets.showOtpBottomSheet(context, bookingId);
                }
                bookingController.openOtpAfterImageSubmit.value = false;
              });
            }
            return SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
