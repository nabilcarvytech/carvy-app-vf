import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/full_screen_image_view.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/model/door_step_address_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../../controller/booking_controller.dart';
import '../../controller/items_detail_controller.dart';
import '../../model/booking_model.dart';
import '../../model/item_details_model.dart';
import '../../utils/vehicle_common_widgets.dart';
import '../../work_space.dart';

class EReceiptScreen extends StatefulWidget {
  final Bookings? bookings;
  final bool? fromPropBooking;
  final String? doorStepPrice;
  const EReceiptScreen(
      {super.key, this.bookings, this.fromPropBooking, this.doorStepPrice});

  @override
  State<EReceiptScreen> createState() => _EReceiptScreenState();
}

class _EReceiptScreenState extends State<EReceiptScreen> {
  ItemDetails? itemDetails;
  bool exp = false;
  DoorStepAddress? doorStepAddressModel;
  ItemDetailsController vehicleDetailController = Get.find();
  BookingController bookingController = Get.find();

  @override
  void initState() {
    super.initState();

    if (widget.bookings!.itemData != null) {
      try {
        if (widget.bookings!.itemData.startsWith("[") &&
            widget.bookings!.itemData.endsWith("]")) {
          var jsonString = widget.bookings!.itemData
              .substring(1, widget.bookings!.itemData.length - 1);

          itemDetails = ItemDetails.fromJson(jsonDecode(jsonString));
        } else {
          itemDetails =
              ItemDetails.fromJson(jsonDecode(widget.bookings!.itemData));
        }
      } catch (e) {
        print("Error parsing itemData: $e");
        print("itemData content: ${widget.bookings!.itemData}");
        // Set itemDetails to null if parsing fails to avoid crashes
        itemDetails = null;
      }
    }
    if (widget.bookings!.doorStepAddress != null &&
        widget.bookings!.doorStepAddress!.isNotEmpty) {
      String addressString = widget.bookings!.doorStepAddress!.trim();

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
        // Decode JSON directly
        doorStepAddressModel =
            DoorStepAddress.fromJson(jsonDecode(addressString));
      }
    } else {
      print("Error: doorStepAddress is null or empty.");
    }
    print(widget.bookings!.status);
    setState(() {});
    bookingController.moduleBasedData(bookings: widget.bookings!);
    print(widget.bookings!.iteriorImage);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) return;
            Get.back();
          },
          child: Scaffold(
            backgroundColor: notifires.getbgcolor,
            appBar: CustomAppBars(
              title: 'Customer Receipt'.tr,
              backgroundColor: notifires.getbgcolor,
              iconColor: notifires.getwhiteblackcolor,
              titleColor: notifires.getwhiteblackcolor,
              elevation: 0,
              onBackButtonPressed: () => Get.back(),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: erecieptBasedOnModuleId(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String formatBookedDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      DateTime parsedDate = DateTime.parse(rawDate).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(parsedDate);
    } catch (e) {
      return rawDate;
    }
  }

  /// Valeur non vide et différente de la chaîne littérale "null".
  String? _nonEmptyId(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') return null;
    return trimmed;
  }

  String _prefixedIdOrPending(String? value) {
    final id = _nonEmptyId(value);
    return id != null ? '#$id' : 'Pending'.tr;
  }

  String get _reservationCodeDisplay => formatBookingReservationCode(
        token: widget.bookings?.token,
        id: widget.bookings?.id,
      );

  String get _transactionIdDisplay {
    final tx = widget.bookings?.transaction;
    final asString = tx == null ? null : tx.toString();
    return _prefixedIdOrPending(asString);
  }

  DateTime? _parseBookingDateOnly(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      final d = DateTime.parse(raw.trim());
      return DateTime(d.year, d.month, d.day);
    } catch (_) {
      try {
        final d = DateFormat('yyyy-MM-dd').parse(raw.trim());
        return DateTime(d.year, d.month, d.day);
      } catch (_) {
        return null;
      }
    }
  }

  /// Durée en jours calculée depuis check-in / check-out (min. 1 jour).
  int get _calculatedTripDays {
    final start = _parseBookingDateOnly(widget.bookings?.checkIn);
    final end = _parseBookingDateOnly(widget.bookings?.checkOut);
    if (start != null && end != null) {
      final calculatedDays = end.difference(start).inDays;
      return calculatedDays > 0 ? calculatedDays : 1;
    }
    final fromApi = int.tryParse(widget.bookings?.totalNight?.trim() ?? '');
    if (fromApi != null && fromApi > 0) return fromApi;
    return 1;
  }

  String get _tripDurationLabel {
    final days = _calculatedTripDays;
    return days == 1 ? '$days ${"day".tr}' : '$days ${"days".tr}';
  }

  Widget erecieptBasedOnModuleId() {
    if (activeModuleId.value == 1 || activeModuleId.value == 2) {
      // Construction robuste de la liste d’URLs d’images à partir de booking_vehicle_images
      List<String> imageUrls = [];
      final dynamic rawImages = widget.bookings!.iteriorImage;

      if (rawImages != null) {
        try {
          if (rawImages is List) {
            imageUrls = rawImages
                .map<String>((image) {
                  if (image == null) return '';

                  // Cas 1 : liste de Strings
                  if (image is String) {
                    return Config.getFullImageUrl(image);
                  }

                  // Cas 2 : liste de Maps { url: "...", path: "..." }
                  if (image is Map<String, dynamic>) {
                    final rawUrl = image['url']?.toString() ??
                        image['path']?.toString() ??
                        '';
                    return Config.getFullImageUrl(rawUrl);
                  }

                  // Fallback : toString
                  return Config.getFullImageUrl(image.toString());
                })
                .where((url) => url.isNotEmpty)
                .toList();
          } else if (rawImages is String && rawImages.isNotEmpty) {
            // Cas où le backend renvoie une seule image sous forme de String
            imageUrls = [Config.getFullImageUrl(rawImages)];
          }
        } catch (e) {
          print('❌ Error parsing booking_vehicle_images: $e');
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'receipt_title'.tr,
              style: heading1(context).copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 7),
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
                Text('booked_date'.tr, style: heading3Grey1(context)),
                const SizedBox(
                  height: 7,
                ),
                Text(
                  formatBookedDate(widget.bookings!.createdAt),
                  style: regular2(context),
                ),
                const SizedBox(height: 7),
                Text("Booked by".tr, style: heading3Grey1(context)),
                const SizedBox(height: 7),
                Text(
                  "${loginModel!.data!.firstName!} ${loginModel!.data!.lastName!}",
                  style: regular2(context),
                ),
                const SizedBox(height: 7),
                Text("Reservation code".tr, style: heading3Grey1(context)),
                const SizedBox(height: 7),
                Text(_reservationCodeDisplay, style: regular2(context)),
                const SizedBox(height: 10),
                Text("Transaction Id".tr, style: heading3Grey1(context)),
                const SizedBox(height: 7),
                Text(_transactionIdDisplay, style: regular2(context)),
                const SizedBox(height: 10),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text("${bookingController.bookingTypeDetail}".tr,
                  style: heading2Grey1(context)),
            ],
          ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'vehicle_name'.tr,
                  style: heading3Grey1(context),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text("${widget.bookings!.propTitle}", style: regular2(context)),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.bookings!.module == "1"
                        ? Text(itemDetails?.beds == "1" ? "bed" : "beds",
                            style: heading3Grey1(context))
                        : Text(
                            bookingController.bookingDetailType.toString().tr,
                            style: heading3Grey1(context)),
                    Text(bookingController.bookingDetailMake.toString().tr,
                        style: heading3Grey1(context)),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.bookings!.module == "1"
                        ? Text("${itemDetails?.beds ?? ""}", style: regular2(context))
                        : Text("${bookingController.vehicleType}",
                            style: regular2(context)),
                    widget.bookings!.module == "1"
                        ? Text("${widget.bookings!.totalGuest}",
                            style: regular2(context))
                        : Text("${bookingController.vehicleModel}",
                            style: regular2(context)),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${bookingController.bookingType}".tr,
                        style: heading3Grey1(context)),
                    widget.bookings!.module == "1"
                        ? const SizedBox()
                        : Text("Make".tr, style: heading3Grey1(context)),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    widget.bookings!.module == "1"
                        ? Text("${itemDetails?.itemType ?? ""}".tr,
                            style: regular2(context))
                        : Text("${bookingController.vehicleYear}",
                            style: regular2(context)),
                    widget.bookings!.module == "1"
                        ? const SizedBox()
                        : Text("${bookingController.vehicleMake}",
                            style: regular2(context)),
                  ],
                ),
                const SizedBox(height: 3),
                widget.bookings!.module == "1"
                    ? const SizedBox()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Transmission".tr,
                              style: heading3Grey1(context)),
                          Text("Odometer".tr, style: heading3Grey1(context)),
                        ],
                      ),
                const SizedBox(height: 3),
                widget.bookings!.module == "1"
                    ? const SizedBox()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              translateBookingVehicleSpec(
                                  bookingController.vehicleTransmission),
                              style: regular2(context)),
                          Text("${bookingController.vehicleOdometer}",
                              style: regular2(context)),
                        ],
                      ),
                const SizedBox(height: 3),
                Text("Location".tr, style: heading3Grey1(context)),
                const SizedBox(height: 5),
                Text(bookingController.address.toString(),
                    style: regular2(context)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text("Owner Details".tr, style: heading2Grey1(context)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Name".tr, style: heading3Grey1(context)),
                    Text("Phone".tr, style: heading3Grey1(context)),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("${widget.bookings!.hostName}",
                        style: regular2(context)),
                    GestureDetector(
                      onTap: () async {
                        final phone = widget.bookings!.hostNumber?.toString();
                        if (phone != null && phone.isNotEmpty) {
                          final uri = Uri.parse('tel:$phone');
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri);
                          }
                        }
                      },
                      child: Text(
                        "${widget.bookings!.hostNumber}",
                        style: regular2(context).copyWith(
                          color: notifires.getwhiteblackcolor,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text("Email".tr, style: heading3Grey1(context)),
                const SizedBox(height: 3),
                GestureDetector(
                  onTap: () async {
                    final email = widget.bookings!.hostEmail?.toString();
                    if (email != null && email.isNotEmpty) {
                      final uri = Uri.parse('mailto:$email');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    }
                  },
                  child: Text(
                    widget.bookings!.hostEmail.toString(),
                    style: regular2(context).copyWith(
                      color: notifires.getwhiteblackcolor,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                if ((widget.bookings!.hostAddress ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text("Address".tr, style: heading3Grey1(context)),
                  const SizedBox(height: 3),
                  Text(
                    widget.bookings!.hostAddress.toString(),
                    style: regular2(context),
                  ),
                ],
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final lat = widget.bookings!.hostLat;
                    final lng = widget.bookings!.hostLng;
                    final hasCoords = lat != null && lng != null;
                    if (!hasCoords) return const SizedBox.shrink();
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final url = 'https://www.google.com/maps/search/?api=1&query=${lat},${lng}';
                          final uri = Uri.parse(url);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.directions_car),
                        label: Text('View itinerary'.tr),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text("Trip Details".tr, style: heading2Grey1(context)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${bookingController.bookingDateStart}".tr,
                            style: heading3Grey1(context)),
                        const SizedBox(height: 5),
                        Text("${DateTimeFormatter.to24HourFormat(widget.bookings!.checkIn)}",
                            style: regular2(context)),
                        const SizedBox(height: 5),
                        widget.bookings!.module == "1"
                            ? const SizedBox()
                            : Text("${TimeFormatter.to24Hour(widget.bookings!.startTime)}",
                                style: regular2(context)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${bookingController.bookingDateEnd}".tr,
                            style: heading3Grey1(context)),
                        const SizedBox(height: 5),
                        Text("${DateTimeFormatter.to24HourFormat(widget.bookings!.checkOut)}",
                            style: regular2(context)),
                        const SizedBox(height: 5),
                        widget.bookings!.module == "1"
                            ? const SizedBox()
                            : Text("${TimeFormatter.to24Hour(widget.bookings!.endTime)}",
                                style: regular2(context)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text("Duration".tr, style: heading3Grey1(context)),
                const SizedBox(height: 3),
                Text(
                  _tripDurationLabel,
                  style: regular2(context),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text("Renter info".tr, style: heading2Grey1(context)),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text("Name :".tr, style: heading3Grey1(context)),
                    const SizedBox(width: 5),
                    Text(
                      "${loginModel!.data!.firstName!} ${loginModel!.data!.lastName!}",
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: getColorBasedOnActiveModuleid(),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.map,
                                      size: 15, color: Colors.white),
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
                          ),
                  ],
                ),
                const SizedBox(height: 3),
                doorStepAddressModel == null
                    ? const SizedBox()
                    : Row(
                        children: [
                          Text("DoorStep Address :".tr,
                              style: heading3Grey1(context)),
                          const SizedBox(width: 5),
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
                const SizedBox(height: 12),
              ],
            ),
          ),
          const SizedBox(height: 10),
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
                widget.bookings?.perNight != null &&
                        widget.bookings!.perNight != "0.00"
                    ? eReceiptWidget(
                        name: _calculatedTripDays == 1
                            ? "${"Amount".tr} ($_calculatedTripDays ${"day".tr}${")".tr}"
                            : "${"Amount".tr} ($_calculatedTripDays ${"days".tr}${")".tr}",
                        value:
                            "${widget.bookings!.currencyCode} ${widget.bookings?.basePrice ?? ""}",
                      )
                    : const SizedBox(),
                const SizedBox(height: 5),
                widget.bookings?.doorStepPrice != null &&
                        widget.bookings!.doorStepPrice != "0.00"
                    ? eReceiptWidget(
                        name: "Doorstep Price".tr,
                        value:
                            "${widget.bookings!.currencyCode} ${widget.bookings?.doorStepPrice ?? ""}",
                      )
                    : const SizedBox(),
                const SizedBox(height: 5),
                widget.bookings?.ivaTax != null &&
                        widget.bookings!.ivaTax != "0.00"
                    ? eReceiptWidget(
                        name: "Tax".tr,
                        value:
                            "${widget.bookings!.currencyCode} ${widget.bookings!.ivaTax}",
                      )
                    : const SizedBox(),
                const SizedBox(height: 5),
                widget.bookings?.serviceCharge != null &&
                        widget.bookings!.serviceCharge != "0.00"
                    ? eReceiptWidget(
                        name: "Service Charge".tr,
                        value:
                            "${widget.bookings!.currencyCode} ${widget.bookings!.serviceCharge}",
                      )
                    : const SizedBox(),
                const SizedBox(height: 5),
                widget.bookings!.cancelledCharge == null ||
                        widget.bookings!.cancelledCharge == "0.00"
                    ? const SizedBox()
                    : eReceiptWidget(
                        name: "Cancelled Charge".tr,
                        value:
                            "${widget.bookings!.currencyCode} ${widget.bookings!.cancelledCharge}",
                      ),
                const SizedBox(height: 5),
                eReceiptWidget(
                  name: "Total".tr,
                  value:
                      "${widget.bookings!.currencyCode} ${widget.bookings!.total}",
                ),
              ],
            ),
          ),
          _buildSecurityDepositSection(context),
          const SizedBox(height: 10),
          Text('status_title'.tr, style: heading2Grey1(context)),
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
                      paymentStatusLabel(
                          widget.bookings!.paymentStatus?.toString()),
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
                      bookingStatusLabel(widget.bookings!.status),
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
                      paymentMethodLabel(
                          widget.bookings!.paymentMethod?.toString()),
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
    return const SizedBox();
  }

  bool get _hasSecurityDeposit {
    final amount = widget.bookings?.securityMoney;
    return amount != null && amount.isNotEmpty && amount != "0.00";
  }

  BoxDecoration _receiptCardDecoration() {
    return BoxDecoration(
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
    );
  }

  Widget _buildSecurityDepositSection(BuildContext context) {
    if (!_hasSecurityDeposit) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text("Security Deposit (Caution)".tr, style: heading2Grey1(context)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(18),
          width: double.maxFinite,
          decoration: _receiptCardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.bookings!.currencyCode} ${widget.bookings!.securityMoney}",
                style: heading1(context).copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 28,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                      size: 22,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "receipt_security_deposit_on_site_info".tr,
                        style: regular2(context).copyWith(
                          fontSize: 13,
                          color: Colors.blue.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
