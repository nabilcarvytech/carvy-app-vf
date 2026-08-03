import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/controller/booking_record_controller.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/navigation_guard.dart';
import 'package:carvy/utils/render_debug.dart';
import 'package:carvy/view/booking/widgets/booking_tab_list_body.dart';

class LiveBooking extends StatefulWidget {
  final bool fromPropBooking;
  final int tabIndex;
  final int initialTabIndex;
  final bool isTransitioning;

  const LiveBooking({
    super.key,
    required this.fromPropBooking,
    this.tabIndex = 1,
    this.initialTabIndex = 0,
    this.isTransitioning = true,
  });

  @override
  State<LiveBooking> createState() => _LiveBookingState();
}

class _LiveBookingState extends State<LiveBooking>
    with AutomaticKeepAliveClientMixin {
  final BookingRecordController bookingRecordController = Get.find();
  RefreshController refreshController = RefreshController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || NavigationGuard.isNavigating) return;
        if (bookingRecordController.shouldSkipInitialFetch(
              'ongoing',
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
      type: 'ongoing',
      offset: 0,
    );
    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

  onLoading() async {
    await bookingRecordController.getBookingRecord(
      type: 'ongoing',
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
    super.build(context);
    renderDebugLog(
      'LiveBooking.build',
      'tabIndex=${widget.tabIndex}, initialTab=${widget.initialTabIndex}',
    );
    return ColoredBox(
      color: notifires.getbgcolor,
      child: SmartRefresher(
        controller: refreshController,
        physics: kBookingTabScrollPhysics,
        onRefresh: onRefresh,
        onLoading: onLoading,
        enablePullUp: bookingRecordController.offset == -1 ? false : true,
        child: BookingTabListBody(
          controller: bookingRecordController,
          fromPropBooking: widget.fromPropBooking,
          listType: 'ongoing',
          btnText: 'Extend duration',
          emptyMessage: 'No Ongoing Booking Available'.tr,
          stateSetter: stateSetter,
          onItemCancelled: onItemCancelled,
          isTransitioning: widget.isTransitioning,
        ),
      ),
    );
  }
}
