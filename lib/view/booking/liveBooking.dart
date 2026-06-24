import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/controller/booking_record_controller.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/safe_rebuild.dart';

class LiveBooking extends StatefulWidget {
  final bool fromPropBooking;
  final int tabIndex;
  final int initialTabIndex;

  const LiveBooking({
    super.key,
    required this.fromPropBooking,
    this.tabIndex = 1,
    this.initialTabIndex = 0,
  });

  @override
  State<LiveBooking> createState() => _LiveBookingState();
}

class _LiveBookingState extends State<LiveBooking> {
  final BookingRecordController bookingRecordController = Get.find();
  RefreshController refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    runAfterFirstFrame(() {
      if (!mounted) return;
      if (bookingRecordController.shouldSkipInitialFetch(
            'ongoing',
            isActiveTab: widget.tabIndex == widget.initialTabIndex,
          )) {
        return;
      }
      getData();
    });
  }

  getData() async {
    await bookingRecordController.getBookingRecord(
      type: "ongoing",
      offset: 0,
    );

    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

  onLoading() async {
    // Pour la pagination, utiliser l'offset actuel du controller
    await bookingRecordController.getBookingRecord(
      type: "ongoing",
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
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        body: SafeBookingRecordObx(
          builder: () => SmartRefresher(
          controller: refreshController,
          onRefresh: onRefresh,
          onLoading: onLoading,
          enablePullUp: bookingRecordController.offset == -1 ? false : true,
          child: bookingRecordController.isLoading.value
              ? myBookingScreenShimmer()
              : bookingRecordController.bookingsList.isEmpty
                  ? Center(
                      child: buildNoDataWidget(
                        context,
                        "No Ongoing Booking Available".tr,
                      ),
                    )
                  : myBookingListWidget(
                      bookingRecordController.bookingsList,
                      "Extend duration",
                      stateSetter,
                      widget.fromPropBooking,
                      "ongoing",
                      onItemCancelled,
                    ),
        ),
        ),
    );
  }
}
