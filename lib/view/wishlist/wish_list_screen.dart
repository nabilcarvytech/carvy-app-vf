import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/model/items_model.dart';
import '../../../api/config.dart';
import '../../../controller/global_scope_controller.dart';
import '../../../controller/wish_list_controller.dart';
import '../../../customwidget/data_not_found.dart';
import '../../../customwidget/project_color.dart';
import '../../../helper/http_service.dart';

import '../../../utils/common_widget.dart';
import '../../../utils/theme_style.dart';
import '../../../work_space.dart';

class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

WishListController wishListController = Get.find();

class _WishListScreenState extends State<WishListScreen> {
  GlobalScopeController globalScopeController = Get.find();
  ItemModel? itemModel;
  bool noData = false;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchData(); // Retrieve dark mode setting
    });
  }

  fetchData() async {
    if (token.isEmpty) {
      return;
    }
    var response = await httpPost(Config.getWishlist, {});
    if (response != null && response['status'] == 200) {
      itemModel = ItemModel.fromJson(response);
    } else {
      noData = true;
      showerrorWhenloginwithOtherDevice = "${response["error"]}";
    }
    setState(() {});
  }

  stateSetter(fn) => setState(() {});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        generalController.tabController.index = 0;
        generalController.currentIndex.value = 0;
      },
      child: Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: AppBar(
          centerTitle: true,
          scrolledUnderElevation: 0,
          leadingWidth: 85,
          backgroundColor: notifires.getbgcolor,
          elevation: 0,
          title: Text(
            "Wishlist".tr,
            style: heading2Grey1(context),
          ),
        ),
        body: showerrorWhenloginwithOtherDevice.toString() ==
                "The selected token is invalid."
            ? Center(
                child: showTokenExpirePlease(),
              )
            : token.isEmpty
                ? Center(
                    child: notloginwidget(),
                  )
                : itemModel == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: verticleShimmerWidgetBookable(),
                        ),
                      )
                    : noData == true
                        ? Center(
                            child: Text(
                              "No Data Found".tr,
                              style: normalAirBk.copyWith(
                                  color: notifires.getwhiteblackcolor),
                            ),
                          )
                        : connectionLost == true
                            ? Center(
                                child: connectionError(
                                    context, "Something went wrong".tr),
                              )
                            : itemModel!.data!.items!.isEmpty
                                ? Center(
                                    child: buildNoDataWidget(
                                        context, "Please add".tr),
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: itemVerticalView(
                                        itemModel!.data!.items,
                                        false,
                                        true,
                                        stateSetter,
                                        false),
                                  ),
      ),
    );
  }
}
