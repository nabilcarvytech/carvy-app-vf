import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:carvy/customwidget/check_internet_connection.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/booking/my_booking_screen.dart';
import 'package:carvy/view/home/vehicleHome/vehicles_home_page.dart';
import 'package:carvy/view/wishlist/wish_list_screen.dart';
import '../../controller/auth_controller.dart';
import '../../controller/global_scope_controller.dart';
import '../../controller/push_notifications.dart';
import '../../controller/wish_list_controller.dart';
import '../../utils/common_widget.dart';
import '../../work_space.dart';
import '../myaccount/account_screen.dart';
import '../chat/inbox_screen.dart';
import 'package:flutter/services.dart';

class HomeMain extends StatefulWidget {
  final int? initialIndex;
  const HomeMain({super.key, required this.initialIndex});
  @override
  State<HomeMain> createState() => _HomeMainScreenState();
}

/// Navigation principale client après inscription OTP (alias explicite pour Home).
class NavPageView extends StatelessWidget {
  const NavPageView({super.key});

  @override
  Widget build(BuildContext context) => const HomeMain(initialIndex: 0);
}

class _HomeMainScreenState extends State<HomeMain>
    with TickerProviderStateMixin {
  GlobalScopeController globalScopeController =
      Get.put(GlobalScopeController());
  AuthController authController = Get.find();
  List<Widget> vehicleList = [
    const VehicleHomePage(),
    const WishListScreen(),
    MyBooking(
      fromPropBooking: false,
      initialTabIndex: generalController
          .myBookingTabIndex.value, 
    ),
    const InboxScreen(),
    const AccountScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showNotification();
      generalController.fetchTotalUnreadCount();
    });
    if (webPlateForm) {
      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments != null) {
        // widget.initialIndex = arguments['initialIndex'] as int?;
      }
    }

    getUserDataLocallyToHandleTheState();

    generalController.fetchGeneralSettings();

    generalController.tabController = TabController(
      length: 5,
      vsync: this,
      initialIndex: widget.initialIndex!,
    );
    generalController.tabController.addListener(() {
      final newIndex = generalController.tabController.index;
      generalController.currentIndex.value = newIndex;
      
      // ========== UX IMPROVEMENT: Refresh Wishlist when switching to Favorites tab ==========
      if (newIndex == 1) { // Index 1 is the Wishlist/Favorites tab
        // Find the controller and force fetch
        if (Get.isRegistered<WishListController>()) {
          Get.find<WishListController>().getWishlistData();
          print("🔄 [Tab Switch] Refreshing Wishlist Data...");
        }
      }
      // ========== END UX IMPROVEMENT ==========
    });
  }

  bool darkMode = GetStorage().read("getDarkValue") ?? false;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.dark,
    ));
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Obx(() => generalController.failed.value == true
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
                              appName.toString().tr,
                              style: heading1(context),
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
                  if (generalController.currentIndex.value != 0) {
                    generalController.tabController.animateTo(0);
                    generalController.currentIndex.value = 0;
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
                      controller: generalController.tabController,
                      children: vehicleList,
                    ),
                  ),
                floatingActionButton: InkWell(
                  onTap: () {
                    if (generalController.currentIndex.value != 0) {
                      generalController.currentIndex.value = 0;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeMain(
                                    initialIndex: 0,
                                  )));
                    }
                  },
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(35),
                      // color: getColorBasedOnActiveModuleid(),
                    ),
                    child: Center(
                      child: ClipOval(
                        child: Image.asset("assets/images/small-app-logo.jpg",
                            fit: BoxFit.fill),
                      ),
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
                              .withOpacity(0.9), 
                          blurRadius: 5,
                          offset: const Offset(0, -5), 
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
                      controller: generalController.tabController,
                      indicator: UnderlineTabIndicator(
                        borderSide: BorderSide(
                            color: getColorBasedOnActiveModuleid(), width: 2),
                        insets: const EdgeInsets.only(bottom: 58),
                      ),
                      tabs: [
                        Tab(
                          child: Column(
                            children: [
                              generalController.currentIndex.value == 0
                                  ? SvgPicture.asset(
                                      'assets/images/searchIcon.svg',
                                      height: 23,
                                      colorFilter: ColorFilter.mode(
                                        getColorBasedOnActiveModuleid(),
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : SvgPicture.asset(
                                      'assets/images/searchIcon.svg',
                                      height: 23,
                                      colorFilter: ColorFilter.mode(
                                        grey4,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                              Text(
                                truncatetext("Explorer".tr, 10),
                                style: regular2(context).copyWith(
                                  color:
                                      generalController.currentIndex.value == 0
                                          ? getColorBasedOnActiveModuleid()
                                          : grey4,
                                ),
                              )
                            ],
                          ),
                        ),
                        Tab(
                          child: Column(
                            children: [
                              generalController.currentIndex.value == 1
                                  ? SvgPicture.asset(
                                      'assets/images/HeartIcon.svg',
                                      height: 23,
                                      colorFilter: ColorFilter.mode(
                                        getColorBasedOnActiveModuleid(),
                                        BlendMode.srcIn,
                                      ),
                                    )
                                  : SvgPicture.asset(
                                      'assets/images/HeartIcon.svg',
                                      height: 23,
                                      colorFilter: ColorFilter.mode(
                                        grey4,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                              Text(
                                truncatetext("Favorite".tr, 9),
                                style: regular2(context).copyWith(
                                  color:
                                      generalController.currentIndex.value == 1
                                          ? getColorBasedOnActiveModuleid()
                                          : grey4,
                                ),
                              )
                            ],
                          ),
                        ),
                        Tab(
                          child: Column(
                            children: [
                              generalController.currentIndex.value == 2
                                  ? const Text('df')
                                  : const Text(''),
                              const SizedBox(height: 7),
                              Text(
                                "Trips".tr,
                                style: regular2(context).copyWith(
                                    color:
                                        generalController.currentIndex.value ==
                                                2
                                            ? getColorBasedOnActiveModuleid()
                                            : grey4),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Column(
                              children: [
                                Obx(() => Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        SizedBox(
                                          width: 23,
                                          child: generalController
                                                      .currentIndex.value ==
                                                  3
                                              ? SvgPicture.asset(
                                                  'assets/images/chatIcon.svg',
                                                  width: 23,
                                                  colorFilter: ColorFilter.mode(
                                                    getColorBasedOnActiveModuleid(),
                                                    BlendMode.srcIn,
                                                  ),
                                                )
                                              : SvgPicture.asset(
                                                  'assets/images/chatIcon.svg',
                                                  width: 23,
                                                  colorFilter: ColorFilter.mode(
                                                    grey4,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                        ),
                                        if (generalController
                                                .totalUnreadCount.value >
                                            0)
                                          Positioned(
                                            top: -2,
                                            right: -2,
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                color: redColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          ),
                                      ],
                                    )),
                                Text(
                                  "Chat".tr,
                                  style: regular2(context).copyWith(
                                    color:
                                        generalController.currentIndex.value ==
                                                3
                                            ? getColorBasedOnActiveModuleid()
                                            : grey4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Tab(
                          child: Column(
                            children: [
                              generalController.currentIndex.value == 4
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
                                        grey4,
                                        BlendMode.srcIn,
                                      ),
                                    ),
                              Text(
                                "Profile".tr,
                                style: regular2(context).copyWith(
                                  color:
                                      generalController.currentIndex.value == 4
                                          ? getColorBasedOnActiveModuleid()
                                          : grey4,
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
            ));
  }
}
