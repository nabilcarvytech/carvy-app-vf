import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/controller/general_controller.dart';
import 'package:carvy/controller/home_controller.dart';
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
import '../../../controller/booking_controller.dart';
import '../../../controller/items_detail_controller.dart';
import '../../../customwidget/miscellaneous_project_elements.dart';
import '../../../utils/vehicle_common_widgets.dart';
import '../../../work_space.dart';
import '../../chat/conversation_screen.dart';
import '../../kyc/user_kyc.dart';
import '../../myaccount/publicProfile/public_profile_screen.dart';
import 'package:carvy/customwidget/search_wizard.dart';

class VehicleDetailSScreen extends StatefulWidget {
  final dynamic id;
  final bool? handleback;
  ItemInfo? itemInfo;
  String? frontImage;
  String? address;
  String? city;
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
    this.city,
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
  // Éviter le crash au démarrage : S'assurer que le KycController est bien injecté AVANT que l'UI ne tente de lire activeStatus.value
  late KycController kycController;
  ItemDetailsController vehicleDetailController = Get.find();
  final ValueNotifier<int> vehicleCurrentPageNotifier = ValueNotifier<int>(0);
  final PageController vehiclePagereviewController = PageController();
  PageController vehiclepageControllerslider = PageController();
  SearchControllerHome filterController = Get.find();
  BookingController bookingController = Get.find();
  PublicProfileController publicProfileController = Get.find();
  final ValueNotifier<int> vehiclecurrentPageSliderNotifier =
      ValueNotifier<int>(0);
  int showWishList = -1;
  @override
  void initState() {
    super.initState();
    // Éviter le crash au démarrage : S'assurer que le KycController est bien injecté AVANT que l'UI ne tente de lire activeStatus.value
    try {
      kycController = Get.find<KycController>();
    } catch (e) {
      // Si le contrôleur n'est pas encore injecté, on le crée ou on attend
      print('⚠️ [KYC] KycController non trouvé, tentative de création...');
      kycController = Get.put(KycController());
    }
    print("🚗 VehicleDetailSScreen initState - widget.id: ${widget.id}");
    print(
        "🚗 VehicleDetailSScreen initState - widget.itemInfo: ${widget.itemInfo}");
    print(
        "🚗 VehicleDetailSScreen initState - widget.itemInfo?.hostId: ${widget.itemInfo?.hostId}");
    handleSearchFordetail = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(
          "🚗 VehicleDetailSScreen postFrameCallback - Starting initialization");
      
      // Log du rôle avant l'appel KYC
      try {
        AuthController? authController = Get.find<AuthController>();
        print('🔍 [DEBUG] Statut du rôle avant crash: ${authController.userRole.value}');
      } catch (e) {
        print('⚠️ [DEBUG] AuthController non trouvé: $e');
      }
      
      try {
        kycController.getUserKycData();
        kycController.getKycDetails(); // Récupérer le statut KYC à jour
      } catch (e, stackTrace) {
        print('❌ [VEHICLE_DETAIL] Erreur lors de l\'appel KYC: $e');
        print('❌ [VEHICLE_DETAIL] StackTrace: $stackTrace');
        // Continuer même si le KYC échoue
      }
      if (handleDirectBooking == false) {
        filterController.clearVehicleDetailSearchDates();
      }
      // Load vehicle details data
      print(
          "🚗 VehicleDetailSScreen - Calling getdataVehicle with id: ${widget.id}");
      vehicleDetailController.getdataVehicle(widget.id).then((_) {
        print("🚗 VehicleDetailSScreen - getdataVehicle completed");
        print(
            "🚗 VehicleDetailSScreen - vehicleDetailModel: ${vehicleDetailController.vehicleDetailModel}");
        print(
            "🚗 VehicleDetailSScreen - vehicleDetailModel?.data: ${vehicleDetailController.vehicleDetailModel?.data}");
        print(
            "🚗 VehicleDetailSScreen - vehicleDetailModel?.data?.itemDetails: ${vehicleDetailController.vehicleDetailModel?.data?.itemDetails}");
      }).catchError((error) {
        print("❌ VehicleDetailSScreen - Error in getdataVehicle: $error");
        print("❌ VehicleDetailSScreen - Error stack: ${error.stackTrace}");
      });
      // Only call publicProfileController if itemInfo and hostId are not null
      print("🚗 VehicleDetailSScreen - Checking itemInfo and hostId");
      if (widget.itemInfo != null && widget.itemInfo?.hostId != null) {
        print(
            "🚗 VehicleDetailSScreen - Calling getDataPublicProfile with hostId: ${widget.itemInfo?.hostId}");
        publicProfileController
            .getDataPublicProfile(widget.itemInfo?.hostId?.toString() ?? "");
      } else {
        print(
            "⚠️ VehicleDetailSScreen - itemInfo or hostId is null, skipping getDataPublicProfile");
        print("⚠️ VehicleDetailSScreen - widget.itemInfo: ${widget.itemInfo}");
        print(
            "⚠️ VehicleDetailSScreen - widget.itemInfo?.hostId: ${widget.itemInfo?.hostId}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String? vehicleRating = vehicleDetailController
            .vehicleDetailModel?.data?.itemDetails?.itemRating ??
        "0";
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
                    final itemDetails = vehicleDetailController
                        .vehicleDetailModel?.data?.itemDetails;
                    final regions = Get.find<HomeController>()
                        .homeDataModel
                        ?.data
                        ?.locations;
                    openSearchWizard(
                      context,
                      initialLocation: buildInitialLocationForVehicle(
                        city: itemDetails?.city ?? widget.city,
                        vehicleLat: itemDetails?.latitude,
                        vehicleLng: itemDetails?.longitude,
                        homeRegions: regions,
                      ),
                    );
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
                                        : "---",
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
                  child: GetBuilder<ItemDetailsController>(
                    builder: (controller) {
                      // Utiliser les données du controller en priorité, avec fallback sur widget
                      final itemDetails = controller.vehicleDetailModel?.data?.itemDetails;
                      final currentItemInfo = controller.itemInfo ?? widget.itemInfo;
                      
                      // Récupérer les données pour l'affichage
                      final displayTitle = itemDetails?.title ?? widget.title;
                      final displayRating = itemDetails?.itemRating ?? widget.rating ?? "0";
                      final displayAddress = itemDetails?.address ?? widget.address;
                      final displayCity = itemDetails?.city ?? widget.city;
                      final displayFrontImage = itemDetails?.frontImageUrl ?? widget.frontImage;
                      final displayGalleryImages = itemDetails?.galleryImageUrls ?? currentItemInfo?.galleryImageUrls ?? [];
                      
                      // Gestion de l'état de chargement
                      if (controller.isLoadingVehicle.value) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 250),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      
                      if (controller.isLoadingVehicleNotFound.value) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 250),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.error_outline, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  "Véhicule non trouvé".tr,
                                  style: heading2(context),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Impossible de charger les détails du véhicule".tr,
                                  style: regular2(context),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      
                      return SingleChildScrollView(
                        child: Column(
                          children: <Widget>[
                            CustomImagesForDetails(
                              imagesList: displayGalleryImages,
                              frontImage: displayFrontImage ?? '',
                            ),

                            ListTile(
                              contentPadding: const EdgeInsets.only(
                                  left: 12, right: 12, top: 10),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      displayTitle != null
                                          ? (displayTitle.length > 50
                                              ? "${displayTitle.substring(0, 50)}..."
                                              : displayTitle)
                                          : "Chargement...".tr,
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
                                    displayRating,
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
                                          ([displayAddress, displayCity]
                                                      .where((s) =>
                                                          s != null && s.isNotEmpty)
                                                      .join(" • "))
                                                  .isNotEmpty
                                              ? [displayAddress, displayCity]
                                                  .where((s) =>
                                                      s != null && s.isNotEmpty)
                                                  .join(" • ")
                                              : "Unknown Location".tr,
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

                            if ((itemDetails?.hasDiscounts ??
                                    currentItemInfo?.hasDiscounts ??
                                    false) ==
                                true)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: _buildSpecialOffersCard(
                                  context,
                                  weeklyDiscount: itemDetails
                                          ?.weeklyDiscountValue
                                          ?.toString() ??
                                      currentItemInfo?.weeklyDiscountValue
                                          ?.toString(),
                                  monthlyDiscount: itemDetails
                                          ?.monthlyDiscountValue
                                          ?.toString() ??
                                      currentItemInfo?.monthlyDiscountValue
                                          ?.toString(),
                                ),
                              ),

                            const SizedBox(
                              height: 10,
                            ),

                            // Utiliser currentItemInfo qui est défini dans le GetBuilder parent
                            Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: notifires.getboxcolor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: grey6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.car_rental,
                                            size: 22,
                                            color: getColorBasedOnActiveModuleid(),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Vehicle Type'.tr,
                                            style: regular2(context).copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Builder(
                                        builder: (context) {
                                          final List<String> categories =
                                              (currentItemInfo?.categoryList != null &&
                                                      currentItemInfo!.categoryList!.isNotEmpty)
                                                  ? currentItemInfo.categoryList!
                                                  : (itemDetails?.categoryList ?? <String>[]);
                                          if (categories.isNotEmpty) {
                                            return Align(
                                              alignment: Alignment.center,
                                              child: Wrap(
                                                spacing: 8,
                                                runSpacing: 6,
                                                alignment: WrapAlignment.center,
                                                children: categories
                                                    .map(
                                                      (name) => Container(
                                                        padding: const EdgeInsets.symmetric(
                                                          horizontal: 12,
                                                          vertical: 6,
                                                        ),
                                                        decoration: BoxDecoration(
                                                          color: Theme.of(context)
                                                              .primaryColor
                                                              .withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(20),
                                                          border: Border.all(
                                                            color: Theme.of(context).primaryColor,
                                                          ),
                                                        ),
                                                        child: Text(
                                                          name,
                                                          style: TextStyle(
                                                            color: Theme.of(context).primaryColor,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            );
                                          }
                                          return Text(
                                            currentItemInfo?.type ??
                                                itemDetails?.itemType ??
                                                'CAR',
                                            style: regular2(context),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                if (currentItemInfo?.makeType != null)
                                  carItemBox(
                                    icon: Icons.settings,
                                    title: 'Make'.tr,
                                    desc: '${currentItemInfo?.makeType}',
                                  ),
                                if (currentItemInfo?.displayModelName != null &&
                                    (currentItemInfo!.displayModelName).isNotEmpty)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      carItemBox(
                                        icon: Icons.star_border_outlined,
                                        title: 'Model'.tr,
                                        desc: currentItemInfo!.displayModelName,
                                      ),
                                      if ((currentItemInfo?.modelName ?? '')
                                              .toLowerCase() ==
                                          'autre')
                                        Padding(
                                          padding: const EdgeInsets.only(top: 6.0, left: 4.0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text(
                                              'Saisie manuelle',
                                              style: TextStyle(
                                                  fontSize: 10, color: Colors.orange),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                if (currentItemInfo?.year != null)
                                  carItemBox(
                                    icon: Icons.calendar_month_outlined,
                                    title: 'Year'.tr,
                                    desc: '${currentItemInfo?.year}',
                                  ),
                                if (currentItemInfo?.transmission != null)
                                  carItemBox(
                                    icon: Icons.track_changes,
                                    title: 'Transmission'.tr,
                                    desc: '${currentItemInfo?.transmission}',
                                  ),
                                if (currentItemInfo?.odometer != null)
                                  carItemBox(
                                    icon: Icons.traffic_outlined,
                                    title: 'Odometer'.tr,
                                    desc: '${currentItemInfo?.odometer}',
                                  ),
                                if (currentItemInfo?.fuelType != null)
                                  carItemBox(
                                    icon: Icons.local_gas_station,
                                    title: 'Fuel Type'.tr,
                                    desc:
                                        '${currentItemInfo?.fuelType == "" ? "Petrol" : "${currentItemInfo?.fuelType}"}',
                                  ),
                                if (currentItemInfo?.seatCapicity != null)
                                  carItemBox(
                                    icon: Icons.event_seat,
                                    title: 'Seats'.tr,
                                    desc: '${currentItemInfo?.seatCapicity}',
                                  ),
                                carItemBox(
                                  icon: Icons.credit_card,
                                  title: 'Plate Number'.tr,
                                  desc: formatPlate(
                                      currentItemInfo?.platNumber),
                                ),
                                carItemBox(
                                  icon: Icons.event,
                                  title: 'Minimum Rental Days'.tr,
                                  desc:
                                      '${currentItemInfo?.minRentalDays ?? "0"}',
                                ),
                                carItemBox(
                                  icon: Icons.person_2,
                                  title: 'Minimum Age'.tr,
                                  desc:
                                      '${currentItemInfo?.ageRistriction ?? "0"}',
                                ),
                                carItemBox(
                                  icon: Icons.verified_user,
                                  title: 'Insurance Coverage'.tr,
                                  desc:
                                      '${currentItemInfo?.insuranceCoverage ?? "0"}',
                                ),
                              ],
                            ),

                            // Description (sans titre « À propos du véhicule »)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeDefault,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      buildDescriptionWidget(currentItemInfo),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      buildShowMoreButton(currentItemInfo),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Large Caution Card - Separate from grid
                            GetBuilder<ItemDetailsController>(
                              builder: (controller) {
                                final depositValue = controller.vehicleDetailModel
                                        ?.data?.itemDetails?.depositValue ??
                                    '';
                                final depositManager = controller.vehicleDetailModel
                                        ?.data?.itemDetails?.depositManager ??
                                    '';

                                return CautionCard(
                                  depositValue: depositValue,
                                  depositManager: depositManager,
                                  context: context,
                                );
                              },
                            ),

                            const SizedBox(height: 16),
                            _buildHomeDeliveryCard(context, currentItemInfo),
                            Builder(
                              builder: (context) {
                                try {
                                  final rawFeatures = currentItemInfo?.featuresData ?? [];
                                  final safeFeatures = rawFeatures.where((x) {
                                    final name = (x.name ?? '').toString().trim();
                                    return name.isNotEmpty && name.toLowerCase() != 'null';
                                  }).toList();

                                  // Règle UX: pas de titre/section si aucune caractéristique exploitable.
                                  if (safeFeatures.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 5,
                                      horizontal: Dimensions.paddingSizeDefault,
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Car Features'.tr, style: heading2(context)),
                                        const SizedBox(height: 7),
                                        for (var x in safeFeatures.take(6))
                                          Padding(
                                            padding: const EdgeInsets.only(left: 8, top: 5),
                                            child: Column(
                                              children: [
                                                featuresbox(
                                                  txt: '${x.name}',
                                                  image: "${x.imageUrl}",
                                                ),
                                                const SizedBox(height: 10),
                                              ],
                                            ),
                                          ),
                                        if (safeFeatures.length > 6)
                                          InkWell(
                                            onTap: () {
                                              featuresBottomSheet(
                                                context,
                                                title: 'Vehicle Features'.tr,
                                                list: safeFeatures,
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Read more'.tr,
                                                  style: regular2(context).copyWith(
                                                    color: getColorBasedOnActiveModuleid(),
                                                  ),
                                                ),
                                                const SizedBox(width: 5),
                                                Icon(
                                                  Icons.arrow_forward,
                                                  size: 16,
                                                  color: getColorBasedOnActiveModuleid(),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                } catch (_) {
                                  // Règle UX: un échec optionnel ne doit jamais casser le reste de la page.
                                  return const SizedBox.shrink();
                                }
                              },
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
                            Builder(builder: (context) {
                              final lat = _parseCoordinate(
                                  itemDetails?.latitude ?? widget.latitute);
                              final lng = _parseCoordinate(
                                  itemDetails?.longitude ?? widget.longtitute);
                              final cityName =
                                  (itemDetails?.city ?? widget.city ?? '')
                                      .toString()
                                      .trim();
                              final countryName =
                                  (itemDetails?.stateRegion ?? '')
                                      .toString()
                                      .trim();
                              final locationLabel = [
                                cityName,
                                countryName,
                              ].where((value) => value.isNotEmpty).join(', ');

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            12, 12, 12, 0),
                                        child: Text(
                                          locationLabel.isNotEmpty
                                              ? locationLabel
                                              : "Approximate area".tr,
                                          style: regular2(context).copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      SizedBox(
                                        height: 220,
                                        width: double.infinity,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: (lat != null && lng != null)
                                              ? GoogleMap(
                                                  initialCameraPosition:
                                                      CameraPosition(
                                                    target: LatLng(lat, lng),
                                                    zoom: 11.5,
                                                  ),
                                                  liteModeEnabled: true,
                                                  markers: const <Marker>{},
                                                  circles: const <Circle>{},
                                                  zoomControlsEnabled: false,
                                                  myLocationButtonEnabled:
                                                      false,
                                                  mapToolbarEnabled: false,
                                                  scrollGesturesEnabled: false,
                                                  zoomGesturesEnabled: false,
                                                  rotateGesturesEnabled: false,
                                                  tiltGesturesEnabled: false,
                                                  compassEnabled: false,
                                                )
                                              : Center(
                                                  child: Text(
                                                    'Map is not available'.tr,
                                                    style: headingh5,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),

                            (currentItemInfo?.reviewData?.isEmpty ?? true)
                                ? const SizedBox()
                                : buildDivider(),
                            (currentItemInfo?.reviewData?.isEmpty ?? true)
                                ? const SizedBox()
                                : const SizedBox(
                                    height: 15,
                                  ),
                            (currentItemInfo?.reviewData?.isEmpty ?? true)
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
                                            ' ${"Review".tr} (${itemDetails?.totalReviews ?? currentItemInfo?.totalReviews ?? "No review Here"})',
                                            style: heading2(context),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      (currentItemInfo?.reviewData?.isEmpty ?? true)
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

                            (currentItemInfo?.reviewData?.isEmpty ?? true)
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
                                            currentItemInfo?.reviewData?.length ?? 0,
                                        physics: const BouncingScrollPhysics(),
                                        itemBuilder: (context, index) {
                                          final reviewData = currentItemInfo?.reviewData ?? [];
                                          final currentReview = (index < reviewData.length) ? reviewData[index] : null;
                                      final guestProfileImage = currentReview?["guest_profile_image"];
                                      print(guestProfileImage);
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
                                              child: guestProfileImage != null &&
                                                      guestProfileImage.toString().isNotEmpty
                                                  ? myNetworkImage(
                                                      guestProfileImage.toString(),
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
                                                currentReview?["guest_name"]?.toString() ??
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
                                                    initialRating: double.tryParse(
                                                      currentReview?["rating"]?.toString() ?? 
                                                      reviewData[vehicleCurrentPageNotifier.value]?["rating"]?.toString() ??
                                                      "0",
                                                    ) ?? 0.0,
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
                                                    currentReview?["updated_at"]?.toString() ?? "Timestamp Missing",
                                                    style: regular(context),
                                                  ),
                                                ],
                                              ),
                                              currentReview?["message"] == null
                                                  ? const SizedBox()
                                                  : Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              top: 4),
                                                      child: Text(
                                                        "${(currentReview["message"]?.toString().length ?? 0) > 32 ? (currentReview["message"]?.toString().substring(0, 32) ?? "") + "..." : currentReview["message"]?.toString() ?? ""}",
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

                        (widget.itemInfo?.reviewData?.isEmpty ?? true)
                            ? const SizedBox()
                            : ValueListenableBuilder<int>(
                                valueListenable: vehicleCurrentPageNotifier,
                                builder: (context, value, child) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      widget.itemInfo?.reviewData?.length ?? 0,
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
                        // Vehicle Rules Section - Matching Cancellation Policy style
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: GetBuilder<ItemDetailsController>(
                            builder: (controller) {
                              // Get vehicle_rules from the controller
                              final vehicleRules = controller.vehicleDetailModel
                                      ?.data?.itemDetails?.vehicleRules ??
                                  [];

                              return GestureDetector(
                                onTap: () {
                                  rulesbuttomSheet(
                                    context,
                                    title: 'Vehicle Rules'.tr,
                                    list: vehicleRules.isEmpty
                                        ? [
                                            'No vehicle rules specified by the host.',
                                          ]
                                        : vehicleRules,
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
                                          'Vehicle Rules'.tr,
                                          style: regular3(context)
                                              .copyWith(color: acentColor),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () {
                                            rulesbuttomSheet(
                                              context,
                                              title: 'Vehicle Rules'.tr,
                                              list: vehicleRules.isEmpty
                                                  ? [
                                                      'No vehicle rules specified by the host.',
                                                    ]
                                                  : vehicleRules,
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
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 12, right: 12),
                          child: GetBuilder<ItemDetailsController>(
                            builder: (controller) {
                              // Get cancellation_rules from the controller (List<String> directement depuis le backend)
                              final cancellationRules = controller
                                      .vehicleDetailModel
                                      ?.data
                                      ?.itemDetails
                                      ?.cancellationRules ??
                                  [];

                              return GestureDetector(
                                onTap: () {
                                  rulesbuttomSheet(
                                    context,
                                    title: "Politique d'annulation".tr,
                                    list: cancellationRules.isNotEmpty
                                        ? cancellationRules
                                        : [
                                            "Aucune politique spécifique définie."
                                                .tr
                                          ],
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
                                                  "Politique d'annulation".tr,
                                              list: cancellationRules.isNotEmpty
                                                  ? cancellationRules
                                                  : [
                                                      "Aucune politique spécifique définie."
                                                          .tr
                                                    ],
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
                              );
                            },
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),

                            GestureDetector(
                              onTap: () {
                                final hostId = itemDetails?.hostId ?? currentItemInfo?.hostId;
                                final hostProfileImage = itemDetails?.hostProfileImage ?? currentItemInfo?.hostProfileImage;
                                final hostFirstName = itemDetails?.hostFirstName ?? currentItemInfo?.hostFirstName;
                                final hostLastName = itemDetails?.hostLastName ?? currentItemInfo?.hostLastName;
                                print(hostProfileImage);
                                Get.to(() => PublicProfile(
                                      userid: hostId?.toString() ?? "",
                                      photo: displayFrontImage,
                                      userName:
                                          "${hostFirstName ?? ""} ${hostLastName ?? ""}".trim(),
                                      profileImage: hostProfileImage ?? "",
                                    ));
                              },
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: (itemDetails?.hostProfileImage ?? currentItemInfo?.hostProfileImage) != null &&
                                          ((itemDetails?.hostProfileImage ?? currentItemInfo?.hostProfileImage)?.isNotEmpty ?? false)
                                      ? Image.network(
                                          "${itemDetails?.hostProfileImage ?? currentItemInfo?.hostProfileImage}",
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
                                  // Utiliser le statut de vérification du véhicule si disponible
                                  // TODO: dynamic verified status basé sur un flag host-level dédié si le backend l'expose
                                  ((itemDetails?.isVerified ?? currentItemInfo?.isVerified)
                                                  ?.toString() ==
                                              '1')
                                      ? "${"Hosted by".tr} ${"Verified Member".tr}"
                                      : "Hosted by".tr,
                                  style: heading3Grey1(context),
                                ),
                                subtitle: Text('View profile'.tr,
                                    style: regular2(context).copyWith(
                                      color: getColorBasedOnActiveModuleid(),
                                    )),
                                trailing: widget.chatafterBooking == null
                                    ? const SizedBox()
                                    : (itemDetails?.hostId ?? currentItemInfo?.hostId) == null ||
                                            (itemDetails?.hostId ?? currentItemInfo?.hostId)?.toString() ==
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
                      );
                    },
                  ),
                ),
                Positioned(
                    left: 0,
                    top: MediaQuery.of(context).padding.top + 10,
                    child: SafeArea(
                      bottom: false,
                      child: backButtonfordetailPageForVehicle(context, true),
                    )),
                Positioned(
                  right: 15,
                  top: MediaQuery.of(context).padding.top + 15,
                  child: SafeArea(
                    bottom: false,
                    child: isHostMode.value == true
                        ? const SizedBox()
                        : showWishList == 0
                            ? const SizedBox(
                                height: 25,
                                width: 25,
                                child:
                                    Center(child: CircularProgressIndicator()))
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
                ),
              ],
            ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barre de navigation principale
          Container(
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
                      // Prix uniquement (sans le texte qui cause l'overflow)
                      GetBuilder<ItemDetailsController>(
                        builder: (controller) {
                          final displayPrice = controller.vehicleDetailModel?.data?.itemDetails?.price ?? widget.price ?? "0";
                          return Text(
                            "$currency $displayPrice",
                            style: heading2(context)
                                .copyWith(color: getColorBasedOnActiveModuleid()),
                          );
                        },
                      ),
                      const Spacer(),
                      GetBuilder<ItemDetailsController>(
                        builder: (controller) {
                          final currentItemInfo = controller.itemInfo ?? widget.itemInfo;
                          final itemDetails = controller.vehicleDetailModel?.data?.itemDetails;
                          final hostId = itemDetails?.hostId ?? currentItemInfo?.hostId;
                          final serviceType = currentItemInfo?.serviceType?.toString() ?? itemDetails?.itemType;
                          return SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () async {
                                await _handleNextButtonPress(context);
                              },
                              style: ButtonStyle(
                                backgroundColor: WidgetStateProperty.all(
                                    getColorBasedOnActiveModuleid()),
                                shape: WidgetStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
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
                          );
                          
                          // ========== CODE ORIGINAL (COMMENTÉ POUR TESTS) ==========
                          /*
                          return loginModel != null &&
                                  hostId?.toString() ==
                                      userId.toString()
                              ? const SizedBox()
                              : serviceType == "sale" ||
                                      serviceType == "rent"
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
                                              final phone = itemDetails?.hostPhone ?? currentItemInfo?.hostPhone ?? "";
                                              if (phone.isNotEmpty) {
                                                launchUrl(Uri.parse('tel:$phone'));
                                              }
                                            },
                                            icon: Icon(Icons.call,
                                                color:
                                                    getColorBasedOnActiveModuleid()),
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
                                              final email = itemDetails?.hostEmail ?? currentItemInfo?.hostEmail ?? "";
                                              if (email.isNotEmpty) {
                                                launchUrl(Uri.parse('mailto:$email'));
                                              }
                                            },
                                            icon: Icon(Icons.email,
                                                color:
                                                    getColorBasedOnActiveModuleid()),
                                          ),
                                        ),
                                      ],
                                    )
                                  : serviceType == "booking"
                                      ? isHostMode.value == true
                                          ? const SizedBox()
                                          : SizedBox(
                                              height: 40,
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  await _handleNextButtonPress(
                                                      context);
                                                },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  WidgetStateProperty.all(
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
                                                  overflow:
                                                      TextOverflow.ellipsis),
                                                ),
                                              ),
                                            )
                                      : const SizedBox();
                          */
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode pour gérer l'action du bouton "Next"
  Future<void> _handleNextButtonPress(BuildContext context) async {
    if (token.isEmpty) {
      loginAlert(context);
      return;
    }

    if (loginModel != null &&
        widget.itemInfo?.hostId.toString() == userId.toString()) {
      showErrorToastMessage("You can't book your own vehicle");
      return;
    }

    // ========== VÉRIFICATION DU STATUT KYC ==========
    final kycStatus = kycController.activeStatus.value.toLowerCase();

    // Si le statut est 'none' ou 'no' ET que l'utilisateur n'a pas passé cette étape dans cette session,
    // rediriger vers UserKyc()
    if ((kycStatus == "none" || kycStatus == "no" || kycStatus.isEmpty) &&
        !kycController.hasSkippedInSession.value) {
      Get.to(() => const UserKyc());
      return;
    }

    // Si le statut est 'pending', 'waiting', 'review' ou 'verified' (ou si l'utilisateur a passé l'étape),
    // ignorer l'étape KYC et continuer avec la navigation normale

    final SearchControllerHome searchController = Get.find();

    final hasSearchDates = generalScopeController
            .startDateCustomDate.value.isNotEmpty &&
        generalScopeController.endDateCustomDate.value.isNotEmpty;

    if (hasSearchDates) {
      bookingController.selectedStartTime.value =
          searchController.startTimeSearch.value;
      bookingController.selectedEndTime.value =
          searchController.endTimeSearch.value;
      bookingController.startDate.value =
          generalScopeController.startDateCustomDate.value;
      bookingController.endDate.value =
          generalScopeController.endDateCustomDate.value;
    } else {
      bookingController.selectedStartTime.value = '';
      bookingController.selectedEndTime.value = '';
      bookingController.startDate.value = '';
      bookingController.endDate.value = '';
    }

    if (handleDirectBooking == true) {
      final itemDetailToSend =
          vehicleDetailController.itemInfo ?? widget.itemInfo;

      bookingController.commonNavigateToBookingSummary(
        context,
        widget.id,
        itemDetailToSend,
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

    bookingController.vehicleBookingTunnelComplete.value = false;
    if (!context.mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleCheckAvailability(
          idFeatured: widget.id,
          itemDetails: widget.itemInfo,
          address: widget.address,
          frontImage: widget.frontImage,
          title: widget.title,
          rating: widget.rating,
          itemType: widget.itemType,
          price: widget.price,
        ),
      ),
    );
  }

  /// Carte « Livraison à domicile » — même enveloppe visuelle que [CautionCard].
  Widget _buildHomeDeliveryCard(BuildContext context, ItemInfo? currentItemInfo) {
    final locations = currentItemInfo?.deliveryLocations;
    if (locations == null || locations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
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
              Row(
                children: [
                  const Text('🚚', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 12),
                  Text(
                    'Livraison à domicile'.tr,
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              Divider(
                height: 24,
                thickness: 1,
                color: Colors.grey.withOpacity(0.2),
              ),
              for (int index = 0; index < locations.length; index++) ...[
                if (index > 0) const SizedBox(height: 10),
                _buildDeliveryLocationRow(context, locations[index]),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeliveryLocationRow(BuildContext context, dynamic item) {
    final location = item is Map ? item['location'] : null;
    final cityName = location is Map
        ? location['cityName']?.toString()
        : null;
    final price = item is Map ? item['price'] : null;
    final priceText = price?.toString() ?? '';

    return Row(
      children: [
        Expanded(
          child: Text(
            (cityName != null && cityName.trim().isNotEmpty) ? cityName : '-',
            style: regular3(context).copyWith(
              fontSize: 14,
              color: notifires.getwhiteblackcolor,
              overflow: TextOverflow.ellipsis,
            ),
            maxLines: 1,
          ),
        ),
        Text(
          'MAD $priceText',
          style: regular2(context).copyWith(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: getColorBasedOnActiveModuleid(),
          ),
        ),
      ],
    );
  }

  Widget buildDescriptionWidget(ItemInfo? itemInfo) {
    final description = (itemInfo?.description ?? vehicleDetailController.vehicleDetailModel?.data?.itemDetails?.description ?? "");
    return Expanded(
      child: Text(
        description,
        style: regular2(context).copyWith(overflow: TextOverflow.ellipsis),
        maxLines:
            vehicleDetailController.vehicleisDescriptionExpanded ? null : 5,
      ),
    );
  }

  Widget buildShowMoreButton(ItemInfo? itemInfo) {
    final description = Intl.message(
      itemInfo?.description ?? vehicleDetailController.vehicleDetailModel?.data?.itemDetails?.description ?? "",
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

  double? _parseCoordinate(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  String formatPlate(String? plate) {
    if (plate == null || plate.isEmpty) return 'N/A';
    if (plate.length < 3) return plate;

    // Logique pour extraire la fin (ex: 1-A) et l'afficher au début
    var parts = plate.split('-');
    if (parts.length >= 3) {
      return '${parts[2]}-${parts[1]}-*****';
    }
    return plate;
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

  Widget _buildDiscountBadge(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3310B981),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        style: regular2(context).copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSpecialOffersCard(
    BuildContext context, {
    String? weeklyDiscount,
    String? monthlyDiscount,
  }) {
    final weekly = _formatDiscountValue(weeklyDiscount);
    final monthly = _formatDiscountValue(monthlyDiscount);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFBEB), Color(0xFFFFF7ED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFF59E0B),
          width: 1.1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14F59E0B),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEDD5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.local_offer_rounded,
                  color: Color(0xFFEA580C),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Special offers'.tr,
                      style: heading3(context).copyWith(
                        color: const Color(0xFF9A3412),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Automatic discounts based on duration'.tr,
                      style: regular3(context).copyWith(
                        color: const Color(0xFFB45309),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              _buildDiscountBadge(
                context,
                'Discount 7d+: @pct'.trParams({'pct': '$weekly%'}),
              ),
              _buildDiscountBadge(
                context,
                'Discount 30d+: @pct'.trParams({'pct': '$monthly%'}),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDiscountValue(String? rawValue) {
    if (rawValue == null) return '0';
    final cleaned = rawValue.replaceAll('%', '').replaceAll('-', '').trim();
    if (cleaned.isEmpty) return '0';
    return cleaned;
  }
}
