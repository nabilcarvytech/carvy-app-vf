import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/custom_bottom_sheet.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/full_screen_image_view.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/cancellation_reason_model.dart';
import 'package:carvy/model/door_step_address_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controller/booking_controller.dart';
import '../../controller/items_detail_controller.dart';
import '../../model/booking_model.dart';
import '../../model/item_details_model.dart';
import '../../utils/vehicle_common_widgets.dart';
import '../../work_space.dart';

class HostEreciept extends StatefulWidget {
  final Bookings bookings;
  final bool fromPropBooking;
  final String? conformBooking;
  const HostEreciept({
    super.key,
    required this.bookings,
    required this.fromPropBooking,
    this.conformBooking,
  });

  @override
  State<HostEreciept> createState() => _HostErecieptState();
}

class _HostErecieptState extends State<HostEreciept> {
  ItemDetails? itemDetails;
  bool exp = false;

  ItemDetailsController vehicleDetailController = Get.find();
  BookingController bookingController = Get.find();
  bool showstatusButton = false;
  bool showConformStatus = false;
  bool showCancelStatus = false;
  DoorStepAddress? doorStepAddressModel;

  @override
  void initState() {
    super.initState();

    if (widget.bookings.itemData != null) {
      if (widget.bookings.itemData.startsWith("[") &&
          widget.bookings.itemData.endsWith("]")) {
        var jsonString = widget.bookings.itemData
            .substring(1, widget.bookings.itemData.length - 1);
        itemDetails = ItemDetails.fromJson(jsonDecode(jsonString));
      } else {
        itemDetails =
            ItemDetails.fromJson(jsonDecode(widget.bookings.itemData));
      }
    }
    if (widget.bookings.doorStepAddress != null &&
        widget.bookings.doorStepAddress!.isNotEmpty) {
      String addressString = widget.bookings.doorStepAddress!.trim();
      if (addressString.startsWith("[") && addressString.endsWith("]")) {
        if (addressString.length > 2) {
          String jsonString =
              addressString.substring(1, addressString.length - 1);
          doorStepAddressModel =
              DoorStepAddress.fromJson(jsonDecode(jsonString));
        } else {
          print("Error: doorStepAddress is an empty array.");
        }
      } else {
        doorStepAddressModel =
            DoorStepAddress.fromJson(jsonDecode(addressString));
      }
    } else {
      print("Error: doorStepAddress is null or empty.");
    }
    setState(() {});
    bookingController.moduleBasedData(bookings: widget.bookings);
  }

  @override
  Widget build(BuildContext context) {
    bool isMatching = isStartDateMatchingCurrentDate(widget.bookings.checkIn);
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          bottomNavigationBar: widget.bookings.userName == null
              ? const SizedBox()
              : widget.conformBooking == "UpComing" &&
                      widget.bookings.status == "Pending" &&
                      showstatusButton == false
                  ? SizedBox(
                      height: 100,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            isMatching == true
                                ? const SizedBox()
                                : Expanded(
                                    child: CustomsButtons(
                                        text: "Cancel",
                                        backgroundColor: redColor,
                                        onPressed: () async {
                                          showLoading();
                                          var response = await httpGet(
                                              Config.getCancelReasons,
                                              {"userType": "host"});
                                          closeLoading();
                                          if (response != null) {
                                            CancellationReasonModel model =
                                                CancellationReasonModel
                                                    .fromJson(response);
                                            await showModalBottomSheet(
                                              showDragHandle: true,
                                              enableDrag: true,
                                              context: context,
                                              builder: (context) {
                                                return CustomBottomSheet(
                                                    model: model);
                                              },
                                            ).then((value) async {
                                              if (value != null) {
                                                showDialog<void>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext contexts) {
                                                    return AlertDialog(
                                                      // title: Text('Are you sure?'.tr,style: TextStyle(color: CustomTheme.theamColor,fontSize: 16, fontFamily: FontStyles.gilroyMedium, fontWeight: FontWeight.w700),),
                                                      content:
                                                          SingleChildScrollView(
                                                        child: ListBody(
                                                          children: <Widget>[
                                                            const Icon(
                                                              Icons.error,
                                                              size: 75,
                                                              color: Colors.red,
                                                            ),
                                                            Text(
                                                              'Do you want to cancel this booking?'
                                                                  .tr
                                                                  .tr,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            // Text('Would you like to approve of this message?'),
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
                                                                          Navigator.pop(
                                                                              contexts);
                                                                        },
                                                                        child: Container(
                                                                            margin: const EdgeInsets.only(left: 8, right: 8),
                                                                            padding: const EdgeInsets.all(10),
                                                                            decoration: BoxDecoration(border: Border.all(), borderRadius: BorderRadius.circular(10)),
                                                                            child: Center(
                                                                                child: Text(
                                                                              "No".tr,
                                                                            ))))),
                                                                Expanded(
                                                                    child: InkWell(
                                                                        onTap: () async {
                                                                          // Navigator.pop(context);
                                                                          showLoading();
                                                                          var resp = await httpPost(
                                                                              Config.cancelBookingByHost,
                                                                              {
                                                                                "booking_id": "${widget.bookings.id}",
                                                                                "cancellation_reasion": "$value"
                                                                              });
                                                                          closeLoading();
                                                                          if (resp['status'] ==
                                                                              200) {
                                                                            showstatusButton =
                                                                                true;
                                                                            showCancelStatus =
                                                                                true;
                                                                            bookingController.updateBookingStatusIfExists(
                                                                              bookingId: widget.bookings.id.toString(),
                                                                              hostId: widget.bookings.hostId.toString(),
                                                                              userId: userId.toString(),
                                                                              newStatus: "Cancelled",
                                                                            );

                                                                            showToastMessage(resp['message']);

                                                                            Navigator.pop(context,
                                                                                "Cancelled");
                                                                            setState(() {});
                                                                          } else {
                                                                            showErrorToastMessage(resp['error']);
                                                                            Navigator.pop(context,
                                                                                "Cancalled");
                                                                          }
                                                                        },
                                                                        child: Container(
                                                                            margin: const EdgeInsets.only(left: 8, right: 8),
                                                                            padding: const EdgeInsets.all(10),
                                                                            decoration: BoxDecoration(border: Border.all(color: themeColor), color: themeColor, borderRadius: BorderRadius.circular(10)),
                                                                            child: Center(
                                                                                child: Text(
                                                                              "Yes".tr,
                                                                              style: const TextStyle(
                                                                                  color: Colors.white,
                                                                                  // fontFamily:
                                                                                  // FontStyles.gilroyMedium,
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
                                            });
                                          }
                                        })),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                                child: CustomsButtons(
                                    text: "Accept",
                                    backgroundColor: yellowColor,
                                    onPressed: () async {
                                      showDialog<void>(
                                        context: context,
                                        builder: (BuildContext contexts) {
                                          return AlertDialog(
                                            // title: Text('Are you sure?'.tr,style: TextStyle(color: CustomTheme.theamColor,fontSize: 16, fontFamily: FontStyles.gilroyMedium, fontWeight: FontWeight.w700),),
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  const Icon(
                                                    Icons.error,
                                                    size: 75,
                                                    color: Colors.red,
                                                  ),
                                                  Text(
                                                    'Do you want to Accept this Order?'
                                                        .tr,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                        // fontFamily: FontStyles
                                                        //     .AirbnbCereal_W_Lt,
                                                        ),
                                                  ),
                                                  // Text('Would you like to approve of this message?'),
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
                                                                Navigator.pop(
                                                                    contexts);
                                                              },
                                                              child: Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8,
                                                                          right:
                                                                              8),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  decoration: BoxDecoration(
                                                                      border: Border
                                                                          .all(),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    "No".tr,
                                                                    style: const TextStyle(
                                                                        // fontFamily:
                                                                        //     FontStyles
                                                                        //         .gilroyMedium,
                                                                        ),
                                                                  ))))),
                                                      Expanded(
                                                          child: InkWell(
                                                              onTap: () async {
                                                                //  Navigator.pop(
                                                                //     context);
                                                                showLoading();
                                                                var resp =
                                                                    await httpPost(
                                                                        Config
                                                                            .confirmBookingByHost,
                                                                        {
                                                                      "booking_id":
                                                                          "${widget.bookings.id}"
                                                                    });
                                                                closeLoading();
                                                                if (resp[
                                                                        'status'] ==
                                                                    200) {
                                                                  bookingController
                                                                      .updateBookingStatusIfExists(
                                                                    bookingId: widget
                                                                        .bookings
                                                                        .id
                                                                        .toString(),
                                                                    hostId: widget
                                                                        .bookings
                                                                        .hostId
                                                                        .toString(),
                                                                    userId: userId
                                                                        .toString(),
                                                                    newStatus:
                                                                        "Confirmed",
                                                                  );
                                                                  showstatusButton =
                                                                      true;
                                                                  showConformStatus =
                                                                      true;

                                                                  showToastMessage(
                                                                      resp[
                                                                          'message']);
                                                                  showstatusButton =
                                                                      true;
                                                                  Navigator.pop(
                                                                      context,
                                                                      "Confirmed");
                                                                  setState(
                                                                      () {});
                                                                } else {
                                                                  showErrorToastMessage(
                                                                      resp[
                                                                          'error']);
                                                                  Navigator.pop(
                                                                      context,
                                                                      "Cancalled");
                                                                }
                                                              },
                                                              child: Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8,
                                                                          right:
                                                                              8),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  decoration:
                                                                      BoxDecoration(
                                                                          border: Border
                                                                              .all(
                                                                            color:
                                                                                getColorBasedOnActiveModuleid(),
                                                                          ),
                                                                          color:
                                                                              getColorBasedOnActiveModuleid(),
                                                                          borderRadius: BorderRadius.circular(
                                                                              10)),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    "Yes".tr,
                                                                    style: const TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold),
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
                                    })),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox(),
          backgroundColor: notifires.getbgcolor,
          appBar: CustomAppBars(
            title: 'Customer Receipt'.tr,
            backgroundColor: notifires.getbgcolor,
            iconColor: notifires.getwhiteblackcolor,
            titleColor: notifires.getwhiteblackcolor,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: erecieptHostBasedOnModuleId(),
            ),
          ),
        ),
      ),
    );
  }

  Widget erecieptHostBasedOnModuleId() {
    List<String> imageUrls = [];
    if (widget.bookings.iteriorImage != null &&
        widget.bookings.iteriorImage is List) {
      try {
        final imageList = widget.bookings.iteriorImage as List;
        imageUrls = imageList
            .map((image) => image['url']?.toString() ?? '')
            .where((url) => url.isNotEmpty)
            .toList();
      } catch (e) {
        print('Error parsing interiorImage: $e');
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          "${"Customer receipt".tr} #${widget.bookings.id}",
          style: heading1(context),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(18),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: notifires.getboxcolor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: notifires.getGrey3Whitecolor.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(5, 5), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Booked Date".tr, style: heading3Grey1(context)),
              const SizedBox(
                height: 7,
              ),
              Text(
                widget.bookings.createdAt!.split(" ")[0],
                style: regular2(context),
              ),
              const SizedBox(
                height: 7,
              ),
              Text("Booked by".tr, style: heading3Grey1(context)),
              const SizedBox(
                height: 7,
              ),
              widget.bookings.userName == null
                  ? Text(
                      "User not Found",
                      style: regular2(context),
                    )
                  : Text(
                      "${widget.bookings.userName}   ",
                      style: regular2(context),
                    ),
              const SizedBox(
                height: 7,
              ),
              Text(
                "Reservation code".tr,
                style: heading3Grey1(context),
              ),
              const SizedBox(
                height: 7,
              ),
              Text(
                "#${widget.bookings.token}",
                style: regular2(context),
              ),
              const SizedBox(
                height: 7,
              ),
              widget.bookings.transaction == ""
                  ? const SizedBox()
                  : Text(
                      "Transaction Id".tr,
                      style: heading3Grey1(context),
                    ),
              widget.bookings.transaction == ""
                  ? const SizedBox()
                  : const SizedBox(
                      height: 7,
                    ),
              widget.bookings.transaction == ""
                  ? const SizedBox()
                  : Text(
                      "#${widget.bookings.transaction}",
                      style: regular2(context),
                    ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            Text(
              "${bookingController.bookingTypeDetail}".tr,
              style: heading2Grey1(context),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(18),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: notifires.getboxcolor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: notifires.getGrey3Whitecolor.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(5, 5), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Vehicle Name",
                style: heading3Grey1(context),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                "${widget.bookings.propTitle}",
                style: regular2(context),
              ),
              const SizedBox(
                height: 5,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.bookings.module == "1"
                      ? Text(
                          itemDetails!.beds == "1" ? "bed" : "beds",
                          style: heading3Grey1(context),
                        )
                      : Text(
                          bookingController.bookingDetailType.toString().tr,
                          style: heading3Grey1(context),
                        ),
                  Text(
                    bookingController.bookingDetailMake.toString().tr,
                    style: heading3Grey1(context),
                  ),
                ],
              ),
              const SizedBox(
                height: 3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.bookings.module == "1"
                      ? Text(
                          "${itemDetails!.beds} ",
                          style: regular2(context),
                        )
                      : Text(
                          "${bookingController.vehicleType}",
                          style: regular2(context),
                        ),
                  widget.bookings.module == "1"
                      ? Text("${widget.bookings.totalGuest}",
                          style: regular2(context))
                      : Text("${bookingController.vehicleModel}",
                          style: regular2(context)),
                ],
              ),
              const SizedBox(
                height: 3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${bookingController.bookingType}".tr,
                    style: heading3Grey1(context),
                  ),
                  widget.bookings.module == "1"
                      ? const SizedBox()
                      : Text(
                          "Make".tr,
                          style: heading3Grey1(context),
                        ),
                ],
              ),
              const SizedBox(
                height: 3,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  widget.bookings.module == "1"
                      ? Text(
                          "${itemDetails!.itemType}",
                          style: regular2(context),
                        )
                      : Text(
                          "${bookingController.vehicleYear}",
                          style: regular2(context),
                        ),
                  widget.bookings.module == "1"
                      ? const SizedBox()
                      : Text(
                          "${bookingController.vehicleMake}",
                          style: regular2(context),
                        )
                ],
              ),
              const SizedBox(
                height: 3,
              ),
              widget.bookings.module == "1"
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Transmission".tr,
                          style: heading3Grey1(context),
                        ),
                        Text(
                          "Odometer".tr,
                          style: heading3Grey1(context),
                        ),
                      ],
                    ),
              const SizedBox(
                height: 3,
              ),
              widget.bookings.module == "1"
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${bookingController.vehicleTransmission}",
                          style: regular2(context),
                        ),
                        Text(
                          "${bookingController.vehicleOdometer}",
                          style: regular2(context),
                        ),
                      ],
                    ),
              const SizedBox(
                height: 3,
              ),
              Text(
                "Location".tr,
                style: heading3Grey1(context),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                bookingController.address.toString(),
                style: regular2(context),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        widget.bookings.userName == null
            ? Text(
                "User Not Found".tr,
                style: heading2Grey1(context),
              )
            : Text(
                "User Details".tr,
                style: heading2Grey1(context),
              ),
        const SizedBox(
          height: 10,
        ),
        widget.bookings.userName == null
            ? Container()
            : Container(
                padding: const EdgeInsets.all(18),
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: notifires.getboxcolor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: notifires.getGrey3Whitecolor.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(5, 5), // changes position of shadow
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Name".tr,
                          style: heading3Grey1(context),
                        ),
                        Text(
                          "Phone".tr,
                          style: heading3Grey1(context),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${widget.bookings.userName}",
                          style: regular2(context),
                        ),
                        Text(
                          "${widget.bookings.userPhoneCountry} ${widget.bookings.userNumber}",
                          style: regular2(context),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text("Email".tr, style: heading3Grey1(context)),
                    const SizedBox(
                      height: 3,
                    ),
                    Row(
                      children: [
                        Text(
                          widget.bookings.userEmail.toString(),
                          style: regular2(context),
                        ),
                        const Spacer(),
                        doorStepAddressModel == null
                            ? const SizedBox()
                            : InkWell(
                                onTap: () async {
                                  if (doorStepAddressModel != null &&
                                      doorStepAddressModel!.doorstepLatitude !=
                                          null &&
                                      doorStepAddressModel!.doorstepLongitude !=
                                          null) {
                                    dynamic latitude =
                                        doorStepAddressModel!.doorstepLatitude;
                                    dynamic longitude =
                                        doorStepAddressModel!.doorstepLongitude;

                                    String url = "";

                                    if (Platform.isIOS) {
                                      url =
                                          "https://maps.apple.com/?q=$latitude,$longitude";
                                    } else {
                                      url =
                                          "https://www.google.com/maps/search/?api=1&query=$latitude,$longitude";
                                    }

                                    if (await canLaunchUrl(Uri.parse(url))) {
                                      await launchUrl(Uri.parse(url));
                                    } else {
                                      showErrorToastMessage(
                                          "Could not open the map");
                                    }
                                  } else {
                                    showErrorToastMessage("Location not found");
                                  }
                                },
                                child: Container(
                                  height: 25,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    color:
                                        getColorBasedOnActiveModuleid(), // Dynamic color
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.map,
                                        size: 15,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        "View on Map",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                      ],
                    ),
                    doorStepAddressModel == null
                        ? const SizedBox()
                        : Row(
                            children: [
                              Text("DoorStep Address :".tr,
                                  style: heading3Grey1(context)),
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Text(
                                  "${doorStepAddressModel!.houseFloorNumber}${doorStepAddressModel!.buildingBlockNumber} ${doorStepAddressModel!.fullAddress}",
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: regular2(context),
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
        Text(
          "Trip Details".tr,
          style: heading2Grey1(context),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          padding: const EdgeInsets.all(18),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: notifires.getboxcolor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: notifires.getGrey3Whitecolor.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${bookingController.bookingDateStart}".tr,
                        style: heading3Grey1(context),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                        "${DateTimeFormatter.to24HourFormat(widget.bookings.checkIn)}",
                        style: regular2(context),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${bookingController.bookingDateEnd}".tr,
                        style: heading3Grey1(context),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Text(
                   "${DateTimeFormatter.to24HourFormat(widget.bookings.checkOut)}",
                        style: regular2(context),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              Text("Duration".tr, style: heading3Grey1(context)),
              const SizedBox(
                height: 5,
              ),
              Text(
                widget.bookings.totalNight == "1"
                    ? "${widget.bookings.totalNight} ${"day".tr}"
                    : "${widget.bookings.totalNight} ${"days".tr}",
                style: regular2(context),
              ),
              const SizedBox(
                height: 3,
              ),
              Row(
                children: [
                  Text(
                    "Country :".tr,
                    style: heading3Grey1(context),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    "${loginModel!.data!.defaultCountry ?? ""} ",
                    style: regular2(context),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Text("Billing".tr, style: heading2Grey1(context)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: notifires.getboxcolor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: notifires.getGrey3Whitecolor.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              widget.bookings.perNight != null &&
                      widget.bookings.perNight != "0.00"
                  ? eReceiptWidget(
                      name: widget.bookings.totalNight == "1"
                          ? "${"Amount".tr} (${widget.bookings.totalNight} ${"day".tr}${")".tr}"
                          : "${"Amount".tr} (${widget.bookings.totalNight} ${"days".tr}${")".tr}",
                      value:
                          "${widget.bookings.currencyCode} ${widget.bookings.basePrice ?? ""}",
                    )
                  : const SizedBox(),
              const SizedBox(height: 5),
              widget.bookings.doorStepPrice != null &&
                      widget.bookings.doorStepPrice != "0.00"
                  ? eReceiptWidget(
                      name: "Doorstep Price".tr,
                      value:
                          "${widget.bookings.currencyCode} ${widget.bookings.doorStepPrice ?? ""}",
                    )
                  : const SizedBox(),
              const SizedBox(height: 5),
              widget.bookings.ivaTax != null && widget.bookings.ivaTax != "0.00"
                  ? eReceiptWidget(
                      name: "Tax".tr,
                      value:
                          "${widget.bookings.currencyCode} ${widget.bookings.ivaTax}",
                    )
                  : const SizedBox(),
              const SizedBox(height: 5),
              widget.bookings.serviceCharge != null &&
                      widget.bookings.serviceCharge != "0.00"
                  ? eReceiptWidget(
                      name: "Service Charge".tr,
                      value:
                          "${widget.bookings.currencyCode} ${widget.bookings.serviceCharge}",
                    )
                  : const SizedBox(),
              const SizedBox(height: 5),
              widget.bookings.securityMoney != null &&
                      widget.bookings.securityMoney != "0.00"
                  ? eReceiptWidget(
                      name: "Security Money".tr,
                      value:
                          "${widget.bookings.currencyCode} ${widget.bookings.securityMoney}",
                    )
                  : const SizedBox(),
              const SizedBox(height: 5),
              widget.bookings.cancelledCharge == null ||
                      widget.bookings.cancelledCharge == "0.00"
                  ? const SizedBox()
                  : eReceiptWidget(
                      name: "Cancelled Charge".tr,
                      value:
                          "${widget.bookings.currencyCode} ${widget.bookings.cancelledCharge}",
                    ),
              const SizedBox(height: 5),
              eReceiptWidget(
                name: "Total".tr,
                value:
                    "${widget.bookings.currencyCode} ${widget.bookings.total}",
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text("Status".tr, style: heading2Grey1(context)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          width: double.maxFinite,
          decoration: BoxDecoration(
            color: notifires.getboxcolor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: notifires.getGrey3Whitecolor.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(5, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Payment Status".tr, style: heading3Grey1(context)),
                  Text(
                    "${widget.bookings.paymentStatus.toString() == "paid" ? "Paid" : widget.bookings.paymentStatus}"
                        .tr,
                    style: regular2(context)
                        .copyWith(fontSize: 16, color: themeColor),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Booking Status".tr, style: heading3Grey1(context)),
                  Text(
                    "${widget.bookings.status}".tr,
                    style: regular2(context)
                        .copyWith(fontSize: 16, color: themeColor),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Payment Method".tr, style: heading3Grey1(context)),
                  Text(
                    "${widget.bookings.paymentMethod}".tr,
                    style: regular2(context)
                        .copyWith(fontSize: 16, color: themeColor),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        imageUrls.isEmpty
            ? SizedBox()
            :
            // Add Vehicle Images section
            Text("Vehicle Interior Images".tr, style: heading2Grey1(context)),
        const SizedBox(height: 10),
        imageUrls.isEmpty
            ? SizedBox()
            : Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: notifires.getboxcolor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: notifires.getGrey3Whitecolor.withOpacity(0.2),
                      spreadRadius: 5,
                      blurRadius: 15,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: FullScreenImageView(
                  imagesList: imageUrls.isNotEmpty ? imageUrls : [],
                ),
              ),
        const SizedBox(height: 100),
      ],
    );
  }
}
