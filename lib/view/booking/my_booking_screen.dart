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
  int index = 0;
  @override
  void initState() {
    super.initState();
    handleBoackfromPayment = false;
    bookingController = Get.find();
    print(widget.initialTabIndex);

    tabController = TabController(
      initialIndex: widget.initialTabIndex ?? 0,
      vsync: this,
      length: 4,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      tabController!.animateTo(widget.initialTabIndex ?? 0);
    });

    tabController!.addListener(() {
      if (index != tabController!.index) {
        index = tabController!.index;
        
        // Appeler getBookingRecord explicitement selon l'onglet sélectionné
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
        
        // Appeler l'API explicitement lors du changement d'onglet
        bookingRecordController.getBookingRecord(type: type, offset: 0);
        
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (widget.initialTabIndex != null) {
      tabController!.animateTo(widget.initialTabIndex!);
    }
  }

  @override
  void dispose() {
    tabController?.removeListener(() {});
    tabController?.dispose();
    super.dispose();
  }

  /// Retour depuis l’écran poussé (ex. compte) : réinitialise l’onglet accueil puis ferme la route.
  void _onExitPushedBooking(BuildContext context) {
    generalController.tabController.animateTo(0);
    generalController.currentIndex.value = 0;
    if (Navigator.of(context).canPop()) {
      Get.back();
    }
  }

  /// Retour depuis l’onglet « Mes réservations » dans la barre du bas : aller à l’accueil (Explorer).
  void _goToHomeTab() {
    if (generalController.tabController.index != 0) {
      generalController.tabController.animateTo(0);
    }
    generalController.currentIndex.value = 0;
  }

  void _onBackPressed(BuildContext context) {
    if (Navigator.of(context).canPop()) {
      _onExitPushedBooking(context);
    } else {
      _goToHomeTab();
    }
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
                                      widget.fromPropBooking ?? false),
                              LiveBooking(
                                  fromPropBooking:
                                      widget.fromPropBooking ?? false),
                              PreviousTrip(
                                  fromPropBooking:
                                      widget.fromPropBooking ?? false),
                              CancelledTrip(
                                  fromPropBooking:
                                      widget.fromPropBooking ?? false),
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
