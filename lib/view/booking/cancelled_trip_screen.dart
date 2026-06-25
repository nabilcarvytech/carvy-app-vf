import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import '../../controller/booking_record_controller.dart';
import '../../model/booking_model.dart';
import '../../customwidget/data_not_found.dart';
import '../../utils/common_widget.dart';
import '../../utils/safe_rebuild.dart';

class CancelledTrip extends StatefulWidget {
  final bool fromPropBooking;
  final int tabIndex;
  final int initialTabIndex;

  const CancelledTrip({
    super.key,
    required this.fromPropBooking,
    this.tabIndex = 3,
    this.initialTabIndex = 0,
  });
  @override
  State<CancelledTrip> createState() => _CancelledTripState();
}

class _CancelledTripState extends State<CancelledTrip> {
  final BookingRecordController bookingRecordController = Get.find();
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    runAfterFirstFrame(() {
      if (!mounted) return;
      if (bookingRecordController.shouldSkipInitialFetch(
            'cancelled',
            isActiveTab: widget.tabIndex == widget.initialTabIndex,
          )) {
        return;
      }
      getData();
    });
  }

  getData() async {
    await bookingRecordController.getBookingRecord(
      type: "Cancelled",
      offset: 0,
    );

    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

  onLoading() async {
    // Pour la pagination, utiliser l'offset actuel du controller
    await bookingRecordController.getBookingRecord(
      type: "Cancelled",
      offset: bookingRecordController.offset, // Utiliser l'offset pour la pagination
    );
    refreshController.loadComplete();
  }

  onRefresh() {
    bookingRecordController.resetList();
    getData();
  }

  void onItemCancelled(int index) {
    bookingRecordController.removeBooking(index);
  }

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  stateSetter(fn) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        body: SmartRefresher(
          controller: refreshController,
          onRefresh: onRefresh,
          onLoading: onLoading,
          enablePullUp: bookingRecordController.offset == -1 ? false : true,
          child: SafeBookingRecordObx(
            builder: () {
              if (bookingRecordController.isLoading.value &&
                  bookingRecordController.bookingsList.isEmpty) {
                return myBookingScreenShimmer();
              }
              if (bookingRecordController.bookingsList.isEmpty) {
                return Center(
                  child: buildNoDataWidget(
                    context,
                    'No Cancelled Booking Available'.tr,
                  ),
                );
              }
              return myBookingListWidget(
                List<Bookings>.from(bookingRecordController.bookingsList),
                'Cancelled',
                stateSetter,
                widget.fromPropBooking,
                'Cancelled',
                onItemCancelled,
              );
            },
          ),
        ),
    );
  }
}
