import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:provider/provider.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/orders/cancel_orders.dart';
import 'package:carvy/view/host/orders/live_orders.dart';
import 'package:carvy/view/host/orders/previous_orders.dart';
import 'package:carvy/view/host/orders/upcoming_orders.dart';
import 'package:carvy/work_space.dart';

import '../../../controller/booking_controller.dart';
import '../../../utils/common_widget.dart';

class OrdersScreen extends StatefulWidget {
  final bool? fromPropBooking;
  const OrdersScreen({super.key, this.fromPropBooking});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late BookingController bookingController;

  TabController? tabController;
  int index = 0;
  @override
  void initState() {
    super.initState();

    bookingController = Get.find();
    tabController = TabController(initialIndex: 0, vsync: this, length: 4);
    tabController!.addListener(() {
      index = tabController!.index;
      setState(() {});
    });
  }

  @override
  void dispose() {
    tabController?.removeListener(() {}); // Remove listener
    tabController?.dispose(); // Dispose of the TabController
    super.dispose();
  }

  void _onExitPushedOrders(BuildContext context) {
    generalController.tabController.index = 0;
    generalController.currentIndex.value = 0;
    if (Navigator.of(context).canPop()) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    final bool isPushedRoute = Navigator.of(context).canPop();
    return PopScope(
      canPop: !isPushedRoute,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        _onExitPushedOrders(context);
      },
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Dimensions.containerWidth,
          child: Scaffold(
              backgroundColor: notifires.getbgcolor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: getColorBasedOnActiveModuleid(),
                foregroundColor: whiteColor,
                surfaceTintColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                leadingWidth: 80,
                centerTitle: true,
                leading: !isPushedRoute
                    ? const SizedBox()
                    : IconButton(
                        padding: const EdgeInsets.only(left: 12),
                        onPressed: () => _onExitPushedOrders(context),
                        icon: Icon(
                          Icons.arrow_back_ios_new,
                          color: whiteColor,
                          size: 20,
                        ),
                      ),
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "Orders".tr,
                    style: heading2Grey1(context).copyWith(color: whiteColor),
                  ),
                ),
              ),
              body: showerrorWhenloginwithOtherDevice == "token not match"
                  ? Center(child: showTokenExpirePlease())
                  : token.isEmpty
                      ? Center(child: notloginwidget())
                      : SafeArea(
                          child: Column(children: <Widget>[
                          TabBar(
                            indicatorColor: getColorBasedOnActiveModuleid(),
                            controller: tabController,
                            labelColor: getColorBasedOnActiveModuleid(),
                            labelStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700),
                            unselectedLabelColor: Colors.grey,
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
                                UpcomingOrders(
                                    fromPropBooking: widget.fromPropBooking!),
                                LiveOrderds(
                                    fromPropBooking: widget.fromPropBooking!),
                                PreviousOrders(
                                    fromPropBooking: widget.fromPropBooking!),
                                CancelOrders(
                                    fromPropBooking: widget.fromPropBooking!),
                              ],
                            ),
                          ),
                        ]))),
        ),
      ),
    );
  }
}
