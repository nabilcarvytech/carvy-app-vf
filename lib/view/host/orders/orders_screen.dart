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

  Future<bool> handleWillPop() async {
    generalController.tabController.index = 0;
    generalController.currentIndex.value = 0;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return PopScope(
      canPop: false,
      onPopInvoked: (v) => handleWillPop,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Dimensions.containerWidth,
          child: Scaffold(
              backgroundColor: notifires.getbgcolor,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                backgroundColor: notifires.getbgcolor,
                elevation: 0,
                leadingWidth: 80,
                centerTitle: true,
                leading: widget.fromPropBooking == false
                    ? const SizedBox()
                    : GestureDetector(
                        onTap: () {
                          if (widget.fromPropBooking == true) {
                            Get.back();
                            return;
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 20, top: 8, bottom: 8, right: 20),
                          child: PhysicalModel(
                            color: Colors.transparent,
                            shadowColor: notifires.getGrey4Whitecolor,
                            elevation:
                                5.0, // Adjust the elevation value as needed
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              alignment: Alignment.center,
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                  color: notifires.getboxcolor,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Icon(Icons.arrow_back,
                                  color: getColorBasedOnActiveModuleid()),
                            ),
                          ),
                        )),
                title: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text("Orders".tr, style: heading2Grey1(context)),
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
