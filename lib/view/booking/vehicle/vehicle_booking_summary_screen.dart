import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/controller/kyc_controller.dart';
import 'package:carvy/view/kyc/user_kyc.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:get/get.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/booking/payment_method_screen.dart';
import 'package:carvy/view/chat/conversation_screen.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/itemdetail/vehicle/vehicle_check_availability_screen.dart';
import '../../../controller/general_controller.dart';
import '../../../controller/booking_controller.dart';
import '../../../controller/items_detail_controller.dart';
import '../../../model/vehicle_home_model.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/vehicle_common_widgets.dart';
import '../../../work_space.dart';

class VehicleBookingSummary extends StatefulWidget {
  final dynamic bookingForSomeOne;
  final dynamic noteForOwner;
  final dynamic numberofguest;
  final dynamic idFeatured;
  final int? totalNight;
  final ItemInfo? itemDetails;
  final String? frontImage;
  final String? address;
  final String? rating;
  final String? itemType;
  final String? title;
  final String? price;
  final String? isAddDoorStepPrice;
  const VehicleBookingSummary({
    super.key,
    this.bookingForSomeOne,
    this.noteForOwner,
    this.numberofguest,
    this.idFeatured,
    this.totalNight,
    this.itemDetails,
    this.address,
    this.rating,
    this.itemType,
    this.title,
    this.price,
    this.isAddDoorStepPrice,
    this.frontImage,
  });

  @override
  State<VehicleBookingSummary> createState() => _VehicleBookingSummaryState();
}

class _VehicleBookingSummaryState extends State<VehicleBookingSummary> {
  BookingController bookingController = Get.find();

  ItemDetailsController vehicleDetailController = Get.find();
  
  // État de validation de la politique d'annulation
  bool isPolicyAccepted = false;

  getData(coupon, wallet) async {
    setState(() {});
    await bookingController.getDataBookingSummery(
        widget.idFeatured, coupon, wallet, widget.isAddDoorStepPrice,
        dailyPrice: widget.price);
    await bookingController.getWalletData();
    setState(() {});
  }

  bool switchWallet = false;
  @override
  void initState() {
    super.initState();
    print('🔄 [initState] Début de l\'initialisation de VehicleBookingSummary');
    debugPrint(
        '🔄 [initState] Début de l\'initialisation de VehicleBookingSummary');

    handleDirectBooking = false;
    handleBackonBooking = false;
    generalController.myBookingTabIndex.value = 0;
    bookingController.textEditingController.clear();
    bookingController.getItemPrices = null;
    bookingController.isPaymentSuccess.value = false;
    print('📋 [initState] isAddDoorStepPrice: ${widget.isAddDoorStepPrice}');
    debugPrint(
        '📋 [initState] isAddDoorStepPrice: ${widget.isAddDoorStepPrice}');

    bookingController.textEditingController
        .addListener(bookingController.listner);
    bookingController.currency = currency;

    // Utiliser addPostFrameCallback pour s'assurer que le framework Flutter est prêt
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print(
          '✅ [initState] addPostFrameCallback exécuté - Framework Flutter prêt');
      debugPrint(
          '✅ [initState] addPostFrameCallback exécuté - Framework Flutter prêt');

      if (token.isNotEmpty) {
        print('🔐 [initState] Token présent, appel de getData()');
        debugPrint('🔐 [initState] Token présent, appel de getData()');
        getData("", "");
      } else {
        print('⚠️ [initState] Token vide, getData() non appelé');
        debugPrint('⚠️ [initState] Token vide, getData() non appelé');
      }

      print('✅ [initState] Fin de l\'initialisation de VehicleBookingSummary');
      debugPrint(
          '✅ [initState] Fin de l\'initialisation de VehicleBookingSummary');
    });
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
      },
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Dimensions.containerWidth,
          child: Scaffold(
            bottomNavigationBar: bookingController.getItemPrices == null
                ? SizedBox()
                : SafeArea(
                    child: Container(
                      height: 100,
                      width: Get.size.width,
                      color: notifires.getbgcolor,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            Obx(() {
                              // Réinitialiser hasSkippedKyc après une réservation réussie
                              if (bookingController.isPaymentSuccess.value ==
                                  true) {
                                final kycController = Get.find<KycController>();
                                kycController.hasSkippedKyc.value = false;
                              }

                              if (bookingController.isPaymentSuccess.value ==
                                  true) {
                                return Row(
                                  children: [
                                    Expanded(
                                      child: CustomsButtons(
                                          onPressed: () {
                                            generalController
                                                .currentIndex.value = 2;
                                            Get.offAll(() => const HomeMain(
                                                  initialIndex: 2,
                                                ));
                                          },
                                          // text: "Pay now".tr,
                                          text: "See Bookings".tr,
                                          backgroundColor:
                                              getColorBasedOnActiveModuleid()),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Expanded(
                                      child: CustomsButtons(
                                          onPressed: () {},
                                          text: "Chat".tr,
                                          backgroundColor:
                                              getColorBasedOnActiveModuleid()),
                                    )
                                  ],
                                );
                              }

                              return ConstrainedBox(
                                constraints: const BoxConstraints.expand(
                                    width: double.infinity, height: 50.0),
                                child: ElevatedButton(
                                    onPressed: (bookingController
                                            .isProcessingBooking.value || !isPolicyAccepted)
                                        ? null
                                        : () {
                                            // Afficher un message si la politique n'est pas acceptée
                                            if (!isPolicyAccepted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text("Veuillez accepter la politique d'annulation avant de continuer.".tr),
                                                  backgroundColor: Colors.orange,
                                                  duration: const Duration(seconds: 3),
                                                  action: SnackBarAction(
                                                    label: "OK".tr,
                                                    textColor: Colors.white,
                                                    onPressed: () {
                                                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                    },
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            KycController kycController =
                                                Get.find();
                                            final kycStatus = kycController
                                                .activeStatus.value;

                                            // Debug: Vérifier si le clic a bien été enregistré
                                            print(
                                                'DEBUG: Skip flag is ${kycController.hasSkippedInSession.value}');

                                            // Si le statut est NONE (vide, "no", "none") ET que l'utilisateur n'a pas encore cliqué sur Skip dans cette session,
                                            // rediriger vers UserKyc. Sinon, continuer avec la réservation.
                                            if ((kycStatus.isEmpty ||
                                                    kycStatus == "no" ||
                                                    kycStatus == "none") &&
                                                !kycController
                                                    .hasSkippedInSession
                                                    .value) {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (builder) =>
                                                          const UserKyc()));
                                              return;
                                            }

                                            // Si le statut est PENDING ou VERIFIED/approved, autoriser le paiement
                                            // (ignorer l'étape KYC et continuer directement vers le paiement)
                                            // Convertir en minuscules pour une comparaison insensible à la casse
                                            final kycStatusLower =
                                                kycStatus.toLowerCase();
                                            if (kycStatusLower == "pending" ||
                                                kycStatusLower == "review" ||
                                                kycStatusLower == "approved" ||
                                                kycStatusLower == "verified") {
                                              // Continuer avec le processus de paiement
                                              if (loginModel!.data!.firstName !=
                                                  null) {
                                                if (loginModel!
                                                        .data!.firstName ==
                                                    "") {
                                                  profileUpdate(context);
                                                  return;
                                                }
                                              } else if ((loginModel!
                                                      .data!.lastName !=
                                                  null)) {
                                                if (loginModel!
                                                        .data!.lastName ==
                                                    "") {
                                                  profileUpdate(context);
                                                  return;
                                                }
                                              }
                                              // Naviguer vers l'écran de sélection des méthodes de paiement
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PaymentMethodScreen(
                                                    vehicleId: widget.idFeatured
                                                        .toString(),
                                                  ),
                                                ),
                                              );
                                              return;
                                            }

                                            // Pour les autres statuts (rejected, etc.), utiliser la logique existante
                                            kycController
                                                .kycStatus(kycStatus, context)
                                                .then((isValid) {
                                              if (!isValid) return;
                                              if (loginModel!.data!.firstName !=
                                                  null) {
                                                if (loginModel!
                                                        .data!.firstName ==
                                                    "") {
                                                  profileUpdate(context);
                                                  return;
                                                }
                                              } else if ((loginModel!
                                                      .data!.lastName !=
                                                  null)) {
                                                if (loginModel!
                                                        .data!.lastName ==
                                                    "") {
                                                  profileUpdate(context);
                                                  return;
                                                }
                                              }
                                              // Naviguer vers l'écran de sélection des méthodes de paiement
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      PaymentMethodScreen(
                                                    vehicleId: widget.idFeatured
                                                        .toString(),
                                                  ),
                                                ),
                                              );
                                            });
                                          },
                                    style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.only(
                                            left: 5,
                                            right: 5,
                                            top: 10,
                                            bottom: 10),
                                        backgroundColor: isPolicyAccepted
                                            ? getColorBasedOnActiveModuleid()
                                            : Colors.grey, // Gris quand désactivé
                                        disabledBackgroundColor: Colors.grey,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12))),
                                    child: bookingController
                                            .isProcessingBooking.value
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : Text(
                                            generalDataModel?.data?.metaData
                                                        ?.onlinePayment
                                                        .toString() ==
                                                    "Inactive"
                                                ? "Confirm"
                                                : "Pay now".tr,
                                            style: heading2(context)
                                                .copyWith(color: bgColor),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          )),
                              );
                            })
                          ],
                        ),
                      ),
                    ),
                  ),
            backgroundColor: notifires.getbgcolor,
            appBar: AppBar(
              backgroundColor: notifires.getbgcolor,
              elevation: 0,
              scrolledUnderElevation: 0,
              leadingWidth: 80,
              leading: GestureDetector(
                  onTap: () {
                    if (handleBoackfromPayment == true) {
                      bookingScetionClean(context);

                      return;
                    }
                    setdefultData();
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 20, top: 8, bottom: 8, right: 20),
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
                        child: Icon(Icons.arrow_back,
                            color: getColorBasedOnActiveModuleid()),
                      ),
                    ),
                  )),
              title: Obx(
                () => bookingController.isPaymentSuccess.value == true
                    ? Text(
                        'Booking Summary'.tr,
                        style: heading2Grey1(context).copyWith(),
                      )
                    : Text(
                        'Confirm and Pay'.tr,
                        style: heading2Grey1(context).copyWith(),
                      ),
              ),
            ),
            body: connectionLost == true
                ? Center(
                    child: connectionError(context, "Something Went Wrong".tr),
                  )
                : bookingController.getItemPrices == null
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            // Bandeau d'information si KYC a été passé
                            Obx(() {
                              final kycController = Get.find<KycController>();
                              if (kycController.hasSkippedInSession.value) {
                                return Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.all(20),
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.orange.shade200,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange.shade700,
                                        size: 24,
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          "Note : Vous pourrez finaliser votre profil (permis) plus tard dans votre espace compte."
                                              .tr,
                                          style: TextStyle(
                                            color: Colors.orange.shade900,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            }),
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: GestureDetector(
                                onTap: () {},
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          color: grey5,
                                          borderRadius:
                                              BorderRadius.circular(0),
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(0),
                                          child: Stack(
                                            children: [
                                              // Image
                                              Positioned.fill(
                                                child:
                                                    myNetworkImageWithShimmer(
                                                        widget.frontImage),
                                              ),

                                              Positioned.fill(
                                                child: Align(
                                                  alignment:
                                                      Alignment.bottomCenter,
                                                  child: Container(
                                                    height:
                                                        80, // adjust shadow height
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                        colors: [
                                                          Colors.transparent,
                                                          Colors.black
                                                              .withOpacity(0.7),
                                                          Colors.black
                                                              .withOpacity(0.9),
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
                                                          widget.title != null
                                                              ? widget.title!
                                                                          .length >
                                                                      25
                                                                  ? "${widget.title!.substring(0, 24)}..."
                                                                  : widget
                                                                      .title!
                                                              : "",
                                                          style: heading3Grey1(
                                                                  context)
                                                              .copyWith(
                                                            color: whiteColor,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const Spacer(),
                                                        Container(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          7),
                                                              color: getColorBasedOnActiveModuleid()
                                                                  .withValues(
                                                                      alpha:
                                                                          .4)),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                Icons.star,
                                                                color:
                                                                    orangeColor,
                                                                size: 14,
                                                              ),
                                                              const SizedBox(
                                                                  width: 5),
                                                              Text(
                                                                '${widget.rating ?? ""}.0'
                                                                    .tr,
                                                                style: boldstyle(
                                                                        context)
                                                                    .copyWith(
                                                                        color:
                                                                            whiteColor,
                                                                        fontSize:
                                                                            9),
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
                                                        if (widget.itemDetails!
                                                                    .transmission !=
                                                                null &&
                                                            widget
                                                                .itemDetails!
                                                                .transmission!
                                                                .isNotEmpty)
                                                          Text(
                                                            widget.itemDetails!
                                                                .transmission!,
                                                            style: regular3(
                                                                    context)
                                                                .copyWith(
                                                              fontSize: 12,
                                                              color: whiteColor,
                                                            ),
                                                          ),
                                                        if (widget.itemDetails!
                                                                    .transmission !=
                                                                null &&
                                                            widget
                                                                .itemDetails!
                                                                .transmission!
                                                                .isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4),
                                                            child: Text(
                                                              "•",
                                                              style: TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 12),
                                                            ),
                                                          ),
                                                        if (widget.itemDetails!
                                                                    .makeType !=
                                                                null &&
                                                            widget
                                                                .itemDetails!
                                                                .makeType!
                                                                .isNotEmpty)
                                                          Text(
                                                            widget.itemDetails!
                                                                .makeType!,
                                                            style: regular3(
                                                                    context)
                                                                .copyWith(
                                                              fontSize: 12,
                                                              color: whiteColor,
                                                            ),
                                                          ),
                                                        if (widget.itemDetails!
                                                                    .makeType !=
                                                                null &&
                                                            widget
                                                                .itemDetails!
                                                                .makeType!
                                                                .isNotEmpty)
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        4),
                                                            child: Text(
                                                              "•",
                                                              style: TextStyle(
                                                                  color:
                                                                      whiteColor,
                                                                  fontSize: 12),
                                                            ),
                                                          ),
                                                        if (widget.itemDetails!
                                                                .seatCapicity !=
                                                            null)
                                                          Text(
                                                            "${widget.itemDetails!.seatCapicity} Seats",
                                                            style: regular3(
                                                                    context)
                                                                .copyWith(
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
                                                              "$currency ${bookingController.getItemPrices?.data?.pricePerNight != null ? (bookingController.getItemPrices!.data!.pricePerNight!.length > 8 ? "${bookingController.getItemPrices!.data!.pricePerNight!.substring(0, 8)}.." : bookingController.getItemPrices!.data!.pricePerNight!) : ''}",
                                                              style: boldstyle(
                                                                      context)
                                                                  .copyWith(
                                                                      color:
                                                                          getColorBasedOnActiveModuleid(),
                                                                      fontSize:
                                                                          14,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis),
                                                            ),
                                                            Text(
                                                              ' /day'.tr,
                                                              maxLines: 1,
                                                              style: regular(context).copyWith(
                                                                  color: notifires
                                                                      .getGrey4Whitecolor,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis),
                                                            )
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
                                            color:
                                                getColorBasedOnActiveModuleid(),
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Expanded(
                                            child: Text(
                                              "${widget.address ?? ""},",
                                              overflow: TextOverflow.ellipsis,
                                              style: regular3(context).copyWith(
                                                fontSize: 12,
                                              ),
                                              maxLines: 1,
                                            ),
                                          ),
                                          Spacer(),
                                          if (widget
                                                  .itemDetails!.hostFirstName !=
                                              null)
                                            Row(
                                              children: [
                                                Icon(
                                                  CupertinoIcons.person,
                                                  size: 17,
                                                  color:
                                                      getColorBasedOnActiveModuleid(),
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  "By - ${widget.itemDetails!.hostFirstName ?? ""}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: regular3(context)
                                                      .copyWith(
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
                            ),
                            // ========== NOUVELLE SECTION "Vérifier la disponibilité" ==========
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 20.0),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () {
                                  // Logique récupérée de l'ancien IconButton stylo
                                  setdefultData();
                                  showPopUpScreen(
                                      context,
                                      VehicleCheckAvailability(
                                        idFeatured: widget.idFeatured,
                                        itemDetails: widget.itemDetails,
                                        address: widget.address,
                                        frontImage: widget.frontImage,
                                        title: widget.title,
                                        rating: widget.rating,
                                        itemType: widget.itemType,
                                        price: widget.price,
                                        cleanvalue: true,
                                      ));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: notifires.getboxcolor,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: notifires.getGrey4Whitecolor
                                            .withOpacity(0.3)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: getColorBasedOnActiveModuleid()
                                              .withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.calendar_month,
                                          color: getColorBasedOnActiveModuleid(),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          "Check Availability".tr,
                                          style: heading3(context).copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: notifires.getGrey3Whitecolor,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // ========== SECTION "Votre voyage" (masquée si pas de dates) ==========
                            Obx(() {
                              final hasDatesSelected = bookingController
                                          .startDate.value.isNotEmpty &&
                                      bookingController.endDate.value.isNotEmpty;
                              
                              return Visibility(
                                visible: hasDatesSelected,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: notifires.getboxcolor,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: Offset(0, 0),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: Get.size.width,
                                          decoration: BoxDecoration(
                                            color: notifires.getboxcolor,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              left: 20,
                                              right: 20,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                // ========== TITRE "Votre voyage" (sans l'icône stylo) ==========
                                                Text(
                                                  "Your Trip".tr,
                                                  style: heading2(context),
                                                ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Trip start".tr,
                                                  style: regular2(context)
                                                      .copyWith(
                                                          color: notifires
                                                              .getGrey2Whitecolor),
                                                ),
                                                const Spacer(),
                                                Obx(
                                                  () => Text(
                                                      '${bookingController.startDate}'
                                                          .tr,
                                                      style: regular2(context)
                                                          .copyWith(
                                                              color: notifires
                                                                  .getGrey3Whitecolor)),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Trip end".tr,
                                                  style: regular2(context)
                                                      .copyWith(
                                                          color: notifires
                                                              .getGrey2Whitecolor),
                                                ),
                                                const Spacer(),
                                                Obx(
                                                  () => Text(
                                                    '${bookingController.endDate}'
                                                        .tr,
                                                    style: regular2(context)
                                                        .copyWith(
                                                            color: notifires
                                                                .getGrey3Whitecolor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "Start Time".tr,
                                                  style: regular2(context)
                                                      .copyWith(
                                                          color: notifires
                                                              .getGrey2Whitecolor),
                                                ),
                                                const Spacer(),
                                                Text(
                                                    TimeFormatter.to24Hour(
                                                        bookingController
                                                            .selectedStartTime
                                                            .toString()),
                                                    style: regular2(context)
                                                        .copyWith(
                                                            color: notifires
                                                                .getGrey3Whitecolor)),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  "End Time".tr,
                                                  style: regular2(context)
                                                      .copyWith(
                                                          color: notifires
                                                              .getGrey2Whitecolor),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  TimeFormatter.to24Hour(
                                                      bookingController
                                                          .selectedEndTime
                                                          .toString()),
                                                  style: regular2(context)
                                                      .copyWith(
                                                          color: notifires
                                                              .getGrey3Whitecolor),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Obx(
                                      () => bookingController
                                                  .isPaymentSuccess.value ==
                                              true
                                          ? const SizedBox()
                                          : const SizedBox(
                                              height: 10,
                                            ),
                                    ),
                                    Obx(
                                      () => bookingController
                                                  .isPaymentSuccess.value ==
                                              true
                                          ? const SizedBox()
                                          : Container(
                                              width: Get.size.width,
                                              color: notifires.getboxcolor,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 20,
                                                  right: 20,
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    bookingController
                                                                .isPaymentSuccess
                                                                .value ==
                                                            true
                                                        ? const SizedBox()
                                                        : Text(
                                                            "Coupon".tr,
                                                            style: heading2(
                                                                    context)
                                                                .copyWith(),
                                                          ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Container(
                                                      height: 50,
                                                      width: Get.size.width,
                                                      decoration: BoxDecoration(
                                                        color: notifires
                                                            .getbgcolor,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          const SizedBox(
                                                            width: 15,
                                                          ),
                                                          Icon(
                                                            Icons.discount,
                                                            size: 18,
                                                            color: notifires
                                                                .getwhiteblackcolor,
                                                          ),
                                                          const SizedBox(
                                                            width: 15,
                                                          ),
                                                          Expanded(
                                                            child: TextField(
                                                              controller:
                                                                  bookingController
                                                                      .textEditingController,
                                                              decoration: InputDecoration.collapsed(
                                                                  hintText:
                                                                      "coupon code"
                                                                          .tr,
                                                                  hintStyle:
                                                                      regular2(
                                                                          context)),
                                                              style: regular2(
                                                                      context)
                                                                  .copyWith(
                                                                      color: notifires
                                                                          .getGrey2Whitecolor),
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Obx(() => bookingController
                                                                      .showAddCouponBtn
                                                                      .value ==
                                                                  false
                                                              ? const SizedBox()
                                                              : InkWell(
                                                                  onTap:
                                                                      () async {
                                                                    showLoading();
                                                                    if (switchWallet) {
                                                                      await getData(
                                                                          bookingController
                                                                              .textEditingController
                                                                              .text,
                                                                          bookingController
                                                                              .walletModel!
                                                                              .data!
                                                                              .walletBalance!);
                                                                    } else {
                                                                      await getData(
                                                                          bookingController
                                                                              .textEditingController
                                                                              .text,
                                                                          "");
                                                                    }

                                                                    closeLoading();
                                                                  },
                                                                  child: Text(
                                                                    'Apply'.tr,
                                                                    style: regular2(
                                                                            context)
                                                                        .copyWith(
                                                                            color:
                                                                                getColorBasedOnActiveModuleid()),
                                                                  ),
                                                                )),
                                                          const SizedBox(
                                                            width: 15,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                    ),
                                    Obx(
                                      () => bookingController
                                                  .isPaymentSuccess.value ==
                                              true
                                          ? const SizedBox()
                                          : const SizedBox(
                                              height: 10,
                                            ),
                                    ),
                                    Obx(
                                      () => bookingController
                                                  .isPaymentSuccess.value ==
                                              true
                                          ? const SizedBox()
                                          : bookingController
                                                      .isPaymentSuccess.value ==
                                                  true
                                              ? const SizedBox()
                                              : bookingController.walletModel ==
                                                      null
                                                  ? const SizedBox()
                                                  : bookingController
                                                              .walletModel
                                                              ?.data
                                                              ?.walletBalance ==
                                                          null
                                                      ? const SizedBox()
                                                      : bookingController
                                                                  .walletModel
                                                                  ?.data
                                                                  ?.walletBalance ==
                                                              "0"
                                                          ? const SizedBox()
                                                          : bookingController
                                                                      .walletModel
                                                                      ?.data
                                                                      ?.walletBalance ==
                                                                  "0.00"
                                                              ? const SizedBox()
                                                              : Container(
                                                                  width: Get
                                                                      .size
                                                                      .width,
                                                                  color: notifires
                                                                      .getboxcolor,
                                                                  child:
                                                                      Padding(
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .only(
                                                                      left: 20,
                                                                      right: 20,
                                                                    ),
                                                                    child:
                                                                        Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Column(
                                                                          children: [
                                                                            Row(
                                                                              mainAxisAlignment: MainAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  "Pay from Wallet".tr,
                                                                                  style: heading2(context).copyWith(),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            const SizedBox(
                                                                              height: 10,
                                                                            ),
                                                                            Container(
                                                                              decoration: BoxDecoration(
                                                                                color: notifires.getBoxColor,
                                                                                borderRadius: BorderRadius.circular(12),
                                                                              ),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                children: [
                                                                                  Text(
                                                                                    "Wallet Balance".tr,
                                                                                    style: heading3Grey1(context).copyWith(color: notifires.getGrey1Whitecolor),
                                                                                  ),
                                                                                  const SizedBox(
                                                                                    height: 5,
                                                                                  ),
                                                                                  Row(
                                                                                    children: [
                                                                                      Wrap(
                                                                                        children: [
                                                                                          Text(
                                                                                            "Available for Payment : ".tr,
                                                                                            style: regular2(context),
                                                                                          ),
                                                                                          bookingController.walletModel!.data!.walletBalance == null
                                                                                              ? const SizedBox()
                                                                                              : Text(
                                                                                                  '${bookingController.currency} ${bookingController.walletModel!.data!.walletBalance!}',
                                                                                                  style: boldstyle(context).copyWith(color: notifires.getGrey2Whitecolor, fontSize: 14),
                                                                                                ),
                                                                                        ],
                                                                                      ),
                                                                                      Spacer(),
                                                                                      bookingController.walletModel == null
                                                                                          ? const SizedBox()
                                                                                          : SizedBox(
                                                                                              height: 10,
                                                                                              child: Transform.scale(
                                                                                                scale: .6,
                                                                                                child: Transform.translate(
                                                                                                    offset: Offset(10, 0),
                                                                                                    child: Switch(
                                                                                                        activeColor: getColorBasedOnActiveModuleid(),
                                                                                                        value: switchWallet,
                                                                                                        onChanged: (onChanged) async {
                                                                                                          if (bookingController.walletModel!.data!.walletBalance == "0" || bookingController.walletModel!.data!.walletBalance == "0.00") {
                                                                                                            showErrorToastMessage("Wallet balance is 0");
                                                                                                            return;
                                                                                                          }

                                                                                                          String? cp;
                                                                                                          if (bookingController.getItemPrices!.data!.couponCode == null) {
                                                                                                            cp = "";
                                                                                                          } else {
                                                                                                            cp = bookingController.getItemPrices!.data!.couponCode;
                                                                                                          }
                                                                                                          showLoading();
                                                                                                          if (onChanged == true) {
                                                                                                            await getData(cp, bookingController.walletModel!.data!.walletBalance!);
                                                                                                          } else {
                                                                                                            await getData(cp, "");
                                                                                                          }
                                                                                                          closeLoading();
                                                                                                          switchWallet = onChanged;
                                                                                                          setState(() {});
                                                                                                        })),
                                                                                              ))
                                                                                    ],
                                                                                  ),
                                                                                  bookingController.getItemPrices!.data!.remainingWalletBalance == '0' && !switchWallet
                                                                                      ? const SizedBox()
                                                                                      : const SizedBox(
                                                                                          height: 8,
                                                                                        ),
                                                                                  bookingController.getItemPrices!.data!.remainingWalletBalance == '0' && !switchWallet
                                                                                      ? const SizedBox()
                                                                                      : Wrap(
                                                                                          children: [
                                                                                            Text(
                                                                                              "Remaining Wallet Balance : ".tr,
                                                                                              style: regular2(context),
                                                                                            ),
                                                                                            Text(
                                                                                              "${bookingController.currency} ${bookingController.getItemPrices!.data!.remainingWalletBalance!}",
                                                                                              style: boldstyle(context).copyWith(color: notifires.getGrey2Whitecolor, fontSize: 14),
                                                                                            ),
                                                                                          ],
                                                                                        )
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: Get.size.width,
                                      color: notifires.getboxcolor,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 20,
                                          right: 20,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text("Price Details".tr,
                                                style: heading2(context)),
                                            const SizedBox(
                                              height: 16,
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${"Price".tr} ( ${bookingController.getItemPrices!.data!.totalNights!} ${int.parse(bookingController.getItemPrices!.data!.totalNights!) > 1 ? "days" : "day"} )",
                                                      style: regular2(context)
                                                          .copyWith(
                                                              color: notifires
                                                                  .getGrey3Whitecolor),
                                                    )
                                                  ],
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "${bookingController.currency} ${double.tryParse(bookingController.getItemPrices!.data!.priceBeforeDiscount ?? "0")?.toStringAsFixed(2) ?? bookingController.getItemPrices!.data!.priceBeforeDiscount ?? "0.00"}",
                                                  style: regular2(context)
                                                      .copyWith(
                                                          color: greenback),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            bookingController.getItemPrices!
                                                        .data!.discountPrice !=
                                                    "0"
                                                ? Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            bookingController
                                                                .getItemPrices!
                                                                .data!
                                                                .discountType!,
                                                            style: regular2(
                                                                    context)
                                                                .copyWith(
                                                                    color: notifires
                                                                        .getGrey3Whitecolor),
                                                          )
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "- ${bookingController.currency} ${bookingController.getItemPrices!.data!.discountPrice!}",
                                                        style: regular2(context)
                                                            .copyWith(
                                                                color: notifires
                                                                    .getGrey3Whitecolor),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  )
                                                : const SizedBox(),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            bookingController.getItemPrices!
                                                        .data!.couponDiscount ==
                                                    "0"
                                                ? const SizedBox()
                                                : Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "${"Coupon".tr} ( ${bookingController.getItemPrices!.data!.couponCode!} )",
                                                            style: regular2(
                                                                    context)
                                                                .copyWith(
                                                                    color: notifires
                                                                        .getGrey3Whitecolor),
                                                          )
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "- ${bookingController.currency}${bookingController.getItemPrices!.data!.couponDiscount!}",
                                                        style: regular2(context)
                                                            .copyWith(
                                                                color: notifires
                                                                    .getGrey3Whitecolor),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            bookingController.getItemPrices!
                                                        .data!.serviceCharge ==
                                                    "0"
                                                ? const SizedBox()
                                                : Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Service Charge".tr,
                                                            style: regular2(
                                                                    context)
                                                                .copyWith(
                                                                    color: notifires
                                                                        .getGrey3Whitecolor),
                                                          )
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "${bookingController.currency} ${bookingController.getItemPrices!.data!.serviceCharge!}",
                                                        style: regular2(context)
                                                            .copyWith(
                                                                color: notifires
                                                                    .getGrey3Whitecolor),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            bookingController.getItemPrices!
                                                        .data!.cleaningCharge ==
                                                    "0"
                                                ? const SizedBox()
                                                : Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Cleaning Charge"
                                                                .tr,
                                                            style: regular2(
                                                                    context)
                                                                .copyWith(
                                                                    color: notifires
                                                                        .getGrey3Whitecolor),
                                                          )
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "${bookingController.currency} ${bookingController.getItemPrices!.data!.cleaningCharge!}",
                                                        style: regular2(context)
                                                            .copyWith(
                                                                color: notifires
                                                                    .getGrey3Whitecolor),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  ),
                                            widget.isAddDoorStepPrice == "0" ||
                                                    widget.isAddDoorStepPrice ==
                                                        ""
                                                ? const SizedBox()
                                                : Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Doorstep price".tr,
                                                            style: regular2(
                                                                    context)
                                                                .copyWith(
                                                                    color: notifires
                                                                        .getGrey3Whitecolor),
                                                          )
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "${bookingController.currency} ${widget.isAddDoorStepPrice}",
                                                        style: regular2(context)
                                                            .copyWith(
                                                                color: notifires
                                                                    .getGrey3Whitecolor),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            bookingController
                                                        .getItemPrices!
                                                        .data!
                                                        .securityDeposit!
                                                        .isEmpty ||
                                                    bookingController
                                                            .getItemPrices!
                                                            .data!
                                                            .securityDeposit ==
                                                        "0"
                                                ? const SizedBox()
                                                : Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Security Deposit"
                                                                .tr,
                                                            style: regular2(
                                                                    context)
                                                                .copyWith(
                                                                    color: notifires
                                                                        .getGrey3Whitecolor),
                                                          )
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "${bookingController.currency} ${bookingController.getItemPrices!.data!.securityDeposit!}",
                                                        style: regular2(context)
                                                            .copyWith(
                                                                color: notifires
                                                                    .getGrey3Whitecolor),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            bookingController.getItemPrices!
                                                        .data!.tax ==
                                                    "0"
                                                ? const SizedBox()
                                                : Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Tax".tr,
                                                            style: regular2(
                                                                    context)
                                                                .copyWith(
                                                                    color: notifires
                                                                        .getGrey3Whitecolor),
                                                          )
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "${bookingController.currency} ${bookingController.getItemPrices!.data!.tax!}",
                                                        style: regular2(context)
                                                            .copyWith(
                                                                color: notifires
                                                                    .getGrey3Whitecolor),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            bookingController.getItemPrices!
                                                        .data!.walletAmount ==
                                                    "0"
                                                ? const SizedBox()
                                                : Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            "Wallet".tr,
                                                            style: regular2(
                                                                    context)
                                                                .copyWith(
                                                                    color: notifires
                                                                        .getGrey3Whitecolor),
                                                          )
                                                        ],
                                                      ),
                                                      const Spacer(),
                                                      Text(
                                                        "${bookingController.currency} ${bookingController.getItemPrices!.data!.walletAmount!}",
                                                        style: regular2(context)
                                                            .copyWith(
                                                                color: notifires
                                                                    .getGrey3Whitecolor),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  ),
                                            const SizedBox(
                                              height: 7,
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text("Total Price".tr,
                                                        style: heading3(context)
                                                            .copyWith(
                                                                color:
                                                                    getColorBasedOnActiveModuleid()))
                                                  ],
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "${bookingController.currency} ${double.tryParse(bookingController.getItemPrices!.data!.grossPrice ?? "0")?.toStringAsFixed(2) ?? bookingController.getItemPrices!.data!.grossPrice ?? "0.00"}",
                                                  style: heading3(context).copyWith(
                                                      color:
                                                          getColorBasedOnActiveModuleid()),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15, right: 15),
                                      child: Card(
                                        color: notifires.getBoxColor,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 20, bottom: 20),
                                          child: Row(
                                            children: [
                                              const SizedBox(
                                                width: 20,
                                              ),
                                              // Checkbox professionnelle avec design moderne
                                              Checkbox(
                                                value: isPolicyAccepted,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    isPolicyAccepted = value ?? false;
                                                    print('🔐 [VALIDATION] Politique acceptée : $isPolicyAccepted');
                                                    debugPrint('🔐 [VALIDATION] Politique acceptée : $isPolicyAccepted');
                                                  });
                                                },
                                                activeColor: getColorBasedOnActiveModuleid(),
                                                checkColor: Colors.white,
                                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                visualDensity: VisualDensity.compact,
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Expanded(
                                                child: RichText(
                                                  text: TextSpan(
                                                    style: regular3(context).copyWith(
                                                      color: getColorBasedOnActiveModuleid(),
                                                    ),
                                                    children: [
                                                      TextSpan(
                                                        text: "J'ai lu et j'accepte ".tr,
                                                      ),
                                                      WidgetSpan(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            // Ouvrir la modale de détails de la politique
                                                            String policy = widget.itemDetails?.cancellationReasonTitle ?? 
                                                                           widget.itemDetails?.cancellationReason ?? 
                                                                           'Non spécifiée';
                                                            print('✅ [FIX_CONFIRMED] Policy chargée: $policy');
                                                            debugPrint('✅ [FIX_CONFIRMED] Policy chargée: $policy');
                                                            
                                                            cancellationPolicyBottomSheet(
                                                                context,
                                                                policy,
                                                                widget.itemDetails!
                                                                    .cancellationReasonDescription);
                                                          },
                                                          child: Text(
                                                            "la politique d'annulation".tr,
                                                            style: regular3(context).copyWith(
                                                              color: getColorBasedOnActiveModuleid(),
                                                              decoration: TextDecoration.underline,
                                                              decorationColor: getColorBasedOnActiveModuleid(),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              InkWell(
                                                onTap: () {
                                                  // Tester tous les champs possibles
                                                  String policy = widget.itemDetails?.cancellationReasonTitle ?? 
                                                                 widget.itemDetails?.cancellationReason ?? 
                                                                 'Non spécifiée';
                                                  print('✅ [FIX_CONFIRMED] Policy chargée: $policy');
                                                  debugPrint('✅ [FIX_CONFIRMED] Policy chargée: $policy');
                                                  
                                                  rulesbuttomSheet(
                                                    context,
                                                    title: policy,
                                                    list: widget.itemDetails!
                                                            .cancellationReasonDescription ??
                                                        [],
                                                  );
                                                },
                                                child: vehicleDetailController
                                                        .cancellationLoading
                                                    ? const SizedBox(
                                                        height: 25,
                                                        width: 25,
                                                        child:
                                                            CircularProgressIndicator())
                                                    : Icon(
                                                        Icons
                                                            .arrow_forward_ios,
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
                                    widget.itemDetails!.rules!.isEmpty
                                        ? const SizedBox()
                                        : Padding(
                                            padding: const EdgeInsets.only(
                                                left: 15, right: 15),
                                            child: GestureDetector(
                                              onTap: () {
                                                rulesbuttomSheet(context,
                                                    title: 'Rules'.tr,
                                                    list: widget
                                                        .itemDetails!.rules!);
                                              },
                                              child: Card(
                                                color: notifires.getBoxColor,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 20, bottom: 20),
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 20,
                                                      ),
                                                      SvgPicture.asset(
                                                        "assets/images/menurule.svg",
                                                        colorFilter:
                                                            ColorFilter.mode(
                                                          getColorBasedOnActiveModuleid(),
                                                          BlendMode.srcIn,
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                        "Rules".tr,
                                                        style: regular3(context)
                                                            .copyWith(
                                                                color:
                                                                    getColorBasedOnActiveModuleid()),
                                                      ),
                                                      const Spacer(),
                                                      InkWell(
                                                        onTap: () {
                                                          rulesbuttomSheet(
                                                            context,
                                                            title:
                                                                'Car Rules'.tr,
                                                            list:
                                                                itemInfoDetails[
                                                                    "rules"],
                                                          );
                                                        },
                                                        child: Icon(
                                                          Icons
                                                              .arrow_forward_ios,
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
                                  ],
                                ),
                              ),
                            ),
                              );
                            }),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20.0),
                              child: Container(
                                width: double.maxFinite,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 12),
                                decoration: BoxDecoration(
                                  color: notifires.getboxcolor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 0),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.info_outline,
                                            color: themeColor, size: 18),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Note".tr,
                                          style: TextStyle(
                                            color: blackColor,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    noteItem(
                                      label: "Smoking Allowed".tr,
                                      value:
                                          widget.itemDetails!.smokingStatus ==
                                              '1',
                                    ),
                                    const SizedBox(height: 8),
                                    noteItem(
                                      label: "International Travel Allowed".tr,
                                      value: widget.itemDetails!
                                              .internationalTravel ==
                                          '1',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
      ),
    );
  }

  Widget noteItem({required String label, required bool value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value ? "Yes" : "No",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
