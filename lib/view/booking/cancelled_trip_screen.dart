import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/customwidget/project_color.dart';
import '../../controller/booking_record_controller.dart';
import '../../utils/common_widget.dart';
import '../../utils/navigation_guard.dart';
import 'package:carvy/utils/render_debug.dart';
import 'package:carvy/view/booking/widgets/booking_tab_list_body.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || NavigationGuard.isNavigating) return;
        if (bookingRecordController.shouldSkipInitialFetch(
              'cancelled',
              isActiveTab: widget.tabIndex == widget.initialTabIndex,
            )) {
          return;
        }
        getData();
      });
    });
  }

  getData() async {
    await bookingRecordController.getBookingRecord(
      type: 'Cancelled',
      offset: 0,
    );
    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

  onLoading() async {
    await bookingRecordController.getBookingRecord(
      type: 'Cancelled',
      offset: bookingRecordController.offset,
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
    renderDebugLog(
      'CancelledTrip.build',
      'tabIndex=${widget.tabIndex}, initialTab=${widget.initialTabIndex}',
    );
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: onRefresh,
        onLoading: onLoading,
        enablePullUp: bookingRecordController.offset == -1 ? false : true,
        child: BookingTabListBody(
          controller: bookingRecordController,
          fromPropBooking: widget.fromPropBooking,
          listType: 'Cancelled',
          btnText: 'Cancelled',
          emptyMessage: 'No Cancelled Booking Available'.tr,
          stateSetter: stateSetter,
          onItemCancelled: onItemCancelled,
        ),
      ),
    );
  }
}
