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
import 'package:carvy/utils/render_debug.dart';
import 'package:carvy/view/booking/widgets/booking_tab_list_body.dart';
import 'package:carvy/view/booking/widgets/my_booking_otp_overlay.dart';
import 'package:carvy/view/bottombar/home_main.dart';

class MyUpCommingTrip extends StatefulWidget {
  final bool fromPropBooking;
  final int tabIndex;
  final int initialTabIndex;
  final bool isTransitioning;

  const MyUpCommingTrip({
    super.key,
    required this.fromPropBooking,
    this.tabIndex = 0,
    this.initialTabIndex = 0,
    this.isTransitioning = true,
  });

  @override
  State<MyUpCommingTrip> createState() => _MyUpCommingTripState();
}

class _MyUpCommingTripState extends State<MyUpCommingTrip>
    with AutomaticKeepAliveClientMixin {
  final BookingRecordController bookingRecordController = Get.find();
  RefreshController refreshController = RefreshController();
  bool _localIsTransitioning = true;

  @override
  bool get wantKeepAlive => true;

  void _tryInitialFetch({bool allowRetry = true}) {
    if (!mounted) return;
    if (NavigationGuard.isNavigating) {
      if (allowRetry) _scheduleInitialFetchAfterNavigation();
      return;
    }
    final skip = bookingRecordController.shouldSkipInitialFetch(
      'upcoming',
      isActiveTab: widget.tabIndex == widget.initialTabIndex,
    );
    paymentFlowLog('STEP 14 — MyUpCommingTrip postFrame',
        'tabIndex=${widget.tabIndex}, initialTab=${widget.initialTabIndex}, skipFetch=$skip, listLen=${bookingRecordController.bookingsList.length}, isLoading=${bookingRecordController.isLoading.value}');
    if (skip) {
      if (allowRetry && NavigationGuard.isNavigating) {
        _scheduleInitialFetchAfterNavigation();
      }
      return;
    }
    getData();
  }

  void _scheduleInitialFetchAfterNavigation() {
    paymentFlowLog('STEP 14-retry — scheduling upcoming fetch after navigation');
    NavigationGuard.runWhenIdle(() async {
      if (!mounted) return;
      _tryInitialFetch(allowRetry: false);
    });
  }

  bool get _actionsLocked => widget.isTransitioning || _localIsTransitioning;

  void _scheduleLocalTransitionUnlock() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (context.findAncestorWidgetOfExactType<HomeMain>() == null) {
        setState(() => _localIsTransitioning = false);
        return;
      }
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _localIsTransitioning = false);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _localIsTransitioning = true;
    _scheduleLocalTransitionUnlock();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _tryInitialFetch();
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
    super.build(context);
    renderDebugLog(
      'MyUpCommingTrip.build',
      'tabIndex=${widget.tabIndex}, initialTab=${widget.initialTabIndex}',
    );
    return ColoredBox(
      color: notifires.getbgcolor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          SmartRefresher(
            controller: refreshController,
            physics: kBookingTabScrollPhysics,
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
              isTransitioning: _actionsLocked,
            ),
          ),
          MyBookingOtpOverlay(
            bookingRecordController: bookingRecordController,
            onShowOtp: CommonWidgets.showOtpBottomSheet,
          ),
        ],
      ),
    );
  }
}
