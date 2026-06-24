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

  @override
  void initState() {
    super.initState();
    handleBoackfromPayment = false;
    bookingController = Get.find();
    _initialTab = widget.initialTabIndex ?? 0;

    tabController = TabController(
      initialIndex: _initialTab,
      vsync: this,
      length: 4,
    );

    index = tabController!.index;

    _tabListener = () {
      if (!mounted || tabController == null) return;
      if (index != tabController!.index) {
        index = tabController!.index;

        String type;
        switch (index) {
          case 0:
            type = 'upcoming';
            break;
          case 1:
            type = 'ongoing';
            break;
          case 2:
            type = 'previous';
            break;
          case 3:
            type = 'cancelled';
            break;
          default:
            type = 'upcoming';
        }

        if (!Get.isRegistered<BookingRecordController>()) return;
        if (bookingRecordController.isClosed) return;
        if (bookingRecordController.isLoading.value) return;
        if (bookingRecordController.hasDataForType(type)) return;

        bookingRecordController.getBookingRecord(type: type, offset: 0);
      }
    };

    tabController!.addListener(_tabListener);
  }

  @override
  void dispose() {
    tabController?.removeListener(_tabListener);
    tabController?.dispose();
    super.dispose();
  }

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
                          ], // list of tabs
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        Expanded(
                          child: TabBarView(
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
