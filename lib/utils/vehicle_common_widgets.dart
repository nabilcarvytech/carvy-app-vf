import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/controller/home_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/item_type_model.dart';
import 'package:carvy/model/make_type_model.dart';
import 'package:carvy/model/items_model.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/itemdetail/vehicle/view_on_map_screen.dart';
import 'package:carvy/view/search/after_search.dart';
import '../controller/search_controller.dart';
import '../customwidget/form_elements.dart';
import '../customwidget/project_color.dart';

import '../view/itemdetail/vehicle/vehicle_detail_screen.dart';
import '../view/wishlist/wish_list_screen.dart';
import '../helper/cancellation_policy_helper.dart';
import '../helper/vehicle_card_helper.dart';
import '../work_space.dart';
import 'common_widget.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/search_wizard.dart';

Widget vehicleTypeWidget(
  List<ItemTypes> list,
  notifire,
  StateSetter setState,
) {
  HomeController homeController = Get.find();
  SearchControllerHome filterController = Get.find();

  return SizedBox(
    width: double.infinity,
    height: 80.0,
    child: Padding(
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeSmall),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: list.length,
        itemBuilder: (context, index) {
          final dynamic id = list[index].id!;
          final dynamic city = list[index].name!;
          return Padding(
            padding:
                const EdgeInsets.only(right: 10, top: 5, bottom: 5, left: 2),
            child: InkWell(
              onTap: () async {
                filterController.globalItemType.value = id;
                filterController.globalItemTypNamee.value = city;
                GetStorage().write("selectedVehicleType", id);
                GetStorage().write("selectedVehicleTypeName", city);
                homeController.homeDataModel = null;
                GetStorage().remove("homeData");
                homeController.onVehicleHomeScreenRefresh();
              },
              child: Obx(() {
                return Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: filterController.globalItemType.value == id
                            ? getColorBasedOnActiveModuleid()
                            : grey6),
                    color: grey6,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 5,
                        ),
                        // Pour la catégorie "All", utiliser l'icône locale
                        (list[index].name?.toLowerCase() == 'all')
                            ? Image.asset("assets/images/suv.png", height: 40)
                            : SizedBox(
                                height: 40,
                                child: myNetworkImageFillBox(list[index].image),
                              ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          list[index].name!.length > 10
                              ? list[index].name!.substring(0, 9)
                              : list[index].name.toString().tr,
                          style: boldstyle(context)
                              .copyWith(fontSize: 16, color: themeColor),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        },
      ),
    ),
  );
}

vehicalCategory(List<Makes> list, notifire) {
  SearchControllerHome filterController = Get.find();

  return SizedBox(
    width: double.infinity,
    height: 85,
    child: Padding(
      padding: const EdgeInsets.only(left: 0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        // itemCount: (list?.length ?? 0) > 5 ? 5 : (list?.length ?? 0),
        itemCount: list.length,
        itemBuilder: (context, index) {
          // ========== LOGS DE DÉBOGAGE POUR DIAGNOSTIQUER LES URLs ==========
          final rawUrl = list.elementAt(index).imageUrl;
          final transformedUrl = rawUrl != null ? Config.getFullImageUrl(rawUrl) : 'null';
          print('📸 [DEBUG IMAGE MARQUE] Index $index - Nom: ${list.elementAt(index).makeName ?? "N/A"}');
          print('📸 [DEBUG IMAGE MARQUE] URL Brute: $rawUrl');
          print('📸 [DEBUG IMAGE MARQUE] URL Transformée: $transformedUrl');
          print('📸 [DEBUG IMAGE MARQUE] URL est null?: ${rawUrl == null}');
          print('📸 [DEBUG IMAGE MARQUE] URL est vide?: ${rawUrl?.isEmpty ?? true}');
          // ===================================================================
          
          return Padding(
            padding:
                const EdgeInsets.only(right: 14, top: 5, bottom: 5, left: 8),
            child: InkWell(
              onTap: () {
                filterController.setDefaultDates(
                  startDateCustomDate:
                      generalScopeController.startDateCustomDate,
                  endDateCustomDate: generalScopeController.endDateCustomDate,
                  startDate: filterController.startDate,
                  endDates: filterController.endDates,
                );
                filterController.maketypesValus.clear();
                filterController.maketypesValus.add(list[index].id);

                Future.microtask(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AfterSearch(
                        mode: "make",
                      ),
                    ),
                  );
                });
              },
              child: Container(
                margin: const EdgeInsets.all(0),
                decoration: BoxDecoration(
                  color: notifires.getboxcolor,
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: notifires.getGrey3Whitecolor.withOpacity(0.1),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: const Offset(0, 0), // changes position of shadow
                    ),
                  ],
                ),
                height: 75,
                width: 75,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: list.elementAt(index).imageUrl != null &&
                            list.elementAt(index).imageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              Config.getFullImageUrl(
                                  list.elementAt(index).imageUrl!),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.directions_car_rounded,
                                color: notifires.getgreycolor,
                                size: 30,
                              ),
                            ),
                          )
                        : Icon(
                            Icons.directions_car_rounded,
                            color: notifires.getgreycolor,
                            size: 30,
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Padding avatarprofilevehicle(image) {
  return Padding(
    padding: const EdgeInsets.all(0),
    child: CircleAvatar(
      maxRadius: 32,
      backgroundColor: whiteColor,
      backgroundImage: NetworkImage(
        '$image',
      ),
    ),
  );
}

Widget vehicalVerticalView(list, shrink, fromWishList, StateSetter setState) {
  if (list == null || list.isEmpty) {
    return Container();
  }
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
    itemCount: list.length,
    itemBuilder: (context, index) {
      String? serviceType = '';
      ItemInfo? itemInfoData;
      if (list != null && list.length > index && list[index] != null) {
        final item = list[index]!;
        String? jsonSliders = item.itemInfo;
        if (jsonSliders != null) {
          itemInfoData = ItemInfo.fromJson(json.decode(jsonSliders));
          Map<String, dynamic> itemInfo = jsonDecode(jsonSliders);
          serviceType = itemInfo["service_type"];
        }

        // Construire un texte de localisation propre (ville / adresse)
        final locationParts = <String>[];
        if ((item.address ?? '').trim().isNotEmpty) {
          locationParts.add((item.address ?? '').trim());
        }
        if ((item.city ?? '').trim().isNotEmpty) {
          locationParts.add((item.city ?? '').trim());
        }
        final String locationText = locationParts.isNotEmpty
            ? locationParts.join(" • ")
            : "Unknown Location".tr;
        final double parsedRating =
            VehicleCardHelper.resolveItemRating(list[index]);
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
                            rating: parsedRating > 0
                                ? parsedRating.toStringAsFixed(1)
                                : list[index].itemRating,
                            title: list[index].name,
                            address: list[index].address,
                            city: list[index].city,
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
                color: notifires.getboxcolor,
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
                                            parsedRating.toStringAsFixed(1),
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
                                VehicleCardHelper.buildSpecsAndPriceRow(
                                  itemInfo: itemInfoData,
                                  price: list.elementAt(index).price,
                                  showPerDay: serviceType == "booking",
                                  chipStyle: regular3(context).copyWith(
                                    fontSize: 12,
                                    color: whiteColor,
                                  ),
                                  priceStyle: boldstyle(context).copyWith(
                                    color: getColorBasedOnActiveModuleid(),
                                    fontSize: 14,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  perDayStyle: regular(context).copyWith(
                                    color: notifires.getGrey4Whitecolor,
                                    overflow: TextOverflow.ellipsis,
                                  ),
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
                                        child: list[index].isInWishlist == true
                                            ? SvgPicture.asset(
                                                'assets/images/redHeart.svg', // Update the asset path to the SVG file
                                                height: 20,
                                              )
                                            : SvgPicture.asset(
                                                'assets/images/whitHeart.svg', // Update the asset path to the SVG file
                                                height: 20,
                                              ),
                                        onTap: () async {
                                          wishListLoadingHorizontal = index;
                                          setState(() {});

                                          try {
                                            bool success = false;
                                            if (list[index].isInWishlist ==
                                                true) {
                                              success = await wishListController
                                                  .removeToWishlist(
                                                      list[index].id);
                                              if (success) {
                                                list[index].isInWishlist =
                                                    false;
                                              }
                                            } else {
                                              success = await wishListController
                                                  .addTowishlist(
                                                      list[index].id);
                                              if (success) {
                                                list[index].isInWishlist = true;
                                              }
                                            }
                                          } catch (e) {
                                            print(
                                                "❌ [Wishlist] Error toggling wishlist: $e");
                                          } finally {
                                            // CRITICAL: Always reset loading state, no matter what
                                            wishListLoadingHorizontal = -1;
                                            try {
                                              setState(() {});
                                            } catch (e) {
                                              // Widget might be disposed, but we still reset the loading state
                                              print(
                                                  "⚠️ [Wishlist] setState failed (widget disposed): $e");
                                            }
                                          }
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
                          locationText,
                          overflow: TextOverflow.ellipsis,
                          style: regular3(context).copyWith(
                            fontSize: 12,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      Spacer(),
                      if (itemInfoData?.hostFirstName != null)
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
                              "${"By".tr} - ${itemInfoData?.hostFirstName ?? ""}",
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
        // return Padding(
        //   padding: const EdgeInsets.all(5),
        //   child: InkWell(
        //     onTap: () {
        //       if (webPlateForm) {
        //         Get.toNamed(
        //           WebRoutes.getItemDetails,
        //           arguments: {
        //             'id': list!.elementAt(index).id,
        //           },
        //         );
        //       } else {
        //         Navigator.push(
        //             context,
        //             MaterialPageRoute(
        //                 builder: (context) => VehicleDetailSScreen(
        //                       id: list!.elementAt(index).id,
        //                       itemInfo: itemInfoData,
        //                       rating: list![index].itemRating,
        //                       title: list![index].name,
        //                       address: list![index].address,
        //                       latitute: list![index].latitude,
        //                       longtitute: list![index].longitude,
        //                       frontImage: list![index].image,
        //                       itemType: list![index].itemType,
        //                       isWishList: list![index].isInWishlist,
        //                       price: list![index].price,
        //                     )));
        //       }
        //     },
        //     child: Container(
        //       width: double.maxFinite,
        //       height: 136,
        //               decoration: BoxDecoration(
        //           color: notifires.getboxcolor,
        //           borderRadius: BorderRadius.circular(12),
        //           boxShadow: [
        //             BoxShadow(
        //               color: Colors.black.withOpacity(0.1),
        //               blurRadius: 4,
        //               offset: Offset(0, 4),
        //             ),
        //           ],
        //         ),
        //       child: Column(
        //         crossAxisAlignment: CrossAxisAlignment.start,
        //         children: [
        //           Stack(
        //             children: [
        //               Container(
        //                 width: double.maxFinite,
        //                 height: 136,
        //                 decoration: BoxDecoration(
        //                     color: grey5,
        //                     borderRadius: BorderRadius.circular(12)),
        //                 child: ClipRRect(
        //                   borderRadius: BorderRadius.circular(12),
        //                   child: myNetworkImageWithShimmer(
        //                       list.elementAt(index)!.image),
        //                 ),
        //               ),
        //               serviceType == "booking"
        //                   ? const SizedBox()
        //                   : Positioned(
        //                       left: 0,
        //                       top: 0,
        //                       child: serviceType == ""
        //                           ? const SizedBox()
        //                           : Container(
        //                               alignment: Alignment.center,
        //                               padding: const EdgeInsets.only(
        //                                   left: 5, right: 5, top: 4, bottom: 4),
        //                               decoration: const BoxDecoration(
        //                                 borderRadius: BorderRadius.only(
        //                                   bottomRight: Radius.circular(12),
        //                                   topLeft: Radius.circular(12),
        //                                 ),
        //                                 color: Colors.orange,
        //                               ),
        //                               child: Text(
        //                                 serviceType ?? "",
        //                                 style: regular2(context)
        //                                     .copyWith(color: Colors.white),
        //                               ),
        //                             )),
        //               Positioned(
        //                 top: 15,
        //                 right: 15,
        //                 child: Row(
        //                   mainAxisAlignment: MainAxisAlignment.center,
        //                   children: [
        //                     wishListLoading == index
        //                         ? const SizedBox(
        //                             height: 25,
        //                             width: 25,
        //                             child: CircularProgressIndicator())
        //                         : InkWell(
        //                             child: list[index].isInWishlist == false
        //                                 ? SvgPicture.asset(
        //                                     'assets/images/whitHeart.svg', // Update the asset path to the SVG file
        //                                     height: 20,
        //                                   )
        //                                 : SvgPicture.asset(
        //                                     'assets/images/redHeart.svg', // Update the asset path to the SVG file
        //                                     height: 20,
        //                                   ),
        //                             onTap: () async {
        //                               wishListLoading = index;
        //                               setState(() {});
        //                               if (list[index].isInWishlist == false) {
        //                                 var value = await wishListController
        //                                     .addTowishlist(list[index].id);

        //                                 if (value == true) {
        //                                   var vvv = list![index];
        //                                   vvv.wishlistSetter = true;
        //                                   list[index] = vvv;
        //                                 }
        //                               } else {
        //                                 var value = await wishListController
        //                                     .removeToWishlist(list[index].id);

        //                                 if (value == true) {
        //                                   if (fromWishList == true) {
        //                                     list.removeAt(index);
        //                                   } else {
        //                                     var vvv = list![index];
        //                                     vvv.wishlistSetter = false;
        //                                     list[index] = vvv;
        //                                   }
        //                                 }
        //                               }
        //                               wishListLoading = -1;
        //                               setState(() {});
        //                             },
        //                           ),
        //                   ],
        //                 ),
        //               ),
        //               showhidedistance == "Inactive"
        //                   ? SizedBox()
        //                   : list[index]!.distance == null
        //                       ? const SizedBox()
        //                       : Positioned(
        //                           bottom: 0,
        //                           right: 0,
        //                           child: Container(
        //                             padding: const EdgeInsets.symmetric(
        //                                 horizontal: 6, vertical: 4),
        //                             decoration: BoxDecoration(
        //                                 color: getColorBasedOnActiveModuleid(),
        //                                 borderRadius: const BorderRadius.only(
        //                                   bottomRight: Radius.circular(12),
        //                                   topLeft: Radius.circular(12),
        //                                 )),
        //                             child: Text(
        //                               "${list[index]!.distance!}",
        //                               style: boldstyle(context).copyWith(
        //                                 color: Colors.white,
        //                                 fontSize: 11,
        //                               ),
        //                               textAlign: TextAlign.end,
        //                               overflow: TextOverflow.ellipsis,
        //                               softWrap: false,
        //                             ),
        //                           ),
        //                         ),
        //             ],
        //           ),
        //           const SizedBox(
        //             height: 5,
        //           ),
        //           Padding(
        //             padding: const EdgeInsets.symmetric(horizontal: 5),
        //             child: Row(
        //               children: [
        //                 Expanded(
        //                   flex: 9,
        //                   child: Text(
        //                     list.elementAt(index)!.name!.length > 21
        //                         ? list.elementAt(index)!.name!.substring(0, 20)
        //                         : list.elementAt(index)!.name! ?? "",
        //                     style: heading3Grey1(context).copyWith(
        //                       overflow: TextOverflow.ellipsis,
        //                     ),
        //                   ),
        //                 ),
        //                 const Spacer(),
        //                 Row(
        //                   children: [
        //                     Text(
        //                         '${list.elementAt(index)!.itemRating ?? "0"}'
        //                             .tr,
        //                         style: boldstyle(context).copyWith(
        //                           fontSize: 12,
        //                         )),
        //                     const SizedBox(width: 5),
        //                     Icon(
        //                       Icons.star,
        //                       color: orangeColor,
        //                       size: 14,
        //                     ),
        //                     // SizedBox(
        //                     //   width: 5,
        //                     // ),
        //                   ],
        //                 ),
        //               ],
        //             ),
        //           ),
        //           const SizedBox(
        //             height: 3,
        //           ),
        //           Padding(
        //             padding:
        //                 const EdgeInsets.only(left: 4, right: 5, bottom: 3),
        //             child: Row(
        //               children: [
        //                 Icon(
        //                   Icons.location_on_outlined,
        //                   size: 14,
        //                   color: getColorBasedOnActiveModuleid(),
        //                 ),
        //                 Expanded(
        //                   child: Text(
        //                     "${list.elementAt(index)!.address ?? ""},",
        //                     overflow: TextOverflow.ellipsis,
        //                     style: regular3(context).copyWith(
        //                       fontSize: 12,
        //                     ),
        //                     maxLines: 1,
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //           Row(
        //             children: [
        //               const SizedBox(width: 5),

        //               // Wrap in Flexible so text won't overflow
        //               Flexible(
        //                 child: Row(
        //                   children: [
        //                     if (itemInfoData!.transmission != null &&
        //                         itemInfoData.transmission!.isNotEmpty)
        //                       Text(
        //                         itemInfoData.transmission!,
        //                         style: regular3(context).copyWith(fontSize: 12),
        //                         overflow: TextOverflow.ellipsis,
        //                       ),
        //                     if (itemInfoData.transmission != null &&
        //                         itemInfoData.transmission!.isNotEmpty)
        //                       Padding(
        //                         padding:
        //                             const EdgeInsets.symmetric(horizontal: 4),
        //                         child:
        //                             Text("•", style: TextStyle(fontSize: 12)),
        //                       ),
        //                     if (itemInfoData.makeType != null &&
        //                         itemInfoData.makeType!.isNotEmpty)
        //                       Text(
        //                         itemInfoData.makeType!,
        //                         style: regular3(context).copyWith(fontSize: 12),
        //                         overflow: TextOverflow.ellipsis,
        //                       ),
        //                     if (itemInfoData.makeType != null &&
        //                         itemInfoData.makeType!.isNotEmpty)
        //                       Padding(
        //                         padding:
        //                             const EdgeInsets.symmetric(horizontal: 4),
        //                         child:
        //                             Text("•", style: TextStyle(fontSize: 12)),
        //                       ),
        //                     if (itemInfoData.seatCapicity != null)
        //                       Flexible(
        //                         child: Text(
        //                           "${itemInfoData.seatCapicity} Seats",
        //                           style:
        //                               regular3(context).copyWith(fontSize: 12),
        //                           overflow: TextOverflow.ellipsis,
        //                         ),
        //                       ),
        //                   ],
        //                 ),
        //               ),
        //             ],
        //           ),
        //           SizedBox(
        //             height: 5,
        //           ),
        //           Row(
        //             children: [
        //               const SizedBox(
        //                 width: 5,
        //               ),
        //               Text(
        //                 "$currency ${list.elementAt(index)!.price!.length > 8 ? list.elementAt(index)!.price!.substring(0, 7) : list.elementAt(index)!.price ?? ""}",
        //                 maxLines: 1,
        //                 style: boldstyle(context).copyWith(
        //                     color: getColorBasedOnActiveModuleid(),
        //                     fontSize: 14,
        //                     overflow: TextOverflow.ellipsis),
        //               ),
        //               serviceType == "booking"
        //                   ? Text(
        //                       ' /day'.tr,
        //                       maxLines: 1,
        //                       style: regular(context).copyWith(
        //                           color: notifires.getGrey4Whitecolor,
        //                           overflow: TextOverflow.ellipsis),
        //                     )
        //                   : const SizedBox(),
        //             ],
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        // );
      } else {
        return Container();
      }
    },
  );
}

Container carbox({
  final IconData? icons,
  required String title,
  required String desc,
  TextDirection? descTextDirection,
}) {
  return Container(
    width: 170,
    height: 75,
    decoration: BoxDecoration(
      color: notifires.getboxcolor,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: notifires.getGrey3Whitecolor.withOpacity(0.1),
          spreadRadius: 3,
          blurRadius: 5,
          offset: const Offset(0, 0),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 8,
        ),
        Icon(
          icons, // Pass the IconData here, not the Icon widget
          size: 30,
          color: getColorBasedOnActiveModuleid(),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 18,
              ),
              Text(
                title,
                style: regular02.copyWith(color: notifires.getGrey2Whitecolor),
              ),
              Expanded(
                child: Text(
                  desc,
                  style:
                      regular02.copyWith(color: notifires.getGrey3Whitecolor),
                  textDirection: descTextDirection,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Divider buildDividervehicle() {
  return Divider(
    height: 0,
    color: notifires.getgreywhite,
  );
}

Widget CautionCard({
  required String depositValue,
  required String depositManager,
  required BuildContext context,
}) {
  // Format deposit value with "DH" or "MAD"
  String depositText = depositValue.isNotEmpty ? '$depositValue MAD' : '0 MAD';

  // Format manager text
  String managerText = '';
  if (depositManager == 'CARVY') {
    managerText = 'Gérée par Carvy'.tr;
  } else if (depositManager == 'AGENCY') {
    managerText = "Gérée par l'agence".tr;
  } else if (depositManager.isNotEmpty) {
    managerText = depositManager;
  }

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 16.0),
    child: Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Row: Icon + Caution + Value + Info Icon + Important (all on one line)
            Row(
              children: [
                Icon(
                  Icons.security_outlined,
                  color: getColorBasedOnActiveModuleid(),
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Caution'.tr,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  depositText,
                  style: TextStyle(
                    color: getColorBasedOnActiveModuleid(),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.info_outline,
                  color: Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'Important'.tr,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            // Second Row: Manager text aligned with "Caution"
            if (managerText.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 36), // Compensate for shield icon (24) + spacing (12)
                child: Text(
                  managerText,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

seeMore(BuildContext context, String test, String description) {
  showModalBottomSheet(
    enableDrag: true,
    // showDragHandle: true,
    // isDismissible: true,
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
        child: ListView(
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
                  ),
                ),
                const SizedBox(
                  width: 20,
                )
              ],
            ),
            const SizedBox(height: 25),
            Text(test.tr,
                style: boldstyle(context).copyWith(
                    color: notifires.getGrey2Whitecolor, fontSize: 24)),
            const SizedBox(
              height: 10,
            ),
            Text(
              description.tr,
              style: regular2(context).copyWith(fontSize: 14),
            )
          ],
        ),
      );
    },
  );
}

Row starReview(String rating) {
  return Row(
    children: [
      Icon(
        Icons.star,
        color: orangeColor,
        size: 18,
      ),
      const SizedBox(
        width: 3,
      ),
      Text(
        rating.tr,
        style: appNormelText.copyWith(color: notifires.getwhiteblackcolor),
      ),
      const SizedBox(
        width: 5,
      )
    ],
  );
}

void cancellationPolicyBottomSheet(BuildContext context, title, description) {
  showModalBottomSheet(
    useRootNavigator: true,
    backgroundColor: notifires.getblackwhitecolor,
    isScrollControlled: true,
    // useSafeArea: false,
    context: context,
    builder: (BuildContext context) {
      final rulesList = CancellationPolicyHelper.resolveDisplayRules(
        description,
        isCancellationPolicy: true,
      );
      
      return SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: Padding(
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
                      color: notifires.getGrey1Whitecolor,
                      size: 25,
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  )
                ],
              ),
              const SizedBox(height: 25),
              Text(
                'cancellation_policy_title'.tr,
                style: boldstyle(context).copyWith(
                  color: notifires.getGrey2Whitecolor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 20),
              // Liste des règles avec icônes
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: rulesList.isEmpty
                        ? [
                            // Si aucune règle n'est disponible
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Aucune politique spécifique définie.".tr,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ]
                        : rulesList
                            .map((rule) =>
                                CancellationPolicyHelper.buildRuleListTile(rule))
                            .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget eReceiptWidget({String? name, String? value}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        name.toString().tr,
        style: heading03.copyWith(color: notifires.getGrey1Whitecolor),
      ),
      Text(
        value.toString().tr,
        style: regular02.copyWith(color: notifires.getGrey2Whitecolor),
      ),
    ],
  );
}

Widget customDatePickerForFilter(BuildContext context) {
  SearchControllerHome controllerHome = Get.find();
  return GestureDetector(
    onTap: () {
      openSearchWizard(context);
    },
    child: Container(
        height: 50,
        decoration: BoxDecoration(
            color: notifires.getboxcolor,
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            const SizedBox(width: 15),
            Icon(
              Icons.calendar_today_outlined,
              color: notifires.getGrey2Whitecolor,
              size: 20,
            ),
            const SizedBox(width: 15),
            const SizedBox(
              height: 6,
            ),
            Obx(() => Flexible(
                  child: Text(
                    controllerHome.startDate.value != "" &&
                            controllerHome.endDates.value != ""
                        ? "${controllerHome.startDate.value} ${controllerHome.startTimeSearch.value} - ${controllerHome.endDates.value} ${controllerHome.endTimeSearch.value}"
                        : "Select Dates".tr,
                    style: regular3(context).copyWith(
                        color: notifires.getGrey1Whitecolor, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )),
          ],
        )),
  );
}

void customDatePicker(BuildContext context, [bool? clesrdata]) {
  final SearchControllerHome searchController = Get.find();

  List<String> getSlotsStartTime() {
    switch (searchController.curreentStatus.value) {
      case "CurrebtDate":
        if (searchController.handleTimeSlotsOnCurrentDate.value == true) {
          return searchController.currenttimeSlots;
        } else {
          return searchController.filteredTimeSlotsEndTime;
        }
      case "StartCurrentEndOther":
        return searchController.currenttimeSlots;
      case "SameDate":
        return searchController.filteredTimeSlotsEndTime;
      case "otherDates":
        return searchController.filteredTimeSlotsEndTime;
      default:
        return searchController.searchPickerBaselineSlots();
    }
  }

  List<String> getSlotsEndTime() {
    switch (searchController.curreentStatus.value) {
      case "CurrebtDate":
        if (searchController.startDate.value ==
            searchController.endDates.value) {
          if (searchController.handleTimeSlotsOnCurrentDate.value == true) {
            return searchController.currenttimeSlots;
          } else {
            return searchController.filteredTimeSlotsEndTime;
          }
        } else {
          return searchController.searchPickerBaselineSlots();
        }
      case "SameDate":
        return searchController.filteredTimeSlotsEndTime;
      case "otherDates":
        if (searchController.startDate.value ==
            searchController.endDates.value) {
          return searchController.filteredTimeSlotsEndTime;
        } else {
          return searchController.searchPickerBaselineSlots();
        }
      default:
        return searchController.searchPickerBaselineSlots();
    }
  }

  List<Items>? list = [];
  ItemModel? itemModel;

  Future<void> searchMethod() async {
    itemModel = null;
    list = [];

    showLoading();
    try {
      String price =
          "${searchController.startRange.value}-${searchController.endRage.value}";
      var result = await searchController.searchItems(
        '',
        searchController.selectedtypesvalues.toString(),
        price,
        "${activeModuleId.value == 1 ? searchController.selectedBeds : '0'}",
        "${activeModuleId.value == 1 ? searchController.selectedBathroom : '0'}",
        searchController.featuresvalues.toString(),
        "1000",
        generalScopeController.startDateCustomDate.value.toString(),
        generalScopeController.endDateCustomDate.value.toString(),
        activeModuleId.value == 1 ? "0" : "0",
        "$slatsearch",
        "$sLongSearch",
        context,
        "${activeModuleId.value == 2 ? searchController.maketypeFunction() : activeModuleId.value == 5 ? searchController.bookablemetadata() : ''}",
      );

      itemModel = ItemModel.fromJson(result);
      list!.addAll(itemModel!.data!.items!);
      searchController.searchFilterList.addAll(itemModel!.data!.items!);
      searchController.offset = itemModel!.data!.offset!;

      if (list!.isNotEmpty) {
        closeLoading();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ViewOnMapScreen(title: "", list: list),
          ),
        );
      } else {
        closeLoading();
        showErrorToastMessage("Data not found!".tr);
      }
    } catch (error) {
      closeLoading();
    }
  }

  showModalBottomSheet(
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: notifires.getbgcolor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(22),
        topRight: Radius.circular(22),
      ),
    ),
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          final date =
              searchController.dateRangePickerControllerCustom.displayDate ??
                  DateTime.now();
          final locale = Get.locale?.languageCode ?? 'en';
          final monthName = getMonthName(date.month, locale: locale);
          final yearText = convertToLocaleDigits(date.year.toString());

          return SizedBox(
            height: MediaQuery.of(context).size.height - 100,
            child: Scaffold(
              backgroundColor: notifires.getbgcolor,
              bottomNavigationBar: SizedBox(
                height: 70,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      height: 70,
                      child: CustomsButtons(
                        onPressed: () {
                          if (slatsearch.toString().isNotEmpty &&
                              sLongSearch.toString().isNotEmpty) {
                            if (searchController.hitApiOnMap == true) {
                              searchMethod();
                            } else if (generalScopeController
                                    .homeSearchLocation.value !=
                                "") {
                              searchController.submitMethod(context);
                            }
                          } else {
                            showErrorToastMessage(
                                "Please Select Location".tr);
                          }
                        },
                        text: 'Continue'.tr,
                        backgroundColor: getColorBasedOnActiveModuleid(),
                      ),
                    ),
                  ],
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: [
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Align(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white,
                                  ),
                                  padding: const EdgeInsets.all(12.0),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.black,
                                    size: 20.0,
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.delete_forever_outlined,
                                        color: notifires.getwhiteblackcolor),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      'clear'.tr,
                                      style: smallHeading.copyWith(
                                          color: notifires.getwhiteblackcolor),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                searchController.datecleatr(clesrdata);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 7,
                    ),

                    // --- Calendar ---
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: SfDateRangePicker(
                        navigationDirection:
                            DateRangePickerNavigationDirection.vertical,
                        navigationMode: DateRangePickerNavigationMode.scroll,
                        enableMultiView: true,
                        headerStyle: DateRangePickerHeaderStyle(),
                        monthCellStyle: DateRangePickerMonthCellStyle(
                          todayTextStyle: TextStyle(
                            color: themeColor,
                          ),
                          weekendTextStyle: TextStyle(
                            color: themeColor,
                          ),
                        ),
                        monthViewSettings: DateRangePickerMonthViewSettings(
                            dayFormat: 'EEE',
                            viewHeaderStyle: DateRangePickerViewHeaderStyle(
                                textStyle: TextStyle(
                              color: notifires.getwhiteblackcolor,
                            ))),
                        backgroundColor: notifires.getboxcolor,
                        minDate: DateTime.now(),
                        maxDate: DateTime.now().add(const Duration(days: 160)),
                        controller:
                            searchController.dateRangePickerControllerCustom,
                        selectionMode: DateRangePickerSelectionMode.range,
                        startRangeSelectionColor: Colors.transparent,
                        endRangeSelectionColor: Colors.transparent,
                        rangeSelectionColor: Colors.transparent,
                        selectionColor: Colors.transparent,
                        onSelectionChanged: (args) {
                          searchController
                              .onSelectionChangedCustomDatePicker(args);
                          setState(() {}); // ✅ refresh after selection
                        },
                        cellBuilder: (context, details) {
                          final now = DateTime.now();
                          final isToday = details.date.year == now.year &&
                              details.date.month == now.month &&
                              details.date.day == now.day;

                          bool isDisabled =
                              details.date.isBefore(now) && !isToday;

                          final range = searchController
                              .dateRangePickerControllerCustom.selectedRange;
                          bool isSelected = false;

                          if (range != null) {
                            DateTime? start = range.startDate;
                            DateTime? end = range.endDate ??
                                start; // if only 1 selected yet

                            if (start != null && end != null) {
                              if (isSameDate(details.date, start) ||
                                  isSameDate(details.date, end) ||
                                  (details.date.isAfter(start) &&
                                      details.date.isBefore(end))) {
                                isSelected = true;
                              }
                            }
                          }

                          return Container(
                            margin: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? getColorBasedOnActiveModuleid()
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isDisabled
                                    ? Colors.grey.shade300
                                    : Colors.grey.shade400,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              convertToLocaleDigits("${details.date.day}"),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDisabled
                                    ? Colors.grey.shade400
                                    : isSelected
                                        ? Colors.white
                                        : notifires.getwhiteblackcolor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

bool isSameDate(DateTime d1, DateTime d2) {
  return d1.year == d2.year && d1.month == d2.month && d1.day == d2.day;
}

Widget searchLocatiopnForFilter() {
  return GooglePlaceAutoCompleteTextField(
    boxDecoration: BoxDecoration(
        color: notifires.getboxcolor,
        border: Border.all(
          color: notifires.getGrey3Whitecolor,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12)),
    textStyle: regular02.copyWith(color: notifires.getGrey1Whitecolor),
    textEditingController: generalScopeController.textEditingControllerCity,
    googleAPIKey: Config.googleKey,
    countries: null,
    inputDecoration: InputDecoration(
        prefixIcon: Icon(
          Icons.location_on_outlined,
          color: getColorBasedOnActiveModuleid(),
        ),
        contentPadding: const EdgeInsets.only(left: 10, top: 10),
        hintStyle: regular02.copyWith(color: notifires.getGrey2Whitecolor),
        hintText: "Enter Address".tr,
        border: InputBorder.none),
    isLatLngRequired: true,
    getPlaceDetailWithLatLng: (Prediction prediction) {
      slatsearch = prediction.lat.toString();
      sLongSearch = prediction.lng.toString();
      FocusManager.instance.primaryFocus?.unfocus();
      generalScopeController.citySelected =
          generalScopeController.textEditingControllerCity.text;
      generalScopeController.textEditingControllerCity.text =
          prediction.description!;
      generalScopeController.textEditingControllerCity.selection =
          TextSelection.fromPosition(
              TextPosition(offset: prediction.description!.length));
    },
    itemClick: (Prediction prediction) {},
    itemBuilder: (context, index, Prediction prediction) {
      return Container(
        decoration: BoxDecoration(
          color: notifires.getboxcolor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Column(
          children: [
            const SizedBox(
              height: 3,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: notifires.getgreycolor,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      prediction.description ?? "",
                      style: regular2(context)
                          .copyWith(color: notifires.getwhiteblackcolor),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            Divider(
              color: notifires.getgreycolor,
              thickness: 1,
            ),
            // SizedBox(height: 5,),
          ],
        ),
      );
    },
  );
}

//for top dialod==========
class TopDialog extends StatelessWidget {
  final Widget child;
  final Color backgroundColor;

  const TopDialog({
    super.key,
    required this.child,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Container(
              color: Colors.transparent,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 300,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(15),
                    bottomRight: Radius.circular(15),
                  ),
                  color: notifires.getbgcolor),
              child: Column(
                children: [
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 15,
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(
                            CupertinoIcons.clear_thick,
                            color: notifires.getGrey3Whitecolor,
                          )),
                      const SizedBox(
                        width: 20,
                      ),
                      Text(
                        "Change your search",
                        style: heading3Grey1(context),
                      )
                    ],
                  ),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showTopDialog({
  required BuildContext context,
  required WidgetBuilder builder,
  Color backgroundColor = Colors.white,
}) async {
  await showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return SafeArea(
        child: Builder(builder: (context) {
          return TopDialog(
            backgroundColor: backgroundColor,
            child: builder(context),
          );
        }),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(0.0, -1.0);
      const end = Offset(0.0, 0.0);
      const curve = Curves.easeInOut;

      final tween =
          Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      final offsetAnimation = animation.drive(tween);

      return SlideTransition(
        position: offsetAnimation,
        child: child,
      );
    },
  );
}

Widget customSearchContainer(
    BuildContext context, VoidCallback onSearch, bool? fromHomeScreen) {
  SearchControllerHome filterController = Get.find();
  return Container(
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(24), bottomLeft: Radius.circular(24))),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 13, top: 13, right: 13),
          child: Table(
            children: [
              TableRow(children: [
                Card(
                  elevation: 2,
                  child: InkWell(
                    onTap: () {
                      filterController.datePopup.value = false;
                      openSearchWizard(context, onSearch: onSearch);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: notifires.getboxcolor,
                          borderRadius: BorderRadius.circular(8)),
                      child: Container(
                          padding: const EdgeInsets.only(
                              left: 10, right: 11, top: 5, bottom: 5),
                          child: Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              SizedBox(
                                height: 35,
                                child: Icon(
                                  Icons.location_on_outlined,
                                  color: notifires.getGrey2Whitecolor,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 19,
                                child: Obx(
                                  () => Text(
                                    generalScopeController
                                                .homeSearchLocation.value !=
                                            ""
                                        ? generalScopeController
                                            .homeSearchLocation.value
                                        : generalScopeController
                                                .textEditingControllerCity
                                                .text
                                                .isEmpty
                                            ? "Where do you go?".tr
                                            : generalScopeController
                                                .textEditingControllerCity.text,
                                    style: regular3(context).copyWith(
                                        color: notifires.getGrey1Whitecolor,
                                        fontSize: 13,
                                        overflow: TextOverflow.ellipsis),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                              const Spacer(),
                            ],
                          )),
                    ),
                  ),
                )
              ]),
              TableRow(children: [
                SizedBox(
                  height: 53,
                  child: Card(
                      elevation: 2, child: customDatePickerForFilter(context)),
                )
              ]),
              TableRow(children: [
                Card(
                  elevation: 2,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: GestureDetector(
                          onTap: () {
                            onSearch();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(8),
                                  bottomLeft: Radius.circular(8),
                                  topRight: Radius.circular(8),
                                  bottomRight: Radius.circular(8),
                                ),
                                color: yelloColor2),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 10, bottom: 12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Search".tr,
                                    style: boldstyle(context)
                                        .copyWith(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () {
                          final hasLocation = generalScopeController
                                  .homeSearchLocation.value.isNotEmpty ||
                              generalScopeController
                                  .textEditingControllerCity.text.isNotEmpty;
                          final hasDates = filterController
                                  .startDate.value.isNotEmpty &&
                              filterController.endDates.value.isNotEmpty;
                          if (!hasLocation && !hasDates) {
                            return const SizedBox();
                          }
                          return Expanded(
                                flex: 1,
                                child: GestureDetector(
                                  onTap: () {
                                    filterController.clearFilter();
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(8),
                                        bottomLeft: Radius.circular(8),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                          top: 10,
                                          bottom: 12),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: redColor,
                                            size: 17,
                                          ),
                                          Text(
                                            "clear".tr,
                                            style: boldstyle(context).copyWith(
                                                color: redColor, fontSize: 14),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                        },
                      ),
                    ],
                  ),
                )
              ]),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    ),
  );
}

Widget vehicalHorizontalViewNearYou(
  List<ItemsData>? list,
  StateSetter setState,
  notifir,
) {
  return SizedBox(
    width: double.infinity,
    height: 230,
    child: ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: (list?.length ?? 0) > 5 ? 5 : (list?.length ?? 0),
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        String? serviceType = '';
        ItemInfo? itemInfoData;
        if (list != null && list.length > index && list.isNotEmpty) {
          String? city = list[index].city;
          String? cityy = list[index].city;
          String? jsonSliders = list[index].itemInfo;
          if (jsonSliders != null) {
            itemInfoData = ItemInfo.fromJson(json.decode(jsonSliders));
            Map<String, dynamic> itemInfo = jsonDecode(jsonSliders);
            serviceType = itemInfo["service_type"];
          }

          if (city != null) {
            city = cityy;
          }
          final double parsedRating =
              VehicleCardHelper.resolveItemRating(list[index]);

          return Padding(
            padding:
                const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 5),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VehicleDetailSScreen(
                              id: list.elementAt(index).id,
                              itemInfo: itemInfoData,
                              rating: parsedRating > 0
                                  ? parsedRating.toStringAsFixed(1)
                                  : list[index].itemRating,
                              title: list[index].name,
                              address: list[index].address,
                              city: list[index].city,
                              latitute: list[index].latitude,
                              longtitute: list[index].longitude,
                              frontImage: list[index].image,
                              itemType: list[index].itemType,
                              isWishList: list[index].isInWishlist,
                              price: list[index].price,
                            )));
              },
              child: Container(
                width: 332,
                height: 230,
                decoration: BoxDecoration(
                  color: notifir.getboxcolor,
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
                      width: 332,
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
                              child:
                                  myNetworkImageWithShimmer(list[index].image),
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
                                            : list[index].name!.tr,
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
                                            color:
                                                getColorBasedOnActiveModuleid()
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
                                              parsedRating
                                                  .toStringAsFixed(1),
                                              style: boldstyle(context)
                                                  .copyWith(
                                                      color: whiteColor,
                                                      fontSize: 9),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      )
                                    ],
                                  ),
                                  VehicleCardHelper.buildSpecsAndPriceRow(
                                    itemInfo: itemInfoData,
                                    price: list.elementAt(index).price,
                                    showPerDay: serviceType == "booking",
                                    chipStyle: regular3(context).copyWith(
                                      fontSize: 12,
                                      color: whiteColor,
                                    ),
                                    priceStyle: boldstyle(context).copyWith(
                                      color: getColorBasedOnActiveModuleid(),
                                      fontSize: 14,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    perDayStyle: regular(context).copyWith(
                                      color: notifires.getGrey4Whitecolor,
                                      overflow: TextOverflow.ellipsis,
                                    ),
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
                                                  list[index].isInWishlist ==
                                                      null
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

                                            try {
                                              if (list[index].isInWishlist ==
                                                  false) {
                                                var value =
                                                    await wishListController
                                                        .addTowishlist(
                                                            list[index].id);
                                                if (value == true) {
                                                  var vvv = list[index];
                                                  vvv.wishlistSetter = true;
                                                  list[index] = vvv;
                                                }
                                              } else {
                                                var value =
                                                    await wishListController
                                                        .removeToWishlist(
                                                            list[index].id);
                                                if (value == true) {
                                                  var vvv = list[index];
                                                  vvv.wishlistSetter = false;
                                                  list[index] = vvv;
                                                }
                                              }
                                            } catch (e) {
                                              print(
                                                  "❌ [Wishlist] Error toggling wishlist: $e");
                                            } finally {
                                              // CRITICAL: Always reset loading state, no matter what
                                              wishListLoadingHorizontal = -1;
                                              try {
                                                setState(() {});
                                              } catch (e) {
                                                // Widget might be disposed, but we still reset the loading state
                                                print(
                                                    "⚠️ [Wishlist] setState failed (widget disposed): $e");
                                              }
                                            }
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
                        if (itemInfoData?.hostFirstName != null)
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
                                "${"By".tr} - ${itemInfoData?.hostFirstName ?? ""}",
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
    ),
  );
}
