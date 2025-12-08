import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/kyc_controller.dart';
import 'package:carvy/controller/publix_profile_controller.dart';
import 'package:carvy/controller/push_notifications.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/full_screen_image_view.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:get/get.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/itemdetail/vehicle/reviews/item_review_screen.dart';
import 'package:carvy/view/itemdetail/vehicle/vehicle_check_availability_screen.dart';
import 'package:carvy/view/wishlist/wish_list_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../controller/items_detail_controller.dart';
import '../../../customwidget/miscellaneous_project_elements.dart';
import '../../../utils/vehicle_common_widgets.dart';
import '../../../work_space.dart';
import '../../chat/conversation_screen.dart';
import '../../myaccount/publicProfile/public_profile_screen.dart';
import 'package:carvy/customwidget/search_wizard.dart';

class VehicleDetailSScreen extends StatefulWidget {
  final dynamic id;
  final bool? handleback;
  ItemInfo? itemInfo;
  String? frontImage;
  String? address;
  String? rating;
  String? itemType;
  String? title;
  String? latitute;
  String? longtitute;
  String? price;
  bool? isWishList;
  bool? chatafterBooking;
  VehicleDetailSScreen({
    super.key,
    this.id,
    this.handleback,
    this.itemInfo,
    this.frontImage,
    this.address,
    this.rating,
    this.itemType,
    this.title,
    this.latitute,
    this.longtitute,
    this.price,
    this.isWishList,
    this.chatafterBooking,
  });
  @override
  State<VehicleDetailSScreen> createState() => _VehicleDetailSScreenState();
}

class _VehicleDetailSScreenState extends State<VehicleDetailSScreen> {
  KycController kycController = Get.find();
  ItemDetailsController vehicleDetailController = Get.find();
  final ValueNotifier<int> vehicleCurrentPageNotifier = ValueNotifier<int>(0);
  final PageController vehiclePagereviewController = PageController();
  PageController vehiclepageControllerslider = PageController();
  SearchControllerHome filterController = Get.find();
  PublicProfileController publicProfileController = Get.find();
  final ValueNotifier<int> vehiclecurrentPageSliderNotifier =
      ValueNotifier<int>(0);
  int showWishList = -1;
  @override
  void initState() {
    super.initState();
    handleSearchFordetail = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      kycController.getUserKycData();
      if (handleDirectBooking == false) {
        filterController.setDefaultDates(
          startDateCustomDate: generalScopeController.startDateCustomDate,
          endDateCustomDate: generalScopeController.endDateCustomDate,
          startDate: filterController.startDate,
          endDates: filterController.endDates,
        );
      }
      publicProfileController
          .getDataPublicProfile(widget.itemInfo!.hostId.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    print("sdfsd. ${widget.itemInfo!.reviewData!}");
    String? vehicleRating = vehicleDetailController
                .vehicleDetailModel?.data?.itemDetails?.itemRating !=
            null
        ? vehicleDetailController
            .vehicleDetailModel!.data!.itemDetails!.itemRating
        : "0";
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: themeColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Semantics(
                label: 'Date Range Selector',
                child: GestureDetector(
                  onTap: () {
                    openSearchWizard(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: notifires.getboxcolor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: notifires.getGrey2Whitecolor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: getColorBasedOnActiveModuleid()
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            color: getColorBasedOnActiveModuleid(),
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Obx(() => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filterController
                                                .startDate.value.isNotEmpty &&
                                            filterController
                                                .endDates.value.isNotEmpty
                                        ? "Dates".tr
                                        : "Select Dates".tr,
                                    style: regular2(context).copyWith(
                                      fontSize: 10,
                                      color: notifires.getGrey1Whitecolor,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    filterController
                                                .startDate.value.isNotEmpty &&
                                            filterController
                                                .endDates.value.isNotEmpty
                                        ? "${filterController.startDate.value}-${filterController.startTimeSearch.value}  -  ${filterController.endDates.value} ${filterController.endTimeSearch.value} "
                                        : "Tap to select".tr,
                                    style: regular3(context).copyWith(
                                      fontSize: 12,
                                      color: notifires.getwhiteblackcolor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              )),
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: getColorBasedOnActiveModuleid()
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.edit,
                            color: getColorBasedOnActiveModuleid(),
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: notifires.getbgcolor,
      body: connectionLost == true
          ? Center(child: connectionError(context, "Something Went Wrong".tr))
          : Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  top: 100,
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        CustomImagesForDetails(
                          imagesList:
                              widget.itemInfo!.galleryImageUrls!.isNotEmpty
                                  ? widget.itemInfo!.galleryImageUrls!
                                  : [],
                          frontImage: widget.frontImage ?? '',
                        ),

                        ListTile(
                          contentPadding: const EdgeInsets.only(
                              left: 12, right: 12, top: 10),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.title != null
                                      ? widget.title!.length > 50
                                          ? "${widget.title!.substring(0, 19)}..."
                                          : widget.title!
                                      : "",
                                  style: boldstyle(context).copyWith(
                                      color: notifires.getwhiteblackcolor,
                                      fontSize: 24),
                                  maxLines: 2,
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              Text(
                                widget.rating ?? "No rating",
                                style: boldstyle(context)
                                    .copyWith(color: appyellow, fontSize: 18),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Icons.star,
                                color: appyellow,
                                size: 20,
                              )
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(height: 5,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.location_on_outlined,
                                    color: getColorBasedOnActiveModuleid(),
                                    size: 20,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 9,
                                    child: Text(
                                      widget.address ?? "",
                                      style: regular3(context).copyWith(
                                        fontSize: 12,
                                        overflow: TextOverflow.visible,
                                      ),
                                      softWrap: true,
                                      maxLines: null,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            if (widget.itemInfo?.vehicleType != null)
                              carItemBox(
                                icon: Icons.car_rental,
                                title: 'Vehicle Type'.tr,
                                desc: '${widget.itemInfo?.vehicleType}',
                              ),
                            if (widget.itemInfo?.makeType != null)
                              carItemBox(
                                icon: Icons.settings,
                                title: 'Make'.tr,
                                desc: '${widget.itemInfo?.makeType}',
                              ),
                            if (widget.itemInfo?.model != null)
                              carItemBox(
                                icon: Icons.star_border_outlined,
                                title: 'Model'.tr,
                                desc: '${widget.itemInfo?.model}',
                              ),
                            if (widget.itemInfo?.year != null)
                              carItemBox(
                                icon: Icons.calendar_month_outlined,
                                title: 'Year'.tr,
                                desc: '${widget.itemInfo?.year}',
                              ),
                            if (widget.itemInfo?.transmission != null)
                              carItemBox(
                                icon: Icons.track_changes,
                                title: 'Transmission'.tr,
                                desc: '${widget.itemInfo?.transmission}',
                              ),
                            if (widget.itemInfo?.odometer != null)
                              carItemBox(
                                icon: Icons.traffic_outlined,
                                title: 'Odometer'.tr,
                                desc: '${widget.itemInfo?.odometer}',
                              ),
                            if (widget.itemInfo?.fuelType != null)
                              if (widget.itemInfo?.fuelType != null)
                                carItemBox(
                                  icon: Icons.local_gas_station,
                                  title: 'Fuel Type'.tr,
                                  desc:
                                      '${widget.itemInfo?.fuelType == "" ? "Petrol" : "${widget.itemInfo?.fuelType}"}',
                                ),
                            if (widget.itemInfo?.seatCapicity != null)
                              carItemBox(
                                icon: Icons.event_seat,
                                title: 'Seats'.tr,
                                desc: '${widget.itemInfo?.seatCapicity}',
                              ),
                            carItemBox(
                              icon: Icons.credit_card,
                              title: 'Plate Number'.tr,
                              desc: '${widget.itemInfo?.platNumber ?? "0"}',
                            ),
                            carItemBox(
                              icon: Icons.event,
                              title: 'Minimum Rental Days'.tr,
                              desc: '${widget.itemInfo?.minRentalDays ?? "0"}',
                            ),
                            carItemBox(
                              icon: Icons.person_2,
                              title: 'Minimum Age'.tr,
                              desc: '${widget.itemInfo?.ageRistriction ?? "0"}',
                            ),
                            carItemBox(
                              icon: Icons.verified_user,
                              title: 'Insurance Coverage'.tr,
                              desc:
                                  '${widget.itemInfo?.insuranceCoverage ?? "0"}',
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 20,
                        ),
                        const SizedBox(height: 5.0),
                        ListTile(
                          title: Padding(
                            padding: const EdgeInsets.only(bottom: 5.0),
                            child: Text('About the car'.tr,
                                style: heading2(context)),
                          ),
                          subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    buildDescriptionWidget(),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    buildShowMoreButton(),
                                  ],
                                ),
                              ]),
                        ),
                        widget.itemInfo?.featuresData == null ||
                                widget.itemInfo!.featuresData!.isEmpty
                            ? const SizedBox()
                            : Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: Dimensions.paddingSizeDefault),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Car Features'.tr,
                                        style: heading2(context)),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    for (var x in widget.itemInfo!.featuresData!
                                        .take(6))
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 8, top: 5),
                                        child: Column(
                                          children: [
                                            featuresbox(
                                                txt: '${x.name}',
                                                image: "${x.imageUrl}"),
                                            const SizedBox(
                                                height:
                                                    10), // Adjust the height according to your needs
                                          ],
                                        ),
                                      ),
                                    if (widget.itemInfo!.featuresData!.length >
                                        6)
                                      InkWell(
                                        onTap: () {
                                          featuresBottomSheet(context,
                                              title: 'Vehicle Features'.tr,
                                              list: widget
                                                      .itemInfo?.featuresData ??
                                                  []);
                                        },
                                        child: Row(
                                          children: [
                                            Text(
                                              'Read more'.tr,
                                              style: regular2(context).copyWith(
                                                  color:
                                                      getColorBasedOnActiveModuleid()),
                                            ),
                                            const SizedBox(width: 5),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: 16,
                                              color:
                                                  getColorBasedOnActiveModuleid(),
                                            )
                                          ],
                                        ),
                                      )
                                  ],
                                ),
                              ),
                        const SizedBox(
                          height: 15.0,
                        ),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Row(
                                children: [
                                  Text(
                                    "You will be here".tr,
                                    style: heading2(context),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 12, right: 12),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Stack(
                                  children: [
                                    widget.latitute != null &&
                                            widget.longtitute != null
                                        ? GestureDetector(
                                            onTap: () {
                                              Get.to(() => FullMapScreen(
                                                    latitude: widget.latitute,
                                                    longitude:
                                                        widget.longtitute,
                                                  ));
                                            },
                                            child: SizedBox(
                                              height: 300,
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                child: Stack(
                                                  fit: StackFit.expand,
                                                  children: [
                                                    Image.asset(
                                                      "assets/images/blur.png",
                                                      fit: BoxFit.cover,
                                                    ),
                                                    // Black shade with "Tap to view" message
                                                    Container(
                                                      color: Colors.black
                                                          .withOpacity(
                                                              0.2), // Semi-transparent black shade
                                                      child: Center(
                                                        child: Text(
                                                          "Tap to view".tr,
                                                          style: headingh5
                                                              .copyWith(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Text(
                                              'Map is not available'.tr,
                                              style: headingh5,
                                            ),
                                          ),
                                    Positioned(
                                      top: 16,
                                      left: 16,
                                      child: Material(
                                        elevation: 2,
                                        borderRadius: BorderRadius.circular(8),
                                        child: InkWell(
                                          onTap: () {
                                            if (widget.latitute != null &&
                                                widget.longtitute != null) {
                                              Get.to(() => FullMapScreen(
                                                    latitude: widget.latitute,
                                                    longitude:
                                                        widget.longtitute,
                                                  ));
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.only(
                                                left: 6,
                                                right: 6,
                                                top: 4,
                                                bottom: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.fullscreen,
                                              size: 30,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),

                        widget.itemInfo!.reviewData == null ||
                                widget.itemInfo!.reviewData!.isEmpty
                            ? const SizedBox()
                            : buildDivider(),
                        widget.itemInfo!.reviewData == null ||
                                widget.itemInfo!.reviewData!.isEmpty
                            ? const SizedBox()
                            : const SizedBox(
                                height: 15,
                              ),
                        widget.itemInfo!.reviewData == null ||
                                widget.itemInfo!.reviewData!.isEmpty
                            ? const SizedBox()
                            : Row(
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Icon(
                                        Icons.star,
                                        color: orangeColor,
                                        size: 24,
                                      ),
                                      const SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        ' ${"Review".tr} (${widget.itemInfo?.totalReviews ?? "No review Here"})',
                                        style: heading2(context),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  widget.itemInfo!.reviewData!.isEmpty
                                      ? const SizedBox()
                                      : InkWell(
                                          onTap: () {
                                            Get.to(() => YourReview(
                                                id: widget.id.toString()));
                                          },
                                          child: Text(
                                            "See All".tr,
                                            style: regular3(context).copyWith(
                                              color:
                                                  getColorBasedOnActiveModuleid(),
                                            ),
                                          ),
                                        ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                ],
                              ),

                        widget.itemInfo!.reviewData == null ||
                                widget.itemInfo!.reviewData!.isEmpty
                            ? const SizedBox()
                            : SizedBox(
                                height: 120,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 20, top: 10),
                                  child: PageView.builder(
                                    controller: vehiclePagereviewController,
                                    onPageChanged: (index) {
                                      vehicleCurrentPageNotifier.value = index;
                                    },
                                    itemCount:
                                        widget.itemInfo!.reviewData!.length,
                                    physics: const BouncingScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      print(widget.itemInfo!.reviewData![index]
                                          ["guest_profile_image"]);
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Guest profile image
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(50),
                                            child: SizedBox(
                                              height: 55,
                                              width: 55,
                                              child: widget.itemInfo!.reviewData![
                                                                  index][
                                                              "guest_profile_image"] !=
                                                          null &&
                                                      widget
                                                          .itemInfo!
                                                          .reviewData![index][
                                                              "guest_profile_image"]
                                                          .isNotEmpty
                                                  ? myNetworkImage(
                                                      widget.itemInfo!
                                                                  .reviewData![
                                                              index][
                                                          "guest_profile_image"],
                                                      true,
                                                    )
                                                  : Container(
                                                      color: Colors.grey[200],
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 30,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                            ),
                                          ),

                                          const SizedBox(
                                            width: 16,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                widget.itemInfo!
                                                            .reviewData![index]
                                                        ["guest_name"] ??
                                                    "Guest Name Missing".tr,
                                                style: heading3Grey1(context),
                                              ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  RatingBar.builder(
                                                    initialRating: double.parse(
                                                      "${widget.itemInfo!.reviewData![vehicleCurrentPageNotifier.value]["rating"]}",
                                                    ),
                                                    itemSize: 20,
                                                    ignoreGestures: true,
                                                    direction: Axis.horizontal,
                                                    itemCount: 5,
                                                    itemPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 0),
                                                    itemBuilder: (context, _) =>
                                                        Icon(
                                                      Icons.star,
                                                      color:
                                                          getColorBasedOnActiveModuleid(),
                                                    ),
                                                    onRatingUpdate:
                                                        (double value) {},
                                                  ),
                                                  Text(
                                                    "${widget.itemInfo!.reviewData![index]["updated_at"] ?? "Timestamp Missing"}",
                                                    style: regular(context),
                                                  ),
                                                ],
                                              ),
                                              widget.itemInfo!.reviewData![
                                                          index]["message"] ==
                                                      null
                                                  ? const SizedBox()
                                                  : Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 4),
                                                      child: Text(
                                                        "${widget.itemInfo!.reviewData![index]["message"].length > 32 ? widget.itemInfo!.reviewData![index]["message"].substring(0, 32) + "..." : widget.itemInfo!.reviewData![index]["message"]}",
                                                        style: regular2(context)
                                                            .copyWith(),
                                                      ),
                                                    ),
                                              const SizedBox(
                                                height: 4,
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),

                        widget.itemInfo!.reviewData == null ||
                                widget.itemInfo!.reviewData!.isEmpty
                            ? const SizedBox()
                            : ValueListenableBuilder<int>(
                                valueListenable: vehicleCurrentPageNotifier,
                                builder: (context, value, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      widget.itemInfo!.reviewData!.length,
                                      // Same as itemCount in PageView
                                      (index) {
                                        return Container(
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2.0),
                                          width: 8.0,
                                          height: 8.0,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: value == index
                                                ? getColorBasedOnActiveModuleid()
                                                : Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),

                        const SizedBox(
                          height: 20,
                        ),
                        widget.itemInfo!.rules == null ||
                                widget.itemInfo!.rules!.isEmpty
                            ? const SizedBox()
                            : Padding(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
                                child: GestureDetector(
                                  onTap: () {
                                    rulesbuttomSheet(
                                      context,
                                      title: 'Vehicle Rules'.tr,
                                      list: widget.itemInfo?.rules ?? [],
                                    );
                                  },
                                  child: Card(
                                    color: notifires.getboxcolor,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 20, bottom: 20),
                                      child: Row(
                                        children: [
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          SvgPicture.asset(
                                            "assets/images/menurule.svg",
                                            colorFilter: ColorFilter.mode(
                                                getColorBasedOnActiveModuleid(),
                                                BlendMode.srcIn),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Text(
                                            "Vehicle Rules".tr,
                                            style: regular3(context)
                                                .copyWith(color: acentColor),
                                          ),
                                          const Spacer(),
                                          InkWell(
                                            onTap: () {
                                              rulesbuttomSheet(
                                                context,
                                                title: 'Vehicle Rules'.tr,
                                                list: widget.itemInfo?.rules ??
                                                    [],
                                              );
                                            },
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
                                ),
                              ),
                        widget.itemInfo!.rules == null ||
                                widget.itemInfo!.rules!.isEmpty
                            ? const SizedBox()
                            : const SizedBox(
                                height: 10,
                              ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: GestureDetector(
                            onTap: () {
                              rulesbuttomSheet(
                                context,
                                title:
                                    "${widget.itemInfo!.cancellationReasonTitle}",
                                list: widget.itemInfo
                                        ?.cancellationReasonDescription ??
                                    [],
                              );
                            },
                            child: Card(
                              color: notifires.getboxcolor,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 20, bottom: 20),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    SvgPicture.asset(
                                      "assets/images/hash.svg",
                                      colorFilter: ColorFilter.mode(
                                          getColorBasedOnActiveModuleid(),
                                          BlendMode.srcIn),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Cancellation Policy".tr,
                                      style: regular3(context)
                                          .copyWith(color: acentColor),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        rulesbuttomSheet(
                                          context,
                                          title:
                                              "${widget.itemInfo!.cancellationReasonTitle}",
                                          list: widget.itemInfo
                                                  ?.cancellationReasonDescription ??
                                              [],
                                        );
                                      },
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
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),

                        GestureDetector(
                          onTap: () {
                            print(widget.itemInfo!.hostProfileImage);
                            Get.to(() => PublicProfile(
                                  userid: widget.itemInfo!.hostId.toString(),
                                  photo: widget.frontImage,
                                  userName:
                                      "${widget.itemInfo!.hostFirstName} ${widget.itemInfo!.hostLastName}",
                                  profileImage:
                                      widget.itemInfo!.hostProfileImage ?? "",
                                ));
                          },
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: widget.itemInfo!.hostProfileImage != null
                                  ? Image.network(
                                      "${widget.itemInfo!.hostProfileImage}",
                                      height: 55,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                        Icons.account_circle_rounded,
                                        size: 55,
                                        color: notifires.getgreycolor,
                                      ),
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                    )
                                  : Icon(
                                      Icons.account_circle_rounded,
                                      size: 55,
                                      color: notifires.getgreycolor,
                                    ),
                            ),
                            title: Text(
                              "${"Hosted by".tr} ${widget.itemInfo?.hostFirstName ?? ""} "
                                  .tr,
                              // 'Hosted by Marry',
                              style: heading3Grey1(context),
                            ),
                            subtitle: Text('View profile'.tr,
                                style: regular2(context).copyWith(
                                  color: getColorBasedOnActiveModuleid(),
                                )),
                            trailing: widget.chatafterBooking == null
                                ? const SizedBox()
                                : widget.itemInfo!.hostId == null ||
                                        widget.itemInfo!.hostId!.toString() ==
                                            userId.toString()
                                    ? const SizedBox()
                                    : GestureDetector(
                                        onTap: () {},
                                        child: SvgPicture.asset(
                                            "assets/images/share.svg"),
                                      ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        const SizedBox(
                          height: 85,
                        ),

                        // vehicleItemHorizontalView( notifires),
                      ],
                    ),
                  ),
                ),
                Positioned(
                    left: 0,
                    top: 115,
                    child: backButtonfordetailPageForVehicle(context, true)),
                Positioned(
                  right: 15,
                  top: 120,
                  child: isHostMode.value == true
                      ? const SizedBox()
                      : showWishList == 0
                          ? const SizedBox(
                              height: 25,
                              width: 25,
                              child: Center(child: CircularProgressIndicator()))
                          : Padding(
                              padding: const EdgeInsets.only(
                                  top: Dimensions.paddingSizeDefault,
                                  bottom: 8),
                              child: InkWell(
                                child: widget.isWishList == false
                                    ? SvgPicture.asset(
                                        'assets/images/whitHeart.svg',
                                        // height: 15,
                                      )
                                    : SvgPicture.asset(
                                        'assets/images/redHeart.svg',
                                      ),
                                onTap: () async {
                                  if (token.isEmpty) {
                                    showErrorToastMessage(
                                        "You are not Login Yet Please Login ");
                                    return;
                                  }
                                  setState(() {});
                                  showWishList = -1;
                                  if (widget.isWishList == false) {
                                    showWishList = 0;
                                    var value = await wishListController
                                        .addTowishlist(widget.id);
                                    if (value == true) {
                                      setState(() {
                                        widget.isWishList = true;
                                        showWishList = -1;
                                      });
                                    }
                                  } else {
                                    showWishList = 0;
                                    var value = await wishListController
                                        .removeToWishlist(widget.id);
                                    if (value == true) {
                                      setState(() {
                                        widget.isWishList = false;
                                        showWishList = -1;
                                      });
                                    }
                                  }
                                },
                              ),
                            ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: notifires.getgreycolor, blurRadius: 5)
        ]),
        child: BottomAppBar(
          elevation: 0,
          surfaceTintColor: notifires.getbgcolor,
          color: notifires.getbgcolor,
          height: 55,
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: Dimensions.containerWidth,
              child: Row(
                children: [
                  Text(
                    "$currency ${widget.price!}",
                    style: heading2(context)
                        .copyWith(color: getColorBasedOnActiveModuleid()),
                  ),
                  widget.itemInfo!.serviceType!.toString() == "booking"
                      ? Text(
                          " / day".tr,
                          style: regular2(context)
                              .copyWith(color: notifires.getGrey4Whitecolor),
                        )
                      : Text(
                          " / ${widget.itemInfo!.serviceType!}",
                          style: regular2(context)
                              .copyWith(color: notifires.getGrey4Whitecolor),
                        ),
                  const Spacer(),
                  loginModel != null &&
                          widget.itemInfo?.hostId.toString() ==
                              userId.toString()
                      ? const SizedBox()
                      : widget.itemInfo!.serviceType!.toString() == "sale" ||
                              widget.itemInfo!.serviceType!.toString() == "rent"
                          ? Row(
                              children: [
                                Container(
                                  height: 40,
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: notifires.getGrey5Whitecolor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          'tel:${widget.itemInfo!.hostPhone!}'));
                                    },
                                    icon: Icon(Icons.call,
                                        color: getColorBasedOnActiveModuleid()),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Container(
                                  height: 40,
                                  width: 40,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: notifires.getGrey5Whitecolor,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      launchUrl(Uri.parse(
                                          'mailto:${widget.itemInfo!.hostEmail!}'));
                                    },
                                    icon: Icon(Icons.email,
                                        color: getColorBasedOnActiveModuleid()),
                                  ),
                                ),
                              ],
                            )
                          : widget.itemInfo!.serviceType!.toString() ==
                                  "booking"
                              ? isHostMode.value == true
                                  ? const SizedBox()
                                  : SizedBox(
                                      height: 56,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (token.isEmpty) {
                                            loginAlert(context);
                                            return;
                                          }

                                          if (loginModel != null &&
                                              widget.itemInfo?.hostId
                                                      .toString() ==
                                                  userId.toString()) {
                                            showErrorToastMessage(
                                                "You can't book your own vehicle");
                                            return;
                                          }

                                          late SearchControllerHome
                                              searchController = Get.find();

                                          bookingController
                                                  .selectedStartTime.value =
                                              searchController
                                                  .startTimeSearch.value;

                                          bookingController
                                                  .selectedEndTime.value =
                                              searchController
                                                  .endTimeSearch.value;

                                          bookingController.startDate.value =
                                              generalScopeController
                                                  .startDateCustomDate.value;

                                          bookingController.endDate.value =
                                              generalScopeController
                                                  .endDateCustomDate.value;
// if allready filteres

                                          kycController
                                              .kycStatus(
                                                  kycController
                                                      .activeStatus.value,
                                                  context)
                                              .then((isValid) {
                                            if (!isValid) return;

                                            if (handleDirectBooking == true) {
                                              bookingController
                                                  .commonNavigateToBookingSummary(
                                                context,
                                                widget.id,
                                                widget.itemInfo,
                                                widget.address,
                                                widget.frontImage,
                                                widget.title,
                                                widget.rating,
                                                widget.itemType,
                                                widget.price,
                                                "",
                                              );

                                              return;
                                            }
                                            showLoading();
                                            bookingController
                                                .checkDateApi(
                                                    idFeatured: '${widget.id}')
                                                .then((value) {
                                              closeLoading();
                                              try {
                                                final data = value?["data"];
                                                if (data == null) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VehicleCheckAvailability(
                                                        idFeatured: widget.id,
                                                        itemDetails:
                                                            widget.itemInfo,
                                                        address: widget.address,
                                                        frontImage:
                                                            widget.frontImage,
                                                        title: widget.title,
                                                        rating: widget.rating,
                                                        itemType:
                                                            widget.itemType,
                                                        price: widget.price,
                                                      ),
                                                    ),
                                                  );
                                                  return;
                                                }
                                                String? startTime =
                                                    data["next_start_time"];
                                                String? endTime =
                                                    data["next_end_time"];
                                                final availability =
                                                    data["availability"];
                                                if (availability != null) {
                                                  startTime = availability[
                                                          "next_start_time"] ??
                                                      startTime;
                                                  endTime = availability[
                                                          "next_end_time"] ??
                                                      endTime;
                                                  startTime ??= "12:00 AM";
                                                  endTime ??= "11:30 AM";
                                                  bookingController
                                                      .selectedStartTime
                                                      .value = startTime;
                                                  bookingController
                                                      .selectedEndTime
                                                      .value = endTime;

                                                  bookingController
                                                      .commonNavigateToBookingSummary(
                                                    context,
                                                    widget.id,
                                                    widget.itemInfo,
                                                    widget.address,
                                                    widget.frontImage,
                                                    widget.title,
                                                    widget.rating,
                                                    widget.itemType,
                                                    widget.price,
                                                    "",
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          VehicleCheckAvailability(
                                                        idFeatured: widget.id,
                                                        itemDetails:
                                                            widget.itemInfo,
                                                        address: widget.address,
                                                        frontImage:
                                                            widget.frontImage,
                                                        title: widget.title,
                                                        rating: widget.rating,
                                                        itemType:
                                                            widget.itemType,
                                                        price: widget.price,
                                                      ),
                                                    ),
                                                  );
                                                }

                                                debugPrint(
                                                  '✅ Checkout Time -> Start: $startTime | End: $endTime',
                                                );

                                                closeLoading();
                                              } catch (e) {
                                                debugPrint(
                                                    'Error parsing checkDateApi response: $e');
                                                showErrorToastMessage(
                                                    "Something went wrong. Please try again."
                                                        .tr);
                                              }
                                            }).catchError((error) {
                                              closeLoading();
                                              debugPrint(
                                                  '❌ Error in checkDateApi: $error');
                                              showErrorToastMessage(
                                                  "An error occurred while checking availability."
                                                      .tr);
                                            });
                                          });
                                        },
                                        style: ButtonStyle(
                                          backgroundColor: WidgetStateProperty.all(
                                              getColorBasedOnActiveModuleid()),
                                          shape: WidgetStateProperty.all(
                                            RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          'Next'.tr,
                                          style: heading3(context).copyWith(
                                              color: whiteColor,
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                    )
                              : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDescriptionWidget() {
    final description = (widget.itemInfo?.description ?? "");
    return Expanded(
      child: Text(
        description,
        style: regular2(context).copyWith(overflow: TextOverflow.ellipsis),
        maxLines:
            vehicleDetailController.vehicleisDescriptionExpanded ? null : 5,
      ),
    );
  }

  Widget buildShowMoreButton() {
    final description = Intl.message(
      widget.itemInfo?.description ?? "",
      name: 'description',
      desc: 'Description of the property',
    );

    final hasMoreThanFiveLines = description.length > 250;

    return hasMoreThanFiveLines
        ? GestureDetector(
            onTap: () {
              setState(() {
                seeMore(context, "About the car".tr, description.tr);
              });
            },
            child: Row(
              children: [
                Text(
                  vehicleDetailController.isDescriptionExpanded
                      ? "Show Less".tr
                      : "Show More".tr,
                  style: regular2(context)
                      .copyWith(color: getColorBasedOnActiveModuleid()),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: getColorBasedOnActiveModuleid(),
                ),
              ],
            ),
          )
        : const SizedBox
            .shrink(); // If no need for Show More button, return an empty SizedBox
  }

  Widget carItemBox({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return SizedBox(
      width: (Get.width / 2) - 24, // Two boxes per row with spacing
      child: GestureDetector(
        child: carbox(
          icons: icon,
          title: title,
          desc: desc,
        ),
      ),
    );
  }
}
