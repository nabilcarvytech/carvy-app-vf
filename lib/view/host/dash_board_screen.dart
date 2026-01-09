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
import 'package:get_storage/get_storage.dart';
import 'package:carvy/view/auth/login_screen.dart';

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
    // ========== Clear list if this is initial load (offset == 0) ==========
    if (offset == 0) {
      list.clear();
      print('🚗 [DASHBOARD] Liste vidée pour le chargement initial (offset = 0)');
    }
    
    // ========== API CALL - Real endpoint ==========
    print('🚗 [DASHBOARD] Appel API my-items avec offset: $offset');
    var response = await httpPost(Config.myItems, {"offset": "$offset"});
    
    // ========== DEBUG: Print response status ==========
    print('🚗 [DASHBOARD] Réponse API reçue - status: ${response?['status']}');
    
    if (response != null && response['status'] == 200) {
      myItemsModels = MyItemsModel.fromJson(response);
      if (myItemsModels?.data != null) {
        final hostStatus = myItemsModels?.data?.hoststatus;
        if (hostStatus == "0" || hostStatus == 0) {
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
        
        // ========== DEBUG: Print items before adding ==========
        final newItems = myItemsModels?.data?.items;
        final itemsCount = newItems?.length ?? 0;
        print('🚗 [DASHBOARD] Nombre de véhicules reçus de l\'API : $itemsCount');
        
        if (itemsCount > 0 && newItems != null) {
          print('🚗 [DASHBOARD] Premier véhicule reçu : ${newItems[0].title}');
          
          // ========== Add items safely ==========
          list.addAll(newItems);
          
          // ========== Update offset safely ==========
          final newOffset = myItemsModels?.data?.offset;
          if (newOffset != null) {
            offset = newOffset;
          }
          
          // ========== DEBUG: Print total after adding ==========
          print('🚗 [DASHBOARD] Nombre total de véhicules dans la liste après ajout : ${list.length}');
        } else {
          print('⚠️ [DASHBOARD] WARNING: Aucun véhicule reçu ou items est null');
        }
      } else {
        print('⚠️ [DASHBOARD] WARNING: myItemsModels.data est null');
      }
    } else {
      if (response != null && response["error"] != null) {
        print('❌ [DASHBOARD] Erreur API: ${response["error"]}');
        showerrorWhenloginwithOtherDevice = "${response["error"]}";
        showErrorToastMessage("${response["error"]}");
      } else {
        print('❌ [DASHBOARD] Erreur: Réponse null ou status != 200');
        showErrorToastMessage("Failed to load items. Please try again.".tr);
      }
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
    
    // ========== 2c. Checking User Token ==========
    print('🔐 [DASHBOARD_AUTH] 2c. Checking User Token...');
    
    // Check token from global variable
    String? userToken = token;
    if (userToken == null || userToken.isEmpty) {
      // Try to load from storage as fallback
      userToken = GetStorage().read("raw_user_token");
      print('🔐 [DASHBOARD_AUTH] Token from global variable is empty, checking storage...');
    }
    
    if (userToken == null || userToken.isEmpty) {
      print('❌ [DASHBOARD_AUTH] ERROR: User Token is EMPTY! Cannot proceed with dashboard request.');
      print('❌ [DASHBOARD_AUTH] Redirecting to login screen...');
      showErrorToastMessage("Session expired. Please login again".tr);
      // Force logout and redirect to login
      Future.delayed(const Duration(seconds: 1), () {
        logout();
      });
      setState(() {});
      return;
    }
    
    print('✅ [DASHBOARD_AUTH] User Token is present: ${userToken.length > 10 ? userToken.substring(0, 10) : userToken}... (length: ${userToken.length})');
    print('🔐 [DASHBOARD_AUTH] Proceeding with dashboard API call...');
    
    var response = await httpPost(Config.hostDashBoard, {});
    
    // ========== RAW DEBUG: Voir exactement ce qui est reçu du serveur ==========
    print('📡 [RAW_RECEIVE] Body complet : $response');
    print('📡 [RAW_RECEIVE] Type de response : ${response.runtimeType}');
    if (response != null && response is Map) {
      try {
        print('📡 [RAW_RECEIVE] JSON stringifié : ${jsonEncode(response)}');
      } catch (e) {
        print('⚠️ [RAW_RECEIVE] Impossible de stringifier en JSON: $e');
      }
      print('🔑 [KEYS_CHECK] Clés présentes : ${response.keys.toList()}');
      print('🔑 [KEYS_CHECK] Valeur de status : ${response['status']}');
      print('🔑 [KEYS_CHECK] Type de status : ${response['status']?.runtimeType}');
      print('🔑 [KEYS_CHECK] Valeur de data : ${response['data']}');
      print('🔑 [KEYS_CHECK] Type de data : ${response['data']?.runtimeType}');
      print('🔑 [KEYS_CHECK] Valeur de message : ${response['message']}');
      print('🔑 [KEYS_CHECK] Valeur de error : ${response['error']}');
    } else {
      print('⚠️ [RAW_RECEIVE] WARNING: response est null ou n\'est pas un Map');
    }
    
    // ========== DEBUG: Print response body ==========
    print('📥 [DASHBOARD_DEBUG] Response Body: $response');
    
    // ========== Handle 401 Unauthorized ==========
    // Vérification flexible du statut (200, '200', ou statusCode)
    var status = response?['status'];
    var statusCode = response?['statusCode'];
    
    if (response != null && (status == 401 || status == '401' || statusCode == 401)) {
      print('❌ [DASHBOARD_AUTH] ERROR: 401 Unauthorized - Token is invalid or expired');
      print('❌ [DASHBOARD_AUTH] Response status: ${response['status']}');
      print('❌ [DASHBOARD_AUTH] Response error: ${response['error']}');
      showErrorToastMessage("Session expired. Please login again".tr);
      // Force logout and redirect to login
      Future.delayed(const Duration(seconds: 1), () {
        logout();
      });
      setState(() {});
      return;
    }
    
    // ========== Vérification flexible du statut (200, '200', ou statusCode) ==========
    if (response != null && (status == 200 || status == '200' || statusCode == 200)) {
      print('✅ [STATUS_CHECK] Status valide détecté: status=$status, statusCode=$statusCode');
      
      // ========== DEBUG: Check response structure ==========
      if (response['data'] == null) {
        print('⚠️ [DATA_ERROR] Le champ data est manquant dans la réponse');
        print('⚠️ [DATA_ERROR] Structure complète de la réponse: $response');
        showErrorToastMessage("Invalid response: missing 'data' field");
        setState(() {});
        return;
      }
      
      final dashboardData = response['data'];
      print('📊 [DASHBOARD_DEBUG] Dashboard data keys: ${dashboardData.keys}');
      print('📊 [DASHBOARD_DEBUG] total_sales: ${dashboardData['total_sales']}');
      print('📊 [DASHBOARD_DEBUG] today_orders: ${dashboardData['today_orders']}');
      print('📊 [DASHBOARD_DEBUG] new_products: ${dashboardData['new_products']}');
      print('📊 [DASHBOARD_DEBUG] total_items: ${dashboardData['total_items']}');
      print('📊 [DASHBOARD_DEBUG] pending_orders: ${dashboardData['pending_orders']}');
      print('📊 [DASHBOARD_DEBUG] confirmedOrders: ${dashboardData['confirmedOrders']}');
      print('📊 [DASHBOARD_DEBUG] cancelledOrders: ${dashboardData['cancelledOrders']}');
      print('📊 [DASHBOARD_DEBUG] weekly_total_bookings: ${dashboardData['weekly_total_bookings']}');
      print('📊 [DASHBOARD_DEBUG] weekly_total_earnings: ${dashboardData['weekly_total_earnings']}');
      print('📊 [DASHBOARD_DEBUG] weekly_income_report: ${dashboardData['weekly_income_report']}');
      
      // ========== Try-Catch for JSON parsing ==========
      try {
        dashBoardHostModel = DashBoardHost.fromJson(response);
        print('✅ [DASHBOARD_DEBUG] DashBoardHost parsed successfully');
      } catch (e, stackTrace) {
        print('❌ [DASHBOARD_DEBUG] ERROR parsing DashBoardHost: $e');
        print('❌ [DASHBOARD_DEBUG] Stack trace: $stackTrace');
        showErrorToastMessage("Error parsing dashboard data: $e");
        setState(() {});
        return;
      }
      
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

      // ========== DEBUG: Check weekly_income_report ==========
      if (dashBoardHostModel?.data?.data?.weeklyIncomeReport != null) {
        final report = dashBoardHostModel!.data!.data!.weeklyIncomeReport!;
        print('✅ [DASHBOARD_DEBUG] weekly_income_report found');
        print('📊 [DASHBOARD_DEBUG] Monday: ${report.monday}');
        print('📊 [DASHBOARD_DEBUG] Tuesday: ${report.tuesday}');
        print('📊 [DASHBOARD_DEBUG] Wednesday: ${report.wednesday}');
        print('📊 [DASHBOARD_DEBUG] Thursday: ${report.thursday}');
        print('📊 [DASHBOARD_DEBUG] Friday: ${report.friday}');
        print('📊 [DASHBOARD_DEBUG] Saturday: ${report.saturday}');
        print('📊 [DASHBOARD_DEBUG] Sunday: ${report.sunday}');
        
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
      } else {
        print('⚠️ [DASHBOARD_DEBUG] WARNING: weekly_income_report is null or missing');
        print('📋 [DASHBOARD_DEBUG] Available fields in dashboardData: ${dashboardData.keys}');
        weeklyData = []; // Initialize empty to avoid null errors
      }
    } else {
      print('❌ [DASHBOARD_DEBUG] ERROR: Response status is not 200');
      print('📊 [DASHBOARD_DEBUG] Response status: $status');
      print('📊 [DASHBOARD_DEBUG] Response statusCode: $statusCode');
      print('📊 [DASHBOARD_DEBUG] Response error: ${response?['error']}');
      print('📊 [DASHBOARD_DEBUG] Response message: ${response?['message']}');
      print('📊 [DASHBOARD_DEBUG] Response complet: $response');
      
      // Vérification spéciale si status est null
      if (status == null && statusCode == null) {
        print('⚠️ [STATUS_NULL] ATTENTION: Le champ status est null dans la réponse!');
        print('⚠️ [STATUS_NULL] Cela peut indiquer un problème côté serveur Node.js');
        showErrorToastMessage("Erreur serveur: status manquant dans la réponse");
      } else {
        showErrorToastMessage("${response?['error'] ?? response?['message'] ?? 'Unknown error'}");
      }
    }
    setState(() {});
  }

  deleteMethod(index) async {
    showLoading();
    
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpPost(Config.deleteItem, {"id": list[index].id.toString()});
    
    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // MOCK: Static success response for deleting an item
    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Vehicle deleted successfully",
      "error": "",
      "data": {
        "id": list[index].id.toString(),
        "deleted": true
      }
    };
    
    var response = mockResponse;
    // ========== END MOCK DATA ==========
    
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
                                    width: MediaQuery.of(context).size.width - 30,
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
                                          child: LayoutBuilder(
                                            builder: (context, constraints) {
                                              return Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.spaceEvenly,
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

                                              return Expanded(
                                                child: Column(
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
                                                  Flexible(
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        entry['day'],
                                                        style: regular2(context).copyWith(fontSize: 10),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Container(
                                                    width: 25,
                                                    height: 1,
                                                    color: Colors.grey,
                                                  ),
                                                  const SizedBox(height: 5),
                                                  Flexible(
                                                    child: FittedBox(
                                                      fit: BoxFit.scaleDown,
                                                      child: Text(
                                                        truncatetext(
                                                          convertToLocaleDigits(
                                                              '${currency} ${entry['amount']}'),
                                                          11,
                                                        ),
                                                        style: regular2(context).copyWith(fontSize: 10),
                                                      ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                              );
                                            },
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(title,
                    style: regular2(context).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: themeColor)),
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(value,
                    style: regular2(context).copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: valueColor),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1),
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(subtitle,
                    style: regular2(context).copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: themeColor)),
              ),
            ),
          ],
        ),
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
                          child: Text('${itemInfoData?.vehicleType ?? 'Sans Matricule'}',
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
