import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/customwidget/check_internet_connection.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/booking/cancelled_trip_screen.dart';
import 'package:carvy/view/booking/liveBooking.dart';
import 'package:carvy/view/booking/up_comming_trip.dart';
import 'package:carvy/view/booking/previous_trip_screen.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import '../../controller/booking_controller.dart';
import '../../controller/booking_record_controller.dart';
import '../../utils/common_widget.dart';
import '../../utils/navigation_guard.dart';
import '../../utils/payment_flow_debug.dart';
import '../../work_space.dart';

class MyBooking extends StatefulWidget {
  final bool? fromPropBooking;
  int? initialTabIndex;

  MyBooking({super.key, this.fromPropBooking, this.initialTabIndex});
  @override
  State<MyBooking> createState() => _MyBookingState();
}

class _MyBookingState extends State<MyBooking> with TickerProviderStateMixin {
  late BookingController bookingController;
  final BookingRecordController bookingRecordController = Get.find();

  TabController? tabController;
  late VoidCallback _tabListener;
  int index = 0;
  late final int _initialTab;
  bool _routeReady = false;
  bool _disposed = false;

  String _typeForIndex(int tabIndex) {
    switch (tabIndex) {
      case 1:
        return 'ongoing';
      case 2:
        return 'previous';
      case 3:
        return 'cancelled';
      default:
        return 'upcoming';
    }
  }

  void _fetchActiveTabRecord() {
    if (!mounted || _disposed || NavigationGuard.isNavigating) return;
    if (!Get.isRegistered<BookingRecordController>()) return;
    if (bookingRecordController.isClosed) return;

    final type = _typeForIndex(_initialTab);
    if (bookingRecordController.shouldSkipInitialFetch(
      type,
      isActiveTab: true,
    )) {
      return;
    }

    bookingRecordController.getBookingRecord(type: type, offset: 0);
  }

  void _initTabControllerAfterMount() {
    if (!mounted || _disposed || tabController != null) return;

    tabController = TabController(
      initialIndex: _initialTab,
      vsync: this,
      length: 4,
    );
    index = tabController!.index;
    tabController!.addListener(_tabListener);

    if (!NavigationGuard.isNavigating) {
      _fetchActiveTabRecord();
    }

    setState(() => _routeReady = true);
    paymentFlowLog('STEP 10b — MyBooking tabController ready',
        'initialTab=$_initialTab');
  }

  @override
  void initState() {
    super.initState();
    handleBoackfromPayment = false;
    bookingController = Get.find();
    _initialTab = widget.initialTabIndex ?? 0;
    paymentFlowLog('STEP 10a — MyBooking initState',
        'initialTab=$_initialTab, fromPropBooking=${widget.fromPropBooking}');

    _tabListener = () {
      if (!mounted || _disposed || tabController == null) return;
      if (tabController!.indexIsChanging) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _disposed || tabController == null) return;
        if (tabController!.indexIsChanging) return;
        if (index != tabController!.index) {
          index = tabController!.index;

          final type = _typeForIndex(index);

          if (!Get.isRegistered<BookingRecordController>()) return;
          if (bookingRecordController.isClosed) return;
          if (NavigationGuard.isNavigating) return;
          if (bookingRecordController.isLoading.value) return;
          if (bookingRecordController.hasDataForType(type)) return;

          bookingRecordController.getBookingRecord(type: type, offset: 0);
        }
      });
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _disposed) return;
      _initTabControllerAfterMount();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    final controller = tabController;
    if (controller != null) {
      controller.removeListener(_tabListener);
      controller.dispose();
      tabController = null;
    }
    super.dispose();
  }

  bool get _tabControllerUsable =>
      !_disposed && _routeReady && tabController != null;

  /// Retour AppBar / système : compatible Navigator.push, onglet principal et Get.offAll(MyBooking).
  void _onBackPressed(BuildContext context) {
    final nav = Navigator.of(context);

    if (nav.canPop()) {
      try {
        generalController.tabController.animateTo(0);
      } catch (_) {}
      generalController.currentIndex.value = 0;
      nav.pop();
      return;
    }

    final inHomeShell =
        context.findAncestorWidgetOfExactType<HomeMain>() != null;
    if (inHomeShell) {
      try {
        if (generalController.tabController.index != 0) {
          generalController.tabController.animateTo(0);
        }
      } catch (_) {}
      generalController.currentIndex.value = 0;
      return;
    }

    Get.offAll(() => HomeMain(initialIndex: 0));
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);

    if (!_routeReady || !_tabControllerUsable) {
      return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) return;
          _onBackPressed(context);
        },
        child: Align(
          alignment: Alignment.center,
          child: SizedBox(
            width: Dimensions.containerWidth,
            child: Scaffold(
              backgroundColor: notifires.getbgcolor,
              appBar: AppBar(
                backgroundColor: vehicalThemColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leadingWidth: 56,
                centerTitle: true,
                leading: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => _onBackPressed(context),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: whiteColor,
                    size: 20,
                  ),
                ),
                title: Text(
                  "My Booking".tr,
                  style: heading2Grey1(context).copyWith(color: whiteColor),
                ),
              ),
              body: const SizedBox.shrink(),
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        _onBackPressed(context);
      },
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Dimensions.containerWidth,
          child: ConnectivityWrapper(
            child: Scaffold(
                backgroundColor: notifires.getbgcolor,
                appBar: AppBar(
                  backgroundColor: vehicalThemColor,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  leadingWidth: 56,
                  centerTitle: true,
                  leading: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () => _onBackPressed(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: whiteColor,
                      size: 20,
                    ),
                  ),
                  title: Text("My Booking".tr,
                      style:
                          heading2Grey1(context).copyWith(color: whiteColor)),
                ),
                body: token.isEmpty
                    ? Center(child: notloginwidget())
                    : SafeArea(
                        child: Column(children: <Widget>[
                        TabBar(
                          indicatorColor: getColorBasedOnActiveModuleid(),
                          controller: tabController,
                          labelColor: getColorBasedOnActiveModuleid(),
                          labelStyle: heading3Grey1(context),
                          unselectedLabelColor: notifires.getGrey3Whitecolor,
                          tabs: [
                            Tab(
                              text: "Upcoming".tr,
                            ),
                            Tab(
                              text: "Live".tr,
                            ),
                            Tab(
                              text: "Completed".tr,
                            ),
                            Tab(
                              text: "Cancelled".tr,
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Expanded(
                          child: tabController!.indexIsChanging
                              ? const SizedBox.shrink()
                              : TabBarView(
                            controller: tabController,
                            children: [
                              MyUpCommingTrip(
                                  fromPropBooking:
                                      widget.fromPropBooking ?? false,
                                  tabIndex: 0,
                                  initialTabIndex: _initialTab),
                              LiveBooking(
                                  fromPropBooking:
                                      widget.fromPropBooking ?? false,
                                  tabIndex: 1,
                                  initialTabIndex: _initialTab),
                              PreviousTrip(
                                  fromPropBooking:
                                      widget.fromPropBooking ?? false,
                                  tabIndex: 2,
                                  initialTabIndex: _initialTab),
                              CancelledTrip(
                                  fromPropBooking:
                                      widget.fromPropBooking ?? false,
                                  tabIndex: 3,
                                  initialTabIndex: _initialTab),
                            ],
                          ),
                        ),
                      ]))),
          ),
        ),
      ),
    );
  }
}
