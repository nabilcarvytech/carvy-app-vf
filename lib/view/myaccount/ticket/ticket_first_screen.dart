import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/ticket_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/myaccount/ticket/ticket_close_screen.dart';
import 'package:carvy/view/myaccount/ticket/ticket_create_screen.dart';
import 'package:carvy/view/myaccount/ticket/ticket_open_screen.dart';
import 'package:carvy/work_space.dart';

class TicketFirstScreen extends StatefulWidget {
  const TicketFirstScreen({super.key});

  @override
  State<TicketFirstScreen> createState() => _TicketFirstScreenState();
}

TicketController ticketController = Get.find();

class _TicketFirstScreenState extends State<TicketFirstScreen>
    with SingleTickerProviderStateMixin {
  TabController? tabController;
  int index = 0;

  List list = [
    const OpenTicketScreen(),
    const CloseTicketScreen(),
  ];

  @override
  void initState() {
    super.initState();
    tabController = TabController(initialIndex: 0, vsync: this, length: 2);
    tabController!.addListener(() {
      index = tabController!.index;
      setState(() {});
    });
  }

  stateSetter(fn) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        if (isHostMode.value == true) {
          generalController.currentIndexHost.value == 4;
          generalController.tabControllerHost.index == 4;
          Get.to(() => const BottomHost(initialIndex: 4));
        } else {
          generalController.currentIndex.value == 4;
          generalController.tabController.index == 4;
          Get.to(() => const HomeMain(initialIndex: 4));
        }
      },
      child: Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: AppBar(
          backgroundColor: notifires.getbgcolor,
          elevation: 0,
          leadingWidth: 80,
          leading: InkWell(
            onTap: () {
              if (isHostMode.value == true) {
                generalController.currentIndexHost.value == 4;
                generalController.tabControllerHost.index == 4;
                Get.to(const BottomHost(initialIndex: 4));
              } else {
                generalController.currentIndex.value == 4;
                generalController.tabController.index == 4;
                Get.to(const HomeMain(initialIndex: 4));
              }
            },
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 20, top: 8, bottom: 8, right: 20),
              child: PhysicalModel(
                color: Colors.transparent,
                shadowColor: notifires.getGrey4Whitecolor,
                elevation: 1.0, // Adjust the elevation value as needed
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
            ),
          ),
          centerTitle: true,
          title: Text(
            'Ticket'.tr,
            style: heading2Grey1(context).copyWith(),
          ),
          actions: [
            InkWell(
                onTap: () {
                  Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const TicketCreateScreen()))
                      .then((value) async {
                    ticketController.ticketLoading.value = true;
                    await Future.delayed(const Duration(seconds: 1));
                    ticketController.ticketLoading.value = false;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Image.asset('assets/images/Plus.png',
                      color:
                          getColorBasedOnActiveModuleid() // Your desired color
                      ),
                ))
          ],
        ),
        body: SafeArea(
            child: Column(children: <Widget>[
          TabBar(
            controller: tabController,
            labelColor: getColorBasedOnActiveModuleid(),
            labelStyle: heading3(context).copyWith(),
            unselectedLabelColor: notifires.getGrey3Whitecolor,

            tabs: [
              Tab(
                text: 'Open'.tr,
              ),
              Tab(
                text: 'Closed'.tr,
              ),
            ], // list of tabs
          ),
          const SizedBox(
            height: 8,
          ),
          Expanded(child: list[index]),
        ])),
      ),
    );
  }
}
