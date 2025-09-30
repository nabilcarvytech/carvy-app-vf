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
      if (widget.userId != null) {
        response = await httpGet(Config.getUseritems,
            {"userid": widget.userId, "offset": "$offset"});
      } else if (widget.title == "Recommended Vehicle") {
        response = await httpPost(Config.featuredItems, {"offset": "$offset"});
      } else if (widget.title == "Vehicles Near You") {
        response = await httpPost(Config.nearbyItems, {
          "offset": "$offset",
          "item_type": "${searchController.globalItemType.value}"
        });
      } else {
        response = await httpPost(Config.getItemsByLocation,
            {"location_id": widget.locationId, "offset": "$offset"});
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
