import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import '../../controller/booking_record_controller.dart';
import '../../customwidget/project_color.dart';
import '../../utils/common_widget.dart';
import '../../utils/navigation_guard.dart';
import '../../utils/safe_rebuild.dart';
import 'package:carvy/view/booking/widgets/booking_tab_list_body.dart';

class PreviousTrip extends StatefulWidget {
  final bool fromPropBooking;
  final int tabIndex;
  final int initialTabIndex;

  const PreviousTrip({
    super.key,
    required this.fromPropBooking,
    this.tabIndex = 2,
    this.initialTabIndex = 0,
  });

  @override
  State<PreviousTrip> createState() => _PreviousTripState();
}

class _PreviousTripState extends State<PreviousTrip> {
  final BookingRecordController bookingRecordController = Get.find();
  RefreshController refreshController = RefreshController();

  void onItemCancelled(int index) {
    bookingRecordController.removeBooking(index);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || NavigationGuard.isNavigating) return;
        if (bookingRecordController.shouldSkipInitialFetch(
              'previous',
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
      type: 'previous',
      offset: 0,
    );
    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

  onLoading() async {
    await bookingRecordController.getBookingRecord(
      type: 'previous',
      offset: bookingRecordController.offset,
    );
    refreshController.loadComplete();
  }

  onRefresh() {
    bookingRecordController.resetList();
    getData();
  }

  stateSetter(fn) => setState(() {});

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          listType: 'Previous',
          btnText: 'Add Review',
          emptyMessage: 'No Previous Booking Available'.tr,
          stateSetter: stateSetter,
          onItemCancelled: onItemCancelled,
        ),
      ),
    );
  }
}
