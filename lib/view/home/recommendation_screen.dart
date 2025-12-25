import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/items_model.dart';
import 'package:carvy/utils/theme_style.dart';
import '../../../api/config.dart';
import '../../../customwidget/data_not_found.dart';
import '../../../helper/http_service.dart';
import '../../../utils/common_widget.dart';
import '../../controller/items_detail_controller.dart';
import '../../work_space.dart';
import '../bottombar/home_main.dart';

class RecommendationScreen extends StatefulWidget {
  final String? title;
  final String? locationId;
  final String? userId;
  final dynamic itemTypeId;
  final bool? comefromprofilepage; // it is for top category
  List? itemList; // it is for top category
  RecommendationScreen(
      {super.key,
      this.title,
      this.locationId,
      this.userId,
      this.comefromprofilepage,
      this.itemList,
      this.itemTypeId});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final SearchControllerHome searchController = Get.find();
  ItemModel? itemModel;
  RefreshController refreshController = RefreshController();
  ItemDetailsController propertyDetailController = Get.find();
  num offset = 0;
  var list = [];
  @override
  void initState() {
    super.initState();
    if (widget.locationId == "-1") {
    } else {
      fetchData();
      widget.itemList = list;
    }

    // fetchData();
  }

  var isLoading = false;
  fetchData() async {
    dynamic response;
    try {
      isLoading = true;
      setState(() {});
      
      // ========== MOCK DATA - OLD API CALLS COMMENTED ==========
      // if (widget.userId != null) {
      //   response = await httpGet(Config.getUseritems,
      //       {"userid": widget.userId, "offset": "$offset"});
      // } else if (widget.title == "Recommended Vehicle") {
      //   response = await httpPost(Config.featuredItems, {"offset": "$offset"});
      // } else if (widget.title == "Vehicles Near You") {
      //   response = await httpPost(Config.nearbyItems, {
      //     "offset": "$offset",
      //     "item_type": "${searchController.globalItemType.value}"
      //   });
      // } else {
      //   response = await httpPost(Config.getItemsByLocation,
      //       {"location_id": widget.locationId, "offset": "$offset"});
      // }
      
      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));
      
      // MOCK: Return static ItemModel data based on title
      if (widget.userId != null) {
        response = {
          "status": 200,
          "message": "User items retrieved successfully",
          "error": "",
          "data": {
            "items": [
              {
                "id": 501,
                "name": "User Vehicle 1",
                "item_rating": "4.6",
                "mobile": "+1234567895",
                "person_allowed": "5",
                "address": "100 User Street",
                "state_region": "California",
                "city": "San Diego",
                "zip_postal_code": "92101",
                "price": "75.00",
                "latitude": "32.7157",
                "longitude": "-117.1611",
                "status": "1",
                "item_type_id": "1",
                "image": "https://example.com/user1.jpg",
                "item_info": null,
                "is_in_wishlist": false,
                "item_type": "Sedan",
                "distance": null
              }
            ],
            "offset": 0
          }
        };
      } else if (widget.title == "Recommended Vehicle") {
        response = {
          "status": 200,
          "message": "Featured items retrieved successfully",
          "error": "",
          "data": {
            "items": [
              {
                "id": 201,
                "name": "BMW 3 Series 2023",
                "item_rating": "4.8",
                "mobile": "+1234567892",
                "person_allowed": "5",
                "address": "789 Luxury Lane",
                "state_region": "California",
                "city": "Beverly Hills",
                "zip_postal_code": "90210",
                "price": "120.00",
                "latitude": "34.0736",
                "longitude": "-118.4004",
                "status": "1",
                "item_type_id": "1",
                "image": "https://example.com/bmw3.jpg",
                "item_info": null,
                "is_in_wishlist": false,
                "item_type": "Sedan",
                "distance": null
              }
            ],
            "offset": 0
          }
        };
      } else if (widget.title == "Vehicles Near You") {
        response = {
          "status": 200,
          "message": "Nearby items retrieved successfully",
          "error": "",
          "data": {
            "items": [
              {
                "id": 101,
                "name": "Toyota Camry 2023",
                "item_rating": "4.5",
                "mobile": "+1234567890",
                "person_allowed": "5",
                "address": "123 Main Street",
                "state_region": "California",
                "city": "Los Angeles",
                "zip_postal_code": "90001",
                "price": "50.00",
                "latitude": "34.0522",
                "longitude": "-118.2437",
                "status": "1",
                "item_type_id": "1",
                "image": "https://example.com/camry.jpg",
                "item_info": null,
                "is_in_wishlist": false,
                "item_type": "Sedan",
                "distance": "2.5"
              }
            ],
            "offset": 0
          }
        };
      } else {
        response = {
          "status": 200,
          "message": "Location items retrieved successfully",
          "error": "",
          "data": {
            "items": [
              {
                "id": 601,
                "name": "Location Vehicle 1",
                "item_rating": "4.4",
                "mobile": "+1234567896",
                "person_allowed": "5",
                "address": "200 Location Blvd",
                "state_region": "California",
                "city": "Sacramento",
                "zip_postal_code": "95814",
                "price": "60.00",
                "latitude": "38.5816",
                "longitude": "-121.4944",
                "status": "1",
                "item_type_id": "2",
                "image": "https://example.com/location1.jpg",
                "item_info": null,
                "is_in_wishlist": false,
                "item_type": "SUV",
                "distance": null
              }
            ],
            "offset": 0
          }
        };
      }

      if (response != null && response['status'] == 200) {
        itemModel = ItemModel.fromJson(response);
        list.addAll(itemModel!.data!.items!);
        widget.itemList = list;
        offset = itemModel!.data!.offset!;
        isLoading = false;
        setState(() {});
      } else {
        isLoading = false;
        showerrorWhenloginwithOtherDevice = "${response["error"]}";
        showErrorToastMessage("${response["error"]}");
      }
      refreshController.loadComplete();
      refreshController.refreshCompleted();
      setState(() {});
    } catch (e) {
      showErrorToastMessage(e);
      setState(() {});
    }
  }

  onLoading() {
    setState(() {});
    fetchData();
    setState(() {});
  }

  onRefresh() {
    itemModel = null;
    list = [];
    setState(() {});
    offset = 0;
    fetchData();
  }

  stateSetter(fn) => setState(() {});

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return WillPopScope(
      onWillPop: () async {
        if (widget.comefromprofilepage == true) {
          Get.back();
        } else {
          if (webPlateForm) {
            Get.toNamed(
              WebRoutes.homeMain,
            );
          } else {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => const HomeMain(
                          initialIndex: 0,
                        )));
          }
        }
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: notifires.getbgcolor,
          centerTitle: true,
          leadingWidth: 85,
          scrolledUnderElevation: 0,
          leading: GestureDetector(
              onTap: () {
                if (widget.comefromprofilepage == true) {
                  Navigator.pop(context);
                } else {
                  if (webPlateForm) {
                    Get.toNamed(
                      WebRoutes.homeMain,
                    );
                  } else {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const HomeMain(
                                  initialIndex: 0,
                                )));
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 8, bottom: 8, right: 20),
                child: PhysicalModel(
                  color: Colors.transparent,
                  shadowColor: notifires.getGrey4Whitecolor,
                  elevation: 5.0, // Adjust the elevation value as needed
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
          title: Text("${widget.title}".tr, style: heading2Grey1(context)),
        ),
        backgroundColor: notifires.getbgcolor,
        body: Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          child: SmartRefresher(
            controller: refreshController,
            onRefresh: onRefresh,
            onLoading: () async {
              await onLoading();
              setState(() {
                isLoading =
                    false; // Set isLoading to false after loading is completed
              });
            },
            enablePullUp: offset == -1 ? false : true,
            child: isLoading
                ? Center(
                    child: verticleShimmerWidgetBookable(),
                  )
                : connectionLost == true
                    ? Center(
                        child:
                            connectionError(context, "Something went wrong".tr),
                      )
                    : widget.itemList!.isEmpty
                        ? Center(
                            child:
                                buildNoDataWidget(context, "No Data founds".tr),
                          )
                        : itemVerticalView(
                            widget.itemList!, false, false, stateSetter, false),
          ),
        ),
      ),
    );
  }
}
