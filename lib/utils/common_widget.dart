import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/home_controller.dart';
import 'package:carvy/controller/push_notifications.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/utils/vehicle_common_widgets.dart';
import 'package:carvy/view/booking/vehicle/vehicle_booking_summary_screen.dart';
import 'package:carvy/view/booking/vehicle_photoes_booking.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/digitalsignatuecommon/digital_singnature.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/myaccount/addaddress/pick_address_with_map.dart';
import 'package:carvy/view/myaccount/my_profile_screen.dart';
import 'package:carvy/view/search/search_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/config.dart';
import '../customwidget/custom_bottom_sheet.dart';
import '../customwidget/miscellaneous_project_elements.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../helper/http_service.dart';
import '../model/booking_model.dart';
import '../model/cancellation_reason_model.dart';
import '../model/vehicle_home_model.dart';
import '../view/auth/login_screen.dart';
import '../view/booking/e_reciept.dart';
import '../view/chat/conversation_screen.dart';
import '../view/itemdetail/vehicle/vehicle_detail_screen.dart';
import '../view/wishlist/wish_list_screen.dart';
import '../work_space.dart';

Widget commonlyUserlogoAlert() {
  return Center(
    child: ClipOval(
        child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: getColorBasedOnActiveModuleid()),
      child: Image.asset('assets/images/logo-carvy.png', fit: BoxFit.fill),
    )),
  );
}

Widget commonlyUserlogo() {
  return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(color: getColorBasedOnActiveModuleid()),
          child:
              Image.asset('assets/images/logo-carvy.png', fit: BoxFit.fill)));
}

class LocationItem {
  final String assetImage;
  final String country;

  const LocationItem({
    required this.assetImage,
    required this.country,
  });
}

homeLocations(List<Location> list, notifire) {
  SearchControllerHome filterController = Get.find();
  if (list.isEmpty) {
    return SizedBox(
      height: 146.0,
      child: Container(
        color: const Color.fromARGB(255, 250, 247, 247),
        child: Center(
          child: Text(
            "No data found",
            style: TextStyle(
              color: notifires.getwhiteblackcolor,
              fontSize: 16, // Adjust font size as needed
            ),
          ),
        ),
      ),
    );
  }
  return SizedBox(
    width: double.infinity,
    height: 146.0,
    child: Padding(
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: (list.length) > 5 ? 5 : (list.length),
        itemBuilder: (context, index) {
          return list.isEmpty
              ? Text("locations Not Found".tr)
              : Padding(
                  padding: const EdgeInsets.only(right: 15, top: 5, bottom: 5),
                  child: InkWell(
                    onTap: () {
                      if (list[index].latitude != null &&
                          list[index].longitude != null) {
                        slatsearch = list[index].latitude;
                        sLongSearch = list[index].longitude;
                        generalScopeController.homeSearchLocation.value =
                            list[index].cityName!;
                        generalScopeController.textEditingControllerCity.text =
                            list[index].cityName!;
                      } else {
                        slatsearch = "";
                        sLongSearch = "";
                      }
                      filterController.setDefaultDates(
                        startDateCustomDate:
                            generalScopeController.startDateCustomDate,
                        endDateCustomDate:
                            generalScopeController.endDateCustomDate,
                        startDate: filterController.startDate,
                        endDates: filterController.endDates,
                      );

                      filterController.submitMethod(context, true);
                    },
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.all(0),
                          decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(12)),
                          height: 125,
                          width: 146,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                                height: 125,
                                child: myNetworkImageWithShimmer(
                                    list.elementAt(index).image)),
                          ),
                        ),
                        Column(
                          children: [
                            const Expanded(child: SizedBox()),
                            SizedBox(
                              width: 146,
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        bottomRight: Radius.circular(12),
                                        bottomLeft: Radius.circular(12)),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    )),
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                        list.elementAt(index).cityName!.length >
                                                10
                                            ? list
                                                .elementAt(index)
                                                .cityName!
                                                .substring(0, 9)
                                            : list.elementAt(index).cityName ??
                                                "".tr,
                                        style: boldstyle(context)
                                            .copyWith(color: whiteColor)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    ),
  );
}

bool isSelected = false;
int wishListLoading = -1;
int wishListLoadingHorizontal = -1;

Widget itemVerticalView(
    list, shrink, fromWishList, StateSetter setState, openDetailInButtMSheet) {
  return GridView.builder(
    shrinkWrap: shrink,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 1,
      crossAxisSpacing: 5,
      mainAxisExtent: 240,
      mainAxisSpacing: 3,
    ),
    physics: shrink == false
        ? const BouncingScrollPhysics()
        : const NeverScrollableScrollPhysics(),
    itemCount: shrink == true
        ? (list != null && list!.length > 4 ? 4 : (list?.length ?? 0))
        : (list?.length ?? 0),
    itemBuilder: (context, index) {
      String? serviceType = "";
      ItemInfo? itemInfoData;
      if (list != null && list.length > index && list[index] != null) {
        if (activeModuleId.value == 1 ||
            activeModuleId.value == 2 ||
            activeModuleId.value == 3 ||
            activeModuleId.value == 5) {
          String? jsonSliders = list[index].itemInfo;
          if (jsonSliders != null) {
            itemInfoData = ItemInfo.fromJson(json.decode(jsonSliders));
            Map<String, dynamic> itemInfo = jsonDecode(jsonSliders);
            serviceType = itemInfo["service_type"];
          }
        }
        return Padding(
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 5),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VehicleDetailSScreen(
                            id: list.elementAt(index).id,
                            itemInfo: itemInfoData,
                            rating: list[index].itemRating,
                            title: list[index].name,
                            address: list[index].address,
                            latitute: list[index].latitude,
                            longtitute: list[index].longitude,
                            frontImage: list[index].image,
                            itemType: list[index].itemType,
                            isWishList: list[index].isInWishlist,
                            price: list[index].price,
                          )));
            },
            child: Container(
              width: double.infinity,
              height: 230,
              decoration: BoxDecoration(
                // color: notifires.getboxcolor,
                color: blackColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: grey5,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          // Image
                          Positioned.fill(
                            child: myNetworkImageWithShimmer(list[index].image),
                          ),

                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 80, // adjust shadow height
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                      Colors.black.withOpacity(0.9),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          Positioned(
                            bottom: 7,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      list[index].name!.length > 21
                                          ? list[index].name!.substring(0, 20)
                                          : list[index].name!,
                                      style: heading3Grey1(context).copyWith(
                                        color: whiteColor,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(7),
                                          color: getColorBasedOnActiveModuleid()
                                              .withValues(alpha: .4)),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: orangeColor,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${list[index].itemRating ?? ""}.0'
                                                .tr,
                                            style: boldstyle(context).copyWith(
                                                color: whiteColor, fontSize: 9),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    if (itemInfoData!.transmission != null &&
                                        itemInfoData.transmission!.isNotEmpty)
                                      Text(
                                        itemInfoData.transmission!,
                                        style: regular3(context).copyWith(
                                          fontSize: 12,
                                          color: whiteColor,
                                        ),
                                      ),
                                    if (itemInfoData.transmission != null &&
                                        itemInfoData.transmission!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Text(
                                          "•",
                                          style: TextStyle(
                                              color: whiteColor, fontSize: 12),
                                        ),
                                      ),
                                    if (itemInfoData.makeType != null &&
                                        itemInfoData.makeType!.isNotEmpty)
                                      Text(
                                        itemInfoData.makeType!,
                                        style: regular3(context).copyWith(
                                          fontSize: 12,
                                          color: whiteColor,
                                        ),
                                      ),
                                    if (itemInfoData.makeType != null &&
                                        itemInfoData.makeType!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Text(
                                          "•",
                                          style: TextStyle(
                                              color: whiteColor, fontSize: 12),
                                        ),
                                      ),
                                    if (itemInfoData.seatCapicity != null)
                                      Text(
                                        "${itemInfoData.seatCapicity} ${"Seats".tr}",
                                        style: regular3(context).copyWith(
                                          fontSize: 12,
                                          color: whiteColor,
                                        ),
                                      ),
                                    Spacer(),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "$currency ${list.elementAt(index).price!.length > 8 ? list.elementAt(index).price!.substring(0, 7) : list.elementAt(index).price ?? ""}",
                                          style: boldstyle(context).copyWith(
                                              color:
                                                  getColorBasedOnActiveModuleid(),
                                              fontSize: 14,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                        serviceType == "booking"
                                            ? Text(
                                                ' /day'.tr,
                                                maxLines: 1,
                                                style: regular(context)
                                                    .copyWith(
                                                        color: notifires
                                                            .getGrey4Whitecolor,
                                                        overflow: TextOverflow
                                                            .ellipsis),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 5,
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),

                          Positioned(
                            top: 10,
                            right: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                wishListLoadingHorizontal == index
                                    ? const SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: CircularProgressIndicator())
                                    : InkWell(
                                        child: list[index].isInWishlist ==
                                                    false ||
                                                list[index].isInWishlist == null
                                            ? SvgPicture.asset(
                                                'assets/images/whitHeart.svg', // Update the asset path to the SVG file
                                                height: 20,
                                              )
                                            : SvgPicture.asset(
                                                'assets/images/redHeart.svg', // Update the asset path to the SVG file
                                                height: 20,
                                              ),
                                        onTap: () async {
                                          wishListLoadingHorizontal = index;
                                          setState(() {});
                                          if (list[index].isInWishlist ==
                                              false) {
                                            var value = await wishListController
                                                .addTowishlist(list[index].id);
                                            if (value == true) {
                                              var vvv = list[index];
                                              vvv.wishlistSetter = true;
                                              list[index] = vvv;
                                            }
                                          } else {
                                            var value = await wishListController
                                                .removeToWishlist(
                                                    list[index].id);
                                            if (value == true) {
                                              var vvv = list[index];
                                              vvv.wishlistSetter = false;
                                              list[index] = vvv;
                                            }
                                          }
                                          wishListLoadingHorizontal = -1;
                                          setState(() {});
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 7,
                      ),
                      Icon(
                        CupertinoIcons.location,
                        size: 20,
                        color: getColorBasedOnActiveModuleid(),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          "${list.elementAt(index).address ?? ""},",
                          overflow: TextOverflow.ellipsis,
                          style: regular3(context).copyWith(
                            fontSize: 12,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      Spacer(),
                      if (itemInfoData.hostFirstName != null)
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.person,
                              size: 17,
                              color: getColorBasedOnActiveModuleid(),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "${"By".tr} - ${itemInfoData.hostFirstName ?? ""}",
                              overflow: TextOverflow.ellipsis,
                              style: regular3(context).copyWith(
                                fontSize: 12,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      SizedBox(
                        width: 5,
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return Container();
      }
    },
  );
}

Widget itemVerticalViewPublic(list, bool shrink, bool fromWishList,
    StateSetter setState, BuildContext context) {
  if (list == null || list.isEmpty) {
    return Container();
  }

  int itemLimit = shrink ? (list.length > 4 ? 4 : list.length) : list.length;
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: List.generate(itemLimit, (index) {
      String? serviceType = "";
      ItemInfo? itemInfoData;
      if (list.length > index && list[index] != null) {
        if (activeModuleId.value == 1 ||
            activeModuleId.value == 2 ||
            activeModuleId.value == 3 ||
            activeModuleId.value == 5) {
          String? jsonSliders = list[index].itemInfo;
          if (jsonSliders != null) {
            itemInfoData = ItemInfo.fromJson(json.decode(jsonSliders));
            Map<String, dynamic> itemInfo = jsonDecode(jsonSliders);
            serviceType = itemInfo["service_type"];
          }
        }
        return Padding(
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 5),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VehicleDetailSScreen(
                    id: list[index].id,
                    itemInfo: itemInfoData,
                    rating: list[index].itemRating,
                    title: list[index].name,
                    address: list[index].address,
                    latitute: list[index].latitude,
                    longtitute: list[index].longitude,
                    frontImage: list[index].image,
                    itemType: list[index].itemType,
                    isWishList: list[index].isInWishlist,
                    price: list[index].price,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              height: 230,
              decoration: BoxDecoration(
                color: notifires.getbgcolor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: grey5,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: myNetworkImageWithShimmer(list[index].image),
                          ),
                          Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                height: 80,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.7),
                                      Colors.black.withOpacity(0.9),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 7,
                            left: 0,
                            right: 0,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 8,
                                    ),
                                    Text(
                                      list[index].name!.length > 21
                                          ? list[index].name!.substring(0, 20)
                                          : list[index].name!,
                                      style: heading3Grey1(context).copyWith(
                                        color: whiteColor,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(7),
                                        color: getColorBasedOnActiveModuleid()
                                            .withValues(alpha: 0.4),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.star,
                                            color: orangeColor,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            '${list[index].itemRating ?? ""}.0'
                                                .tr,
                                            style: boldstyle(context).copyWith(
                                              color: whiteColor,
                                              fontSize: 9,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 10,
                                    ),
                                    if (itemInfoData!.transmission != null &&
                                        itemInfoData.transmission!.isNotEmpty)
                                      Text(
                                        itemInfoData.transmission!,
                                        style: regular3(context).copyWith(
                                          fontSize: 12,
                                          color: whiteColor,
                                        ),
                                      ),
                                    if (itemInfoData.transmission != null &&
                                        itemInfoData.transmission!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Text(
                                          "•",
                                          style: TextStyle(
                                              color: whiteColor, fontSize: 12),
                                        ),
                                      ),
                                    if (itemInfoData.makeType != null &&
                                        itemInfoData.makeType!.isNotEmpty)
                                      Text(
                                        itemInfoData.makeType!,
                                        style: regular3(context).copyWith(
                                          fontSize: 12,
                                          color: whiteColor,
                                        ),
                                      ),
                                    if (itemInfoData.makeType != null &&
                                        itemInfoData.makeType!.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: Text(
                                          "•",
                                          style: TextStyle(
                                              color: whiteColor, fontSize: 12),
                                        ),
                                      ),
                                    if (itemInfoData.seatCapicity != null)
                                      Text(
                                        "${itemInfoData.seatCapicity} ${"Seats".tr}",
                                        style: regular3(context).copyWith(
                                          fontSize: 12,
                                          color: whiteColor,
                                        ),
                                      ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          "$currency ${list[index].price!.length > 8 ? list[index].price!.substring(0, 7) : list[index].price ?? ""}",
                                          style: boldstyle(context).copyWith(
                                            color:
                                                getColorBasedOnActiveModuleid(),
                                            fontSize: 14,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        serviceType == "booking"
                                            ? Text(
                                                ' /day'.tr,
                                                style:
                                                    regular(context).copyWith(
                                                  color: notifires
                                                      .getGrey4Whitecolor,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              )
                                            : const SizedBox(),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                wishListLoadingHorizontal == index
                                    ? const SizedBox(
                                        height: 25,
                                        width: 25,
                                        child: CircularProgressIndicator())
                                    : InkWell(
                                        child: list[index].isInWishlist ==
                                                    false ||
                                                list[index].isInWishlist == null
                                            ? SvgPicture.asset(
                                                'assets/images/whitHeart.svg',
                                                height: 20,
                                              )
                                            : SvgPicture.asset(
                                                'assets/images/redHeart.svg',
                                                height: 20,
                                              ),
                                        onTap: () async {
                                          wishListLoadingHorizontal = index;
                                          setState(() {});
                                          if (list[index].isInWishlist ==
                                              false) {
                                            var value = await wishListController
                                                .addTowishlist(list[index].id);
                                            if (value == true) {
                                              var vvv = list[index];
                                              vvv.wishlistSetter = true;
                                              list[index] = vvv;
                                            }
                                          } else {
                                            var value = await wishListController
                                                .removeToWishlist(
                                                    list[index].id);
                                            if (value == true) {
                                              var vvv = list[index];
                                              vvv.wishlistSetter = false;
                                              list[index] = vvv;
                                            }
                                          }
                                          wishListLoadingHorizontal = -1;
                                          setState(() {});
                                        },
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      SizedBox(
                        width: 7,
                      ),
                      Icon(
                        CupertinoIcons.location,
                        size: 20,
                        color: getColorBasedOnActiveModuleid(),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Expanded(
                        child: Text(
                          "${list[index].address ?? ""},",
                          overflow: TextOverflow.ellipsis,
                          style: regular3(context).copyWith(
                            fontSize: 12,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const Spacer(),
                      if (itemInfoData.hostFirstName != null)
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.person,
                              size: 17,
                              color: getColorBasedOnActiveModuleid(),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Text(
                              "${"By".tr} - ${itemInfoData.hostFirstName ?? ""}",
                              overflow: TextOverflow.ellipsis,
                              style: regular3(context).copyWith(
                                fontSize: 12,
                              ),
                              maxLines: 1,
                            ),
                          ],
                        ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      } else {
        return Container(); // Fallback for invalid index
      }
    }),
  );
}

myBookingListWidget(
  List<Bookings> list,
  btnText,
  StateSetter setState,
  bool fromPropBooking,
  String listType,
  onItemCancelled,
) {
  innerMethod(context, index) async {
    if (btnText == "Cancel") {
      showLoading();
      var response =
          await httpGet(Config.getCancelReasons, {"userType": "user"});
      closeLoading();
      if (response != null) {
        CancellationReasonModel model =
            CancellationReasonModel.fromJson(response);
        await showModalBottomSheet(
          showDragHandle: true,
          enableDrag: true,
          context: context,
          builder: (context) {
            return CustomBottomSheet(model: model);
          },
        ).then((value) async {
          if (value != null) {
            showDialog<void>(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: notifires.getbgcolor,
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: <Widget>[
                        SizedBox(
                            height: 100,
                            child: Image.asset("assets/images/alert.png")),
                        const SizedBox(
                          height: 20,
                        ),
                        Icon(
                          Icons.error,
                          size: 32,
                          color: getColorBasedOnActiveModuleid(),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        list[index].status == "Confirmed" &&
                                listType == 'UpComing'
                            ? Text(
                                'Your booking is confirmed. Do you still want to cancel it?'
                                    .tr,
                                textAlign: TextAlign.center,
                                style: regular2(context),
                              )
                            : Text(
                                'Do you want to cancel this booking?'.tr,
                                textAlign: TextAlign.center,
                                style: regular2(context),
                              ),
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
                                    onTap: () {
                                      Navigator.pop(context);
                                    },
                                    child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            color: notifires.getBoxColor,
                                            border: Border.all(
                                                color: notifires.getBoxColor),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                            child: Text(
                                          "No".tr,
                                          style: heading3Grey1(context),
                                        ))))),
                            Expanded(
                                child: InkWell(
                                    onTap: () async {
                                      BookingController bookingController =
                                          Get.find();
                                      Navigator.pop(context);
                                      showLoading();
                                      var resp = await httpPost(
                                          Config.cancelBookingByUser, {
                                        "booking_id".tr: "${list[index].id}".tr,
                                        "cancellation_reasion".tr: "$value".tr
                                      });
                                      closeLoading();
                                      if (resp['status'] == 200) {
                                        showToastMessage(resp['message']);
                                        bookingController
                                            .updateBookingStatusIfExists(
                                          bookingId: list[index].id.toString(),
                                          hostId: list[index].hostId.toString(),
                                          userId: userId.toString(),
                                          newStatus:
                                              "Cancelled", // or "Confirmed", "Pending", etc.
                                        );

                                        onItemCancelled(index);
                                        setState(() {});
                                      } else {
                                        showErrorToastMessage(resp['error']);
                                      }
                                    },
                                    child: Container(
                                        margin: const EdgeInsets.only(
                                            left: 8, right: 8),
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color:
                                                    getColorBasedOnActiveModuleid()),
                                            color:
                                                getColorBasedOnActiveModuleid(),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Center(
                                            child: Text(
                                          "Yes".tr,
                                          style: heading3(context).copyWith(
                                            color: Colors.white,
                                          ),
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
        });
      }
    } else if (btnText == "Add Review") {
      if (list[index].reviewStatus != null && list[index].reviewStatus != "0") {
        await showModalBottomSheet(
          isDismissible: true,
          showDragHandle: true,
          enableDrag: true,
          context: context,
          builder: (context) {
            return bottomSheetReviewed(
                list[index].reviewRating, list[index].review);
          },
        );
      } else {
        RxInt count = 0.obs;
        textEditingControllerReview.text = "";
        await showModalBottomSheet(
          isScrollControlled: true,
          showDragHandle: true,
          enableDrag: true,
          context: context,
          builder: (context) {
            return bottomSheetReview(list[index].id, count, fromPropBooking,
                list[index], setState, context);
          },
        );
      }
    }
  }

  BookingController bookingController = Get.find();
  bookingController.clearBookingData();
  return ListView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        print(list[index].status);

        var itemData = jsonDecode(list[index].itemData);
        String address = itemData[0]['address'] ?? 'N/A'.tr;
        dynamic latitude = itemData[0]['latitude'] ?? 'N/A'.tr;
        dynamic longitude = itemData[0]['longitude'] ?? 'N/A'.tr;
        dynamic image = itemData[0]['image'] ?? 'N/A'.tr;
        String? totalNights =
            "${list[index].currencyCode} ${list[index].total} for ${list[index].totalNight} day";
        Map<String, dynamic> itemInfoMap = jsonDecode(itemData[0]['item_info']);
        ItemInfo? itemInfoData;
        itemInfoData = ItemInfo.fromJson(itemInfoMap);

        dynamic proType = itemData[0]['item_type'] ?? 'N/A'.tr;
        String? doorStepPrice = itemInfoData.doorStepPrice;

        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!bookingAgrinmentUser2 &&
              bookingAgrinmentuser == true &&
              listType == "UpComing") {
            bookingAgrinmentUser2 = true;
            showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: StatefulBuilder(
                    builder: (context, setBottomSheetState) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Interior Image Required'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Please upload at least two interior image of the vehicle before entering the pickup OTP."
                                      .tr,
                                  style: regular02.copyWith(
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Note: Adding interior images helps verify the condition of the car before and after pickup. This ensures fair evaluation and avoids disputes regarding the vehicle’s condition."
                                      .tr,
                                  style: regular02.copyWith(
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomsButtons(
                                    text: "Cancel".tr,
                                    backgroundColor: Colors.grey.shade400,
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: CustomsButtons(
                                    text: "Add Image".tr,
                                    backgroundColor:
                                        getColorBasedOnActiveModuleid(),
                                    onPressed: () async {
                                      bookingAgrinmentuser = false;
                                      Navigator.pop(context);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (builder) =>
                                                  VehiclePhotoesBooking(
                                                      id: "${list[index].id}")));
                                      // Handle image submission flow
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        });

        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (!otpSheetOpened &&
              openOtpAfterImageSubmit == true &&
              listType == "UpComing") {
            otpSheetOpened = true;
            showModalBottomSheet<String>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) {
                return Padding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    top: 20,
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: StatefulBuilder(
                    builder: (context, setBottomSheetState) {
                      return SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Enter OTP'.tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Enter the pickup OTP given by the vendor".tr,
                              style: regular02.copyWith(
                                color: getColorBasedOnActiveModuleid(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Pinput(
                              length: 4,
                              controller: bookingController.otpController,
                              keyboardType: TextInputType.number,
                              mainAxisAlignment: MainAxisAlignment.center,
                              defaultPinTheme: PinTheme(
                                width: 50,
                                height: 50,
                                textStyle: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: getColorBasedOnActiveModuleid()),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            CustomsButtons(
                              text: "Submit".tr,
                              backgroundColor: getColorBasedOnActiveModuleid(),
                              onPressed: () async {
                                if (bookingController
                                    .otpController.text.isEmpty) {
                                  showErrorToastMessage(
                                      "Please fill the OTP".tr);
                                  return;
                                }
                                try {
                                  final value = await bookingController
                                      .updateItemReceivedStatus(
                                    bookingId: list[index].id.toString(),
                                  );
                                  print("OTP Verified: $value");
                                  if (value == "yes") {
                                    list[index].isItemReceivedSetter = "1";
                                    generalController.myBookingTabIndex.value =
                                        1;

                                    openOtpAfterImageSubmit = false;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const HomeMain(initialIndex: 2),
                                      ),
                                    );
                                  } else {
                                    setBottomSheetState(() {});
                                  }
                                } catch (error) {
                                  print("Error in OTP verification: $error");
                                  showErrorToastMessage(
                                      "OTP verification failed.");
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        });

        /////handle the buttomsheet
        return Padding(
          padding:
              const EdgeInsets.only(left: 13, right: 13, bottom: 10, top: 10),
          child: GestureDetector(
            onTap: () {
              if (webPlateForm) {
                Get.toNamed(WebRoutes.customerEreciept, arguments: {
                  "bookings": list[index],
                  "fromPropBooking": fromPropBooking,
                })?.then((value) {
                  list[index].statusSetter = value;
                  setState(() {});
                });
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => EReceiptScreen(
                              bookings: list[index],
                              fromPropBooking: fromPropBooking,
                              doorStepPrice: doorStepPrice ?? "",
                            ))).then((value) {
                  if (value != null) {
                    list[index].statusSetter = value;
                    setState(() {});
                  }
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: notifires.getbgcolor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: notifires.getwhiteblackcolor.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      showPopUpScreen(
                          context,
                          VehicleDetailSScreen(
                            id: list.elementAt(index).itemid,
                            itemInfo: itemInfoData!,
                            rating: list[index].rating,
                            title: list[index].propTitle,
                            address: address,
                            latitute: latitude,
                            longtitute: longitude,
                            frontImage: image,
                            itemType: proType,
                            isWishList: false,
                            chatafterBooking: true,
                            price: list[index].perNight,
                          ));
                    },
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            Container(
                              height: 164,
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                  color: grey5,
                                  borderRadius: BorderRadius.circular(12)),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: myNetworkImageWithShimmer(image),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 4, bottom: 4),
                              decoration: BoxDecoration(
                                  color: getColorBasedOnActiveModuleid()
                                      .withOpacity(.8),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text("#${list[index].token}",
                                  style: regular2(context)
                                      .copyWith(color: whiteColor)),
                            )),
                        listType == "Cancelled"
                            ? SizedBox()
                            : Positioned(
                                bottom: 10,
                                right: 10,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => ConversationScreen(
                                          bookingStatus: list[index].status,
                                          bookingId: '${list[index].id}',
                                          image: image,
                                          title: list[index].propTitle!,
                                          conversationId:
                                              "${userId}_${list[index].id}_${list[index].hostId}",
                                          from: "${list[index].hostName}",
                                          senderId: "$userId",
                                          reciverId: "${list[index].hostId}",
                                        ));
                                  },
                                  child: Container(
                                    height: 35,
                                    width: 35,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: getColorBasedOnActiveModuleid(),
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble_outline,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        list[index].propTitle == null
                            ? SizedBox()
                            : Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: notifires.getboxcolor,
                                        borderRadius: BorderRadius.circular(6)),
                                    padding: EdgeInsets.all(5),
                                    child: Text(
                                      "${itemInfoData.vehicleType}",
                                      style: regular2(context).copyWith(),
                                    ),
                                  ),
                                  const Spacer(),
                                ],
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        list[index].propTitle == null
                            ? SizedBox()
                            : Row(
                                children: [
                                  Text(
                                    (list[index].propTitle!.length > 20
                                            ? '${list[index].propTitle!.substring(0, 19)}..'
                                            : list[index].propTitle!)
                                        .tr,
                                    style: heading3Grey1(context).copyWith(),
                                  ),
                                  const Spacer(),
                                  Text(
                                    totalNights.tr,
                                    style: boldstyle(context).copyWith(
                                        color: getColorBasedOnActiveModuleid(),
                                        fontSize: 16),
                                  ),
                                ],
                              ),
                      ],
                    ),
                  ),
                  Divider(
                    color: notifires.getwhiteblackcolor.withOpacity(0.2),
                    thickness: 1,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: getColorBasedOnActiveModuleid(),
                              size: 16,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Text(
                              (address.length > 30
                                  ? '${address.substring(0, 29)}..'
                                  : address),
                              style: regular2(context)
                                  .copyWith(overflow: TextOverflow.ellipsis),
                            ),
                            Spacer(),
                            listType == "ongoing"
                                ? SizedBox()
                                : Container(
                                    padding: const EdgeInsets.only(
                                        left: 8, right: 8, top: 4, bottom: 4),
                                    decoration: BoxDecoration(
                                        color: list[index].status ==
                                                    "Confirmed" ||
                                                list[index].status == "live"
                                            ? greensColor
                                            : list[index].status == "Pending"
                                                ? yellowColor
                                                : list[index].status ==
                                                        "Completed"
                                                    ? blueColor
                                                    : redColor,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: list[index].status == "Confirmed" ||
                                            list[index].status == "live" ||
                                            list[index].status == "Pending" ||
                                            list[index].status == "Declined" &&
                                                listType == "UpComing" ||
                                            listType == "Previous"
                                        ? Text("${list[index].status}",
                                            style: regular(context)
                                                .copyWith(color: whiteColor))
                                        : listType == 'Cancelled'
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    color: redColor,
                                                    border: Border.all(
                                                      color: redColor,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Text(
                                                      '${list[index].status}',
                                                      style: regular(context)
                                                          .copyWith(
                                                              color:
                                                                  whiteColor)),
                                                ),
                                              )
                                            : const SizedBox(),
                                  )
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: getColorBasedOnActiveModuleid(),
                            ),
                            const SizedBox(width: 7),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${list[index].checkIn}".tr,
                                style: regular2(context).copyWith(),
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 16,
                              color: getColorBasedOnActiveModuleid(),
                            ),
                            const SizedBox(width: 7),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                "${list[index].checkOut}".tr,
                                style: regular2(context).copyWith(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.person,
                                    size: 18,
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                  const SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      list[index].hostName == null
                                          ? "User Not Found".tr
                                          : "${list[index].hostName}",
                                      style: regular2(context),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            list[index].hostNumber != null &&
                                    list[index].hostNumber!.isNotEmpty
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(
                                        Icons.phone,
                                        size: 18,
                                        color: getColorBasedOnActiveModuleid(),
                                      ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        onTap: () => launchUrl(Uri.parse(
                                            'tel:${list[index].hostPhoneCountry}${list[index].hostNumber}')),
                                        child: Text(
                                          "${list[index].hostPhoneCountry} ${list[index].hostNumber!}",
                                          style: regular2(context),
                                        ),
                                      ),
                                    ],
                                  )
                                : const SizedBox(),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.settings,
                                    size: 18,
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                  const SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      "${itemInfoData.makeType}",
                                      style: regular2(context),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.star_border_outlined,
                                    size: 18,
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                  const SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      "${itemInfoData.model}",
                                      style: regular2(context),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_month_outlined,
                                    size: 18,
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                  const SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      "${itemInfoData.year}",
                                      style: regular2(context),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.track_changes,
                                    size: 18,
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                  const SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      "${itemInfoData.transmission}",
                                      style: regular2(context),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.local_gas_station,
                                    size: 18,
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                  const SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      "${itemInfoData.fuelType}",
                                      style: regular2(context),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.event_seat,
                                    size: 18,
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                  const SizedBox(width: 7),
                                  Flexible(
                                    child: Text(
                                      "${itemInfoData.seatCapicity}",
                                      style: regular2(context),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),

//////
                  Divider(
                    color: notifires.getwhiteblackcolor.withOpacity(0.2),
                    thickness: 1,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            list[index].basePrice != null &&
                                    list[index].basePrice != "0.00"
                                ? eReceiptWidget(
                                    name:
                                        "${"Amount".tr}(${list[index].totalNight} ${"days".tr}${")".tr}",
                                    value:
                                        "${list[index].currencyCode} ${list[index].basePrice}")
                                : const SizedBox(),
                            list[index].doorStepPrice != null &&
                                    list[index].doorStepPrice != "0.00"
                                ? eReceiptWidget(
                                    name: "Doorstep Price".tr,
                                    value:
                                        "${list[index].currencyCode} ${list[index].doorStepPrice ?? ""}")
                                : const SizedBox(),
                            list[index].ivaTax != null &&
                                    list[index].ivaTax != "0.00"
                                ? eReceiptWidget(
                                    name: "Tax".tr,
                                    value:
                                        "${list[index].currencyCode} ${list[index].ivaTax}")
                                : const SizedBox(),
                            list[index].serviceCharge != null &&
                                    list[index].serviceCharge != "0.00"
                                ? eReceiptWidget(
                                    name: "Service Charge".tr,
                                    value:
                                        "${list[index].currencyCode} ${list[index].serviceCharge}")
                                : const SizedBox(),
                            list[index].securityMoney != null &&
                                    list[index].securityMoney != "0.00"
                                ? eReceiptWidget(
                                    name: "Security Money".tr,
                                    value:
                                        "${list[index].currencyCode} ${list[index].securityMoney}",
                                  )
                                : const SizedBox(),
                            list[index].cancelledCharge == null
                                ? const SizedBox()
                                : list[index].cancelledCharge == "0.00"
                                    ? const SizedBox()
                                    : eReceiptWidget(
                                        name: "Cancelled Charge".tr,
                                        value:
                                            "${list[index].currencyCode} ${list[index].cancelledCharge}"),
                            SizedBox(
                              height: 4,
                            ),
                            eReceiptWidget(
                                name: "Total".tr,
                                value:
                                    "${list[index].currencyCode} ${list[index].total}"),
                          ],
                        ),
                      ],
                    ),
                  ),

///////

                  Divider(
                    color: notifires.getwhiteblackcolor.withOpacity(0.2),
                    thickness: 1,
                  ),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            listType == 'Cancelled'
                                ? const SizedBox()
                                : list[index].isItemReturned == 1
                                    ? Expanded(
                                        child: InkWell(
                                          onTap: () async {
                                            if (list[index].hostName == null) {
                                              showErrorToastMessage(
                                                  "Owner not found");
                                              return;
                                            }

                                            try {
                                              showLoading();
                                              var responce = await httpPost(
                                                  Config.getItemDetails, {
                                                "item_id":
                                                    "${list[index].itemid}"
                                              });
                                              if (responce != null &&
                                                  responce["status"] == 500) {
                                                closeLoading();
                                                showErrorToastMessage(
                                                    responce["message"]);
                                                return;
                                              } else {
                                                closeLoading();
                                              }
                                            } catch (e) {
                                              closeLoading();
                                            }
                                            innerMethod(context, index);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Container(
                                                height: 49,
                                                padding: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 0,
                                                    bottom: 0),
                                                decoration: BoxDecoration(
                                                  color: btnText == "Cancelled"
                                                      ? const Color.fromARGB(
                                                          128, 128, 128, 128)
                                                      : btnText == "Cancel"
                                                          ? notifires
                                                              .getBoxColor
                                                          : list[index].reviewStatus !=
                                                                      null &&
                                                                  list[index]
                                                                          .reviewStatus !=
                                                                      "0"
                                                              ? Colors.blue
                                                              : getColorBasedOnActiveModuleid(),
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                ),
                                                child: Center(
                                                    // child: Text("Cancel"),
                                                    child: Text(
                                                  list[index].reviewStatus !=
                                                              null &&
                                                          list[index]
                                                                  .reviewStatus ==
                                                              "1"
                                                      ? "View Review".tr
                                                      : "$btnText".tr,
                                                  style: boldstyle(context)
                                                      .copyWith(
                                                          color: whiteColor,
                                                          fontSize: 14),
                                                ))),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                            listType == 'Cancelled'
                                ? const SizedBox()
                                : listType == 'Previous'
                                    ? const SizedBox()
                                    : Obx(
                                        () => bookingController
                                                    .showhideisReturn.value ==
                                                true
                                            ? const SizedBox()
                                            : list[index].isItemReceived == 1
                                                ? const SizedBox()
                                                : Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        if (list[index]
                                                                .hostName ==
                                                            null) {
                                                          showErrorToastMessage(
                                                              "Owner not found");
                                                          return;
                                                        }

                                                        try {
                                                          showLoading();
                                                          var responce =
                                                              await httpPost(
                                                                  Config
                                                                      .getItemDetails,
                                                                  {
                                                                "item_id":
                                                                    "${list[index].itemid}"
                                                              });
                                                          if (responce !=
                                                                  null &&
                                                              responce[
                                                                      "status"] ==
                                                                  500) {
                                                            closeLoading();
                                                            showErrorToastMessage(
                                                                responce[
                                                                    "message"]);
                                                            return;
                                                          } else {
                                                            closeLoading();
                                                          }
                                                        } catch (e) {
                                                          closeLoading();
                                                        }

                                                        innerMethod(
                                                            context, index);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                right: 10),
                                                        child: Container(
                                                            height: 49,
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10,
                                                                    right: 10,
                                                                    top: 0,
                                                                    bottom: 0),
                                                            decoration:
                                                                BoxDecoration(
                                                              // color: btnText == "Cancel" ? RedColor:yelloColor,
                                                              color: redColor,

                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          13),
                                                            ),
                                                            child: Center(
                                                                // child: Text("Cancel"),
                                                                child: Text(
                                                              "Cancel".tr,
                                                              style: boldstyle(
                                                                      context)
                                                                  .copyWith(
                                                                      color:
                                                                          whiteColor,
                                                                      fontSize:
                                                                          14),
                                                            ))),
                                                      ),
                                                    ),
                                                  ),
                                      ),
                            Obx(
                              () =>
                                  bookingController.showhideisReturn.value ==
                                          true
                                      ? const SizedBox()
                                      : list[index].isItemDelivered == 1
                                          ? list[index].isItemRecivedButton ==
                                                  "yes"
                                              ? Expanded(
                                                  flex: 1,
                                                  child: InkWell(
                                                    onTap: () async {
                                                      if (digitalsingnature ==
                                                          "Active") {
                                                        BookingController
                                                            bookingController =
                                                            Get.find();

                                                        try {
                                                          final result =
                                                              await bookingController
                                                                  .singnatureApi(
                                                                      list[index]
                                                                          .id
                                                                          .toString(),
                                                                      true);

                                                          if (result != null &&
                                                              result.success ==
                                                                  200) {
                                                            if (result.data
                                                                    .userSigned ==
                                                                0) {
                                                              showModalBottomSheet<
                                                                  String>(
                                                                context:
                                                                    context,
                                                                isScrollControlled:
                                                                    true,
                                                                backgroundColor:
                                                                    notifires
                                                                        .getbgcolor,
                                                                shape:
                                                                    const RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            20),
                                                                  ),
                                                                ),
                                                                builder:
                                                                    (context) {
                                                                  return Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      left: 20,
                                                                      right: 20,
                                                                      top: 20,
                                                                      bottom: MediaQuery.of(
                                                                              context)
                                                                          .viewInsets
                                                                          .bottom,
                                                                    ),
                                                                    child:
                                                                        StatefulBuilder(
                                                                      builder:
                                                                          (context,
                                                                              setBottomSheetState) {
                                                                        return SingleChildScrollView(
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                'Vehicle Delivery Confirmation'.tr,
                                                                                style: TextStyle(
                                                                                  fontSize: 18,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 12),
                                                                              Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  // Bullet points
                                                                                  Text(
                                                                                    "Before proceeding with the vehicle delivery, you are required to sign the booking’s Terms & Conditions.\n\nThis step ensures full transparency between vendor and customer, protecting both parties from any disputes related to:".tr,
                                                                                    style: regular02.copyWith(
                                                                                      color: getColorBasedOnActiveModuleid(),
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    "Vehicle usage".tr,
                                                                                    style: regular02.copyWith(
                                                                                      color: getColorBasedOnActiveModuleid(),
                                                                                    ),
                                                                                  ),
                                                                                  Text(
                                                                                    "Responsibilities and liabilities".tr,
                                                                                    style: regular02.copyWith(
                                                                                      color: getColorBasedOnActiveModuleid(),
                                                                                    ),
                                                                                  ),

                                                                                  const SizedBox(height: 12),

                                                                                  Text(
                                                                                    "Signing the Terms & Conditions helps establish a clear agreement, ensuring a smooth and fair transaction.".tr,
                                                                                    style: regular02.copyWith(
                                                                                      color: getColorBasedOnActiveModuleid(),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 20),
                                                                              Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: CustomsButtons(
                                                                                      text: "Cancel".tr,
                                                                                      backgroundColor: Colors.grey.shade400,
                                                                                      onPressed: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                  const SizedBox(width: 12),
                                                                                  Expanded(
                                                                                    child: CustomsButtons(
                                                                                      text: "Sign T&C".tr,
                                                                                      backgroundColor: getColorBasedOnActiveModuleid(),
                                                                                      onPressed: () async {
                                                                                        Navigator.pop(context);
                                                                                        Navigator.push(
                                                                                          context,
                                                                                          MaterialPageRoute(
                                                                                            builder: (builder) => DigitalSignature(
                                                                                              bookings: list[index],
                                                                                              fromPropBooking: fromPropBooking,
                                                                                            ),
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 10),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    ),
                                                                  );
                                                                },
                                                              );

                                                              return;
                                                            }

                                                            if (result.data
                                                                    .userSigned ==
                                                                0) {
                                                              showErrorToastMessage(
                                                                "${list[index].userNumber} has not signed yet. Please wait for their signature before proceeding.",
                                                              );
                                                              return;
                                                            }
                                                          } else {
                                                            showErrorToastMessage(
                                                                "Failed to fetch signature data. Please try again.");
                                                          }
                                                        } catch (e, stacktrace) {
                                                          print(
                                                              'Error in onTap: $e');
                                                          print(
                                                              'Stacktrace: $stacktrace');
                                                          showErrorToastMessage(
                                                              "An error occurred. Please try again.");
                                                        }
                                                      }
                                                      if (internalVehicleImage ==
                                                          "Active") {
                                                        // validation for iteriorImage
                                                        if (list[index]
                                                            .iteriorImage
                                                            .isEmpty) {
                                                          showModalBottomSheet<
                                                              String>(
                                                            context: context,
                                                            isScrollControlled:
                                                                true,
                                                            shape:
                                                                const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .vertical(
                                                                top: Radius
                                                                    .circular(
                                                                        20),
                                                              ),
                                                            ),
                                                            builder: (context) {
                                                              return Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .only(
                                                                  left: 20,
                                                                  right: 20,
                                                                  top: 20,
                                                                  bottom: MediaQuery.of(
                                                                          context)
                                                                      .viewInsets
                                                                      .bottom,
                                                                ),
                                                                child:
                                                                    StatefulBuilder(
                                                                  builder: (context,
                                                                      setBottomSheetState) {
                                                                    return SingleChildScrollView(
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            'Interior Image Required'.tr,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 18,
                                                                              fontWeight: FontWeight.bold,
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 12),
                                                                          Column(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "Please upload at least two interior image of the vehicle before entering the pickup OTP.".tr,
                                                                                style: regular02.copyWith(
                                                                                  color: getColorBasedOnActiveModuleid(),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 12),
                                                                              Text(
                                                                                "Note: Adding interior images helps verify the condition of the car before and after pickup. This ensures fair evaluation and avoids disputes regarding the vehicle’s condition.".tr,
                                                                                style: regular02.copyWith(
                                                                                  color: getColorBasedOnActiveModuleid(),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 20),
                                                                          Row(
                                                                            children: [
                                                                              Expanded(
                                                                                child: CustomsButtons(
                                                                                  text: "Cancel",
                                                                                  backgroundColor: Colors.grey.shade400,
                                                                                  onPressed: () {
                                                                                    Navigator.pop(context);
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: 12),
                                                                              Expanded(
                                                                                child: CustomsButtons(
                                                                                  text: "Add Image",
                                                                                  backgroundColor: getColorBasedOnActiveModuleid(),
                                                                                  onPressed: () async {
                                                                                    Navigator.pop(context);
                                                                                    Navigator.push(context, MaterialPageRoute(builder: (builder) => VehiclePhotoesBooking(id: "${list[index].id}")));
                                                                                    // Handle image submission flow
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 10),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              );
                                                            },
                                                          );

                                                          return;
                                                        }
                                                      }

                                                      showModalBottomSheet<
                                                          String>(
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        shape:
                                                            const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          20)),
                                                        ),
                                                        builder: (context) {
                                                          return Padding(
                                                            padding:
                                                                EdgeInsets.only(
                                                              left: 20,
                                                              right: 20,
                                                              top: 20,
                                                              bottom: MediaQuery
                                                                      .of(context)
                                                                  .viewInsets
                                                                  .bottom,
                                                            ),
                                                            child:
                                                                StatefulBuilder(
                                                              builder: (context,
                                                                  setBottomSheetState) {
                                                                return SingleChildScrollView(
                                                                  child: Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: [
                                                                      Text(
                                                                        'Enter OTP'
                                                                            .tr,
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              10),
                                                                      Text(
                                                                        "Enter the pickup OTP given by the vendor"
                                                                            .tr,
                                                                        style: regular02
                                                                            .copyWith(
                                                                          color:
                                                                              getColorBasedOnActiveModuleid(),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              10),
                                                                      Pinput(
                                                                        length:
                                                                            4,
                                                                        controller:
                                                                            bookingController.otpController,
                                                                        keyboardType:
                                                                            TextInputType.number,
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        defaultPinTheme:
                                                                            PinTheme(
                                                                          width:
                                                                              50,
                                                                          height:
                                                                              50,
                                                                          textStyle:
                                                                              const TextStyle(
                                                                            fontSize:
                                                                                22,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            borderRadius:
                                                                                BorderRadius.circular(8),
                                                                            border:
                                                                                Border.all(color: getColorBasedOnActiveModuleid()),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              20),
                                                                      CustomsButtons(
                                                                        text: "Submit"
                                                                            .tr,
                                                                        backgroundColor:
                                                                            getColorBasedOnActiveModuleid(),
                                                                        onPressed:
                                                                            () async {
                                                                          if (bookingController
                                                                              .otpController
                                                                              .text
                                                                              .isEmpty) {
                                                                            showErrorToastMessage("Please fill the OTP".tr);
                                                                            return;
                                                                          }
                                                                          try {
                                                                            final value =
                                                                                await bookingController.updateItemReceivedStatus(
                                                                              bookingId: list[index].id.toString(),
                                                                            );
                                                                            print("OTP Verified: $value");
                                                                            if (value ==
                                                                                "yes") {
                                                                              openOtpAfterImageSubmit = false;
                                                                              list[index].isItemReceivedSetter = "1";
                                                                              generalController.myBookingTabIndex.value = 1;
                                                                              print("alok");
                                                                              print(generalController.myBookingTabIndex.value);
                                                                              Navigator.pushReplacement(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => const HomeMain(initialIndex: 2),
                                                                                ),
                                                                              );
                                                                            } else {
                                                                              setBottomSheetState(() {});
                                                                            }
                                                                          } catch (error) {
                                                                            print("Error in OTP verification: $error");
                                                                            showErrorToastMessage("OTP verification failed.");
                                                                          }
                                                                        },
                                                                      ),
                                                                      const SizedBox(
                                                                          height:
                                                                              10),
                                                                    ],
                                                                  ),
                                                                );
                                                              },
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 10),
                                                      child: Container(
                                                        height: 49,
                                                        alignment:
                                                            Alignment.center,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 10,
                                                                right: 10,
                                                                top: 0,
                                                                bottom: 0),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                              color:
                                                                  getColorBasedOnActiveModuleid()),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(13),
                                                          color:
                                                              getColorBasedOnActiveModuleid(),
                                                        ),
                                                        child: Text(
                                                            "Pickup OTP?".tr,
                                                            style: boldstyle(
                                                                    context)
                                                                .copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 14,
                                                            )),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : list[index].isItemReceived ==
                                                          1 &&
                                                      listType == "ongoing" &&
                                                      list[index]
                                                              .isItemReturned ==
                                                          0 &&
                                                      list[index].status ==
                                                          "Live"
                                                  ? Expanded(
                                                      flex: 1,
                                                      child: InkWell(
                                                        onTap: () async {
                                                          showModalBottomSheet<
                                                              String>(
                                                            isScrollControlled:
                                                                true, // Ensures the bottom sheet resizes with the keyboard
                                                            context: context,
                                                            shape:
                                                                const RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius.vertical(
                                                                      top: Radius
                                                                          .circular(
                                                                              20)),
                                                            ),
                                                            builder: (context) {
                                                              return StatefulBuilder(
                                                                builder: (context,
                                                                    setBottomSheetState) {
                                                                  return Padding(
                                                                    padding:
                                                                        EdgeInsets
                                                                            .only(
                                                                      left: 20,
                                                                      right: 20,
                                                                      top: 20,
                                                                      bottom: MediaQuery.of(
                                                                              context)
                                                                          .viewInsets
                                                                          .bottom, // Pushes up with the keyboard
                                                                    ),
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: [
                                                                          Text(
                                                                            'Enter OTP'.tr,
                                                                            style:
                                                                                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 10),
                                                                          Text(
                                                                            "Enter the Dropoff OTP given by the vendor".tr,
                                                                            style:
                                                                                regular02.copyWith(color: getColorBasedOnActiveModuleid()),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 10),
                                                                          Pinput(
                                                                            length:
                                                                                4,
                                                                            controller:
                                                                                bookingController.dropOtpController,
                                                                            keyboardType:
                                                                                TextInputType.number,
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.center,
                                                                            defaultPinTheme:
                                                                                PinTheme(
                                                                              width: 50,
                                                                              height: 50,
                                                                              textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(8),
                                                                                border: Border.all(color: getColorBasedOnActiveModuleid()),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 20),
                                                                          CustomsButtons(
                                                                            text:
                                                                                "Submit".tr,
                                                                            backgroundColor:
                                                                                getColorBasedOnActiveModuleid(),
                                                                            onPressed:
                                                                                () {
                                                                              if (bookingController.dropOtpController.text.isEmpty) {
                                                                                showErrorToastMessage("Please fill the OTP".tr);
                                                                                return;
                                                                              }
                                                                              bookingController
                                                                                  .updateItemDeliverStatus(
                                                                                bookingId: list[index].id.toString(),
                                                                              )
                                                                                  .then((value) {
                                                                                print("OTP Verified: $value");

                                                                                if (value == "yes") {
                                                                                  generalController.myBookingTabIndex.value = 2;
                                                                                  print("alok");
                                                                                  print(generalController.myBookingTabIndex.value);

                                                                                  bookingController.updateBookingStatusIfExists(
                                                                                    bookingId: list[index].id.toString(),
                                                                                    hostId: list[index].hostId.toString(),
                                                                                    userId: userId.toString(),
                                                                                    newStatus: "Completed", // or "Confirmed", "Pending", etc.
                                                                                  );

                                                                                  // Navigate to HomeMain (Trips tab, index 2)
                                                                                  Navigator.pushReplacement(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => const HomeMain(initialIndex: 2),
                                                                                    ),
                                                                                  );

                                                                                  // Navigator.pop(
                                                                                  //     context);
                                                                                } else {
                                                                                  // Refresh the bottom sheet UI if needed
                                                                                  setBottomSheetState(() {});
                                                                                }
                                                                              }).catchError((error) {
                                                                                print("Error in OTP verification: $error");
                                                                                showErrorToastMessage("OTP verification failed.");
                                                                              });
                                                                            },
                                                                          ),
                                                                          const SizedBox(
                                                                              height: 20),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  );
                                                                },
                                                              );
                                                            },
                                                          );

                                                          setState(() {});
                                                        },
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right: 10),
                                                          child: Container(
                                                              height: 49,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 10,
                                                                      right: 10,
                                                                      top: 0,
                                                                      bottom:
                                                                          0),
                                                              decoration:
                                                                  BoxDecoration(
                                                                // color: btnText == "Cancel" ? RedColor:yelloColor,
                                                                color:
                                                                    getColorBasedOnActiveModuleid(),

                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            13),
                                                              ),
                                                              child: Center(
                                                                  // child: Text("Cancel"),
                                                                  child: Text(
                                                                "DropOff?".tr,
                                                                style: boldstyle(
                                                                        context)
                                                                    .copyWith(
                                                                        color:
                                                                            whiteColor,
                                                                        fontSize:
                                                                            14),
                                                              ))),
                                                        ),
                                                      ),
                                                    )
                                                  : const SizedBox()
                                          : const SizedBox(),
                            ),
                            Obx(
                              () => bookingController.dropoffshowHise.value ==
                                      true
                                  ? const SizedBox()
                                  : listType == "Previous" &&
                                          list[index].isItemReturned == 0 &&
                                          list[index].status == "Confirmed"
                                      ? Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () {
                                              showModalBottomSheet<String>(
                                                isScrollControlled:
                                                    true, // Ensures the bottom sheet resizes with the keyboard
                                                context: context,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              20)),
                                                ),
                                                builder: (context) {
                                                  return StatefulBuilder(
                                                    builder: (context,
                                                        setBottomSheetState) {
                                                      return Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                          left: 20,
                                                          right: 20,
                                                          top: 20,
                                                          bottom: MediaQuery.of(
                                                                  context)
                                                              .viewInsets
                                                              .bottom, // Pushes up with the keyboard
                                                        ),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Column(
                                                            mainAxisSize:
                                                                MainAxisSize
                                                                    .min,
                                                            children: [
                                                              const Text(
                                                                'Enter OTP',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              Text(
                                                                "Enter the Dropoff OTP given by the vendor."
                                                                    .tr,
                                                                style: regular02
                                                                    .copyWith(
                                                                        color:
                                                                            getColorBasedOnActiveModuleid()),
                                                              ),
                                                              const SizedBox(
                                                                  height: 10),
                                                              Pinput(
                                                                length: 4,
                                                                controller:
                                                                    bookingController
                                                                        .dropOtpController,
                                                                keyboardType:
                                                                    TextInputType
                                                                        .number,
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                defaultPinTheme:
                                                                    PinTheme(
                                                                  width: 50,
                                                                  height: 50,
                                                                  textStyle: const TextStyle(
                                                                      fontSize:
                                                                          22,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                    border: Border.all(
                                                                        color:
                                                                            getColorBasedOnActiveModuleid()),
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 20),
                                                              CustomsButtons(
                                                                text: "Submit",
                                                                backgroundColor:
                                                                    getColorBasedOnActiveModuleid(),
                                                                onPressed: () {
                                                                  if (bookingController
                                                                      .dropOtpController
                                                                      .text
                                                                      .isEmpty) {
                                                                    showErrorToastMessage(
                                                                        "Please fill the OTP");
                                                                    return;
                                                                  }
                                                                  bookingController
                                                                      .updateItemDeliverStatus(
                                                                    bookingId: list[
                                                                            index]
                                                                        .id
                                                                        .toString(),
                                                                  )
                                                                      .then(
                                                                          (value) {
                                                                    print(
                                                                        "OTP Verified: $value");

                                                                    if (value ==
                                                                        "yes") {
                                                                      Navigator.pop(
                                                                          context);
                                                                    } else {
                                                                      // Refresh the bottom sheet UI if needed
                                                                      setBottomSheetState(
                                                                          () {});
                                                                    }
                                                                  }).catchError(
                                                                          (error) {
                                                                    print(
                                                                        "Error in OTP verification: $error");
                                                                    showErrorToastMessage(
                                                                        "OTP verification failed.");
                                                                  });
                                                                },
                                                              ),
                                                              const SizedBox(
                                                                  height: 20),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );

                                              setState(() {});
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 10),
                                              child: Container(
                                                height: 49,
                                                alignment: Alignment.center,
                                                padding: const EdgeInsets.only(
                                                    left: 10,
                                                    right: 10,
                                                    top: 0,
                                                    bottom: 0),
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color:
                                                          getColorBasedOnActiveModuleid()),
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                  color:
                                                      getColorBasedOnActiveModuleid(),
                                                ),
                                                child: Text("Drop OTP?".tr,
                                                    style: boldstyle(context)
                                                        .copyWith(
                                                      color: Colors.white,
                                                      fontSize: 14,
                                                    )),
                                              ),
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        listType != 'Cancelled' &&
                                listType != 'UpComing' &&
                                digitalsingnature == "Active"
                            ? Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (builder) => DigitalSignature(
                                          bookings: list[index],
                                          fromPropBooking: fromPropBooking,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: 49,
                                    alignment: Alignment.center,
                                    padding: const EdgeInsets.only(
                                        left: 10, right: 10, top: 0, bottom: 0),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: greensColor),
                                      borderRadius: BorderRadius.circular(13),
                                      color: greensColor,
                                    ),
                                    child: Text(
                                      "Booking Agreement".tr,
                                      style: boldstyle(context).copyWith(
                                        color: whiteColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox(),
                        listType != 'Cancelled' && listType != 'UpComing'
                            ? SizedBox(
                                height: 8,
                              )
                            : SizedBox(),
                        InkWell(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => EReceiptScreen(
                                          bookings: list[index],
                                          fromPropBooking: fromPropBooking,
                                          doorStepPrice: doorStepPrice ?? "",
                                        ))).then((value) {
                              if (value != null) {
                                list[index].statusSetter = value;
                                setState(() {});
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Container(
                                height: 49,
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 0, bottom: 0),
                                decoration: BoxDecoration(
                                  color: themeColor,
                                  borderRadius: BorderRadius.circular(13),
                                ),
                                child: Center(
                                    child: Text(
                                  "Reciept".tr,
                                  style: boldstyle(context).copyWith(
                                      color: whiteColor, fontSize: 14),
                                ))),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

bottomSheetReviewed(rating, text) {
  return SingleChildScrollView(
    child: Column(
      children: [
        Text(
          "Review by you".tr,
          style: heading02.copyWith(color: grey2),
        ),
        const SizedBox(
          height: 30,
        ),
        Image.asset(
          "assets/images/review.png",
          scale: 2.3,
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            height: 1,
            width: Get.size.width,
            color: grey5,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        RatingBar.builder(
          ignoreGestures: true,
          initialRating: double.parse(rating),
          minRating: 1,
          direction: Axis.horizontal,
          itemCount: 5,
          itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(
            Icons.star,
            color: appyellow,
          ),
          onRatingUpdate: (rating) {},
        ),
        const SizedBox(
          height: 10,
        ),

        // Review text
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Text(
            // "${rating}".tr,
            "$text".tr,
            style: heading01.copyWith(color: grey1),
          ),
        ),

        const SizedBox(
          height: 50,
        ),
      ],
    ),
  );
}

Widget myNetworkImage(String? image, [bool? shoeIcononError]) {
  if (image != null && Uri.tryParse(image) != null) {
    // Valid URL, proceed with loading
    return Image.network(
      image,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return shimmerContainer();
        }
      },
      errorBuilder: (context, exception, stackTrace) {
        return shoeIcononError == true ? getErrorIcon() : getErrorImage();
      },
    );
  } else {
    return shoeIcononError == true ? getErrorIcon() : getErrorImage();
  }
}

Widget myNetworkImageWithShimmer(String? image) {
  if (image != null && Uri.tryParse(image) != null) {
    return Image.network(
      image,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return shimmerContainer();
        }
      },
      errorBuilder: (context, exception, stackTrace) {
        return getErrorImage();
      },
    );
  } else {
    return getErrorImage();
  }
}

Widget myNetworkImageFillBox(String? image) {
  if (image != null && Uri.tryParse(image) != null) {
    if (kDebugMode) {
      print(image);
    }
    return Image.network(
      image,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Container(
            height: 200,
            width: 230,
            color: const Color.fromARGB(255, 250, 247, 247),
            child: shimmerContainer(),
          );
        }
      },
      errorBuilder: (context, exception, stackTrace) {
        return getErrorImage();
      },
    );
  } else {
    return getErrorImage();
  }
}

Widget myNetworkImageFitWidth(String? image) {
  if (image != null && Uri.tryParse(image) != null) {
    // Valid URL, proceed with loading
    return Image.network(
      image,
      fit: BoxFit.cover,
      loadingBuilder: (BuildContext context, Widget child,
          ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) {
          return child;
        } else {
          return Container(
            height: 200,
            width: 230,
            color: const Color.fromARGB(255, 250, 247, 247),
            child: shimmerContainer(),
          );
        }
      },
      errorBuilder: (context, exception, stackTrace) {
        return getErrorImage();
      },
    );
  } else {
    return getErrorImage();
  }
}

Widget getErrorImage() {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: Image.asset(
      "assets/images/imageNotFound.png",
      fit: BoxFit.contain,
    ),
  );
}

Widget getErrorIcon() {
  // Return a default error image or handle it based on your app's requirements
  return Icon(
    Icons.account_circle_rounded,
    size: 40,
    color: notifires.getgreycolor,
  );
}

Widget getErrorImageForBoth(String type) {
  if (activeModuleId.value == 1 || activeModuleId.value == 6) {
    return Image.asset(
      "assets/images/nophotoscpace.png",
      fit: BoxFit.contain,
    );
  } else if (activeModuleId.value == 2 || activeModuleId.value == 4) {
    return type == "Car"
        ? Image.asset(
            "assets/images/carNotFound.png",
            fit: BoxFit.fitWidth,
            color: grey2,
          )
        : Image.asset(
            "assets/images/bikeImage.png",
            fit: BoxFit.contain,
            color: grey2,
          );
  } else if (activeModuleId.value == 5) {
    return Image.asset(
      "assets/images/bookable_not_found.png",
      fit: BoxFit.fitWidth,
    );
  } else {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Image.asset(
        "assets/images/imageNotFound.png",
        fit: BoxFit.contain,
      ),
    );
  }
}

notloginwidget() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset(
        "assets/images/forLogin.png",
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        "You Are not Logged in".tr,
        style: heading02.copyWith(color: notifires.getwhiteblackcolor),
      ),
      const SizedBox(
        height: 9,
      ),
      Text(
        "Login to access all functionality".tr,
        style: regular02.copyWith(color: getColorBasedOnActiveModuleid()),
      ),
      const SizedBox(
        height: 48,
      ),
      InkWell(
          onTap: () {
            Get.to(() => const LoginScreen());
          },
          child: Text(
            "Login".tr,
            style: heading03.copyWith(
                color: getColorBasedOnActiveModuleid(),
                decorationColor: getColorBasedOnActiveModuleid(),
                decoration: TextDecoration.underline),
          )),
    ],
  );
}

dialogExit(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: notifires.getboxcolor,
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Icon(
                Icons.error,
                size: 75,
                color: getColorBasedOnActiveModuleid(),
              ),
              Text(
                'Do you want to exit?'.tr,
                textAlign: TextAlign.center,
                style: smallHeadigAirBd.copyWith(
                    color: notifires.getwhiteblackcolor),
              )
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
                          onTap: () {
                            Navigator.pop(context);
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
                                "Cancel".tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    // fontFamily: FontStyles.gilroyMedium,
                                    fontWeight: FontWeight.bold),
                              ))))),
                  Expanded(
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context);
                            if (webPlateForm) {
                              if (token.isEmpty) {
                                Get.toNamed(WebRoutes.loginScreen);
                              }
                            } else {
                              SystemNavigator.pop();
                            }
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
                                "Exit".tr,
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

loginAlert(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              commonlyUserlogoAlert(),
              const SizedBox(
                height: 5,
              ),
              Text(
                'You are not Login yet'.tr,
                textAlign: TextAlign.center,
                style: smallHeadigAirBd.copyWith(
                    fontSize: 15, color: notifires.getwhiteblackcolor),
              )
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
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              margin: const EdgeInsets.only(left: 8, right: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(
                                "Cancel".tr,
                                style: const TextStyle(
                                    color: Colors.black,
                                    // fontFamily: FontStyles.gilroyMedium,
                                    fontWeight: FontWeight.bold),
                              ))))),
                  Expanded(
                      child: InkWell(
                          onTap: () {
                            handlelogin = true;
                            Navigator.pop(context);
                            showPopUpScreen(context, LoginScreen());
                          },
                          child: Container(
                              margin: const EdgeInsets.only(left: 8, right: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(color: themeColor),
                                  color: themeColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(
                                "Login".tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    // fontFamily: FontStyles.gilroyMedium,
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

void bookingScetionClean(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: notifires.getbgcolor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: notifires.getbgcolor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with gradient background
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: getColorBasedOnActiveModuleid(),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.cleaning_services_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 20),

              // Title
              Text(
                'Clear Booking Section'.tr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: notifires.getwhiteblackcolor,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                'Are you sure you want to clear this booking section?'.tr,
                style: TextStyle(
                  fontSize: 14,
                  color: notifires.getGrey3Whitecolor,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              // Buttons Row
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: notifires.getwhiteblackcolor,
                        side: BorderSide(
                          color: notifires.getGrey2Whitecolor,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel".tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: notifires.getwhiteblackcolor,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Clear Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        handleBoackfromPayment = false;
                        generalController.currentIndex.value = 0;
                        Get.offAll(HomeMain(initialIndex: 0));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getColorBasedOnActiveModuleid(),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: Colors.transparent,
                      ),
                      child: Text(
                        "Clear".tr,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

loginExpireAlert(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              commonlyUserlogoAlert(),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Your token is Expired Please Login again'.tr,
                textAlign: TextAlign.center,
                style: smallHeadigAirBd.copyWith(
                    color: notifires.getwhiteblackcolor),
              )
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
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              margin: const EdgeInsets.only(left: 8, right: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(
                                "Cancel".tr,
                                style: const TextStyle(
                                    color: Colors.black,
                                    // fontFamily: FontStyles.gilroyMedium,
                                    fontWeight: FontWeight.bold),
                              ))))),
                  Expanded(
                      child: InkWell(
                          onTap: () {
                            logout();
                          },
                          child: Container(
                              margin: const EdgeInsets.only(left: 8, right: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(color: themeColor),
                                  color: themeColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(
                                "Login".tr,
                                style: const TextStyle(
                                    color: Colors.white,
                                    // fontFamily: FontStyles.gilroyMedium,
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

loginExpireAlertoexitfromappt() {
  int countdown = 3;

  Timer.periodic(const Duration(seconds: 1), (timer) {
    if (countdown > 1) {
      countdown--;
    } else {
      timer.cancel();
      Get.back();
      logout();
    }
  });

  return Get.dialog<void>(
    AlertDialog(
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            commonlyUserlogoAlert(),
            const SizedBox(
              height: 5,
            ),
            Text(
              'Your token is Expired. Please login again.'.tr,
              textAlign: TextAlign.center,
              style: smallHeadigAirBd.copyWith(
                  color: notifires.getwhiteblackcolor),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Redirecting to login in $countdown seconds...'.tr,
              textAlign: TextAlign.center,
              style: smallHeadigAirBd.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.redAccent),
            ),
          ],
        ),
      ),
      actions: const <Widget>[
        Column(
          children: [
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ],
    ),
  );
}

Widget searchContainer() {
  return InkWell(
    onTap: () {
      Get.toNamed(WebRoutes.serachScreen);
    },
    child: Container(
      width: double.infinity,
      height: Get.height * 0.045,
      decoration: BoxDecoration(
          border: Border.all(color: greyColors, width: 1.4),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Stack(
          children: [
            Row(
              children: [
                const SizedBox(width: 10),
                InkWell(
                    onTap: () {},
                    child: Icon(
                      Icons.search_outlined,
                      color: greyColor,
                    )),
                const SizedBox(width: 10),
                Text('Search'.tr, style: appBar.copyWith(color: greyColor))
              ],
            )
          ],
        ),
      ),
    ),
  );
}

featuresBottomSheet(BuildContext context, {final String? title, dynamic list}) {
  showModalBottomSheet(
    enableDrag: true,
    useRootNavigator: true,
    backgroundColor: notifires.getblackwhitecolor,
    isScrollControlled: true,
    useSafeArea: false,
    constraints: const BoxConstraints.expand(width: double.infinity),
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: notifires.getblackwhitecolor,
                      border: Border.all(
                        width: 1.0,
                        color: notifires.getgreywhite,
                      ),
                    ),
                    child: Icon(
                      Icons.close,
                      color: notifires.getwhiteblackcolor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Text(title!.tr,
                style: headingh4.copyWith(color: notifires.getwhiteblackcolor)),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var x in list)
                      Column(
                        children: [
                          featuresbox(
                            txt: '${x.name}'.tr,
                            image: "${x.imageUrl}",
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

rulesbuttomSheet(BuildContext context, {final String? title, dynamic list}) {
  showModalBottomSheet(
    enableDrag: true,
    useRootNavigator: true,
    backgroundColor: notifires.getblackwhitecolor,
    isScrollControlled: true,
    useSafeArea: false,
    constraints: const BoxConstraints.expand(width: double.infinity),
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    Icons.close,
                    color: notifires.getwhiteblackcolor,
                    size: 24,
                  ),
                ),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
            const SizedBox(height: 25),
            Text(title!.tr,
                style: boldstyle(context).copyWith(
                    color: notifires.getGrey2Whitecolor, fontSize: 24)),
            const SizedBox(
              height: 15,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var x in list)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: featuresbox(txt: '$x'.tr, image: "$x"),
                          ),
                          const SizedBox(
                              height:
                                  10), // Adjust the height according to your needs
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget rules(list) {
  return Column(
    children: [
      for (var x in list)
        Column(
          children: [
            featuresbox(txt: '$x'.tr, image: "$x"),
            const SizedBox(height: 10),
          ],
        ),
    ],
  );
}

Row featuresbox({required String txt, required String image}) {
  return Row(
    children: [
      SvgPicture.asset(
        "assets/images/donegreen.svg",
        color: themeColor,
      ),
      const SizedBox(width: 15),
      Expanded(
        child: Text(
          txt.tr,
          style: boldTextstyle.copyWith(
              fontSize: 14, color: notifires.getwhiteblackcolor),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ),
    ],
  );
}

TextEditingController textEditingControllerReview = TextEditingController();
bottomSheetReview(id, count, bool fromPropBooking, Bookings bookings,
    StateSetter setState, context) {
  return Container(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    // height: 600,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Leave a Review".tr,
            style: heading01.copyWith(
                fontSize: 20,
                // fontFamily: FontStyles.gilroyBold,
                color: getColorBasedOnActiveModuleid()),
          ),
          const SizedBox(
            height: 16,
          ),
          Container(
            height: 1,
            width: Get.size.width,
            color: greyColor,
          ),
          const SizedBox(
            height: 16,
          ),
          RatingBar.builder(
            minRating: 1,
            direction: Axis.horizontal,
            itemCount: 5,
            itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: getColorBasedOnActiveModuleid(),
            ),
            onRatingUpdate: (rating) {
              generalScopeController.selectedRatingValue.value = rating;
            },
          ),
          const SizedBox(
            height: 8,
          ),
          Obx(() => Text(
                "${"Rating".tr}: ${generalScopeController.selectedRatingValue.value}",
                style: const TextStyle(
                  // fontFamily: FontStyles.gilroyMedium,
                  fontWeight: FontWeight.bold,
                ),
              )),
          const SizedBox(
            height: 16,
          ),
          Container(
            height: 1,
            width: Get.size.width,
            color: greyColor,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Container(
              decoration: BoxDecoration(
                color: notifires.getBoxColor,
                borderRadius: BorderRadius.circular(15),
                border:
                    Border.all(color: const Color.fromARGB(255, 125, 123, 123)),
              ),
              child: TextFormField(
                controller: textEditingControllerReview,
                minLines: 5,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                cursorColor: notifires.getwhiteblackcolor,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(10),
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: "Add Review here".tr,
                  hintStyle: TextStyle(
                    fontSize: 16,
                    color: notifires.getwhiteblackcolor,
                  ),
                ),
                onChanged: (value) {
                  if (value.length > 150) {
                    textEditingControllerReview.text = value.substring(0, 150);
                    textEditingControllerReview.selection =
                        TextSelection.fromPosition(
                      TextPosition(
                          offset: textEditingControllerReview.text.length),
                    );
                  }
                  count.value = value.length;
                },
                style: TextStyle(
                  fontSize: 16,
                  color: notifires.getwhiteblackcolor,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Obx(() => Text(
                    '$count/150   '.tr,
                    style: const TextStyle(),
                  ))
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              InkWell(
                onTap: () {
                  generalScopeController.selectedRatingValue.value = 0.0;
                  textEditingControllerReview.text = "";
                  Navigator.of(context).pop();
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 30, right: 30, top: 14, bottom: 14),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: themeColor.withOpacity(.3)),
                  child: Text("Maybe Later".tr,
                      style: const TextStyle(
                          // color: ThemeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
              InkWell(
                onTap: () async {
                  if (generalScopeController.selectedRatingValue.value == 0.0) {
                    showErrorToastMessage("Select rating".tr);
                    return;
                  }
                  if (textEditingControllerReview.text.isEmpty) {
                    showErrorToastMessage("Write Message".tr);
                    return;
                  }

                  showLoading();
                  var response = await httpPost(Config.giveReviewByUser, {
                    "rating":
                        "${generalScopeController.selectedRatingValue.value.toInt()}",
                    "message": textEditingControllerReview.text,
                    "booking_id": '$id'
                  });

                  closeLoading();
                  if (response != null) {
                    if (response['status'] == 200) {
                      showToastMessage(response['message']);

                      bookings.reviewStatusSetter = "1";
                      bookings.reviewRatingSetter =
                          "${generalScopeController.selectedRatingValue.value.toInt()}";
                      bookings.reviewSetter = textEditingControllerReview.text;
                      textEditingControllerReview.text = "";
                      generalScopeController.selectedRatingValue.value = 0.0;
                      setState(() {});
                      Navigator.of(context).pop("popped");
                    } else {
                      showErrorToastMessage(response['error']);
                    }
                  }
                },
                child: Container(
                  padding: const EdgeInsets.only(
                      left: 45, right: 45, top: 14, bottom: 14),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: themeColor),
                  child: Text("Submit".tr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          )
        ],
      ),
    ),
  );
}

Divider buildDivider() {
  return Divider(
    height: 0,
    color: notifires.getgreywhite,
    indent: 15,
    endIndent: 15,
  );
}

GestureDetector detailbox(
    {required String title,
    required String link,
    required final VoidCallback onpressed}) {
  return GestureDetector(
    onTap: onpressed,
    child: Card(
      color: notifires.getboxcolor,
      child: Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 20),
        child: Row(
          children: [
            const SizedBox(width: 20),
            SvgPicture.asset(
              "assets/images/call.svg",
              colorFilter: ColorFilter.mode(
                  getColorBasedOnActiveModuleid(), BlendMode.srcIn),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(title.tr,
                style: interRegular.copyWith(
                    color: getColorBasedOnActiveModuleid())),
            const Spacer(),
            InkWell(
              onTap: onpressed,
              child: Icon(
                Icons.arrow_forward_ios,
                color: grey3,
                size: 14,
              ),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        ),
      ),
    ),
  );
}

Container avatarprofile() {
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24), color: blueColor),
    child: Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24), color: whiteColor),
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: CircleAvatar(
            maxRadius: 24,
            backgroundColor: whiteColor,
            backgroundImage: const AssetImage(
              'assets/images/ProfileImage.png',
            ),
          ),
        ),
      ),
    ),
  );
}

carbuildBottomAppBar() {
  return LayoutBuilder(builder: (context, constraints) {
    if (Get.width >= 950) {
      return const SizedBox();
    } else {
      return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          height: 70,
          color: notifires.getblackwhitecolor,
          elevation: 0,
          surfaceTintColor: notifires.getblackwhitecolor,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 5),
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  '\$317.2 / day'.tr,
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: notifires.getwhiteblackcolor),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.toNamed(WebRoutes.checkavailabilityScreen);
                  },
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(themeColor),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(Dimensions
                            .radiusSmall), // Adjust the radius as per your need
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 5),
                      Text(
                        'Continue'.tr,
                        style: smallHeadingAirMd.copyWith(color: whiteColor),
                      ),
                      const SizedBox(width: 3),
                      Icon(Icons.arrow_forward, size: 16, color: whiteColor),
                      const SizedBox(width: 5),
                    ],
                  ),
                )
              ],
            ),
          ));
    }
  });
}

Container arrowbox() {
  return Container(
    width: 15,
    height: 15,
    decoration: BoxDecoration(
        border: Border.all(width: 1.0, color: notifires.getwhiteblackcolor),
        borderRadius: BorderRadius.circular(3.0)),
    child: Icon(Icons.arrow_forward,
        size: 12, color: notifires.getwhiteblackcolor),
  );
}

Container carBoxHost({
  final IconData? icons,
  String? title,
  String? desc,
  String? imageUrl,
  // bool isSelected = false
}) {
  return Container(
    alignment: Alignment.center,
    height: 120,
    decoration: BoxDecoration(
      border: Border.all(width: 2.0, color: notifires.getgreywhite),
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
      // color:
      //     isSelected ? notifires.getWhitepinnetsColor : notifires.getgreywhite,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 5),
        Expanded(
          child: imageUrl!.isNotEmpty
              ? Image.network(
                  imageUrl,
                  width: 30,
                  height: 30,
                )
              : Image.asset(
                  "assets/images/amentiesIcon.png",
                  color: notifires.getwhiteblackcolor,
                ),
        ),
        Expanded(
          child: Text(
            textAlign: TextAlign.center,
            title!.tr,
            style:
                smallHeadigAirBd.copyWith(color: notifires.getwhiteblackcolor),
          ),
        ),
        // ),
      ],
    ),
  );
}

Widget showLogoWhenchangeTheMode() {
  return Scaffold(
    backgroundColor: const Color.fromARGB(255, 250, 247, 247),
    body: Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipOval(
              child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(color: themeColor),
                  child: SvgPicture.asset('assets/images/carvy_vehiclelogo.svg',
                      fit: BoxFit.fill)),
            ),
          ]),
    ),
  );
}

Widget summeryText() {
  return RichText(
      text: TextSpan(children: [
    TextSpan(
        text: "By selecting the button below, I agree to the ".tr,
        style: interRegular.copyWith(
            color: notifires.getGrey1Whitecolor, fontSize: 14)),
    TextSpan(
      text:
          "Hosts's Rules, Ground rules for guest,carvy's Rebooking and Refund Policy "
              .tr,
      style: interRegular.copyWith(
          fontFamily: "IntelSemiBold",
          color: getColorBasedOnActiveModuleid(),
          fontSize: 14
          // fontWeight: FontWeight.bold,
          ),
    ),
    TextSpan(
        text: "and that carvy can ".tr,
        style: interRegular.copyWith(
            color: notifires.getGrey1Whitecolor, fontSize: 14)),
    TextSpan(
        text: "charge my Payment method ".tr,
        style: interRegular.copyWith(
            fontFamily: "IntelSemiBold",
            color: getColorBasedOnActiveModuleid(),
            fontSize: 14)),
    TextSpan(
        text:
            "if I'm responsible for damage. I agree to pay the total amount shown if the Host accepts my booking request."
                .tr,
        style: interRegular.copyWith(
            color: notifires.getGrey1Whitecolor, fontSize: 14))
  ]));
}

Color getColorBasedOnActiveModuleid() {
  return vehicalThemColor;
}

void searchPlaces(
  BuildContext context,
) {
  HomeController homeController = Get.find();
  showPopUpScreen(context, SearchScreen());
}

Widget backButton() {
  return GestureDetector(
      onTap: () {
        Get.back();
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8, right: 20),
        child: PhysicalModel(
          color: Colors.transparent,
          shadowColor: notifires.getGrey4Whitecolor,
          elevation: 1.0,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            alignment: Alignment.center,
            height: 40,
            width: 40,
            decoration: BoxDecoration(
                color: notifires.getboxcolor,
                borderRadius: BorderRadius.circular(8)),
            child:
                Icon(Icons.arrow_back, color: getColorBasedOnActiveModuleid()),
          ),
        ),
      ));
}

Widget backButtonfordetailPage(BuildContext context) {
  return GestureDetector(
      onTap: () {
        if (isHostMode.value == true) {
          generalController.currentIndexHost.value = 0;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const BottomHost(initialIndex: 0)),
          );
        } else {
          generalController.currentIndex.value = 0;
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const HomeMain(initialIndex: 0)),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8, right: 20),
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
            child:
                Icon(Icons.arrow_back, color: getColorBasedOnActiveModuleid()),
          ),
        ),
      ));
}

Widget backButtonfordetailPageForVehicle(BuildContext context, bool check) {
  return InkWell(
      onTap: () {
        handleSearchFordetail = false;
        if (check == true) {
          Navigator.pop(context);
          return;
        } else {
          if (webPlateForm) {
            if (isHostMode.value == true) {
              generalController.currentIndexHost.value = 0;
              Get.toNamed(
                WebRoutes.buttomHost,
              );
            } else {
              generalController.currentIndex.value = 0;
              Get.toNamed(
                WebRoutes.homeMain,
              );
            }
          } else {
            if (isHostMode.value == true) {
              generalController.currentIndexHost.value = 0;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BottomHost(initialIndex: 0)),
              );
            } else {
              generalController.currentIndex.value = 0;
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const HomeMain(initialIndex: 0)),
              );
            }
          }
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8, right: 20),
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
            child:
                Icon(Icons.arrow_back, color: getColorBasedOnActiveModuleid()),
          ),
        ),
      ));
}

showTokenExpirePlease() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Image.asset("assets/images/forLogin.png"),
      const SizedBox(
        height: 20,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 35, right: 35),
        child: Text(
          textAlign: TextAlign.center,
          "Please log in again to access all functionality.".tr,
          style: heading02.copyWith(color: notifires.getwhiteblackcolor),
        ),
      ),
      const SizedBox(
        height: 9,
      ),
      Padding(
        padding: const EdgeInsets.only(left: 35, right: 35, top: 8, bottom: 8),
        child: Text(
          textAlign: TextAlign.center,
          "You are logged in with another device, so the token has expired.".tr,
          style: regular02.copyWith(color: getColorBasedOnActiveModuleid()),
        ),
      ),
      const SizedBox(
        height: 9,
      ),
      const SizedBox(
        height: 25,
      ),
      InkWell(
          onTap: () {
            logout();
          },
          child: Text(
            "Login".tr,
            style: heading03.copyWith(
                color: getColorBasedOnActiveModuleid(),
                decorationColor: getColorBasedOnActiveModuleid(),
                decoration: TextDecoration.underline),
          )),
    ],
  );
}

Widget profilePhotoOnHomeScreen(BuildContext context) {
  return Row(
    children: [
      InkWell(
        onTap: () {
          if (token.isEmpty) {
            loginAlert(context);
            return;
          }
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const MyProfile()));
        },
        child: Obx(
          () => Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: whiteColor,
                    width: 2.0,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: profileController.myImage.value.toString() == ""
                      ? SizedBox(
                          height: 40,
                          width: 40,
                          child: CircleAvatar(
                            radius: 20,
                            child: Icon(
                              Icons.person,
                              size: 30,
                              color: blackColor,
                            ),
                          ),
                        )
                      : CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: profileController.myImage.value,
                          errorWidget: (context, exception, stackTrace) {
                            return const Icon(
                              Icons.account_circle_rounded,
                              size: 30,
                            );
                          },
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget switchToModules(BuildContext context) {
  return Row(
    children: [
      Text(
        "Car".tr,
        style: heading3(context).copyWith(color: whiteColor),
      ),
      const SizedBox(
        width: 5,
      ),
      Transform.scale(
          scale: .8,
          child: Obx(() => Switch(
              value: isHostMode.value,
              activeColor: getColorBasedOnActiveModuleid(),
              inactiveTrackColor: whiteColor,
              activeTrackColor: whiteColor,
              inactiveThumbColor: getColorBasedOnActiveModuleid(),
              trackOutlineColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return getColorBasedOnActiveModuleid(); 
                }
                return getColorBasedOnActiveModuleid(); 
              }),
              onChanged: (value) {
                isHostMode.value = value;
              }))),
      const SizedBox(
        width: 5,
      ),
      Text(
        "Bike".tr,
        style: heading3(context).copyWith(color: whiteColor),
      ),
    ],
  );
}

void showOpenAppSettingsDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Platform.isIOS
          ? CupertinoAlertDialog(
              title: const Text("Permission Required"),
              content: Text(
                message,
              ),
              actions: <Widget>[
                CupertinoDialogAction(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                CupertinoDialogAction(
                  child: const Text(
                    "Open Settings",
                  ),
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            )
          : AlertDialog(
              backgroundColor: notifires.getbgcolor,
              title: Text(
                "Permission Required",
                style: heading3Grey1(context).copyWith(
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              content: Text(
                message,
                style: regular2(context).copyWith(),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    "Cancel",
                    style: heading3Grey1(context).copyWith(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(
                    "Open Settings",
                    style: heading3Grey1(context).copyWith(
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  onPressed: () {
                    openAppSettings();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
    },
  );
}

Widget customOnboardingWidget(String image, String title, String description) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Image.asset(image),
      ),
      const SizedBox(
        height: 20,
      ),
      Text(
        title,
        style: heading01.copyWith(color: notifires.getGrey1Whitecolor),
        textAlign: TextAlign.center,
      ),
      const SizedBox(
        height: 15,
      ),
      Text(
        description,
        style: regular02.copyWith(color: notifires.getGrey2Whitecolor),
        textAlign: TextAlign.center,
      )
    ],
  );
}

profileUpdate(context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              commonlyUserlogoAlert(),
              const SizedBox(
                height: 5,
              ),
              Text(
                'Please Update the Profile Info'.tr,
                textAlign: TextAlign.center,
                style: smallHeadigAirBd.copyWith(
                    color: notifires.getwhiteblackcolor),
              )
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
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              margin: const EdgeInsets.only(left: 8, right: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(
                                "Cancel".tr,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ))))),
                  Expanded(
                      child: InkWell(
                          onTap: () {
                            Navigator.pop(context); // Close the dialog first
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              showPopUpScreen(context, MyProfile());
                            });
                          },
                          child: Container(
                              margin: const EdgeInsets.only(left: 8, right: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(color: themeColor),
                                  color: themeColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(
                                "Profile".tr,
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

hostblocked(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              commonlyUserlogoAlert(),
              const SizedBox(
                height: 5,
              ),
              Text(
                'You have been blocked from becoming a lend by the admin. Please request again.'
                    .tr,
                textAlign: TextAlign.center,
                style: smallHeadigAirBd.copyWith(
                    color: notifires.getwhiteblackcolor),
              )
            ],
          ),
        ),
      );
    },
  );
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: const Center(
        child: Text(
          'Oops! The page you are looking for does not exist.',
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    );
  }
}

backbuttonforWeb(context) async {
  if (webPlateForm) {
    Navigator.of(context).pop(false);
  }
}

addAddressAlert(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              commonlyUserlogoAlert(),
              const SizedBox(
                height: 5,
              ),
              Text(
                'To avail Doorstep service, please add your address.'.tr,
                textAlign: TextAlign.center,
                style: regular3(context).copyWith(color: blackColor),
              )
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
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                              margin: const EdgeInsets.only(left: 8, right: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(
                                "Cancel".tr,
                                style: const TextStyle(
                                    color: Colors.black,
                                    // fontFamily: FontStyles.gilroyMedium,
                                    fontWeight: FontWeight.bold),
                              ))))),
                  Expanded(
                      child: InkWell(
                          onTap: () {
                            addAddressController.preventDate.value = false;
                            Get.offAll(() => PickAddressWitjhMap());
                          },
                          child: Container(
                              margin: const EdgeInsets.only(left: 8, right: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  border: Border.all(color: themeColor),
                                  color: themeColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(
                                "Add Address".tr,
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

String truncatetext(dynamic data, int maxLength) {
  final String text = " ${data?.toString() ?? 'N/A'}";
  if (text.length > maxLength) {
    return "${text.substring(0, maxLength - 3)}...";
  }
  return text;
}
