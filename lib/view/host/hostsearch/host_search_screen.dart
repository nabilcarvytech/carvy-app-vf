import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/controller/home_controller.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/general_data_model.dart';
import 'package:carvy/model/my_items_model.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/dash_board_screen.dart';
import 'package:carvy/view/host/vehiclehost/editvehicle/edit_vehicle_home_screen.dart';
import 'package:carvy/work_space.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../itemdetail/vehicle/vehicle_detail_screen.dart';

class HostSearchScreen extends StatefulWidget {
  final ScreenMode? mode;
  const HostSearchScreen({super.key, this.mode});
  @override
  State<HostSearchScreen> createState() => _HostSearchScreenState();
}

class _HostSearchScreenState extends State<HostSearchScreen> {
  final AddItemsHostController addItemsHostController = Get.find();
  bool showSuggestions = false;
  final FocusNode _focusNode = FocusNode();
  List<Map<String, String>> recentSearches = [];

  MyItemsModel? myItemsModels;
  List<Items> list = [];
  RefreshController refreshController = RefreshController();
  num offset = 0;
  GeneralDataModel? generalDataModel;
  bool publicpost = false;
  getData(String? search) async {
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpPost(
    //     Config.myItems, {"offset": "$offset", "search": "$search"});
    
    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // MOCK: Static my-items data (filtered by search if provided)
    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "My items retrieved successfully",
      "error": "",
      "data": {
        "host_status": "1",
        "checkLimit": 10,
        "offset": offset + 2,
        "limit": "10",
        "items": [
          {
            "id": 101,
            "title": "Toyota Camry 2023",
            "description": "Clean and comfortable sedan perfect for city driving",
            "item_rating": "4.5",
            "mobile": "+1234567890",
            "status": "1",
            "person_allowed": "5",
            "price": "50.00",
            "address": "123 Main Street, Los Angeles",
            "state_region": "California",
            "zip_postal_code": "90001",
            "city_name": "Los Angeles",
            "country": "USA",
            "latitude": "34.0522",
            "longitude": "-118.2437",
            "weekly_discount": "10",
            "weekly_discount_type": "percent",
            "monthly_discount": "15",
            "monthly_discount_type": "percent",
            "item_type_id": "1",
            "features_id": "[1,2,3]",
            "place_id": "ChIJE9on3F3HwoAR9AhGJW_fL-I",
            "booking_policies_id": 1,
            "item_type": "Sedan",
            "front_image": {
              "id": 1,
              "model_type": "Item",
              "model_id": "101",
              "uuid": "abc123",
              "collection_name": "front_image",
              "name": "camry-front",
              "file_name": "camry-front.jpg",
              "mime_type": "image/jpeg",
              "disk": "public",
              "conversions_disk": "public",
              "size": "500000",
              "order_column": "1",
              "created_at": "2024-01-01T00:00:00.000Z",
              "updated_at": "2024-01-01T00:00:00.000Z",
              "url": "https://example.com/host-camry-front.jpg",
              "thumbnail": "https://example.com/host-camry-front-thumb.jpg",
              "preview": "https://example.com/host-camry-front-preview.jpg",
              "original_url": "https://example.com/host-camry-front-original.jpg",
              "preview_url": "https://example.com/host-camry-front-preview.jpg"
            },
            "front_image_doc": null,
            "gallery": [
              {
                "id": 1,
                "model_type": "Item",
                "model_id": "101",
                "uuid": "gallery1",
                "collection_name": "gallery",
                "name": "camry-gallery-1",
                "file_name": "camry-gallery-1.jpg",
                "mime_type": "image/jpeg",
                "disk": "public",
                "conversions_disk": "public",
                "size": "400000",
                "order_column": "1",
                "created_at": "2024-01-01T00:00:00.000Z",
                "updated_at": "2024-01-01T00:00:00.000Z",
                "url": "https://example.com/host-camry-gallery-1.jpg",
                "thumbnail": "https://example.com/host-camry-gallery-1-thumb.jpg",
                "preview": "https://example.com/host-camry-gallery-1-preview.jpg",
                "original_url": "https://example.com/host-camry-gallery-1-original.jpg",
                "preview_url": "https://example.com/host-camry-gallery-1-preview.jpg"
              }
            ],
            "available_dates": null,
            "not_available_dates": null,
            "booked_dates": null,
            "item_info": "{\"host_id\":\"1\",\"service_type\":\"booking\",\"review_data\":[],\"features_data\":[],\"gallery_image_urls\":[]}",
            "metaData": "{}"
          },
          {
            "id": 102,
            "title": "Tesla Model 3 2022",
            "description": "Electric vehicle with autopilot features",
            "item_rating": "4.8",
            "mobile": "+1234567890",
            "status": "1",
            "person_allowed": "5",
            "price": "80.00",
            "address": "456 Market Street, San Francisco",
            "state_region": "California",
            "zip_postal_code": "94102",
            "city_name": "San Francisco",
            "country": "USA",
            "latitude": "37.7749",
            "longitude": "-122.4194",
            "weekly_discount": "12",
            "weekly_discount_type": "percent",
            "monthly_discount": "18",
            "monthly_discount_type": "percent",
            "item_type_id": "2",
            "features_id": "[4,5,6]",
            "place_id": "ChIJIQBpAG2ahYAR_6128GcTUEo",
            "booking_policies_id": 2,
            "item_type": "Electric",
            "front_image": {
              "id": 2,
              "model_type": "Item",
              "model_id": "102",
              "uuid": "def456",
              "collection_name": "front_image",
              "name": "tesla-front",
              "file_name": "tesla-front.jpg",
              "mime_type": "image/jpeg",
              "disk": "public",
              "conversions_disk": "public",
              "size": "600000",
              "order_column": "1",
              "created_at": "2024-01-01T00:00:00.000Z",
              "updated_at": "2024-01-01T00:00:00.000Z",
              "url": "https://example.com/host-tesla-front.jpg",
              "thumbnail": "https://example.com/host-tesla-front-thumb.jpg",
              "preview": "https://example.com/host-tesla-front-preview.jpg",
              "original_url": "https://example.com/host-tesla-front-original.jpg",
              "preview_url": "https://example.com/host-tesla-front-preview.jpg"
            },
            "front_image_doc": null,
            "gallery": [
              {
                "id": 2,
                "model_type": "Item",
                "model_id": "102",
                "uuid": "gallery2",
                "collection_name": "gallery",
                "name": "tesla-gallery-1",
                "file_name": "tesla-gallery-1.jpg",
                "mime_type": "image/jpeg",
                "disk": "public",
                "conversions_disk": "public",
                "size": "450000",
                "order_column": "1",
                "created_at": "2024-01-01T00:00:00.000Z",
                "updated_at": "2024-01-01T00:00:00.000Z",
                "url": "https://example.com/host-tesla-gallery-1.jpg",
                "thumbnail": "https://example.com/host-tesla-gallery-1-thumb.jpg",
                "preview": "https://example.com/host-tesla-gallery-1-preview.jpg",
                "original_url": "https://example.com/host-tesla-gallery-1-original.jpg",
                "preview_url": "https://example.com/host-tesla-gallery-1-preview.jpg"
              }
            ],
            "available_dates": null,
            "not_available_dates": null,
            "booked_dates": null,
            "item_info": "{\"host_id\":\"1\",\"service_type\":\"booking\",\"review_data\":[],\"features_data\":[],\"gallery_image_urls\":[]}",
            "metaData": "{}"
          }
        ]
      }
    };
    
    var response = mockResponse;
    // ========== END MOCK DATA ==========
    
    if (response != null) {
      myItemsModels = MyItemsModel.fromJson(response);
      if (myItemsModels!.data != null) {
        list.addAll(myItemsModels!.data!.items!);
        offset = myItemsModels!.data!.offset!;
      }
    }
    setState(() {});
    refreshController.loadComplete();
    refreshController.refreshCompleted();
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
      } else {
        showErrorToastMessage(response['error']);
      }
    }
  }

  onLoading() {
    getData(generalScopeController.searchLead.text);
    setState(() {});
  }

  onRefresh() {
    myItemsModels = null;
    list = [];
    setState(() {});
    offset = 0;
    getData(generalScopeController.searchLead.text);
  }

  @override
  void initState() {
    super.initState();
    item = null;
    initialitems = null;
    getData("");
  }

  Timer? _debounce;
  @override
  void dispose() {
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  String _previousValue = '';

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    if (value != _previousValue) {
      _debounce = Timer(const Duration(milliseconds: 1000), () {
        _previousValue = value;
        myItemsModels = null;
        list.clear();
        offset = 0;
        getData(value);
      });
    }
  }

  void resetSearch() {
    generalScopeController.searchLead.clear();
    myItemsModels = null;
    list = [];
    offset = 0;
    getData("");
  }

  HomeController homeController = Get.find();

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          appBar: AppBar(
            automaticallyImplyLeading: false,
            // titleSpacing: 10,
            centerTitle: true,
            backgroundColor: notifires.getbgcolor,
            elevation: 0,
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 38,
                child: TextFormField(
                  onChanged: (value) {
                    onSearchChanged(value);
                  },
                  focusNode: _focusNode,
                  style: regular2(context),
                  controller: generalScopeController.searchLead,
                  decoration: InputDecoration(
                    suffixIcon:
                        generalScopeController.searchLead.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: notifires.getgreycolor),
                                onPressed: () {
                                  resetSearch();
                                  setState(() {});
                                },
                              )
                            : null,
                    filled: true,
                    fillColor: notifires.getboxcolor,
                    prefixIcon:
                        Icon(Icons.search, color: notifires.getgreycolor),
                    hintStyle: regular2(context),
                    contentPadding: const EdgeInsets.only(top: 0, bottom: 0),
                    hintText: "Search".tr,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: getColorBasedOnActiveModuleid(), width: 1)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(
                            color: getColorBasedOnActiveModuleid(), width: 1)),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    generalController.currentIndexHost.value = 0;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BottomHost(
                                  initialIndex: 0,
                                )));

                    generalScopeController.searchLead.clear();
                  },
                  icon: Icon(
                    size: 28,
                    Icons.cancel_outlined,
                    color: notifires.getGrey3Whitecolor,
                  ))
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    "My Posts".tr,
                    style: heading3Grey1(context),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SmartRefresher(
                    controller: refreshController,
                    onRefresh: onRefresh,
                    onLoading: onLoading,
                    enablePullUp: offset == -1 ? false : true,
                    child: ListView(
                      children: [
                        myItemsModels == null
                            ? verticleShimmerWidgetBookable()
                            : list.isEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 250),
                                    child: Center(
                                      child: buildNoDataWidget(
                                        context,
                                        "No product found".tr,
                                      ),
                                    ),
                                  )
                                : GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 1,
                                      crossAxisSpacing: 8,
                                      mainAxisExtent: 350,
                                      mainAxisSpacing: 8,
                                    ),
                                    itemCount: list.length,
                                    itemBuilder: (context, index) {
                                      ItemInfo? itemInfoData;
                                      String? jsonString = list[index].itemInfo;
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
                                              getData("");
                                            });
                                          });
                                          if (widget.mode == ScreenMode.edit) {
                                            item = list[index];
                                          }
                                        },
                                        onVehicleDetails: () {
                                          showPopUpScreen(
                                            context,
                                            VehicleDetailSScreen(
                                              id: list[index].id,
                                              itemInfo: itemInfoData,
                                              rating: list[index].itemRating,
                                              title: list[index].title,
                                              address: list[index].address,
                                              latitute: list[index].latitude,
                                              longtitute: list[index].longitude,
                                              frontImage:
                                                  list[index].frontImage?.url ??
                                                      "",
                                              itemType: list[index].itemType,
                                              price: list[index].price,
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
                Text('Do you want to delete your items?'.tr,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                        onTap: () {},
                        child: InkWell(
                            onTap: () {
                              Navigator.pop(context);
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
                                    child: Text("Cancel".tr,
                                        style: normalAirBk.copyWith(
                                            color: Colors.white)))))),
                    InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          deleteMethod(index);
                        },
                        child: Container(
                            margin: const EdgeInsets.only(left: 8, right: 8),
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
                            )))),
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
}
