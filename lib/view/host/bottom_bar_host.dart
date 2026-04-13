import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/customwidget/check_internet_connection.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/calender/calendar_common_screen.dart';
import 'package:carvy/view/host/orders/orders_screen.dart';
import 'package:carvy/view/host/initial_host_common_screen.dart';
import 'package:carvy/view/host/dash_board_screen.dart';
import 'package:carvy/view/vehicle/add_vehicle_screen.dart';
import 'package:carvy/view/myaccount/account_screen.dart';
import 'package:carvy/work_space.dart';
import '../../controller/global_scope_controller.dart';
import '../../controller/push_notifications.dart';
import '../../utils/common_widget.dart';
import '../chat/inbox_screen.dart';

class BottomHost extends StatefulWidget {
  final int? initialIndex;
  const BottomHost({super.key, required this.initialIndex});
  @override
  State<BottomHost> createState() => _BottomHostScreenState();
}

class _BottomHostScreenState extends State<BottomHost>
    with TickerProviderStateMixin {
  GlobalScopeController globalScopeController = Get.find();
  AuthController authController = Get.find();
  AnimationController? controller;
  List<Widget> list = [
    const DashBoardScreen(mode: ScreenMode.edit),
    const CalendarCommonScreen(),
    const OrdersScreen(fromPropBooking: false),
    const InboxScreen(),
    const AccountScreen(),
  ];
  bool darkMode = GetStorage().read("getDarkValue") ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showNotification();
    });

    getUserDataLocallyToHandleTheState();

    generalController.fetchGeneralSettings();

    generalController.tabControllerHost = TabController(
        length: 5, vsync: this, initialIndex: widget.initialIndex!);
    generalController.tabControllerHost.addListener(() {
      generalController.currentIndexHost.value =
          generalController.tabControllerHost.index;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Obx(
      () => generalController.failed.value == true
          ? Scaffold(
              backgroundColor: notifires.getbgcolor,
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset("assets/images/offline.svg"),
                    const SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Something went wrong".tr,
                      style: TextStyle(color: notifires.getwhiteblackcolor),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    InkWell(
                        onTap: () {
                          generalController.fetchGeneralSettings();
                        },
                        child: Text(
                          "Reload",
                          style: heading03.copyWith(
                              color: getColorBasedOnActiveModuleid(),
                              decorationColor: getColorBasedOnActiveModuleid(),
                              decoration: TextDecoration.underline),
                        )),
                  ],
                ),
              ),
            )
          : generalController.hasGeneralData.value == true
              ? Scaffold(
                  backgroundColor: notifires.getbgcolor,
                  body: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              commonlyUserlogo(),
                              const SizedBox(
                                height: 15,
                              ),
                              Text(
                                appName.tr,
                                style: bigHeadingh1.copyWith(
                                    color: notifires.getwhiteblackcolor),
                              )
                            ]),
                      ),
                    ],
                  ),
                )
              : PopScope(
                  canPop: false,
                  onPopInvoked: (didPop) async {
                    if (didPop) return;
                    
                    // Si on n'est pas sur l'onglet principal (index 0), on y retourne
                    if (generalController.currentIndexHost.value != 0) {
                      generalController.tabControllerHost.animateTo(0);
                      generalController.currentIndexHost.value = 0;
                      return; // Empêche de fermer l'application
                    } else {
                      // Si on est déjà sur l'accueil (index 0), on affiche le popup "Souhaitez-vous quitter ?"
                      if (!webPlateForm) {
                        dialogExit(context);
                      }
                    }
                  },
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    backgroundColor: notifires.getbgcolor,
                    body: ConnectivityWrapper(
                      child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: generalController.tabControllerHost,
                        children: list,
                        // children: vehicleListHost,
                      ),
                    ),
                  floatingActionButtonAnimator:
                      FloatingActionButtonAnimator.scaling,
                  floatingActionButton: InkWell(
                    onTap: () {
                      if (showerrorWhenloginwithOtherDevice ==
                              "token not match" ||
                          showerrorWhenloginwithOtherDevice ==
                              "The token field is required.") {
                        showErrorToastMessage("Please login again");

                        return;
                      }
                      if (checkItemPiblicationLimit.toString() == "0") {
                        showErrorToastMessage(
                            "You have reached the limit for publishing items. Please contact the admin for further assistance.");
                        return;
                      }

                      Get.to(() => const AddVehicleScreen());
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                              color: notifires.getblackwhitecolor,
                              offset: const Offset(0, 5),
                              blurRadius: 6)
                        ],
                        border: Border.all(
                            width: 2,
                            color: generalController.currentIndexHost.value == 2
                                ? Colors.black
                                : getColorBasedOnActiveModuleid()),
                        borderRadius: BorderRadius.circular(50),
                        color: whiteColor,
                      ),
                      child: Center(
                        child: Icon(Icons.add,
                            size: 30,
                            color: generalController.currentIndexHost.value == 2
                                ? Colors.black
                                : getColorBasedOnActiveModuleid()),
                      ),
                    ),
                  ),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  bottomNavigationBar: Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                            color: const Color.fromARGB(255, 199, 196, 196)
                                .withOpacity(0.9), // Shadow color
                            blurRadius: 5, // Shadow blur radius
                            offset: const Offset(0, -5), // Vertical offset
                            blurStyle: BlurStyle.normal),
                      ],
                    ),
                    child: BottomAppBar(
                      shape: const CircularNotchedRectangle(),
                      height: 60,
                      padding: EdgeInsets.zero,
                      surfaceTintColor: whiteColor,
                      color: whiteColor,
                      child: TabBar(
                        labelPadding: EdgeInsets.zero,
                        controller: generalController.tabControllerHost,
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                              color: getColorBasedOnActiveModuleid(), width: 2),
                          insets: const EdgeInsets.only(bottom: 58),
                        ),
                        tabs: [
                          Tab(
                            child: Column(
                              children: [
                                generalController.currentIndexHost.value == 0
                                    ? SvgPicture.asset(
                                        'assets/images/Home.svg',
                                        height: 23,
                                        colorFilter: ColorFilter.mode(
                                          getColorBasedOnActiveModuleid(),
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        'assets/images/Home.svg',
                                        height: 23,
                                        colorFilter: ColorFilter.mode(
                                          grey2,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                // SizedBox(height: 1),
                                Text(
                                  truncatetext("DashBoard".tr, 10),
                                  style: regular2(context).copyWith(
                                    color: generalController
                                                .currentIndexHost.value ==
                                            0
                                        ? getColorBasedOnActiveModuleid()
                                        : grey2,
                                  ),
                                )
                              ],
                            ),
                          ),
                          Tab(
                            child: Column(
                              children: [
                                generalController.currentIndexHost.value == 1
                                    ? Image.asset('assets/images/calendar.png',
                                        height: 23,
                                        color: getColorBasedOnActiveModuleid())
                                    : Image.asset('assets/images/calendar.png',
                                        height: 23, color: grey2),
                                // SizedBox(height: 2),
                                Text(
                                  truncatetext("Calendar".tr, 10),
                                  style: regular2(context).copyWith(
                                      color: generalController
                                                  .currentIndexHost.value ==
                                              1
                                          ? getColorBasedOnActiveModuleid()
                                          : grey2),
                                )
                              ],
                            ),
                          ),
                          Tab(
                            child: Column(
                              children: [
                                generalController.currentIndexHost.value == 2
                                    ? const Text('df')
                                    : const Text(''),
                                // SizedBox(height: 15),
                                const SizedBox(height: 4),
                                Text(
                                  "Orders".tr,
                                  style: regular2(context).copyWith(
                                      color: generalController
                                                  .currentIndexHost.value ==
                                              2
                                          ? getColorBasedOnActiveModuleid()
                                          : grey2),
                                ),
                              ],
                            ),
                          ),
                          Tab(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: Dimensions.paddingSizeSmall),
                              child: Column(
                                children: [
                                  generalController.currentIndexHost.value == 3
                                      ? Image.asset('assets/images/inbox.png',
                                          width: 23,
                                          color:
                                              getColorBasedOnActiveModuleid())
                                      : Image.asset('assets/images/inbox.png',
                                          width: 23, color: grey2),
                                  // SizedBox(height: 2),
                                  Expanded(
                                    child: Text(
                                      "Inbox".tr,
                                      style: regular2(context).copyWith(
                                          color: generalController
                                                      .currentIndexHost.value ==
                                                  3
                                              ? getColorBasedOnActiveModuleid()
                                              : Colors.black,
                                          overflow: TextOverflow.ellipsis),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Tab(
                            child: Column(
                              children: [
                                generalController.currentIndexHost.value == 4
                                    ? SvgPicture.asset(
                                        'assets/images/ProfileIcon.svg',
                                        width: 23,
                                        colorFilter: ColorFilter.mode(
                                          getColorBasedOnActiveModuleid(),
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : SvgPicture.asset(
                                        'assets/images/ProfileIcon.svg',
                                        width: 23,
                                        colorFilter: ColorFilter.mode(
                                          grey2,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                // SizedBox(height: 2),
                                Text(
                                  "Profile".tr,
                                  style: regular2(context).copyWith(
                                    color: generalController
                                                .currentIndexHost.value ==
                                            4
                                        ? getColorBasedOnActiveModuleid()
                                        : grey2,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}
