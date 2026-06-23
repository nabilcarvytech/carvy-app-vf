
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
import 'package:intl/intl.dart' hide TextDirection;
import 'package:permission_handler/permission_handler.dart';
import 'package:pinput/pinput.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/booking_record_controller.dart';
import 'package:carvy/controller/home_controller.dart';
import 'package:carvy/controller/push_notifications.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/rolling_calendar_bounds.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/utils/vehicle_common_widgets.dart';
import 'package:carvy/model/extension_payment_context.dart';
import 'package:carvy/view/booking/payment_method_screen.dart';
import 'package:carvy/view/booking/vehicle/vehicle_booking_summary_screen.dart';
import 'package:carvy/view/booking/vehicle_photoes_booking.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/digitalsignatuecommon/digital_singnature.dart';
import 'package:carvy/view/review/review_popup_widget.dart';
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
import '../helper/cancellation_policy_helper.dart';
import '../helper/city_name_helper.dart';
import '../helper/http_service.dart';
import '../helper/vehicle_card_helper.dart';
import '../model/booking_model.dart';
import '../model/cancellation_reason_model.dart';
import '../model/vehicle_home_model.dart';
import '../view/auth/login_screen.dart';
import '../view/booking/e_reciept.dart';
import '../view/chat/conversation_screen.dart';
import '../view/itemdetail/vehicle/vehicle_detail_screen.dart';
import '../view/wishlist/wish_list_screen.dart';
import 'extension.dart';

import '../work_space.dart';

/// Extrait un ObjectId Mongo de conversation depuis le JSON booking si le backend le fournit.
String mongoChatIdFromBooking(Bookings b) {
  try {
    final map = b.toJson();
    for (final key in <String>[
      'mongoId',
      'conversationMongoId',
      'chatMongoId',
      'chat_mongo_id',
      'conversation_mongo_id',
    ]) {
      final v = map[key]?.toString().trim() ?? '';
      if (RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(v)) return v;
    }
    final cid = map['conversation_id']?.toString().trim() ??
        map['conversationId']?.toString().trim() ??
        '';
    if (RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(cid)) return cid;
    for (final nestedKey in ['conversation', 'chat']) {
      final nested = map[nestedKey];
      if (nested is Map) {
        final v = nested['_id']?.toString().trim() ?? '';
        if (RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(v)) return v;
      }
    }
  } catch (_) {}
  return '';
}

class BookingStatusDetails {
  final String label;
  final Color color;
  final IconData icon;

  const BookingStatusDetails({
    required this.label,
    required this.color,
    required this.icon,
  });
}

/// Ouvre Google Maps (Android) ou Apple Maps (iOS) vers les coordonnées de l’agence.
Future<void> launchBookingAgencyDirections({
  required double? latitude,
  required double? longitude,
}) async {
  if (latitude == null || longitude == null) {
    showErrorToastMessage('Location not found'.tr);
    return;
  }
  final lat = latitude.toString();
  final lng = longitude.toString();
  final Uri uri = Platform.isIOS
      ? Uri.parse('https://maps.apple.com/?daddr=$lat,$lng')
      : Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
        );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    showErrorToastMessage('Could not open the map'.tr);
  }
}

/// Affiche « Voir l’itinéraire » pour les réservations confirmées ou en cours (hors terminées / annulées).
bool shouldShowBookingAgencyDirections({
  required String? bookingStatus,
  required String listType,
}) {
  if (listType == 'Cancelled' || listType == 'Previous') return false;
  final s = bookingStatus?.trim().toUpperCase() ?? '';
  if (s.isEmpty) return false;
  if (s == 'CONFIRMED' ||
      s == 'CONFIRMÉE' ||
      s == 'CONFIRMEE') {
    return true;
  }
  if (s == 'LIVE' ||
      s == 'ONGOING' ||
      s == 'EN DIRECT' ||
      s == 'EN_DIRECT') {
    return true;
  }
  return false;
}

/// Clé GetX pour le libellé de statut réservation (évite le texte brut API).
String bookingStatusTranslationKey(String? status) {
  switch (status.toStandardStatus()) {
    case 'CONFIRMED':
      return 'status_confirmed';
    case 'PENDING':
      return 'status_pending';
    case 'CANCELLED':
      return 'status_cancelled';
    case 'COMPLETED':
      return 'status_completed';
    case 'DECLINED':
      return 'status_cancelled';
    case 'LIVE':
    case 'ONGOING':
      return 'status_confirmed';
    default:
      final raw = status?.trim().toLowerCase() ?? '';
      if (raw.isEmpty || raw == 'null') return 'status_pending';
      return 'status_$raw';
  }
}

String bookingStatusLabel(String? status) =>
    bookingStatusTranslationKey(status).tr;

/// Code réservation court : token / référence API, sinon 8 derniers caractères de l’id.
String formatBookingReservationCode({String? token, String? id}) {
  String? raw;
  final t = token?.trim();
  if (t != null && t.isNotEmpty && t.toLowerCase() != 'null') {
    raw = t;
  } else {
    final i = id?.trim();
    if (i != null && i.isNotEmpty && i.toLowerCase() != 'null') raw = i;
  }
  if (raw == null) return 'Pending'.tr;
  final upper = raw.toUpperCase();
  if (upper.length <= 10) return '#$upper';
  final start = upper.length > 8 ? upper.length - 8 : 0;
  return '#${upper.substring(start)}';
}

String paymentStatusLabel(String? paymentStatus) {
  final s = paymentStatus?.trim().toLowerCase() ?? '';
  if (s.isEmpty || s == 'null') return 'status_pending'.tr;
  if (s == 'paid') return 'paid'.tr;
  return 'status_$s'.tr;
}

String paymentMethodLabel(String? method) {
  final s = method?.trim().toLowerCase() ?? '';
  if (s.isEmpty || s == 'null') return '';
  const aliases = <String, String>{
    'cash': 'cash_payment',
    'espece': 'cash_payment',
    'espèce': 'cash_payment',
    'espèces': 'cash_payment',
    'especes': 'cash_payment',
  };
  final key = aliases[s] ?? 'payment_method_$s';
  final translated = key.tr;
  if (translated == key && method != null) return method;
  return translated;
}

/// Indicatif + numéro sans afficher la chaîne « null ».
String formatBookingPhoneDisplay(String? countryCode, String? phone) {
  final cc = countryCode?.trim();
  final validCc =
      cc != null && cc.isNotEmpty && cc.toLowerCase() != 'null';
  final num = phone?.trim();
  final validNum =
      num != null && num.isNotEmpty && num.toLowerCase() != 'null';
  if (!validCc && !validNum) return '';
  if (validCc && validNum) return '$cc $num';
  return validNum ? num! : cc!;
}

String bookingPhoneTelUri(String? countryCode, String? phone) {
  final cc = countryCode?.trim();
  final validCc =
      cc != null && cc.isNotEmpty && cc.toLowerCase() != 'null' ? cc : '';
  final num = phone?.trim();
  final validNum =
      num != null && num.isNotEmpty && num.toLowerCase() != 'null' ? num : '';
  return 'tel:$validCc$validNum';
}

String formatBookingCardPriceLine({
  required String? currencyCode,
  required String? total,
  required String? totalNight,
}) {
  final currency = currencyCode?.trim() ?? '';
  final amount = total?.trim() ?? '';
  final nights = totalNight?.trim() ?? '';
  final validNights =
      nights.isNotEmpty && nights.toLowerCase() != 'null';
  if (!validNights) {
    return '$currency $amount'.trim();
  }
  return '$currency $amount ${'for_x_days'.trParams({'count': nights})}'
      .trim();
}

/// Carburant (carte réservation, etc.) : clé API en minuscules → .tr.
String translateBookingFuelType(dynamic fuelType) {
  final s = fuelType?.toString().trim().toLowerCase() ?? '';
  if (s.isEmpty || s == 'null') return '';
  const aliases = <String, String>{
    'gas': 'gasoline',
    'essence': 'petrol',
    'hybride': 'hybrid',
    'electrique': 'electric',
    'électrique': 'electric',
  };
  return (aliases[s] ?? s).tr;
}

/// Transmission : normalise la valeur API puis .tr.
String translateBookingVehicleSpec(String? value) {
  final s = value?.trim().toLowerCase() ?? '';
  if (s.isEmpty || s == 'null') return '';
  const aliases = <String, String>{
    'manual': 'manuelle',
    'manu': 'manuelle',
    'automatic': 'automatique',
    'auto': 'automatique',
  };
  return (aliases[s] ?? s).tr;
}

BookingStatusDetails getBookingStatusDetails(String? status) {
  switch (status.toStandardStatus()) {
    case 'CONFIRMED':
      return BookingStatusDetails(
        label: bookingStatusLabel(status),
        color: greensColor,
        icon: Icons.check_circle_outline,
      );
    case 'PENDING':
      return BookingStatusDetails(
        label: bookingStatusLabel(status),
        color: orangeColor,
        icon: Icons.schedule,
      );
    case 'CANCELLED':
      return BookingStatusDetails(
        label: bookingStatusLabel(status),
        color: redColor,
        icon: Icons.close,
      );
    case 'COMPLETED':
      return BookingStatusDetails(
        label: bookingStatusLabel(status),
        color: greensColor,
        icon: Icons.check_circle,
      );
    default:
      return BookingStatusDetails(
        label: bookingStatusLabel(status),
        color: greyColor,
        icon: Icons.info_outline,
      );
  }
}

// --- GLOBAL FUNCTIONS ---
Widget commonlyUserlogoAlert() {
  return Center(
    child: ClipOval(
        child: Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: getColorBasedOnActiveModuleid()),
      child: Image.asset('assets/images/small-app-logo.jpg', fit: BoxFit.fill),
    )),
  );
}

Widget commonlyUserlogo() {
  return ClipOval(
    child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(color: getColorBasedOnActiveModuleid()),
        child: Image.asset('assets/images/app-logo-car.jpg', fit: BoxFit.fill)),
  );
}

class CommonWidgets {
  // FONCTION STATIQUE POUR OUVRIR LA MODALE OTP
  // FONCTION STATIQUE POUR OUVRIR LA MODALE OTP
  static void showOtpBottomSheet(BuildContext context, String bookingId) {
    print('📌 [UI] Tentative d\'affichage de la modale OTP maintenant');
    final BookingController bookingController = Get.find<BookingController>();

    showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Container(
            color: Colors.white,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Enter OTP'.tr,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please enter the 4-digit code to validate the vehicle reception.'.tr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),
                Pinput(
                  length: 4,
                  controller: bookingController.otpController,
                  defaultPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      color: Color.fromRGBO(30, 60, 87, 1),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                  ),
                  focusedPinTheme: PinTheme(
                    width: 56,
                    height: 56,
                    textStyle: const TextStyle(
                      fontSize: 22,
                      color: Color.fromRGBO(30, 60, 87, 1),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(19),
                      border: Border.all(color: themeColor),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (bookingController.otpController.text.length == 4) {
                        Navigator.pop(context); // Fermer la modale avant l'appel API
                        bookingController.updateItemReceivedStatus(
                          bookingId: bookingId,
                          otp: bookingController.otpController.text,
                        );
                      } else {
                        Get.snackbar(
                          "Error",
                          "Please enter a valid 4-digit OTP",
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Valider'.tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget commonlyUserlogoAlert() {
    return Center(
      child: ClipOval(
          child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(color: getColorBasedOnActiveModuleid()),
        child: Image.asset('assets/images/small-app-logo.jpg', fit: BoxFit.fill),
      )),
    );
  }

  static Widget commonlyUserlogo() {
    return ClipOval(
      child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(color: getColorBasedOnActiveModuleid()),
          child: Image.asset('assets/images/app-logo-car.jpg', fit: BoxFit.fill)),
    );
  }
}

Widget splashLogo() {
  try {
    return Image.asset(
      'assets/images/spl-logo.png',
      width: 300,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('⚠️ [SPLASH] Erreur lors du chargement de l\'image: $error');
        // Retourner un widget de fallback si l'image ne peut pas être chargée
        return Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            color: themeColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              'Carvy',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  } catch (e) {
    debugPrint('⚠️ [SPLASH] Erreur dans splashLogo: $e');
    // Retourner un widget de fallback en cas d'erreur
    return Container(
      width: 300,
      height: 300,
      decoration: BoxDecoration(
        color: themeColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'Carvy',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
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
        primary: false,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
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
                                    Flexible(
                                      child: Text(
                                        CityNameHelper.displayName(
                                          list.elementAt(index).cityName,
                                        ),
                                        style: boldstyle(context).copyWith(
                                          color: whiteColor,
                                          fontSize: 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                        softWrap: true,
                                      ),
                                    ),
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
        final item = list[index];
        // DEBUG demandé: tracer chaque véhicule rendu dans la liste.
        print('🚗 [DEBUG] Véhicule chargé : ${item.name} | ID: ${item.id}');
        if ((item.id ?? '').trim().isEmpty ||
            (item.id ?? '').toLowerCase() == 'null') {
          print(
              "⚠️ [DEBUG] Véhicule potentiellement dummy détecté: nom=${item.name}, id='${item.id}'");
        }

        if (activeModuleId.value == 1 ||
            activeModuleId.value == 2 ||
            activeModuleId.value == 3 ||
            activeModuleId.value == 5) {
          String? jsonSliders = item.itemInfo;
          if (jsonSliders != null) {
            itemInfoData = ItemInfo.fromJson(json.decode(jsonSliders));
            Map<String, dynamic> itemInfo = jsonDecode(jsonSliders);
            serviceType = itemInfo["service_type"];
          }
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
        final double parsedRating = VehicleCardHelper.resolveItemRating(item);

        return Padding(
          padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5, right: 5),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VehicleDetailSScreen(
                            id: item.id,
                            itemInfo: itemInfoData,
                            rating: parsedRating > 0
                                ? parsedRating.toStringAsFixed(1)
                                : item.itemRating,
                            title: item.name,
                            address: item.address,
                            city: item.city,
                            latitute: item.latitude,
                            longtitute: item.longitude,
                            frontImage: item.image,
                            itemType: item.itemType,
                            isWishList: item.isInWishlist,
                            price: item.price,
                          )));
            },
            child: Container(
              width: double.infinity,
              height: 230,
              decoration: BoxDecoration(
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
                          Positioned.fill(
                            child: myNetworkImageWithShimmer(item.image),
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
                                      (item.name ?? '').length > 21
                                          ? (item.name ?? '').substring(0, 20)
                                          : (item.name ?? ''),
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
                                  price: item.price,
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
                                                'assets/images/redHeart.svg',
                                                height: 20,
                                              )
                                            : SvgPicture.asset(
                                                'assets/images/whitHeart.svg',
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
                                                list[index].isInWishlist = false;
                                              }
                                            } else {
                                              success = await wishListController
                                                  .addTowishlist(list[index].id);
                                              if (success) {
                                                list[index].isInWishlist = true;
                                              }
                                            }
                                          } catch (e) {
                                            print("❌ [Wishlist] Error toggling wishlist: $e");
                                          } finally {
                                            // CRITICAL: Always reset loading state, no matter what
                                            wishListLoadingHorizontal = -1;
                                            try {
                                              setState(() {});
                                            } catch (e) {
                                              // Widget might be disposed, but we still reset the loading state
                                              print("⚠️ [Wishlist] setState failed (widget disposed): $e");
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
                      if (itemInfoData != null &&
                          itemInfoData!.hostFirstName != null)
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

        // Texte de localisation propre pour la vue publique
        final locationPartsPublic = <String>[];
        if ((list[index].address ?? '').trim().isNotEmpty) {
          locationPartsPublic.add((list[index].address ?? '').trim());
        }
        if ((list[index].city ?? '').trim().isNotEmpty) {
          locationPartsPublic.add((list[index].city ?? '').trim());
        }
        final String locationTextPublic = locationPartsPublic.isNotEmpty
            ? locationPartsPublic.join(" • ")
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
                    id: list[index].id,
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
                                            parsedRating.toStringAsFixed(1),
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
                                VehicleCardHelper.buildSpecsAndPriceRow(
                                  itemInfo: itemInfoData,
                                  price: list[index].price,
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
                                          
                                          try {
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
                                          } catch (e) {
                                            print("❌ [Wishlist] Error toggling wishlist: $e");
                                          } finally {
                                            // CRITICAL: Always reset loading state, no matter what
                                            wishListLoadingHorizontal = -1;
                                            try {
                                              setState(() {});
                                            } catch (e) {
                                              // Widget might be disposed, but we still reset the loading state
                                              print("⚠️ [Wishlist] setState failed (widget disposed): $e");
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
                          locationTextPublic,
                          overflow: TextOverflow.ellipsis,
                          style: regular3(context).copyWith(
                            fontSize: 12,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      const Spacer(),
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
                      ),
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
    }),
  );
}

bool _bookingIsCompleted(Bookings booking) =>
    booking.status?.toStandardStatus() == 'COMPLETED';

bool _bookingHasSecurityDeposit(Bookings booking) {
  final v = booking.securityMoney?.trim();
  if (v == null || v.isEmpty) return false;
  return v != '0' && v != '0.00' && v != '0.0';
}

bool _bookingShowsDepositOnSiteInfo(Bookings booking, String listType) {
  if (listType == 'UpComing') return true;
  final s = booking.status?.toStandardStatus() ?? '';
  return s == 'UPCOMING' || s == 'CONFIRMED' || s == 'ACCEPTED';
}

bool _bookingIsReviewedFlag(Bookings booking) {
  final v = booking.isReviewed?.trim();
  if (v == null || v.isEmpty) return false;
  return v == '1' || v.toLowerCase() == 'true';
}

bool _bookingShowLeaveReviewButton(Bookings booking) =>
    _bookingIsCompleted(booking) && !_bookingIsReviewedFlag(booking);

bool _bookingShowReviewSentBadge(Bookings booking) =>
    _bookingIsCompleted(booking) && _bookingIsReviewedFlag(booking);

Widget _buildClientBookingReviewSection(
  BuildContext context,
  Bookings booking,
  VoidCallback onListRefresh,
) {
  if (_bookingShowReviewSentBadge(booking)) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 4),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Text(
            'Review submitted'.tr,
            style: regular2(context).copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade900,
            ),
          ),
        ),
      ),
    );
  }

  if (!_bookingShowLeaveReviewButton(booking)) {
    return const SizedBox.shrink();
  }

  return Padding(
    padding: const EdgeInsets.only(top: 12, left: 8, right: 8, bottom: 4),
    child: SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          final bookingController = Get.find<BookingController>();
          bookingController.resetClientReviewForm();
          showClientBookingReviewBottomSheet(
            context,
            booking,
            onReviewSubmitted: onListRefresh,
          );
        },
        icon: const Icon(Icons.star_outline, size: 20),
        label: Text(
          'Leave a Review'.tr,
          style: boldstyle(context).copyWith(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: getColorBasedOnActiveModuleid(),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    ),
  );
}

DateTime? _parseBookingDateTime(String? raw) {
  final value = raw?.trim() ?? '';
  if (value.isEmpty) return null;
  try {
    return DateFormat('dd-MM-yyyy hh:mm a').parse(value);
  } catch (_) {}
  try {
    return DateTime.parse(value);
  } catch (_) {}
  return null;
}

DateTime? _parseBookingEndDateTime(Bookings booking) {
  return _parseBookingDateTime(booking.checkOut);
}

DateTime? _parseBookingStartDateTime(Bookings booking) {
  return _parseBookingDateTime(booking.checkIn);
}

Color _bookingListPrimaryActionColor(String btnText) {
  if (btnText == 'Extend duration') {
    return getColorBasedOnActiveModuleid();
  }
  if (btnText == 'Cancel') {
    return redColor;
  }
  return getColorBasedOnActiveModuleid();
}

bool _bookingAllowsExtension(String? status) {
  final s = status.toStandardStatus();
  return s == 'LIVE' || s == 'CONFIRMED';
}

DateTime _bookingEndDateOnly(DateTime dateTime) {
  return DateTime(dateTime.year, dateTime.month, dateTime.day);
}

DateTime _newEndFromPickedDate(DateTime currentEnd, DateTime pickedDate) {
  return DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
    currentEnd.hour,
    currentEnd.minute,
  );
}

String _formatBookingDateForDisplay(DateTime dateTime) {
  return DateFormat('dd-MM-yyyy').format(dateTime);
}

String _formatNewEndDateIso(DateTime currentEnd, DateTime pickedDate) {
  return _newEndFromPickedDate(currentEnd, pickedDate).toIso8601String();
}

int _extensionDaysBetween(DateTime oldEnd, DateTime newEnd) {
  return _bookingEndDateOnly(newEnd)
      .difference(_bookingEndDateOnly(oldEnd))
      .inDays;
}

Future<void> _showExtendReservationConfirmSheet({
  required BuildContext context,
  required Bookings booking,
  required DateTime currentEnd,
  required DateTime selectedNewEnd,
  required String newEndDateIso,
  required StateSetter setState,
}) async {
  final recordController = Get.find<BookingRecordController>();
  final extraDays = _extensionDaysBetween(currentEnd, selectedNewEnd);
  final oldEndLabel = _formatBookingDateForDisplay(currentEnd);
  final newEndLabel = _formatBookingDateForDisplay(selectedNewEnd);
  final startDate = _parseBookingStartDateTime(booking);
  final startLabel = startDate != null
      ? _formatBookingDateForDisplay(startDate)
      : null;
  var previewRequested = false;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (sheetContext) {
      Map<String, dynamic>? previewData;
      var previewLoading = true;
      var confirming = false;

      return StatefulBuilder(
        builder: (sheetContext, setSheetState) {
          if (!previewRequested) {
            previewRequested = true;
            recordController
                .extendReservationPreview(
              bookingId: '${booking.id}',
              newEndDate: newEndDateIso,
            )
                .then((preview) {
              if (!sheetContext.mounted) return;
              setSheetState(() {
                previewData = preview;
                previewLoading = false;
              });
            });
          }

          final additionalAmount = previewData == null
              ? null
              : '${previewData!['additionalAmount'] ?? previewData!['additional_amount'] ?? '0'}';
          final currency = previewData == null
              ? ''
              : '${previewData!['currency'] ?? previewData!['currencyCode'] ?? booking.currencyCode ?? ''}';

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 8,
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Extend duration'.tr, style: heading1(sheetContext)),
                const SizedBox(height: 16),
                CustomsButtons(
                  text: 'Select new end date'.tr,
                  backgroundColor: getColorBasedOnActiveModuleid(),
                  onPressed: () {},
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    newEndLabel,
                    style: boldstyle(sheetContext).copyWith(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notifires.getBoxColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: notifires.getGrey6Whitecolor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Extension of @days days'.trParams({
                          'days': '$extraDays',
                        }),
                        style: boldstyle(sheetContext).copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'extension_added_period'.trParams({
                          'from': oldEndLabel,
                          'to': newEndLabel,
                        }),
                        style: regular2(sheetContext),
                      ),
                      if (startLabel != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'extension_total_rental_period'.trParams({
                            'from': startLabel,
                            'to': newEndLabel,
                          }),
                          style: regular3(sheetContext).copyWith(
                            color: notifires.getGrey2Whitecolor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                if (previewLoading)
                  const Center(child: CircularProgressIndicator())
                else if (previewData != null && additionalAmount != null)
                  Text(
                    'Additional amount to pay: @amount @currency'.trParams({
                      'amount': additionalAmount,
                      'currency': currency,
                    }),
                    style: boldstyle(sheetContext).copyWith(
                      fontSize: 16,
                      color: getColorBasedOnActiveModuleid(),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'extension_payment_notice'.tr,
                  style: regular3(sheetContext).copyWith(
                    color: notifires.getGrey2Whitecolor,
                  ),
                ),
                if (previewData != null && !previewLoading) ...[
                  const SizedBox(height: 20),
                  confirming
                      ? const Center(child: CircularProgressIndicator())
                      : CustomsButtons(
                          text: 'Confirm extension'.tr,
                          backgroundColor: getColorBasedOnActiveModuleid(),
                          onPressed: () async {
                            setSheetState(() => confirming = true);

                            final amountRaw = previewData![
                                    'additionalAmount'] ??
                                previewData!['additional_amount'] ??
                                '0';
                            final amount =
                                double.tryParse('$amountRaw') ?? 0.0;
                            final paymentUrl = previewData!['payment_url']
                                    ?.toString() ??
                                previewData!['paymentUrl']?.toString();

                            final bookingController =
                                Get.find<BookingController>();
                            bookingController.setExtensionPaymentContext(
                              ExtensionPaymentContext(
                                bookingId: '${booking.id}',
                                newEndDateIso: newEndDateIso,
                                additionalAmount: amount,
                                currency: currency,
                                extraDays: extraDays,
                                oldEndLabel: oldEndLabel,
                                newEndLabel: newEndLabel,
                                startLabel: startLabel,
                                paymentUrl: paymentUrl,
                              ),
                            );
                            bookingController.selectedPaymentMethod = null;

                            if (!sheetContext.mounted) return;
                            setSheetState(() => confirming = false);
                            Navigator.pop(sheetContext);

                            final vehicleId = booking.vehicleId ??
                                booking.itemid ??
                                '';
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentMethodScreen(
                                  vehicleId: vehicleId.toString(),
                                  isExtension: true,
                                ),
                              ),
                            );

                            bookingController.setExtensionPaymentContext(null);
                            await recordController.getBookingRecord(
                              type: 'ongoing',
                              offset: 0,
                            );
                            setState(() {});
                          },
                        ),
                ],
              ],
            ),
          );
        },
      );
    },
  );
}

Future<void> _openExtendReservationFlow({
  required BuildContext context,
  required Bookings booking,
  required StateSetter setState,
}) async {
  final currentEnd = _parseBookingEndDateTime(booking);
  if (currentEnd == null) {
    showErrorToastMessage('Something went wrong'.tr);
    return;
  }

  final firstDate = _bookingEndDateOnly(currentEnd).add(const Duration(days: 1));
  final windowLast = RollingCalendarBounds.lastDate();
  if (firstDate.isAfter(windowLast)) {
    showErrorToastMessage(
      'The selected date range must be within the current month and the next two months.'
          .tr,
    );
    return;
  }

  final pickedDate = await showDatePicker(
    context: context,
    initialDate: firstDate,
    firstDate: firstDate,
    lastDate: windowLast,
  );
  if (pickedDate == null || !context.mounted) return;

  final selectedNewEnd = _newEndFromPickedDate(currentEnd, pickedDate);
  final newEndDateIso = selectedNewEnd.toIso8601String();

  await _showExtendReservationConfirmSheet(
    context: context,
    booking: booking,
    currentEnd: currentEnd,
    selectedNewEnd: selectedNewEnd,
    newEndDateIso: newEndDateIso,
    setState: setState,
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
  BookingController bookingController = Get.find();
  innerMethod(context, index) async {
    if (btnText == 'Extend duration') {
      if (!_bookingAllowsExtension(list[index].status)) {
        showErrorToastMessage('Something went wrong'.tr);
        return;
      }
      await _openExtendReservationFlow(
        context: context,
        booking: list[index],
        setState: setState,
      );
    } else if (btnText == "Cancel") {
      showLoading();
      dynamic response;
      try {
        response = await httpGet(Config.getCancelReasons, {"userType": "user"});
        closeLoading();
        
        // Debug: Log the raw response from backend
        print('📥 [FLUTTER_DEBUG] ========================================');
        print('📥 [FLUTTER_DEBUG] Raw response from get-cancel-reasons:');
        print('📥 [FLUTTER_DEBUG] ${response}');
        if (response != null && response['data'] != null && response['data']['reasons'] != null) {
          print('📥 [FLUTTER_DEBUG] First reason structure:');
          print('📥 [FLUTTER_DEBUG] ${response['data']['reasons'][0]}');
        }
        print('📥 [FLUTTER_DEBUG] ========================================');
        
        if (response != null && response['status'] == 200) {
          try {
            CancellationReasonModel model =
                CancellationReasonModel.fromJson(response);
            await showModalBottomSheet(
              isScrollControlled: true,
              useSafeArea: true,
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
                          list[index].status.isConfirmed &&
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
                                        dynamic resp;
                                        try {
                                          String bookingId = "${list[index].id}";
                                          // Convert value to String and validate ObjectId format
                                          String cancelReasonId = value?.toString().trim() ?? "";
                                          
                                          print('📤 [FLUTTER_DEBUG] ========================================');
                                          print('📤 [FLUTTER_DEBUG] Preparing cancellation request:');
                                          print('📤 [FLUTTER_DEBUG]   Raw value from bottom sheet: $value');
                                          print('📤 [FLUTTER_DEBUG]   Value type: ${value.runtimeType}');
                                          print('📤 [FLUTTER_DEBUG]   Converted ID: "$cancelReasonId"');
                                          print('📤 [FLUTTER_DEBUG]   ID length: ${cancelReasonId.length}');
                                          
                                          // Validate MongoDB ObjectId format (24 hex characters)
                                          bool isValidObjectId = cancelReasonId.isNotEmpty && 
                                                                  cancelReasonId.length == 24 &&
                                                                  RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(cancelReasonId);
                                          
                                          if (!isValidObjectId) {
                                            print('⚠️ [FLUTTER_DEBUG] ⚠️ CRITICAL ERROR: Invalid ObjectId format!');
                                            print('⚠️ [FLUTTER_DEBUG]   Received: "$cancelReasonId" (length: ${cancelReasonId.length})');
                                            print('⚠️ [FLUTTER_DEBUG]   Expected: 24 hexadecimal characters (MongoDB ObjectId)');
                                            print('⚠️ [FLUTTER_DEBUG]   This means the backend is NOT sending _id field!');
                                            print('⚠️ [FLUTTER_DEBUG]   Backend must return _id (MongoDB ObjectId) instead of order_cancellation_id (number)');
                                            print('⚠️ [FLUTTER_DEBUG]   Request will FAIL with 404 error!');
                                            // Don't use test ID - let it fail so we can see the error
                                          }
                                          
                                          print('📤 [FLUTTER_DEBUG] Envoi de l\'ID MongoDB réel : $cancelReasonId');
                                          print('💎 [FLUTTER_DEBUG] ID réel sélectionné depuis l\'API : $cancelReasonId');
                                          print('📤 [FLUTTER_DEBUG] Booking ID: $bookingId');
                                          print('📤 [FLUTTER_DEBUG] Route API: ${Config.cancelBookingByUser}');
                                          print('📤 [FLUTTER_DEBUG] ========================================');
                                          
                                          resp = await httpPost(
                                              Config.cancelBookingByUser, {
                                            "booking_id": bookingId,
                                            "cancellation_reason": cancelReasonId
                                          });
                                          closeLoading();
                                          
                                          if (resp != null &&
                                              resp['status'] == 200) {
                                          showToastMessage(resp['message']);
                                          bookingController
                                              .updateBookingStatusIfExists(
                                            bookingId:
                                                list[index].id.toString(),
                                            hostId: list[index]
                                                    .hostId
                                                    ?.toString() ??
                                                "1001",
                                            userId: userId.toString(),
                                            newStatus: "Cancelled",
                                          );

                                          onItemCancelled(index);
                                          setState(() {});
                                        } else {
                                          showErrorToastMessage(resp != null &&
                                                  resp['error'] != null
                                              ? resp['error']
                                              : "Failed to cancel booking");
                                        }
                                        } catch (e) {
                                          closeLoading();
                                          print("Error cancelling booking: $e");
                                          showErrorToastMessage(
                                              "Error cancelling booking. Please try again.");
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
          } catch (e) {
            print("Error parsing cancellation reasons: $e");
            showErrorToastMessage(
                "Error loading cancellation reasons. Please try again.");
          }
        } else if (response != null && response['error'] != null) {
          showErrorToastMessage(response['error']);
        } else {
          showErrorToastMessage(
              "Failed to load cancellation reasons. Please try again.");
        }
      } catch (e) {
        closeLoading();
        print("Error fetching cancellation reasons: $e");
        showErrorToastMessage(
            "Error loading cancellation reasons. Please try again.");
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

  bookingController.clearBookingData();
  return ListView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        print(list[index].status);

        final itemData = Bookings.decodeItemDataList(list[index].itemData);
        if (itemData == null || itemData.isEmpty) {
          return const SizedBox.shrink();
        }
        final firstItem = itemData[0] is Map
            ? Map<String, dynamic>.from(itemData[0] as Map)
            : <String, dynamic>{};
        String vehicleMongoId = Bookings.normalizeEntityId(firstItem['_id']) ??
            Bookings.normalizeEntityId(firstItem['item_id']) ??
            Bookings.normalizeEntityId(list[index].vehicleId) ??
            Bookings.normalizeEntityId(list[index].itemid) ??
            '';
        String address = firstItem['address']?.toString() ?? 'N/A'.tr;
        dynamic latitude = firstItem['latitude'] ?? 'N/A'.tr;
        dynamic longitude = firstItem['longitude'] ?? 'N/A'.tr;
        
        // Priorité 1: Utiliser propImg qui contient l'URL complète depuis le backend
        // Priorité 2: Utiliser itemData[0]['image'] avec fallback intelligent
        String? image;
        if (list[index].propImg != null && list[index].propImg!.isNotEmpty && list[index].propImg != 'N/A') {
          image = list[index].propImg;
          // ========== LOG CRITIQUE POUR DÉBOGUER L'URL DANS LE WIDGET ==========
          print('🖼️ [DEBUG IMAGE] [WIDGET] Image depuis propImg: $image');
        } else {
          dynamic itemDataImage = firstItem['image'] ?? firstItem['front_image_url'];
          if (itemDataImage != null && itemDataImage.toString().isNotEmpty && itemDataImage.toString() != 'N/A') {
            image = itemDataImage.toString();
            // ========== LOG CRITIQUE POUR DÉBOGUER L'URL DANS LE WIDGET ==========
            print('🖼️ [DEBUG IMAGE] [WIDGET] Image depuis itemData: $image');
          } else {
            print('🖼️ [DEBUG IMAGE] [WIDGET] Aucune image trouvée (propImg et itemData sont null/vides)');
          }
        }
        final totalNights = formatBookingCardPriceLine(
          currencyCode: list[index].currencyCode,
          total: list[index].total,
          totalNight: list[index].totalNight,
        );
        final hostPhoneDisplay = formatBookingPhoneDisplay(
          list[index].hostPhoneCountry,
          list[index].hostNumber,
        );
        ItemInfo? itemInfoData;
        try {
          final rawInfo = firstItem['item_info'];
          if (rawInfo != null) {
            final itemInfoMap = rawInfo is String
                ? jsonDecode(rawInfo) as Map<String, dynamic>
                : Map<String, dynamic>.from(rawInfo as Map);
            itemInfoData = ItemInfo.fromJson(itemInfoMap);
          }
        } catch (e) {
          debugPrint('❌ [BookingRecord UI] item_info invalide: $e');
          return const SizedBox.shrink();
        }
        if (itemInfoData == null) {
          return const SizedBox.shrink();
        }

        dynamic proType = firstItem['item_type'] ?? 'N/A'.tr;
        String? doorStepPrice = itemInfoData.doorStepPrice;
        final bool isLiveBookingCard = listType.toLowerCase() == "ongoing";
        final String dropOtpValue = (list[index].dropOtp ?? '').trim();
        final bool hasDropOtp = dropOtpValue.isNotEmpty;

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

        void showOtpBottomSheet(BuildContext context, int index) {
          print('📌 [UI] Tentative d\'affichage de la modale OTP maintenant');
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

                                  bookingController.openOtpAfterImageSubmit.value = false;
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

        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (bookingController.openOtpAfterImageSubmit.value) {
            Future.delayed(Duration(milliseconds: 500), () {
              showOtpBottomSheet(context, index);
              bookingController.openOtpAfterImageSubmit.value = false;
            });
          }
        });
        return Padding(
          padding:
              const EdgeInsets.only(left: 13, right: 13, bottom: 10, top: 10),
          child: GestureDetector(
            // behavior: deferToChild permet aux widgets enfants (comme le bouton chat) 
            // d'avoir la priorité sur les clics
            behavior: HitTestBehavior.deferToChild,
            onTap: () {
              // Extraction de l'ID du véhicule depuis itemData (JSON String)
              // afin d'éviter l'erreur 404 causée par l'envoi de l'ID de réservation
              final vehicleId = Bookings.normalizeEntityId(firstItem['_id']) ??
                  Bookings.normalizeEntityId(firstItem['item_id']) ??
                  Bookings.normalizeEntityId(list[index].vehicleId) ??
                  Bookings.normalizeEntityId(list[index].itemid) ??
                  '';

              print('🚀 [NAVIGATION] ID véhicule extrait pour VehicleDetailSScreen : $vehicleId');
              
              // Inspiration Homepage: Définir un titre de fallback robuste
              String finalTitle = list[index].propTitle ?? "";
              if (finalTitle.isEmpty ||
                  finalTitle == "null" ||
                  finalTitle == "N/A" ||
                  finalTitle.toLowerCase().contains('véhicule sans titre')) {
                finalTitle = firstItem['title']?.toString() ??
                    firstItem['item_title']?.toString() ??
                    firstItem['name']?.toString() ??
                    "Véhicule".tr;
              }

              // Navigation vers les détails du véhicule avec l'ID sécurisé et les données fallback
              showPopUpScreen(
                  context,
                  VehicleDetailSScreen(
                    id: vehicleId,
                    itemInfo: itemInfoData!,
                    rating: list[index].rating,
                    title: finalTitle,
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
                  // Suppression du GestureDetector de l'image - le conteneur principal gère maintenant le clic
                  Stack(
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
                        // Afficher le Drop OTP pour le client sur les réservations en direct
                        isLiveBookingCard && hasDropOtp
                            ? Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 4, bottom: 4),
                                  decoration: BoxDecoration(
                                    color: getColorBasedOnActiveModuleid()
                                        .withOpacity(.8),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Drop OTP: @code".trParams({
                                      'code': dropOtpValue,
                                    }),
                                    style: regular2(context)
                                        .copyWith(color: whiteColor),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        listType == "Cancelled"
                            ? SizedBox()
                            : Positioned(
                                bottom: 10,
                                right: 10,
                                child: InkWell(
                                  onTap: () async {
                                    final booking = list[index];
                                    // ignore: avoid_print
                                    print('--- DUMP COMPLET RÉSERVATION ---');
                                    try {
                                      // ignore: avoid_print
                                      print(jsonEncode(booking.toJson()));
                                    } catch (_) {
                                      // ignore: avoid_print
                                      print(booking.toString());
                                    }
                                    // ignore: avoid_print
                                    print('CONTENU ITEM_DATA : ${booking.itemData}');
                                    // ignore: avoid_print
                                    print('---------------------------------');

                                    // Récupère hostId avec fallback depuis itemData si null/\"null\"/vide
                                    String? primaryHostId =
                                        booking.hostId?.toString().trim();
                                    String? fallbackHostId;
                                    try {
                                      final dynamic raw = itemData;
                                      if (raw is List && raw.isNotEmpty) {
                                        final m = raw.first is Map
                                            ? Map<String, dynamic>.from(raw.first)
                                            : <String, dynamic>{};
                                        fallbackHostId = (m['host_id'] ??
                                                m['hostId'] ??
                                                m['seller_id'] ??
                                                m['vendor_id'] ??
                                                m['owner_id'] ??
                                                m['user_id'])
                                            ?.toString()
                                            .trim();
                                      }
                                    } catch (_) {
                                      // ignore
                                    }
                                    String finalHostId = (primaryHostId != null &&
                                                primaryHostId.isNotEmpty &&
                                                primaryHostId.toLowerCase() != 'null')
                                            ? primaryHostId
                                            : ((fallbackHostId != null &&
                                                        fallbackHostId.isNotEmpty &&
                                                        fallbackHostId.toLowerCase() != 'null')
                                                    ? fallbackHostId!
                                                    : '');

                                    // Fallback "lazy loading" via API véhicule si hostId est encore introuvable
                                    if (finalHostId.isEmpty) {
                                      final itemId = booking.itemid?.toString().trim() ?? '';
                                      if (itemId.isNotEmpty &&
                                          itemId.toLowerCase() != 'null') {
                                        try {
                                          final vehicleResponse = await httpGet(
                                            '${Config.getVehicleDetails}/$itemId',
                                            {},
                                          );
                                          dynamic vehicleData = vehicleResponse?['data'];
                                          if (vehicleData is Map &&
                                              vehicleData['items'] is List &&
                                              (vehicleData['items'] as List).isNotEmpty) {
                                            vehicleData = (vehicleData['items'] as List).first;
                                          }
                                          if (vehicleData is Map) {
                                            final apiHostId = (vehicleData['user_id'] ??
                                                    vehicleData['host_id'] ??
                                                    vehicleData['owner_id'] ??
                                                    vehicleData['vendor_id'] ??
                                                    vehicleData['userId'] ??
                                                    vehicleData['hostId'])
                                                ?.toString()
                                                .trim();
                                            if (apiHostId != null &&
                                                apiHostId.isNotEmpty &&
                                                apiHostId.toLowerCase() != 'null') {
                                              finalHostId = apiHostId;
                                            }
                                          }
                                        } catch (e) {
                                          // ignore: avoid_print
                                          print('DEBUG CHAT : fallback API vehicle échoué: $e');
                                        }
                                      }
                                    }

                                    // Log de debug requis
                                    print("DEBUG CHAT : hostId = $finalHostId");

                                    // Si hostId introuvable, alerte et on stoppe
                                    if (finalHostId.isEmpty) {
                                      showErrorToastMessage(
                                          "Impossible d'ouvrir le chat: identifiant du vendeur introuvable");
                                      return;
                                    }

                                    final Bookings bookingRow = list[index];
                                    final String bookingIdStr =
                                        '${bookingRow.id}'.trim();

                                    Get.to(() => ConversationScreen(
                                          booking: bookingRow,
                                          bookingStatus: bookingRow.status,
                                          bookingId: bookingIdStr,
                                          image: image,
                                          title: bookingRow.propTitle!,
                                          buyerId: '$userId',
                                          sellerId: finalHostId,
                                          from: "${bookingRow.hostName}",
                                          senderId: "$userId",
                                          reciverId: finalHostId,
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
                                      "${proType ?? itemInfoData.vehicleType ?? ''}",
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
                                    totalNights,
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
                                : Builder(
                                    builder: (context) {
                                      final statusUi = getBookingStatusDetails(
                                        list[index].status?.toString(),
                                      );
                                      final standardStatus = list[index]
                                          .status
                                          .toStandardStatus();
                                      final canShowStatusText =
                                          standardStatus == 'CONFIRMED' ||
                                              standardStatus == 'PENDING' ||
                                              standardStatus == 'DECLINED' ||
                                              standardStatus == 'LIVE' ||
                                              listType == "Previous" ||
                                              listType == "UpComing";
                                      return Container(
                                        padding: const EdgeInsets.only(
                                          left: 8,
                                          right: 8,
                                          top: 4,
                                          bottom: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusUi.color,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: canShowStatusText
                                            ? Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    statusUi.icon,
                                                    size: 12,
                                                    color: whiteColor,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    statusUi.label,
                                                    style: regular(context)
                                                        .copyWith(
                                                      color: whiteColor,
                                                    ),
                                                  ),
                                                ],
                                              )
                                            : listType == 'Cancelled'
                                                ? Container(
                                                    decoration: BoxDecoration(
                                                      color: redColor,
                                                      border: Border.all(
                                                        color: redColor,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
                                                      child: Text(
                                                        statusUi.label,
                                                        style: regular(context)
                                                            .copyWith(
                                                          color: whiteColor,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : const SizedBox(),
                                      );
                                    },
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
                                DateTimeFormatter.to24HourFormat(
                                    list[index].checkIn),
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
                                DateTimeFormatter.to24HourFormat(
                                    list[index].checkOut),
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
                            hostPhoneDisplay.isNotEmpty
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
                                            bookingPhoneTelUri(
                                              list[index].hostPhoneCountry,
                                              list[index].hostNumber,
                                            ))),
                                        child: Text(
                                          hostPhoneDisplay,
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
                                      translateBookingVehicleSpec(
                                          itemInfoData.transmission),
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
                                      translateBookingFuelType(
                                          itemInfoData.fuelType),
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
                            if (_bookingHasSecurityDeposit(list[index])) ...[
                              const SizedBox(height: 8),
                              Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Security Deposit (Caution)".tr,
                                      style: regular2(context).copyWith(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "${list[index].currencyCode} ${list[index].securityMoney}",
                                    style: boldstyle(context).copyWith(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                              if (_bookingShowsDepositOnSiteInfo(
                                  list[index], listType)) ...[
                                const SizedBox(height: 8),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 16,
                                      color: getColorBasedOnActiveModuleid(),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        "booking_deposit_on_site_short".tr,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 4),
                            ],
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
                                              // ========== MOCK DATA - OLD API CALL COMMENTED ==========
                                              // var responce = await httpPost(
                                              //     Config.getItemDetails, {
                                              //   "item_id":
                                              //       "${list[index].itemid}"
                                              // });

                                              // MOCK: Simulate network delay
                                              await Future.delayed(
                                                  const Duration(seconds: 1));

                                              // MOCK: Static item details response (success)
                                              var responce = {
                                                "status": 200,
                                                "message":
                                                    "Item details retrieved successfully",
                                                "error": "",
                                                "data": {
                                                  "ItemDetails": {
                                                    "item_id": int.tryParse(
                                                            "${list[index].itemid}") ??
                                                        101,
                                                    "title":
                                                        "Toyota Camry 2023",
                                                    "price": "50.00",
                                                    "description":
                                                        "Clean and comfortable sedan",
                                                    "item_rating": "4.5",
                                                    "status": "1"
                                                  }
                                                }
                                              };
                                              // ========== END MOCK DATA ==========
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
                                                      : btnText ==
                                                              "Extend duration"
                                                          ? getColorBasedOnActiveModuleid()
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
                                            : btnText == 'Extend duration' &&
                                                    !_bookingAllowsExtension(
                                                        list[index].status)
                                                ? const SizedBox()
                                                : Expanded(
                                                    flex: 1,
                                                    child: InkWell(
                                                      onTap: () async {
                                                        if (btnText ==
                                                            'Extend duration') {
                                                          await innerMethod(
                                                              context, index);
                                                          return;
                                                        }
                                                        if (list[index]
                                                                .hostName ==
                                                            null) {
                                                          showErrorToastMessage(
                                                              "Owner not found");
                                                          return;
                                                        }

                                                        try {
                                                          showLoading();
                                                          // ========== MOCK DATA - OLD API CALL COMMENTED ==========
                                                          // var responce =
                                                          //     await httpPost(
                                                          //         Config
                                                          //             .getItemDetails,
                                                          //         {
                                                          //       "item_id":
                                                          //           "${list[index].itemid}"
                                                          //     });

                                                          // MOCK: Simulate network delay
                                                          await Future.delayed(
                                                              const Duration(
                                                                  seconds: 1));

                                                          // MOCK: Static item details response (success)
                                                          var responce = {
                                                            "status": 200,
                                                            "message":
                                                                "Item details retrieved successfully",
                                                            "error": "",
                                                            "data": {
                                                              "ItemDetails": {
                                                                "item_id":
                                                                    int.tryParse(
                                                                            "${list[index].itemid}") ??
                                                                        101,
                                                                "title":
                                                                    "Toyota Camry 2023",
                                                                "price":
                                                                    "50.00",
                                                                "description":
                                                                    "Clean and comfortable sedan",
                                                                "item_rating":
                                                                    "4.5",
                                                                "status": "1"
                                                              }
                                                            }
                                                          };
                                                          // ========== END MOCK DATA ==========
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
                                                              color:
                                                                  _bookingListPrimaryActionColor(
                                                                      btnText),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          13),
                                                            ),
                                                            child: Center(
                                                                child: Text(
                                                              "$btnText".tr,
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
                                                                              bookingController.openOtpAfterImageSubmit.value = false;
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
                                                                true,
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
                                                                          .bottom,
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
                                                                                    hostId: list[index].hostId?.toString() ?? "1001",
                                                                                    userId: userId.toString(),
                                                                                    newStatus: "Completed",
                                                                                  );

                                                                                  Navigator.pushReplacement(
                                                                                    context,
                                                                                    MaterialPageRoute(
                                                                                      builder: (context) => const HomeMain(initialIndex: 2),
                                                                                    ),
                                                                                  );
                                                                                } else {
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
                                                                color:
                                                                    getColorBasedOnActiveModuleid(),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            13),
                                                              ),
                                                              child: Center(
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
                            listType == 'UpComing' &&
                                    list[index].status.isConfirmed
                                ? Expanded(
                                    flex: 1,
                                    child: InkWell(
                                      onTap: () {
                                        print('🚀 [DEBUG] Accès forcé aux photos pour le booking: ${list[index].id}');
                                        
                                        // On ignore toutes les conditions et on navigue direct
                                        Get.to(() => VehiclePhotoesBooking(
                                          id: list[index].id.toString(),
                                        ));
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Container(
                                          height: 49,
                                          alignment: Alignment.center,
                                          padding: const EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                                          decoration: BoxDecoration(
                                            border: Border.all(color: Colors.red),
                                            borderRadius: BorderRadius.circular(13),
                                            color: Colors.red,
                                          ),
                                          child: Text(
                                            'Confirm reception'.tr,
                                            style: boldstyle(context)
                                                .copyWith(
                                                    color: Colors.white,
                                                    fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            Obx(
                              () => bookingController.dropoffshowHise.value ==
                                      true
                                  ? const SizedBox()
                                  : listType == "Previous" &&
                                          list[index].isItemReturned == 0 &&
                                          list[index].status.isConfirmed
                                      ? Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: () {
                                              showModalBottomSheet<String>(
                                                isScrollControlled: true,
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
                                                              .bottom,
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
                        Builder(
                          builder: (context) {
                            final showDirections =
                                shouldShowBookingAgencyDirections(
                                  bookingStatus: list[index].status,
                                  listType: listType,
                                ) &&
                                list[index].hostLat != null &&
                                list[index].hostLng != null;
                            const double actionButtonHeight = 48;
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: SizedBox(
                                height: 50,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    if (showDirections)
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              right: 8),
                                          child: SizedBox(
                                            height: actionButtonHeight,
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed: () =>
                                                  launchBookingAgencyDirections(
                                                latitude: list[index].hostLat,
                                                longitude: list[index].hostLng,
                                              ),
                                              icon: const Icon(
                                                Icons.directions_car,
                                                size: 20,
                                              ),
                                              label: Text(
                                                'View itinerary'.tr,
                                                style: boldstyle(context)
                                                    .copyWith(
                                                  color: Colors.purple,
                                                  fontSize: 13,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                elevation: 0,
                                                tapTargetSize: MaterialTapTargetSize
                                                    .shrinkWrap,
                                                backgroundColor: Colors.purple
                                                    .withOpacity(0.1),
                                                foregroundColor: Colors.purple,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(13),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: SizedBox(
                                        height: actionButtonHeight,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(13),
                                          onTap: () async {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (builder) =>
                                                        EReceiptScreen(
                                                          bookings:
                                                              list[index],
                                                          fromPropBooking:
                                                              fromPropBooking,
                                                          doorStepPrice:
                                                              doorStepPrice ??
                                                                  "",
                                                        ))).then((value) {
                                              if (value != null) {
                                                list[index].statusSetter =
                                                    value;
                                                setState(() {});
                                              }
                                            });
                                          },
                                          child: Container(
                                            height: actionButtonHeight,
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                            ),
                                            decoration: BoxDecoration(
                                              color: themeColor,
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                            ),
                                            child: Text(
                                              "Reciept".tr,
                                              textAlign: TextAlign.center,
                                              style: boldstyle(context)
                                                  .copyWith(
                                                color: whiteColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        _buildClientBookingReviewSection(
                          context,
                          list[index],
                          () => setState(() {}),
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
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Text(
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

/// Affiche une image de profil : data URI base64 (`data:image/...`), URL http(s), ou placeholder d'erreur.
Widget buildAvatarImage(String imageUrl,
    {BoxFit fit = BoxFit.cover, bool? shoeIcononError}) {
  Widget onError() =>
      shoeIcononError == true ? getErrorIcon() : getErrorImage();

  final trimmed = imageUrl.trim();
  if (trimmed.isEmpty) return onError();
  if (trimmed.startsWith('data:image')) {
    try {
      final comma = trimmed.indexOf(',');
      if (comma < 0) return onError();
      final base64String = trimmed.substring(comma + 1);
      final bytes = base64Decode(base64String);
      return Image.memory(
        bytes,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => onError(),
      );
    } catch (_) {
      return onError();
    }
  }
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return CachedNetworkImage(
      imageUrl: trimmed,
      fit: fit,
      placeholder: (context, url) => const Center(
        child: SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      errorWidget: (context, url, error) => onError(),
    );
  }
  return onError();
}

Widget myNetworkImage(String? image, [bool? shoeIcononError]) {
  if (image == null || image.trim().isEmpty) {
    return shoeIcononError == true ? getErrorIcon() : getErrorImage();
  }
  return buildAvatarImage(image, fit: BoxFit.cover, shoeIcononError: shoeIcononError);
}

Widget myNetworkImageWithShimmer(String? image) {
  if (image != null && image.isNotEmpty && image != 'N/A') {
    // Utiliser la fonction utilitaire publique pour construire l'URL complète
    String finalUrl = Config.getFullImageUrl(image);
    
    // ========== LOG CRITIQUE POUR DÉBOGUER L'URL FINALE ==========
    print('🖼️ [DEBUG IMAGE] URL finale utilisée: $finalUrl');
    print('🖼️ [DEBUG IMAGE] URL originale: $image');

    return CachedNetworkImage(
      imageUrl: finalUrl,
      fit: BoxFit.cover,
      placeholder: (context, url) => shimmerContainer(),
      errorWidget: (context, url, error) {
        // ========== ERROR BUILDER DÉTAILLÉ POUR DIAGNOSTIQUER LES ERREURS ==========
        print('🔴 [IMAGE ERROR] URL qui a échoué: $url');
        print('🔴 [IMAGE ERROR] Type d\'erreur: ${error.runtimeType}');
        print('🔴 [IMAGE ERROR] Message d\'erreur: $error');
        print('🔴 [IMAGE ERROR] StackTrace: ${StackTrace.current}');
        
        return Center(
          child: Icon(
            Icons.directions_car,
            color: Colors.grey,
            size: 40,
          ),
        );
      },
    );
  } else {
    print('🖼️ [DEBUG IMAGE] Image est null, vide ou N/A');
    return Center(
      child: Icon(
        Icons.directions_car,
        color: Colors.grey,
        size: 40,
      ),
    );
  }
}

Widget myNetworkImageFillBox(String? image) {
  if (image == null || image.trim().isEmpty) return getErrorImage();
  final t = image.trim();
  if (t.startsWith('data:image')) {
    if (kDebugMode) print(image);
    return buildAvatarImage(t, fit: BoxFit.cover);
  }
  if (t.startsWith('http://') || t.startsWith('https://')) {
    if (kDebugMode) print(image);
    return Image.network(
      t,
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
  }
  return getErrorImage();
}

Widget myNetworkImageFitWidth(String? image) {
  if (image == null || image.trim().isEmpty) return getErrorImage();
  final t = image.trim();
  if (t.startsWith('data:image')) {
    return buildAvatarImage(t, fit: BoxFit.cover);
  }
  if (t.startsWith('http://') || t.startsWith('https://')) {
    return Image.network(
      t,
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
  }
  return getErrorImage();
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
              Row(
                children: [
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
  final safeList = (list is List) ? list : [];
  if (safeList.isEmpty) {
    // Rien à afficher: on n'ouvre pas de bottom sheet vide.
    return;
  }

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
            if ((title ?? '').trim().isNotEmpty) ...[
              Text(
                title!.tr,
                style: headingh4.copyWith(color: notifires.getwhiteblackcolor),
              ),
              const SizedBox(height: 10),
            ],
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (var x in safeList)
                      Column(
                        children: [
                          featuresbox(
                            txt: (x.name ?? '').toString().trim(),
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

bool _rulesTextHasArabicScript(String s) =>
    RegExp(r'[\u0600-\u06FF]').hasMatch(s);

/// Accent / ponctuation / apostrophes neutralisés pour retrouver la règle canonique.
String _foldRuleTextForLookup(String raw) {
  var s = raw.toLowerCase().trim();
  const Map<String, String> accent = {
    'à': 'a', 'â': 'a', 'ä': 'a', 'á': 'a', 'ã': 'a', 'å': 'a', 'ā': 'a',
    'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e', 'ē': 'e', 'ė': 'e', 'ę': 'e',
    'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i', 'ī': 'i', 'į': 'i',
    'ó': 'o', 'ò': 'o', 'ô': 'o', 'ö': 'o', 'õ': 'o', 'ō': 'o', 'ø': 'o',
    'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u', 'ū': 'u', 'ų': 'u',
    'ç': 'c', 'œ': 'oe', 'æ': 'ae',
  };
  for (final e in accent.entries) {
    s = s.replaceAll(e.key, e.value);
  }
  s = s.replaceAll(RegExp(r"[''`´]"), ' ');
  s = s.replaceAll(RegExp(r'[^a-z0-9\s%]'), ' ');
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  return s;
}

/// Phrases FR/EN (toutes variantes pliées) → clé anglaise GetX existante.
const Map<String, String> _kFoldedVehicleRuleToEnglishKey = {
  // FR (API / écrans)
  'il est interdit de preter louer ou sous louer le vehicule a un tiers':
      'It is forbidden to lend, rent, or sublease the car to a third party.',
  'il est interdit de preter louer ou sous louer la voiture a un tiers':
      'It is forbidden to lend, rent, or sublease the car to a third party.',
  'le vehicule doit etre retourne avec le meme niveau de carburant qu au moment de la prise en charge':
      'The vehicle must be returned with the same fuel level as at pickup.',
  'le vehicule doit etre restitue avec le meme niveau de carburant qu a la prise en charge':
      'The vehicle must be returned with the same fuel level as at pickup.',
  'il est interdit de fumer et de manger a l interieur du vehicule':
      'Smoking and eating inside the car are not allowed.',
  'il est interdit de fumer et de manger a l interieur de la voiture':
      'Smoking and eating inside the car are not allowed.',
  'le vehicule doit etre retourne a la date a l heure et au lieu convenus':
      'The vehicle must be returned on the agreed date, time, and location.',
  'le vehicule doit etre retourne a la date l heure et au lieu convenus':
      'The vehicle must be returned on the agreed date, time, and location.',
  // EN (backend)
  'it is forbidden to lend rent or sublease the car to a third party':
      'It is forbidden to lend, rent, or sublease the car to a third party.',
  'the vehicle must be returned with the same fuel level as at pickup':
      'The vehicle must be returned with the same fuel level as at pickup.',
  'smoking and eating inside the car are not allowed':
      'Smoking and eating inside the car are not allowed.',
  'the vehicle must be returned on the agreed date time and location':
      'The vehicle must be returned on the agreed date, time, and location.',
};

/// Politique d’annulation (EN/FR) + règles véhicule standard (EN/FR depuis l’API).
String _translateRulesSheetLine(String text) {
  final normalized = text.trim().toLowerCase();
  if (normalized.isEmpty) return text;

  final foldedRule = _foldRuleTextForLookup(text);
  final canonVehicle = _kFoldedVehicleRuleToEnglishKey[foldedRule];
  if (canonVehicle != null) {
    return canonVehicle.tr;
  }

  if (normalized.contains('15%') &&
      (normalized.contains('48 hours') || normalized.contains('48 heures'))) {
    return "15% deduction will apply if canceled at least 48 hours before the rental start time"
        .tr;
  }
  if (normalized.contains('80%') &&
      (normalized.contains('12 hours') || normalized.contains('12 heures'))) {
    return "80% deduction will apply if canceled within 12 hours of the rental start time."
        .tr;
  }
  if (normalized.contains('50%') &&
      normalized.contains('12') &&
      normalized.contains('24')) {
    return "50% deduction will be issued if canceled between 12 and 24 hours prior to the rental start time."
        .tr;
  }

  if (_matchesVehicleRuleLend(normalized)) {
    return "It is forbidden to lend, rent, or sublease the car to a third party.".tr;
  }
  if (_matchesVehicleRuleFuel(normalized)) {
    return "The vehicle must be returned with the same fuel level as at pickup.".tr;
  }
  if (_matchesVehicleRuleSmoking(normalized)) {
    return "Smoking and eating inside the car are not allowed.".tr;
  }
  if (_matchesVehicleRuleDateTime(normalized)) {
    return "The vehicle must be returned on the agreed date, time, and location.".tr;
  }

  return text.tr;
}

bool _matchesVehicleRuleLend(String s) {
  if (s.contains('third party')) return true;
  if (s.contains('sublease')) return true;
  if (s.contains('forbidden') && s.contains('lend')) return true;
  if (s.contains('interdit') &&
      (s.contains('prêter') ||
          s.contains('preter') ||
          s.contains('louer') ||
          s.contains('sous-louer') ||
          s.contains('sous louer')) &&
      s.contains('tiers')) {
    return true;
  }
  return false;
}

bool _matchesVehicleRuleFuel(String s) {
  if (s.contains('fuel level') || (s.contains('same') && s.contains('fuel'))) {
    return true;
  }
  if (s.contains('carburant') ||
      (s.contains('niveau') && s.contains('carburant'))) {
    return true;
  }
  if ((s.contains('même niveau') || s.contains('meme niveau')) &&
      s.contains('carburant')) {
    return true;
  }
  if (s.contains('prise en charge') && s.contains('carburant')) return true;
  return false;
}

bool _matchesVehicleRuleSmoking(String s) {
  if (s.contains('smoking') && s.contains('eating')) return true;
  if (s.contains('fumer') && s.contains('manger')) return true;
  if (s.contains('interdit') &&
      s.contains('fumer') &&
      (s.contains('manger') || s.contains('véhicule') || s.contains('vehicule'))) {
    return true;
  }
  return false;
}

bool _matchesVehicleRuleDateTime(String s) {
  if (s.contains('agreed date') && s.contains('location')) return true;
  if (s.contains('date') &&
      s.contains('heure') &&
      (s.contains('lieu') || s.contains('convenus'))) {
    return true;
  }
  return false;
}

Widget _rulesSheetLineText(String translated) {
  final isRtl = _rulesTextHasArabicScript(translated);
  return Text(
    translated,
    style: const TextStyle(fontSize: 14),
    textAlign: TextAlign.start,
    textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
  );
}

// Compat: ancien nom
String _getCancellationPolicyTranslation(String text) =>
    _translateRulesSheetLine(text);

rulesbuttomSheet(
  BuildContext context, {
  final String? title,
  dynamic list,
  bool isCancellationPolicy = false,
}) {
  showModalBottomSheet(
    enableDrag: true,
    useRootNavigator: true,
    backgroundColor: notifires.getblackwhitecolor,
    isScrollControlled: true,
    useSafeArea: false,
    constraints: const BoxConstraints.expand(width: double.infinity),
    context: context,
    builder: (BuildContext context) {
      final isCancellation = isCancellationPolicy ||
          CancellationPolicyHelper.isCancellationPolicyContext(title, list);

      List<String> rulesList = CancellationPolicyHelper.resolveDisplayRules(
        list,
        isCancellationPolicy: isCancellation,
      );
      if (rulesList.isEmpty &&
          !isCancellation &&
          title != null &&
          title.trim().isNotEmpty) {
        rulesList = [title.trim()];
      }
      
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
            // Titre : ne pas re-traduire si déjà localisé (arabe) ou texte API long.
            Builder(
              builder: (ctx) {
                String headerText = isCancellation
                    ? 'cancellation_policy_title'.tr
                    : (title?.trim().isNotEmpty == true
                        ? title!.trim()
                        : 'cancellation_policy_title'.tr);
                if (!isCancellation && title != null && title!.trim().isNotEmpty) {
                  final t = title!.trim();
                  if (_rulesTextHasArabicScript(t) || t.length > 72) {
                    headerText = t;
                  } else {
                    headerText = t.tr;
                  }
                }
                return Text(
                  headerText,
                  style: boldstyle(context).copyWith(
                    color: notifires.getGrey2Whitecolor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                  textDirection: _rulesTextHasArabicScript(headerText)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                );
              },
            ),
            const SizedBox(height: 20),
            // Liste des règles avec icônes
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: rulesList.isEmpty
                      ? [
                          // Si aucune règle n'est disponible
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _rulesSheetLineText(
                                  "Aucune politique spécifique définie.".tr,
                                ),
                              ),
                            ],
                          ),
                        ]
                      : rulesList.map((rule) {
                          final line = isCancellation
                              ? rule
                              : _translateRulesSheetLine(rule);
                          return isCancellation
                              ? CancellationPolicyHelper.buildRuleListTile(line)
                              : Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Icon(
                                        Icons.done_all,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _rulesSheetLineText(line),
                                      ),
                                    ],
                                  ),
                                );
                        }).toList(),
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
            featuresbox(
                txt: _getCancellationPolicyTranslation('$x'), image: "$x"),
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
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Leave a Review".tr,
            style: heading01.copyWith(
                fontSize: 20, color: getColorBasedOnActiveModuleid()),
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
                          fontWeight: FontWeight.bold, fontSize: 16)),
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
                  // ========== MOCK DATA - OLD API CALL COMMENTED ==========
                  // var response = await httpPost(Config.giveReviewByUser, {
                  //   "rating":
                  //       "${generalScopeController.selectedRatingValue.value.toInt()}",
                  //   "message": textEditingControllerReview.text,
                  //   "booking_id": '$id'
                  // });

                  // MOCK: Simulate network delay
                  await Future.delayed(const Duration(seconds: 1));

                  // MOCK: Static success response for review submission
                  var response = {
                    "status": 200,
                    "message": "Review added successfully",
                    "error": "",
                    "data": {
                      "booking_id": '$id',
                      "rating":
                          "${generalScopeController.selectedRatingValue.value.toInt()}",
                      "message": textEditingControllerReview.text,
                      "review_status": "1"
                    }
                  };
                  // ========== END MOCK DATA ==========
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
                        borderRadius:
                            BorderRadius.circular(Dimensions.radiusSmall),
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
}) {
  return Container(
    alignment: Alignment.center,
    height: 120,
    decoration: BoxDecoration(
      border: Border.all(width: 2.0, color: notifires.getgreywhite),
      borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
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
          fontSize: 14),
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

void _openProfileFromHomeHeader(BuildContext context) {
  if (token.isEmpty) {
    loginAlert(context);
    return;
  }
  if (!isHostMode.value) {
    try {
      generalController.tabController.animateTo(4);
      generalController.currentIndex.value = 4;
      return;
    } catch (_) {
      // TabController pas encore prêt : repli navigation classique.
    }
  }
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MyProfile()),
  );
}

Widget profilePhotoOnHomeScreen(BuildContext context) {
  return Row(
    children: [
      InkWell(
        onTap: () => _openProfileFromHomeHeader(context),
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
                      : buildAvatarImage(
                          profileController.myImage.value,
                          fit: BoxFit.cover,
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
  // Fonction pour créer un widget de texte avec les couleurs pour Carvy
  Widget buildTitleWithColors(String titleText) {
    // Couleurs pour Carvy
    const Color carColor = Color(0xFF27489E); // Bleu pour "car"
    const Color vyColor = Color(0xFFF78F2C); // Orange pour "vy"

    final baseStyle = heading01.copyWith(color: notifires.getGrey1Whitecolor);

    // Vérifier si le titre contient "Carvy" (insensible à la casse)
    final lowerTitle = titleText.toLowerCase();
    if (lowerTitle.contains('carvy')) {
      // Trouver l'index de "carvy" (insensible à la casse)
      final index = lowerTitle.indexOf('carvy');
      final beforeText = titleText.substring(0, index);
      final carvyText =
          titleText.substring(index, index + 5); // "Carvy" ou "carvy"
      final afterText = titleText.substring(index + 5);

      // Déterminer la casse de "Car" et "vy"
      final carPart = carvyText.substring(0, 3); // "Car" ou "car"
      final vyPart = carvyText.substring(3, 5); // "vy"

      return RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          children: [
            // Texte avant Carvy
            if (beforeText.isNotEmpty)
              TextSpan(
                text: beforeText,
                style: baseStyle,
              ),
            // "Car" en bleu
            TextSpan(
              text: carPart,
              style: baseStyle.copyWith(color: carColor),
            ),
            // "vy" en orange
            TextSpan(
              text: vyPart,
              style: baseStyle.copyWith(color: vyColor),
            ),
            // Texte après Carvy
            if (afterText.isNotEmpty)
              TextSpan(
                text: afterText,
                style: baseStyle,
              ),
          ],
        ),
      );
    } else {
      // Si pas de Carvy, utiliser le texte normal
      return Text(
        titleText,
        style: baseStyle,
        textAlign: TextAlign.center,
      );
    }
  }

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Image.asset(image),
      ),
      const SizedBox(
        height: 20,
      ),
      buildTitleWithColors(title),
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
                            Navigator.pop(context);
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

/// Masks the license plate number, keeping only the city code (part after last hyphen)
/// Example: "10000-0-00" -> "****-00", "12345-A-26" -> "****-26"
String maskLicensePlate(String? plateNumber) {
  if (plateNumber == null || plateNumber.isEmpty) {
    return "0";
  }
  
  // Find the last hyphen position
  int lastHyphenIndex = plateNumber.lastIndexOf('-');
  
  // If no hyphen found, return all asterisks
  if (lastHyphenIndex == -1) {
    return '*' * plateNumber.length;
  }
  
  // Extract the city code (part after last hyphen)
  String cityCode = plateNumber.substring(lastHyphenIndex + 1);
  
  // Return masked version: asterisks + hyphen + city code
  return '****-$cityCode';
}

/// Masks only the numbers in a Moroccan license plate with asterisks,
/// keeping letters and hyphens visible.
/// Example: "1-T-5683" -> "*-T-****", "24-A-12345" -> "**-A-*****"
String maskLicensePlateNumbers(String? plateNumber) {
  if (plateNumber == null || plateNumber.isEmpty) {
    return "";
  }
  
  // Replace all digits (0-9) with asterisks, keeping letters and hyphens
  return plateNumber.replaceAll(RegExp(r'\d'), '*');
}

String truncatetext(dynamic data, int maxLength) {
  final String text = " ${data?.toString() ?? 'N/A'}";
  if (text.length > maxLength) {
    return "${text.substring(0, maxLength - 3)}...";
  }
  return text;
}
