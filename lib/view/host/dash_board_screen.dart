import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/general_data_model.dart';
import 'package:carvy/model/my_items_model.dart';
import 'package:carvy/model/dash_board_host.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/hostsearch/host_search_screen.dart';
import 'package:carvy/view/host/initial_host_common_screen.dart';
import 'package:carvy/view/host/orders/orders_screen.dart';
import 'package:carvy/view/host/switch_splash_screen.dart';
import 'package:carvy/view/host/vehiclehost/editvehicle/edit_vehicle_home_screen.dart';
import 'package:carvy/view/host/wallet/finance_screen.dart';
import 'package:carvy/work_space.dart';
import '../../model/vehicle_home_model.dart';
import '../itemdetail/vehicle/vehicle_detail_screen.dart';

class DashBoardScreen extends StatefulWidget {
  final ScreenMode mode;
  const DashBoardScreen({
    super.key,
    required this.mode,
  });

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  MyItemsModel? myItemsModels;
  DashBoardHost? dashBoardHostModel;
  List<Items> list = [];
  RefreshController refreshController = RefreshController();
  num offset = 0;
  GeneralDataModel? generalDataModel;
  AddItemsHostController addItemsHostController = Get.find();
  bool showTimeOut = false;
  final ScrollController scrollController = ScrollController();
  final GlobalKey vehicleListKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initializeData();
    });
  }

  void initializeData() async {
    showerrorWhenloginwithOtherDevice = "";
    checkUpdateStep1 = false;
    checkUpdateStep2 = false;
    item = null;
    myItemsModels = null;
    list.clear();
    initialitems = null;
    await Future.delayed(const Duration(milliseconds: 800), () async {
      await getdashBoardData();
      await getData();
    });
  }
  getData() async {
    var response = await httpPost(Config.myItems, {"offset": "$offset"});
    if (response != null && response['status'] == 200) {
      myItemsModels = MyItemsModel.fromJson(response);
      if (myItemsModels!.data != null) {
        if (myItemsModels!.data!.hoststatus == "0") {
          hostblocked(context);
          Future.delayed(const Duration(seconds: 5), () {
            Get.to(
              SwitchSplashScreen(
                isHostMode: isHostMode.value,
              ),
            );
          });
          return;
        }
        checkItemPiblicationLimit = response["data"]["checkLimit"];
        list.addAll(myItemsModels!.data!.items!);
        offset = myItemsModels!.data!.offset!;
      }
    } else {
      showerrorWhenloginwithOtherDevice = "${response["error"]}";
      showErrorToastMessage("${response["error"]}");
    }
    setState(() {});
    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

  List<Map<String, String>> items = [];
  List<Map<String, dynamic>> weeklyData = [];
  Future<void> getdashBoardData() async {
    dashBoardHostModel = null;
    items.clear();
    weeklyData.clear();
    var response = await httpPost(Config.hostDashBoard, {});
    if (response != null && response['status'] == 200) {
      dashBoardHostModel = DashBoardHost.fromJson(response);
      items = [
        {
          "title": convertToLocaleDigits(
              "${dashBoardHostModel?.data?.data?.totalSales ?? 'N/A'}"),
          "image": "assets/images/wallet-2.svg",
          "subtitle": "Total sales".tr,
        },
        {
          "title": convertToLocaleDigits(
              "${dashBoardHostModel?.data?.data?.newProducts ?? 'N/A'}"),
          "image": "assets/images/box.svg",
          "subtitle": "Total Products".tr,
        },
        {
          "title": convertToLocaleDigits(
              "${dashBoardHostModel?.data?.data?.todayOrders ?? 'N/A'}"),
          "image": "assets/images/arrange-circle.svg",
          "subtitle": "Today Orders".tr,
        },
        {
          "title": convertToLocaleDigits(
              "${dashBoardHostModel?.data?.data?.pendingOrders ?? 'N/A'}"),
          "image": "assets/images/box.svg",
          "subtitle": "Pending Orders".tr,
        },
        {
          "title": convertToLocaleDigits(
              "${dashBoardHostModel?.data?.data?.confirmedOrders ?? 'N/A'}"),
          "image": "assets/images/arrange-circle.svg",
          "subtitle": "Confirmed Orders".tr,
        },
        {
          "title": convertToLocaleDigits(
              "${dashBoardHostModel?.data?.data?.cancelledOrders ?? 'N/A'}"),
          "image": "assets/images/box.svg",
          "subtitle": "Cancelled Orders".tr,
        },
      ];

      if (dashBoardHostModel?.data?.data?.weeklyIncomeReport != null) {
        final report = dashBoardHostModel!.data!.data!.weeklyIncomeReport!;
        weeklyData = [
          {
            "day": getWeekdayName(1, locale: Get.locale?.languageCode ?? 'en'),
            "amount": report.monday ?? 0
          },
          {
            "day": getWeekdayName(2, locale: Get.locale?.languageCode ?? 'en'),
            "amount": report.tuesday ?? 0
          },
          {
            "day": getWeekdayName(3, locale: Get.locale?.languageCode ?? 'en'),
            "amount": report.wednesday ?? 0
          },
          {
            "day": getWeekdayName(4, locale: Get.locale?.languageCode ?? 'en'),
            "amount": report.thursday ?? 0
          },
          {
            "day": getWeekdayName(5, locale: Get.locale?.languageCode ?? 'en'),
            "amount": report.friday ?? 0
          },
          {
            "day": getWeekdayName(6, locale: Get.locale?.languageCode ?? 'en'),
            "amount": report.saturday ?? 0
          },
          {
            "day": getWeekdayName(7, locale: Get.locale?.languageCode ?? 'en'),
            "amount": report.sunday ?? 0
          },
        ];
      }
    } else {
      showErrorToastMessage("${response['error']}");
    }
    setState(() {});
  }

  deleteMethod(index) async {
    showLoading();
    var response =
        await httpPost(Config.deleteItem, {"id": list[index].id.toString()});
    closeLoading();
    if (response != null) {
      if (response['status'] == 200) {
        showToastMessage(response['message']);
        onRefresh();
        setState(() {});
      } else {
        showErrorToastMessage(response['error']);
      }
    }
  }

  onLoading() {
    getData();
    setState(() {});
  }

  onRefresh() {
    myItemsModels = null;
    list = [];
    setState(() {});
    offset = 0;
    getData();
    getdashBoardData();
  }

  void scrollToVehicleList() {
    final RenderObject? renderObject =
        vehicleListKey.currentContext?.findRenderObject();
    if (renderObject != null) {
      final offset = (renderObject as RenderBox).localToGlobal(Offset.zero).dy;
      scrollController.animateTo(
        offset - 250,
        duration: const Duration(milliseconds: 250),
        curve: Curves.linear,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        tobecomeHost(context);
      },
      child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(190),
            child: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: getColorBasedOnActiveModuleid().withOpacity(1),
              toolbarHeight: 190,
              centerTitle: true,
              title: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        profilePhotoOnHomeScreen(context),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              loginModel?.data?.firstName ?? "",
                              style: heading2Grey1(context).copyWith(
                                color: whiteColor,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              loginModel?.data?.email ?? "",
                              style: heading2Grey1(context).copyWith(
                                color: whiteColor,
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () {
                            Get.to(HostSearchScreen(
                              mode: widget.mode,
                            ));
                          },
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(40),
                              border: Border.all(width: 1, color: whiteColor),
                            ),
                            child: Icon(Icons.search, color: whiteColor),
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (showerrorWhenloginwithOtherDevice ==
                                    "token not match") {
                                  showErrorToastMessage(
                                      "Please login again".tr);
                                  return;
                                }
                                if (checkItemPiblicationLimit.toString() ==
                                    "0") {
                                  showErrorToastMessage(
                                      "You have reached the limit for publishing items. Please contact the admin for further assistance."
                                          .tr);
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const InitialHostCommonScreen()),
                                );
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: getColorBasedOnActiveModuleid(),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: getColorBasedOnActiveModuleid(),
                                      width: 2),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: whiteColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Add Car".tr,
                                style: regular(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: whiteColor)),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(OrdersScreen(
                                  fromPropBooking: true,
                                ));
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: getColorBasedOnActiveModuleid(),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: getColorBasedOnActiveModuleid(),
                                      width: 2),
                                ),
                                child: Icon(Icons.sort, color: whiteColor),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("My Order".tr,
                                style: regular(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: whiteColor)),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.to(FinanceMainScreen(isFormHome: false));
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: getColorBasedOnActiveModuleid(),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: getColorBasedOnActiveModuleid(),
                                      width: 2),
                                ),
                                child:
                                    Icon(Icons.attach_money, color: whiteColor),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Pay Out".tr,
                                style: regular(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: whiteColor)),
                          ],
                        ),
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                searchForHost(context);
                              },
                              child: Container(
                                height: 60,
                                width: 60,
                                decoration: BoxDecoration(
                                  color: getColorBasedOnActiveModuleid(),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: getColorBasedOnActiveModuleid(),
                                      width: 2),
                                ),
                                child: Icon(Icons.directions_car_outlined,
                                    color: whiteColor),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text("Vehicle list".tr,
                                style: regular(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: whiteColor)),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
              elevation: 1,
            ),
          ),
          body: showerrorWhenloginwithOtherDevice == "token not match"
              ? Center(child: showTokenExpirePlease())
              : myItemsModels == null
                  ? homeHostScreenShimmer()
                  : Column(
                      children: [
                        Expanded(
                          child: SmartRefresher(
                            controller: refreshController,
                            onRefresh: onRefresh,
                            onLoading: onLoading,
                            enablePullUp: offset == -1 ? false : true,
                            child: ListView(
                              physics: BouncingScrollPhysics(),
                              shrinkWrap: false,
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: Dimensions.paddingSizeLarge),
                                    Text('Analytics OverView'.tr,
                                        style: heading2Grey1(context)),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Get.to(
                                          const FinanceMainScreen(
                                              isFormHome: false),
                                        );
                                      },
                                      child: Text('See All'.tr,
                                          style: regular2(context).copyWith(
                                              color:
                                                  getColorBasedOnActiveModuleid())),
                                    ),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeLarge)
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: GridView.builder(
                                    key: vehicleListKey,
                                    padding: const EdgeInsets.all(8),
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 8,
                                      mainAxisExtent: 70,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      return analyticOverview(
                                        items[index]["image"]!,
                                        items[index]["title"]!,
                                        items[index]["subtitle"]!,
                                        context,
                                      );
                                    },
                                  ),
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: Dimensions.paddingSizeLarge),
                                    Text(
                                      'Daily Earning Graph'.tr,
                                      style: regular2(context).copyWith(
                                          color: themeColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Spacer(),
                                    InkWell(
                                      onTap: () {
                                        Get.to(
                                          const FinanceMainScreen(
                                              isFormHome: false),
                                        );
                                      },
                                      child: Text('See All'.tr,
                                          style: regular2(context).copyWith(
                                              color:
                                                  getColorBasedOnActiveModuleid())),
                                    ),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeLarge)
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: Container(
                                    height: 250,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: notifires.getboxcolor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          width: 1, color: Colors.black12),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Weekly Report".tr,
                                              style: regular2(context)
                                                  .copyWith(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Bar Chart
                                        Expanded(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: List.generate(7, (index) {
                                              // Define days of the week
                                              final day = getWeekdayName(
                                                  index + 1,
                                                  locale: Get.locale
                                                          ?.languageCode ??
                                                      'en');
                                              // Determine if data exists and calculate bar height
                                              final hasData =
                                                  weeklyData.isNotEmpty;
                                              final entry = hasData &&
                                                      index < weeklyData.length
                                                  ? weeklyData[index]
                                                  : {'day': day, 'amount': 0};
                                              final double maxAmount =
                                                  hasData &&
                                                          weeklyData.isNotEmpty
                                                      ? weeklyData
                                                          .map((e) =>
                                                              (e['amount']
                                                                      as num)
                                                                  .toDouble())
                                                          .reduce((a, b) =>
                                                              a > b ? a : b)
                                                      : 1.0;
                                              final double barHeightFactor =
                                                  hasData && maxAmount > 0
                                                      ? (entry['amount'] as num)
                                                              .toDouble() /
                                                          maxAmount
                                                      : 0;

                                              return Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Container(
                                                    width: 16,
                                                    height: 105,
                                                    decoration: BoxDecoration(
                                                      color:
                                                          grey5, // Use grey5 as the background color
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                    ),
                                                    child: Align(
                                                      alignment: Alignment
                                                          .bottomCenter,
                                                      child:
                                                          TweenAnimationBuilder<
                                                              double>(
                                                        tween: Tween<double>(
                                                            begin: 0,
                                                            end:
                                                                barHeightFactor),
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    500),
                                                        curve: Curves.easeOut,
                                                        builder: (context,
                                                            value, child) {
                                                          return FractionallySizedBox(
                                                            heightFactor: value,
                                                            child: Container(
                                                              width: 16,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: hasData
                                                                    ? getColorBasedOnActiveModuleid()
                                                                    : grey5, // Use grey5 for empty bars
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    entry['day'],
                                                    style: regular2(context),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    width: 25,
                                                    height: 1,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Text(
                                                    truncatetext(
                                                      convertToLocaleDigits(
                                                          '${currency} ${entry['amount']}'),
                                                      11,
                                                    ),
                                                    style: regular2(context),
                                                  ),
                                                ],
                                              );
                                            }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 15, right: 15),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: dashboardSummaryCard(
                                          context: context,
                                          title: 'This Week'.tr,
                                          value: convertToLocaleDigits(
                                              "${dashBoardHostModel?.data?.data?.weeklyTotalBookings ?? 'N/A'}"),
                                          subtitle: 'Total Booking'.tr,
                                          valueColor:
                                              getColorBasedOnActiveModuleid(),
                                          backgroundColor:
                                              notifires.getboxcolor,
                                        ),
                                      ),
                                      const SizedBox(width: 25),
                                      Expanded(
                                        child: dashboardSummaryCard(
                                          context: context,
                                          title: 'This Week'.tr,
                                          value: convertToLocaleDigits(
                                              " ${currency} ${dashBoardHostModel?.data?.data?.weeklyTotalEarnings ?? 'N/A'}"),
                                          subtitle: 'Total Earning'.tr,
                                          valueColor:
                                              getColorBasedOnActiveModuleid(),
                                          backgroundColor:
                                              notifires.getboxcolor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                        width: Dimensions.paddingSizeLarge),
                                    Text('My Posts'.tr,
                                        style: heading2Grey1(context)),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        if (showerrorWhenloginwithOtherDevice ==
                                            "token not match") {
                                          showErrorToastMessage(
                                              "Please login again");

                                          return;
                                        }
                                        if (checkItemPiblicationLimit
                                                .toString() ==
                                            "0") {
                                          showErrorToastMessage(
                                              "You have reached the limit for publishing items. Please contact the admin for further assistance.");
                                          return;
                                        }
                                        Get.to(() =>
                                            const InitialHostCommonScreen());
                                      },
                                      child: Icon(
                                        Icons.add,
                                        size: 35,
                                        color: getColorBasedOnActiveModuleid(),
                                      ),
                                    ),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeLarge)
                                  ],
                                ),
                                list.isEmpty
                                    ? Addproperty(
                                        title: "You don't have any List".tr,
                                        subTitle: staticContantforHost(),
                                        btnTxt: "Add New List".tr,
                                        onTap: () {
                                          if (showerrorWhenloginwithOtherDevice ==
                                              "token not match") {
                                            showErrorToastMessage(
                                                "Please login again");

                                            return;
                                          }
                                          if (checkItemPiblicationLimit
                                                  .toString() ==
                                              "0") {
                                            showErrorToastMessage(
                                                "You have reached the limit for publishing items. Please contact the admin for further assistance.");
                                            return;
                                          }
                                          Get.to(() =>
                                              const InitialHostCommonScreen());
                                        },
                                      )
                                    : GridView.builder(
                                        padding: const EdgeInsets.all(8),
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 1,
                                          crossAxisSpacing: 8,
                                          mainAxisExtent: 335,
                                          mainAxisSpacing: 8,
                                        ),
                                        itemCount: list.length,
                                        itemBuilder: (context, index) {
                                          ItemInfo? itemInfoData;
                                          String? jsonString =
                                              list[index].itemInfo;
                                          if (jsonString != null) {
                                            itemInfoData = ItemInfo.fromJson(
                                                json.decode(jsonString));
                                          }
                                          return VehicleItemCard(
                                            list: list,
                                            index: index,
                                            itemInfoData: itemInfoData,
                                            notifires: notifires,
                                            stateSetter: setState,
                                            onDelete: () {
                                              showDeleteDialog(context, index);
                                            },
                                            onEdit: () {
                                              Get.to(
                                                const EditVehicleHomeScreen(
                                                    mode: ScreenMode.edit),
                                              )?.then((value) {
                                                myItemsModels = null;
                                                offset = 0;
                                                list.clear();
                                                setState(() {
                                                  getData();
                                                });
                                              });
                                              if (widget.mode ==
                                                  ScreenMode.edit) {
                                                item = list[index];
                                              }
                                            },
                                            onVehicleDetails: () {
                                              showPopUpScreen(
                                                context,
                                                VehicleDetailSScreen(
                                                  id: list[index].id,
                                                  itemInfo: itemInfoData,
                                                  rating:
                                                      list[index].itemRating,
                                                  title: list[index].title,
                                                  address: list[index].address,
                                                  latitute:
                                                      list[index].latitude,
                                                  longtitute:
                                                      list[index].longitude,
                                                  frontImage: list[index]
                                                          .frontImage
                                                          ?.url ??
                                                      "",
                                                  itemType:
                                                      list[index].itemType,
                                                  price: list[index].price,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                const SizedBox(
                                  height: 70,
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    )),
    );
  }

  Future<void> showDeleteDialog(BuildContext context, index) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: notifires.getbgcolor,
          surfaceTintColor: notifires.getblackwhitecolor,
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Icon(
                  Icons.error,
                  size: 75,
                  color: Colors.red,
                ),
                Text(
                    'Do you want to delete ${list[index].title!.length > 15 ? list[index].title!.substring(0, 16) : list[index].title!}  ${staticContantforHostDeleteMsg()}?'
                        .tr,
                    textAlign: TextAlign.center,
                    style: smallHeadigAirBd.copyWith(
                        color: notifires.getwhiteblackcolor)),
              ],
            ),
          ),
          actions: <Widget>[
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                        child: InkWell(
                            onTap: () {},
                            child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                    margin: const EdgeInsets.only(
                                        left: 8, right: 8),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                getColorBasedOnActiveModuleid()),
                                        color: getColorBasedOnActiveModuleid(),
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Center(
                                        child: Text("Cancel".tr,
                                            style: normalAirBk.copyWith(
                                                color: Colors.white))))))),
                    Expanded(
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
                              deleteMethod(index);
                              addItemsHostController.removeDashBoardData();
                              addItemsHostController.removeMyPostData();
                            },
                            child: Container(
                                margin:
                                    const EdgeInsets.only(left: 8, right: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: getColorBasedOnActiveModuleid()),
                                    color: getColorBasedOnActiveModuleid(),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                    child: Text(
                                  "Yes".tr,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ))))),
                  ],
                ),
                const SizedBox(
                  height: 8,
                )
              ],
            )
          ],
        );
      },
    );
  }

  Widget dashboardSummaryCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required Color valueColor,
    required Color backgroundColor,
  }) {
    return Container(
      height: 85,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(width: 1, color: Colors.black12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(title,
              style: regular2(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: themeColor)),
          Text(value,
              style: regular2(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: valueColor)),
          Text(subtitle,
              style: regular2(context).copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: themeColor)),
        ],
      ),
    );
  }
}

class VehicleItemCard extends StatelessWidget {
  final List<dynamic> list;
  final int index;
  final dynamic itemInfoData;
  final dynamic notifires;
  final StateSetter stateSetter;
  final VoidCallback? onDelete; // Callback for Delete action
  final VoidCallback? onEdit; // Callback for Edit action
  final VoidCallback? onVehicleDetails; // Callback for Vehicle Details action

  const VehicleItemCard({
    Key? key,
    required this.list,
    required this.index,
    required this.itemInfoData,
    required this.notifires,
    required this.stateSetter,
    this.onDelete,
    this.onEdit,
    this.onVehicleDetails,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: InkWell(
        child: Card(
          color: notifires.getboxcolor,
          elevation: 2,
          shadowColor: grey4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  InkWell(
                    onTap: () {
                      if (list[index].status == "0") {
                        showErrorToastMessage("items is not published!");
                        return;
                      }
                      onVehicleDetails
                          ?.call();
                    },
                    child: Container(
                      width: double.maxFinite,
                      height: 155,
                      decoration: BoxDecoration(
                        color: notifires.getBoxColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: list[index].frontImage?.thumbnail == null
                            ? getErrorImageForBoth(
                                list[index].itemType.toString())
                            : myNetworkImageWithShimmer(
                                "${list[index].frontImage!.thumbnail}"),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18,
                    width: 100,
                    decoration: BoxDecoration(
                        color: notifires.getbgcolor,
                        borderRadius: BorderRadius.circular(5)),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 9,
                        ),
                        Center(
                          child: Text('${itemInfoData!.vehicleType}',
                              style: regular2(context).copyWith(
                                fontSize: 11,
                              )),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      children: [
                        Text(
                          list[index].title!.length > 15
                              ? list[index].title!.substring(0, 16)
                              : list[index].title!,
                          style: heading3Grey1(context).copyWith(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          ("$currency ${list[index].price}/day"),
                          style: boldstyle(context).copyWith(
                            fontSize: 13,
                            // color: notifires.getTextColor
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    color: grey5,
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.near_me_outlined,
                      size: 16,
                      // color: notifires.getIconColor,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        (list[index].address != null &&
                                list[index].address!.length > 20)
                            ? list[index].address!.substring(0, 19)
                            : (list[index].address ?? "N/A"),
                        overflow: TextOverflow.ellipsis,
                        style: regular3(context).copyWith(
                          fontSize: 12,
                          // color: notifires.getTextColor
                        ),
                        maxLines: 1,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: list[index].status == "0"
                            ? Colors.redAccent.shade200
                            : Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            list[index].status == "0"
                                ? "UnPublish".tr
                                : "Publish".tr,
                            style: regular(context).copyWith(color: whiteColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.settings,
                          color: notifires.getGrey3Whitecolor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          itemInfoData.transmission.toString(),
                          style: regular3(context).copyWith(
                            fontSize: 12,
                            color: notifires.getGrey3Whitecolor,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.event_seat,
                          color: notifires.getGrey3Whitecolor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "${itemInfoData.seatCapicity.toString()} Seats",
                          style: regular3(context).copyWith(
                            fontSize: 12,
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.local_gas_station,
                          color: notifires.getGrey3Whitecolor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          itemInfoData.fuelType.toString(),
                          style: regular3(context).copyWith(
                            fontSize: 12,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: SizedBox(
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: onEdit,
                          style: TextButton.styleFrom(
                            backgroundColor: getColorBasedOnActiveModuleid()
                               ,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Edit'.tr,
                            style: TextStyle(
                                color: whiteColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: TextButton(
                          onPressed: onDelete, 
                          style: TextButton.styleFrom(
                            backgroundColor: yelloColor2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Delete'.tr,
                            style: TextStyle(
                                color: getColorBasedOnActiveModuleid(),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
