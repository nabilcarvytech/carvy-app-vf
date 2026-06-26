import 'dart:convert';
import 'dart:core';
import 'dart:async';
import 'dart:math';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/controller/add_address_controller.dart';
import 'package:carvy/controller/items_detail_controller.dart';
import 'package:carvy/controller/kyc_controller.dart';
import 'package:carvy/controller/push_notifications.dart';
import 'package:carvy/controller/booking_record_controller.dart';
import 'package:carvy/controller/payment_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/digital_singnature_model.dart';
import 'package:carvy/model/item_details_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/safe_rebuild.dart';
import 'package:carvy/utils/navigation_guard.dart';
import 'package:carvy/utils/payment_flow_debug.dart';
import 'package:carvy/utils/snackbar_service.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import '../api/config.dart';
import '../customwidget/miscellaneous_project_elements.dart';
import '../customwidget/project_color.dart';
import '../helper/http_service.dart';
import '../model/book_date_real_estate.dart';
import '../model/booking_model.dart';
import '../model/booking_payment_method_model.dart';
import '../model/extension_payment_context.dart';
import '../model/calendar_model.dart';
import '../model/get_item_prices.dart';
import '../model/wallet_model.dart';
import '../utils/rental_billing_days.dart';
import '../view/booking/payment_screen.dart';
import '../view/booking/my_booking_screen.dart';
import '../view/booking/vehicle/vehicle_booking_summary_screen.dart';
import '../view/bottombar/home_main.dart';
import '../work_space.dart';

ItemDetailsController spaceDetailController = Get.find();

/// Une ligne par nuit, prix uniforme [perNight], pour que la somme = [afterDiscount].
List<Prices> _buildAlignedRentalPrices(int totalNightsIn, double afterDiscount) {
  var totalNights = totalNightsIn;
  if (totalNights < 1) totalNights = 1;
  final perNight = (afterDiscount / totalNights).toStringAsFixed(2);
  BookingController? bc;
  try {
    bc = Get.find<BookingController>();
  } catch (_) {
    bc = null;
  }
  DateTime start =
      DateTime.tryParse(bc?.startDate.value ?? '') ?? DateTime.now();
  final out = <Prices>[];
  for (var i = 0; i < totalNights; i++) {
    out.add(Prices(
      date: DateFormat('yyyy-MM-dd').format(start.add(Duration(days: i))),
      price: perNight,
      status: 'Available',
    ));
  }
  return out;
}

/// Ticket véhicule simplifié : taxe, dépôt, nettoyage et frais de service à 0 ;
/// total = prix jours − remise − coupon (sans frais cachés).
GetItemPrices applySimplifiedVehicleBookingPrices(GetItemPrices src) {
  final d = src.data;
  if (d == null) return src;
  final base = double.tryParse(d.priceBeforeDiscount ?? '0') ?? 0.0;
  final discount = double.tryParse(d.discountPrice ?? '0') ?? 0.0;
  final coupon = double.tryParse(d.couponDiscount ?? '0') ?? 0.0;
  final totalNights = int.tryParse(d.totalNights ?? '') ?? d.duration ?? 1;

  // Applique explicitement la remise longue durée au total pour éviter
  // l'incohérence "économie affichée mais non déduite" sur le montant final.
  final itemDetails = spaceDetailController.vehicleDetailModel?.data?.itemDetails;
  final priceDetails = itemDetails?.priceDetails;
  final originalDailyFromPriceDetails =
      double.tryParse(priceDetails?.originalDailyPrice?.toString() ?? '') ?? 0.0;
  final fallbackDaily = totalNights > 0 ? (base / totalNights) : 0.0;
  final originalDaily = originalDailyFromPriceDetails > 0
      ? originalDailyFromPriceDetails
      : fallbackDaily;
  final weeklyDaily = double.tryParse(
          priceDetails?.discountedDailyPriceWeekly?.toString() ?? '') ??
      originalDaily;
  final monthlyDaily = double.tryParse(
          priceDetails?.discountedDailyPriceMonthly?.toString() ?? '') ??
      weeklyDaily;
  final selectedDaily = totalNights >= 30
      ? monthlyDaily
      : (totalNights >= 7 ? weeklyDaily : originalDaily);
  final longDurationDiscount =
      ((originalDaily - selectedDaily) * totalNights).clamp(0, double.infinity);

  var afterDiscount = base - discount - longDurationDiscount;
  if (afterDiscount < 0) afterDiscount = 0;
  var total = afterDiscount - coupon;
  if (total < 0) total = 0;
  final afterDiscStr = afterDiscount.toStringAsFixed(2);
  final totalStr = total.toStringAsFixed(2);
  final perNightStr = totalNights > 0
      ? (afterDiscount / totalNights).toStringAsFixed(2)
      : d.pricePerNight;
  final alignedPrices = _buildAlignedRentalPrices(totalNights, afterDiscount);

  return src.copyWith(
    data: d.copyWith(
      serviceCharge: '0.00',
      cleaningCharge: '0.00',
      tax: '0.00',
      securityDeposit: '0.00',
      // Aligner l’UI / API sur le total locatif réellement calculé (ex. 1046 MAD),
      // pas sur un prix/jour issu seul du détail véhicule (ex. 92).
      priceBeforeDiscount: afterDiscStr,
      pricePerNight: perNightStr,
      prices: alignedPrices,
      priceAfterDiscount: afterDiscStr,
      grossPrice: totalStr,
    ),
  );
}

class BookingController extends GetxController implements GetxService {
  /// ID GetBuilder du corps [PaymentMethodScreen] — jamais de [update] global.
  static const Object paymentMethodBodyId = 'payment_method_body';

  /// ID GetBuilder de l'overlay OTP ([MyBookingOtpOverlay]) — updates manuels uniquement.
  static const Object otpOverlayId = 'otp';

  bool _paymentMethodUiDetached = false;
  bool _otpOverlayDetached = false;

  /// État OTP overlay (non-Rx) — lu par GetBuilder, jamais par Obx.
  bool otpOverlayOpen = false;
  String otpOverlayBookingId = '';

  @override
  void onInit() {
    super.onInit();
    currenttimeSlots = <String>[].obs;
    filteredTimeSlotsEndTime = <String>[].obs;
    avalibleSlots = <String>[];
  }

  Timer? _safeUpdateDebounce;

  /// Ne déclenche [update] que si le contrôleur est encore actif et enregistré.
  /// Les appels rapprochés sont fusionnés (debounce) pour éviter les rebuilds doubles.
  void safeUpdate([List<Object>? ids, bool condition = true]) {
    if (!condition || isClosed) return;
    if (!Get.isRegistered<BookingController>()) return;
    if (NavigationGuard.isNavigating) return;
    if (_paymentMethodUiDetached) {
      if (ids == null) return;
      if (ids.contains(paymentMethodBodyId)) return;
    }
    if (_otpOverlayDetached) {
      if (ids == null) return;
      if (ids.contains(otpOverlayId)) return;
    }

    void schedule() {
      if (isClosed || !Get.isRegistered<BookingController>()) return;
      if (NavigationGuard.isNavigating) return;
      if (_paymentMethodUiDetached &&
          (ids == null || ids.contains(paymentMethodBodyId))) {
        return;
      }
      if (_otpOverlayDetached &&
          (ids == null || ids.contains(otpOverlayId))) {
        return;
      }
      _safeUpdateDebounce?.cancel();
      _safeUpdateDebounce = Timer(const Duration(milliseconds: 16), () {
        if (!isClosed && Get.isRegistered<BookingController>()) {
          if (NavigationGuard.isNavigating) return;
          if (_paymentMethodUiDetached &&
              (ids == null || ids.contains(paymentMethodBodyId))) {
            return;
          }
          if (_otpOverlayDetached &&
              (ids == null || ids.contains(otpOverlayId))) {
            return;
          }
          update(ids, condition);
        }
      });
    }

    final phase = SchedulerBinding.instance.schedulerPhase;
    final duringBuild = phase == SchedulerPhase.midFrameMicrotasks ||
        phase == SchedulerPhase.persistentCallbacks;
    if (duringBuild) {
      WidgetsBinding.instance.addPostFrameCallback((_) => schedule());
      return;
    }
    schedule();
  }

  /// Vide les états temporaires de paiement avant navigation post-checkout.
  void clearListeners() {
    detachPaymentMethodUi();
    paymentMethodsList.clear();
    paymentMethodModel = null;
    isLoadingPaymentMethods.value = false;
    selectedPaymentMethod = null;
    extensionPaymentContext = null;
    prepareForRoutePop();
  }

  /// Détache le GetBuilder [paymentMethodBodyId] — bloque tout update ciblé ou global.
  void detachPaymentMethodUi() {
    _paymentMethodUiDetached = true;
    prepareForRoutePop();
  }

  /// Réactive les updates GetBuilder quand [PaymentMethodScreen] est monté.
  void attachPaymentMethodUi() {
    _paymentMethodUiDetached = false;
  }

  /// Rafraîchit uniquement le corps de [PaymentMethodScreen].
  void notifyPaymentMethodBody() {
    if (_paymentMethodUiDetached || NavigationGuard.isNavigating) return;
    safeUpdate([paymentMethodBodyId]);
  }

  /// Réactive l'overlay OTP quand [MyUpCommingTrip] est monté.
  void attachOtpOverlay() {
    _otpOverlayDetached = false;
  }

  /// Kill switch : bloque tout update(['otp']) pendant navigation / dispose.
  void detachOtpOverlay() {
    _otpOverlayDetached = true;
    otpOverlayOpen = false;
    otpOverlayBookingId = '';
    openOtpAfterImageSubmit.value = false;
    currentBookingIdForOtp.value = '';
    prepareForRoutePop();
  }

  /// Demande l'ouverture de la modale OTP via GetBuilder (pas Obx).
  void requestOtpOverlay(String bookingId) {
    if (_otpOverlayDetached || NavigationGuard.isNavigating) return;
    otpOverlayOpen = true;
    otpOverlayBookingId = bookingId;
    openOtpAfterImageSubmit.value = true;
    currentBookingIdForOtp.value = bookingId;
    notifyOtpOverlay();
  }

  /// Ferme l'overlay OTP sans notifier si [notifyUi] est false (transition).
  void dismissOtpOverlay({bool notifyUi = false}) {
    otpOverlayOpen = false;
    otpOverlayBookingId = '';
    openOtpAfterImageSubmit.value = false;
    currentBookingIdForOtp.value = '';
    if (notifyUi) notifyOtpOverlay();
  }

  /// Rafraîchit uniquement [MyBookingOtpOverlay].
  void notifyOtpOverlay() {
    if (_otpOverlayDetached || NavigationGuard.isNavigating) return;
    safeUpdate([otpOverlayId]);
  }

  /// Annule les [update] différés avant un retour arrière.
  void prepareForRoutePop() {
    _safeUpdateDebounce?.cancel();
    _safeUpdateDebounce = null;
  }

  @override
  void onClose() {
    detachOtpOverlay();
    detachPaymentMethodUi();
    _safeUpdateDebounce?.cancel();
    _safeUpdateDebounce = null;
    reviewCommentController.dispose();
    isProcessingBooking.value = false;
    isLoadingPaymentMethods.value = false;
    super.onClose();
    // Réinitialiser hasSkippedInSession pour que le rappel s'affiche à nouveau pour la prochaine réservation
    try {
      final kycController = Get.find<KycController>();
      kycController.hasSkippedInSession.value = false;
      kycController.setSkipKyc(false);
    } catch (e) {
      // Si le controller n'est pas disponible, ignorer l'erreur
    }
  }

  static const Duration _postNavigationSettleDelay =
      Duration(milliseconds: 600);

  /// Notifie les GetBuilder sans toucher l'UI si le contrôleur est fermé.
  void notifyUi([List<Object>? ids, bool condition = true]) {
    safeUpdate(ids, condition);
  }

  /// Navigation post-paiement : route atomique — aucune mutation Rx avant [Get.offAll].
  Future<void> _navigateToBookingsAfterPayment({
    required int tabIndex,
    required String snackTitle,
    required String snackMessage,
  }) async {
    paymentFlowLog('STEP 8 — _navigateToBookingsAfterPayment START',
        'tabIndex=$tabIndex');

    detachPaymentMethodUi();
    detachOtpOverlay();
    prepareForRoutePop();
    paymentFlowLog('STEP 8-pre — detachPaymentMethodUi + detachOtpOverlay + prepareForRoutePop');

    if (Get.isRegistered<BookingRecordController>()) {
      Get.find<BookingRecordController>().prepareForOffAllNavigation();
      paymentFlowLog('STEP 8-pre2 — BookingRecordController.prepareForOffAllNavigation()');
    }

    if (Get.isRegistered<PaymentController>()) {
      Get.find<PaymentController>().clearListeners();
      Get.delete<PaymentController>(force: true);
      paymentFlowLog('STEP 8-pre3 — PaymentController deleted (force)');
    }

    NavigationGuard.begin();
    paymentFlowLog('STEP 8a — NavigationGuard.isNavigating=true (no Rx yet)');

    paymentFlowLog('STEP 9 — scheduling Get.offAll(MyBooking) post-frame…');
    final navCompleter = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navFuture = Get.offAll(() => MyBooking(
            fromPropBooking: false,
            initialTabIndex: tabIndex,
          ));
      (navFuture ?? Future<void>.value()).whenComplete(() {
        if (!navCompleter.isCompleted) navCompleter.complete();
      });
    });
    await navCompleter.future;
    paymentFlowLog('STEP 10 — Get.offAll(MyBooking) completed');

    paymentFlowLog(
        'STEP 11 — waiting ${_postNavigationSettleDelay.inMilliseconds}ms');
    await Future.delayed(_postNavigationSettleDelay);
    paymentFlowLog('STEP 12 — settle delay done, applying post-nav mutations');

    isProcessingBooking.value = false;
    paymentFlowLog('STEP 12a — isProcessingBooking=false');
    clearListeners();
    paymentFlowLog('STEP 12b — clearListeners() done');

    generalController.myBookingTabIndex.value = tabIndex;
    generalController.currentIndex.value = 2;
    paymentFlowLog('STEP 12c — generalController tabs set',
        'myBookingTabIndex=$tabIndex, currentIndex=2');

    if (Get.isRegistered<BookingRecordController>()) {
      final type = BookingRecordController.typeForTabIndex(tabIndex);
      paymentFlowLog('STEP 13 — getBookingRecord($type)');
      await Get.find<BookingRecordController>().getBookingRecord(
        type: type,
        offset: 0,
        bypassNavigationGuard: true,
      );
      paymentFlowLog('STEP 13b — getBookingRecord completed');
    }

    Get.safeSnackbar(
      snackTitle,
      snackMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );

    NavigationGuard.endAfterFrame();
    if (Get.isRegistered<BookingRecordController>()) {
      Get.find<BookingRecordController>().restoreListeners();
    }
    paymentFlowLog('STEP 14 — _navigateToBookingsAfterPayment END');
  }

  /// Retour arrière puis refresh (extension de réservation, etc.).
  Future<void> _popThenRefreshBookings({
    required String bookingRecordType,
    required String snackTitle,
    required String snackMessage,
  }) async {
    isProcessingBooking.value = false;
    clearListeners();

    if (Get.isRegistered<BookingRecordController>()) {
      Get.find<BookingRecordController>().armPostNavigationFetchDelay();
    }

    if (Get.key.currentState?.canPop() == true) {
      Get.back();
    }
    await Future.delayed(_postNavigationSettleDelay);

    if (Get.isRegistered<BookingRecordController>()) {
      final recordController = Get.find<BookingRecordController>();
      if (!recordController.isClosed && !recordController.isLoading.value) {
        await recordController.getBookingRecord(
          type: bookingRecordType,
          offset: 0,
        );
      }
    }

    Get.safeSnackbar(
      snackTitle,
      snackMessage,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  // ========== Formulaire d'avis client (véhicule + agence) ==========
  RxDouble vehicleRating = 5.0.obs;
  RxDouble agencyRating = 5.0.obs;
  final TextEditingController reviewCommentController = TextEditingController();
  RxBool isSubmittingReview = false.obs;

  void resetClientReviewForm() {
    vehicleRating.value = 5.0;
    agencyRating.value = 5.0;
    reviewCommentController.clear();
    isSubmittingReview.value = false;
  }

  void _logReviewIdDebug(Bookings booking, String? resolvedVehicleId) {
    debugPrint('🚨 [DEBUG REVIEW] ========== IDs réservation ==========');
    debugPrint('🚨 [DEBUG REVIEW] Booking ID (brut): ${booking.id}');
    debugPrint('🚨 [DEBUG REVIEW] Booking ID (normalisé): ${Bookings.normalizeEntityId(booking.id)}');
    debugPrint('🚨 [DEBUG REVIEW] itemid (brut): ${booking.itemid}');
    debugPrint('🚨 [DEBUG REVIEW] vehicleId getter: ${booking.vehicleId}');
    debugPrint('🚨 [DEBUG REVIEW] hostId / vendor: ${booking.hostId}');
    debugPrint('🚨 [DEBUG REVIEW] depuis item_data: ${Bookings.extractVehicleIdFromItemData(booking.itemData)}');
    final itemDataStr = booking.itemData?.toString() ?? '';
    debugPrint(
      '🚨 [DEBUG REVIEW] item_data (aperçu): ${itemDataStr.length > 200 ? itemDataStr.substring(0, 200) : itemDataStr}',
    );
    debugPrint('🚨 [DEBUG REVIEW] Vehicle ID retenu pour API: $resolvedVehicleId');
    debugPrint(
      '🚨 [DEBUG REVIEW] Format MongoDB 24 hex: ${Bookings.isLikelyMongoObjectId(resolvedVehicleId)}',
    );
    debugPrint('🚨 [DEBUG REVIEW] =====================================');
  }

  void _markBookingReviewedLocally(Bookings booking) {
    booking.isReviewedSetter = '1';
    booking.reviewStatusSetter = '1';
    try {
      final brc = Get.find<BookingRecordController>();
      final i = brc.bookingsList.indexWhere((b) => b.id == booking.id);
      if (i >= 0) {
        brc.bookingsList[i].isReviewedSetter = '1';
        brc.bookingsList[i].reviewStatusSetter = '1';
        if (!brc.isClosed) {
          brc.bookingsList.refresh();
        }
      }
    } catch (_) {}
  }

  /// Envoie l'avis client vers [Config.submitReview]. Retourne `true` si succès.
  Future<bool> submitClientReview(
    Bookings booking, {
    VoidCallback? onReviewSubmitted,
  }) async {
    final bookingId = Bookings.normalizeEntityId(booking.id);
    final vendorId = Bookings.normalizeEntityId(booking.hostId);
    final vehicleId = Bookings.resolveVehicleIdForReview(booking);

    _logReviewIdDebug(booking, vehicleId);

    if (bookingId == null || bookingId.isEmpty) {
      showErrorToastMessage('Booking not found'.tr);
      return false;
    }
    if (vendorId == null || vendorId.isEmpty) {
      showErrorToastMessage('Agency not found'.tr);
      return false;
    }
    if (vehicleId == null || vehicleId.isEmpty) {
      debugPrint('🚨 [DEBUG REVIEW] ABORT — vehicle_id vide après résolution');
      showErrorToastMessage('Vehicle not found'.tr);
      return false;
    }
    if (!Bookings.isLikelyMongoObjectId(vehicleId)) {
      debugPrint(
        '🚨 [DEBUG REVIEW] ATTENTION — vehicle_id "$vehicleId" n\'a pas le format MongoDB 24 hex (risque 404 véhicule introuvable)',
      );
    }

    isSubmittingReview.value = true;
    try {
      final body = <String, dynamic>{
        'booking_id': bookingId,
        'vendor_id': vendorId,
        'vehicle_id': vehicleId,
        'vehicle_rating': vehicleRating.value.round(),
        'agency_rating': agencyRating.value.round(),
        'comment': reviewCommentController.text.trim(),
      };
      debugPrint('🚨 [DEBUG REVIEW] Payload submit-review: $body');
      final response = await httpPost(Config.submitReview, body);
      debugPrint('🚨 [DEBUG REVIEW] Réponse serveur: $response');

      if (response != null && response['status'] == 200) {
        _markBookingReviewedLocally(booking);
        onReviewSubmitted?.call();
        return true;
      }
      showErrorToastMessage(
        response?['message']?.toString() ??
            response?['error']?.toString() ??
            'Une erreur est survenue'.tr,
      );
      return false;
    } catch (e) {
      showErrorToastMessage('Erreur de connexion'.tr);
      return false;
    } finally {
      isSubmittingReview.value = false;
    }
  }

  /// Gère l'ouverture automatique de l'écran OTP après upload d'images
  void _handleOtpAfterImageSubmit() {
    print('🚀 [WORKER] Exécution de _handleOtpAfterImageSubmit');
    // Ici, vous pouvez ajouter la logique pour ouvrir l'écran OTP
    // Par exemple : Get.to(() => OtpScreen());
    // Ou notifier l'UI pour afficher une modal, etc.
  }

  int numberofguest = 1;
  bool isChecked = false;
  RxBool isDateAvailale = false.obs;
  bool processing = true;
  RxString endDate = ''.obs;
  RxString startDate = ''.obs;
  RxString datednotAvalibleError = ''.obs;
  final TextEditingController textControllerNotetoOwner =
      TextEditingController();
  final TextEditingController vehicleNoController = TextEditingController();
  final TextEditingController textControllerBookingforSomeone =
      TextEditingController();
  DateRangePickerController dateRangePickerController =
      DateRangePickerController();
  List<DateTime> alreadySelectedList = [];
  List<DateTime> availableDates = [];
  RxBool isDateChecking = false.obs;
  String checkDateMsg = "";
  bool checkDateResult = false;
  bool chack = false;
  bool addDoorStepPrice = false;
  dynamic idFeatured = "";
  RxString curreentStatus = "".obs;
  RxBool openOtpAfterImageSubmit = false.obs;
  RxString currentBookingIdForOtp = "".obs;
  List availableDatesPrice = [];

  /// Tunnel calendrier + sélection d’heure terminé — requis pour activer « Payer maintenant ».
  RxBool vehicleBookingTunnelComplete = false.obs;

  /// Jours facturés pour le véhicule selon le cycle 24h.
  /// Si l'heure de fin est strictement supérieure à l'heure de début,
  /// une journée supplémentaire est ajoutée.
  int calculateRentalDays(
      DateTime start, DateTime end, TimeOfDay startTime, TimeOfDay endTime) {
    return RentalBillingDays.compute(
      startDate: start,
      endDate: end,
      startTime: startTime,
      endTime: endTime,
    ).totalDays;
  }

  /// Backward-compatible helper used by existing summary screens.
  /// Falls back to date-only billing when times are not provided here.
  int vehicleBillableNightCount(DateTime checkIn, DateTime checkOut) {
    final startTime = _parseStringToTimeOfDay(selectedStartTime.value);
    final endTime = _parseStringToTimeOfDay(selectedEndTime.value);
    return calculateRentalDays(checkIn, checkOut, startTime, endTime);
  }

  TimeOfDay _parseStringToTimeOfDay(String value) {
    if (value.isEmpty) return const TimeOfDay(hour: 9, minute: 0);
    try {
      if (RegExp(r'^[0-9]{1,2}:[0-9]{2}$').hasMatch(value)) {
        final parts = value.split(':');
        return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
      final parsed = DateFormat('h:mm a').parse(value);
      return TimeOfDay(hour: parsed.hour, minute: parsed.minute);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }
    return days;
  }

  getData(dynamic idFeatured) async {
    BookdDate bookdDate = await bookDateApi(idFeatured: '$idFeatured');
    for (int i = 0; i < bookdDate.data!.itemBookingDate!.length; i++) {
      List<DateTime> daysx = getDaysInBetween(
        DateTime.tryParse(bookdDate.data!.itemBookingDate![i].checkIn!)!,
        DateTime.tryParse(bookdDate.data!.itemBookingDate![i].checkOut!)!,
      );
      alreadySelectedList.addAll(daysx);
    }
    processing = false;
  }

  checkDateApi({
    String? idFeatured,
  }) async {
    error.value = false;

    if (activeModuleId.value != 2 &&
        activeModuleId.value != 3 &&
        activeModuleId.value != 5 &&
        activeModuleId.value != 6 &&
        activeModuleId.value != 4) {
      if (startDate.value == endDate.value) {
        isDateAvailale.value = false;
        endDate.value = "";
        return;
      }
    }
    isDateChecking.value = true;
    try {
      String startTimeForBackend = selectedStartTime.value;
      String endTimeForBackend = selectedEndTime.value;

      if (selectedStartTime.value.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'))) {
        startTimeForBackend = convert24To12(selectedStartTime.value);
        endTimeForBackend = convert24To12(selectedEndTime.value);
      }
      Map map = {
        "item_id": "$idFeatured",
        "check_in": startDate.value,
        "check_out": endDate.value,
        "start_time": startTimeForBackend,
        "end_time": endTimeForBackend,
      };

      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var result = await httpPost(Config.checkBookingAvailability, map);

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Return static response data
      Map<String, dynamic> result = {
        "status": 200,
        "message": "Booking availability checked successfully",
        "error": "",
        "data": {
          "next_start_time": "12:00 AM",
          "next_end_time": "11:30 AM",
          "availability": {
            "next_start_time": "12:00 AM",
            "next_end_time": "11:30 AM",
            "is_available": true
          },
          "bookingOverlapDetails": []
        }
      };

      if (result['status'] == 200 || result['status'] == 422) {
        final data = result["data"] as Map<String, dynamic>?;
        if (data != null) {
          if (data["next_start_time"] != null) {
            nextStartTime.value =
                convert12To24(data["next_start_time"] as String);
            nextEndTime.value = convert12To24(data["next_end_time"] as String);
          }

          if (data["availability"] != null) {
            final availability = data["availability"] as Map<String, dynamic>;
            if (availability["next_start_time"] != null) {
              nextStartTime.value =
                  convert12To24(availability["next_start_time"] as String);
              nextEndTime.value =
                  convert12To24(availability["next_end_time"] as String);
            }
          }
        }
      }
      if (result['status'] == 422) {
        isDateAvailale.value = false;
        isDateChecking.value = false;
        final bookingDetails =
            (result["data"] as Map<String, dynamic>?)?["bookingOverlapDetails"];
        final nextTimeSlot =
            (result["data"] as Map<String, dynamic>?)?["next_start_time"];
        if (bookingDetails is List && bookingDetails.isNotEmpty) {
          showBookingOverlapBottomSheet(bookingDetails, nextTimeSlot);
          isDateAvailale.value = true;
        } else {
          isDateAvailale.value = false;
        }
      } else if (result['status'] == 200) {
        isDateChecking.value = false;
        checkDateResult =
            result["data"]['availability']['is_available'] as bool;
        checkDateMsg = result["error"] as String;
        if (checkDateResult) {
          isDateAvailale.value = true;
        } else {
          isDateAvailale.value = false;
          showErrorToastMessage((checkDateMsg.isEmpty
                  ? 'Booking not available at this date'
                  : checkDateMsg)
              .tr);
        }
      } else {
        error.value = true;
        isDateAvailale.value = false;
        datednotAvalibleError.value = result["error"] as String? ?? "";
        showErrorToastMessage(result["error"] as String? ?? "");
      }

      safeUpdate();
      return result;
    } finally {
      isDateChecking.value = false;
      safeUpdate();
    }
  }

  int tabIndexOfMybooking = 0;
  var isLoading = false.obs;
  bookDateApi({String? idFeatured}) async {
    isLoading.value = true;
    try {
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response = await httpPost(Config.itemBookingDate, {'id': idFeatured});
      //
      // BookdDate result = BookdDate.fromJson(response);
      //
      // return result;

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Return static BookdDate data
      // NOTE: This simule les plages de dates déjà réservées pour un véhicule.
      Map<String, dynamic> mockResponse = {
        "status": 200,
        "message": "Item booking dates retrieved successfully",
        "error": "",
        "data": {
          "itemBookingDate": [
            {"check_in": "2024-12-20", "check_out": "2024-12-22"},
            {"check_in": "2024-12-28", "check_out": "2025-01-02"}
          ]
        }
      };

      BookdDate result = BookdDate.fromJson(mockResponse);
      return result;
    } finally {
      isLoading.value = false;
      safeUpdate();
    }
  }

  PageController pageControllerslider = PageController();
  final ValueNotifier<int> currentPageSliderNotifier = ValueNotifier<int>(0);
  RxBool showAddCouponBtn = false.obs;
  var isPaymentSuccess = false.obs;
  var isProcessingBooking = false.obs;
  String currency = "";
  double discount = 0;
  double basePrice = 0;
  double serviceCharge = 0;
  double tax = 0;
  GetItemPrices? getItemPrices;
  WalletModel? walletModel;
  BookingPaymentMethodModel? paymentMethodModel;
  RxBool isLoadingPaymentMethods = false.obs;
  PaymentMethod? selectedPaymentMethod;
  List<PaymentMethod> paymentMethodsList = []; // Liste synchronisée pour l'UI
  ExtensionPaymentContext? extensionPaymentContext;
  TextEditingController textEditingController = TextEditingController();
  listner() {
    if (textEditingController.text.isNotEmpty) {
      showAddCouponBtn.value = true;
    } else {
      showAddCouponBtn.value = false;
    }
  }

  onWillPop() {
    if (isPaymentSuccess.value == false) {
      Get.back();
      safeUpdate();
    } else {
      safeUpdate();
    }
  }

  String convert12To24(String time12) {
    if (time12.isEmpty) return "";
    try {
      String cleanTime = time12.trim().toUpperCase();
      if (!cleanTime.contains(" ")) {
        cleanTime = cleanTime.replaceAllMapped(
            RegExp(r'([0-9])([AP]M)'), (Match m) => '${m[1]} ${m[2]}');
      }
      DateFormat inputFormat = DateFormat('h:mm a');
      DateFormat outputFormat = DateFormat('HH:mm');
      DateTime dateTime = inputFormat.parse(cleanTime);
      return outputFormat.format(dateTime);
    } catch (e) {
      debugPrint('Error converting 12 to 24: $e for time: $time12');
      try {
        String cleanTime = time12.trim().toUpperCase();
        bool isPM = cleanTime.contains('PM');
        String timeWithoutAmPm =
            cleanTime.replaceAll(RegExp(r'[AP]M'), '').trim();

        List<String> parts = timeWithoutAmPm.split(':');
        if (parts.length != 2) return time12;
        int hours = int.tryParse(parts[0]) ?? 0;
        int minutes = int.tryParse(parts[1]) ?? 0;

        if (isPM && hours < 12) {
          hours += 12;
        } else if (!isPM && hours == 12) {
          hours = 0;
        }
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      } catch (e2) {
        debugPrint('Manual conversion also failed: $e2');
        return "00:00";
      }
    }
  }

  String convert24To12(String time24) {
    try {
      DateFormat inputFormat = DateFormat('HH:mm');
      DateFormat outputFormat = DateFormat('h:mm a');
      DateTime dateTime = inputFormat.parse(time24);
      return outputFormat.format(dateTime);
    } catch (e) {
      try {
        List<String> parts = time24.split(':');
        int hours = int.parse(parts[0]);
        int minutes = int.parse(parts[1]);

        String amPm = hours >= 12 ? 'PM' : 'AM';
        int hour12 = hours % 12;
        if (hour12 == 0) hour12 = 12;

        return '$hour12:${minutes.toString().padLeft(2, '0')} $amPm';
      } catch (e) {
        return time24;
      }
    }
  }

  var error = false.obs;
  getDataBookingSummery(dynamic idFeatured, coupon, wallet, isAddDoorStepPrice,
      {String? dailyPrice}) async {
    // ========== LOGS DE DÉBUT ==========
    print(
        '🚀 [getDataBookingSummery] ========================================');
    print('🚀 [getDataBookingSummery] Début de la méthode');
    debugPrint('🚀 [getDataBookingSummery] Début de la méthode');

    // ========== LOGS DES ARGUMENTS REÇUS ==========
    print('📥 [getDataBookingSummery] Arguments reçus:');
    print('   - idFeatured: $idFeatured');
    print('   - coupon: $coupon');
    print('   - wallet: $wallet');
    print('   - isAddDoorStepPrice: $isAddDoorStepPrice');
    debugPrint(
        '📥 [getDataBookingSummery] idFeatured: $idFeatured, coupon: $coupon, wallet: $wallet, isAddDoorStepPrice: $isAddDoorStepPrice');

    // ========== INITIALISATION ==========
    error.value = false;
    isLoading.value = true;
    print('🔄 [getDataBookingSummery] isLoading mis à true');
    debugPrint('🔄 [getDataBookingSummery] isLoading mis à true');
    safeUpdate();
    print('🔄 [getDataBookingSummery] Premier appel update() effectué');
    debugPrint('🔄 [getDataBookingSummery] Premier appel update() effectué');

    try {
      String startTimeForBackend = selectedStartTime.value;
      String endTimeForBackend = selectedEndTime.value;

      if (selectedStartTime.value.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'))) {
        startTimeForBackend = convert24To12(selectedStartTime.value);
        endTimeForBackend = convert24To12(selectedEndTime.value);
      }

      Map map = {
        "item_id": "$idFeatured",
        "check_in": "$startDate",
        "check_out": "$endDate",
        "coupon_code": coupon,
        "wallet_amount": "$wallet",
        "start_time": startTimeForBackend,
        "end_time": endTimeForBackend,
        "doorStep_price": "$isAddDoorStepPrice",
      };

      print('📤 [getDataBookingSummery] Données de la requête préparées:');
      print('   - item_id: ${map["item_id"]}');
      print('   - check_in: ${map["check_in"]}');
      print('   - check_out: ${map["check_out"]}');
      print('   - coupon_code: ${map["coupon_code"]}');
      print('   - wallet_amount: ${map["wallet_amount"]}');
      debugPrint('📤 [getDataBookingSummery] Map de requête: $map');

      // ========== LOG AVANT APPEL API ==========
      print(
          '🌐 [getDataBookingSummery] Début de l\'appel API vers: ${Config.getItemPrices}');
      debugPrint(
          '🌐 [getDataBookingSummery] Début de l\'appel API vers: ${Config.getItemPrices}');
      print(
          '🌐 [getDataBookingSummery] URL complète: ${Config.baseurl}${Config.getItemPrices}');
      debugPrint(
          '🌐 [getDataBookingSummery] URL complète: ${Config.baseurl}${Config.getItemPrices}');

      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response = await httpPost(Config.getItemPrices, map);

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Calculate billable days from dates + times (cycle 24h)
      int totalNights = 1;
      if (startDate.value.isNotEmpty && endDate.value.isNotEmpty) {
        try {
          DateTime checkIn =
              DateTime.tryParse(startDate.value) ?? DateTime.now();
          DateTime checkOut =
              DateTime.tryParse(endDate.value) ?? DateTime.now();
          totalNights = calculateRentalDays(
            checkIn,
            checkOut,
            _parseStringToTimeOfDay(selectedStartTime.value),
            _parseStringToTimeOfDay(selectedEndTime.value),
          );
        } catch (e) {
          totalNights = 1;
        }
      }

      // MOCK: Get daily price from parameter or use default
      double dailyPriceValue = 50.00;
      if (dailyPrice != null && dailyPrice.isNotEmpty) {
        try {
          dailyPriceValue = double.parse(dailyPrice);
          if (dailyPriceValue <= 0) dailyPriceValue = 50.00;
        } catch (e) {
          dailyPriceValue = 50.00;
        }
      }

      // Calculate prices using real daily price and real number of days
      double basePrice = dailyPriceValue * totalNights;
      double grossPrice = basePrice;

      // MOCK: Return dynamic response data (sans taxe / dépôt / nettoyage / frais service)
      Map<String, dynamic> response = {
        "status": 200,
        "message": "Item prices retrieved successfully",
        "error": "",
        "data": {
          "discount_type": "",
          "prices": [
            {
              "date":
                  startDate.value.isNotEmpty ? startDate.value : "2024-12-16",
              "price": dailyPriceValue.toStringAsFixed(2),
              "status": "Available"
            },
            {
              "date": endDate.value.isNotEmpty ? endDate.value : "2024-12-17",
              "price": dailyPriceValue.toStringAsFixed(2),
              "status": "Available"
            }
          ],
          "price_before_discount": basePrice.toStringAsFixed(2),
          "price_per_day": dailyPriceValue.toStringAsFixed(2),
          "total_days": "$totalNights",
          "discount_price": "0.00",
          "coupon_discount": "0.00",
          "price_after_discount": basePrice.toStringAsFixed(2),
          "service_charge": "0.00",
          "cleaning_charge": "0.00",
          "coupon_code": coupon ?? "",
          "tax": "0.00",
          "wallet_amount": wallet ?? "0.00",
          "remaining_wallet_balance": "0.00",
          "gross_price": grossPrice.toStringAsFixed(2),
          "duration": totalNights,
          "security_deposit": "0.00",
          "distance": "0",
          "label": ""
        }
      };

      // ========== LOGS DE LA RÉPONSE API ==========
      print('📥 [getDataBookingSummery] Réponse API reçue');
      debugPrint('📥 [getDataBookingSummery] Réponse API reçue');

      // ========== LOG DE LA RÉPONSE BRUTE JSON ==========
      print(
          '📋 [getDataBookingSummery] ========== RÉPONSE BRUTE JSON ==========');
      debugPrint(
          '📋 [getDataBookingSummery] ========== RÉPONSE BRUTE JSON ==========');
      print(
          '📋 [getDataBookingSummery] Réponse complète: ${jsonEncode(response)}');
      debugPrint(
          '📋 [getDataBookingSummery] Réponse complète: ${jsonEncode(response)}');

      // Log spécifique de la structure data.prices
      if (response['data'] != null && response['data']['prices'] != null) {
        print('📋 [getDataBookingSummery] Structure data.prices trouvée');
        debugPrint('📋 [getDataBookingSummery] Structure data.prices trouvée');
        print(
            '📋 [getDataBookingSummery] Type de prices: ${response['data']['prices'].runtimeType}');
        debugPrint(
            '📋 [getDataBookingSummery] Type de prices: ${response['data']['prices'].runtimeType}');
        print(
            '📋 [getDataBookingSummery] Nombre d\'éléments dans prices: ${(response['data']['prices'] as List).length}');
        debugPrint(
            '📋 [getDataBookingSummery] Nombre d\'éléments dans prices: ${(response['data']['prices'] as List).length}');

        // Log de chaque élément dans prices AVANT parsing
        for (var i = 0; i < (response['data']['prices'] as List).length; i++) {
          var rawPriceItem = response['data']['prices'][i];
          print('📋 [getDataBookingSummery] RAW Prix[$i]: $rawPriceItem');
          debugPrint('📋 [getDataBookingSummery] RAW Prix[$i]: $rawPriceItem');
          if (rawPriceItem is Map) {
            print(
                '📋 [getDataBookingSummery]   - date: ${rawPriceItem['date']}');
            print(
                '📋 [getDataBookingSummery]   - price: ${rawPriceItem['price']} (type: ${rawPriceItem['price'].runtimeType})');
            print(
                '📋 [getDataBookingSummery]   - status: ${rawPriceItem['status']}');
            debugPrint(
                '📋 [getDataBookingSummery]   - date: ${rawPriceItem['date']}, price: ${rawPriceItem['price']}, status: ${rawPriceItem['status']}');

            // Vérifier si price est null, vide, ou "0"
            if (rawPriceItem['price'] == null) {
              print(
                  '⚠️ [getDataBookingSummery] ATTENTION: price est NULL dans la réponse brute');
              debugPrint(
                  '⚠️ [getDataBookingSummery] ATTENTION: price est NULL dans la réponse brute');
            } else if (rawPriceItem['price'].toString().isEmpty) {
              print(
                  '⚠️ [getDataBookingSummery] ATTENTION: price est VIDE dans la réponse brute');
              debugPrint(
                  '⚠️ [getDataBookingSummery] ATTENTION: price est VIDE dans la réponse brute');
            } else if (rawPriceItem['price'].toString() == "0" ||
                rawPriceItem['price'].toString() == "0.00") {
              print(
                  '⚠️ [getDataBookingSummery] ATTENTION: price = 0 dans la réponse brute');
              debugPrint(
                  '⚠️ [getDataBookingSummery] ATTENTION: price = 0 dans la réponse brute');
            }
          }
        }
      } else {
        print(
            '⚠️ [getDataBookingSummery] ATTENTION: data.prices est null ou absent dans la réponse');
        debugPrint(
            '⚠️ [getDataBookingSummery] ATTENTION: data.prices est null ou absent dans la réponse');
      }

      // Log de price_per_day
      if (response['data'] != null &&
          response['data']['price_per_day'] != null) {
        print(
            '📋 [getDataBookingSummery] price_per_day brut: ${response['data']['price_per_day']} (type: ${response['data']['price_per_day'].runtimeType})');
        debugPrint(
            '📋 [getDataBookingSummery] price_per_day brut: ${response['data']['price_per_day']}');
      } else {
        print(
            '⚠️ [getDataBookingSummery] ATTENTION: price_per_day est null ou absent');
        debugPrint(
            '⚠️ [getDataBookingSummery] ATTENTION: price_per_day est null ou absent');
      }

      print(
          '📋 [getDataBookingSummery] ============================================');
      debugPrint(
          '📋 [getDataBookingSummery] ============================================');

      if (response != null) {
        print(
            '📊 [getDataBookingSummery] Statut de la réponse: ${response['status']}');
        debugPrint(
            '📊 [getDataBookingSummery] Statut de la réponse: ${response['status']}');
        print('📊 [getDataBookingSummery] Message: ${response['message']}');
        debugPrint(
            '📊 [getDataBookingSummery] Message: ${response['message']}');

        if (response['status'] == 200) {
          print('✅ [getDataBookingSummery] SUCCÈS - Statut 200');
          debugPrint('✅ [getDataBookingSummery] SUCCÈS - Statut 200');

          try {
            getItemPrices = applySimplifiedVehicleBookingPrices(
                GetItemPrices.fromJson(response));
            print('✅ [getDataBookingSummery] Parsing JSON réussi');
            debugPrint('✅ [getDataBookingSummery] Parsing JSON réussi');

            // ========== LOGS DÉTAILLÉS DES PRIX PAR JOUR ==========
            if (getItemPrices != null && getItemPrices!.data != null) {
              print(
                  '💰 [getDataBookingSummery] ========== ANALYSE DES PRIX ==========');
              debugPrint(
                  '💰 [getDataBookingSummery] ========== ANALYSE DES PRIX ==========');

              // Log du prix par nuit
              print(
                  '💰 [getDataBookingSummery] pricePerNight: ${getItemPrices!.data!.pricePerNight}');
              debugPrint(
                  '💰 [getDataBookingSummery] pricePerNight: ${getItemPrices!.data!.pricePerNight}');

              // Log du prix brut
              print(
                  '💰 [getDataBookingSummery] grossPrice: ${getItemPrices!.data!.grossPrice}');
              debugPrint(
                  '💰 [getDataBookingSummery] grossPrice: ${getItemPrices!.data!.grossPrice}');

              // Log de la liste des prix par jour
              if (getItemPrices!.data!.prices != null &&
                  getItemPrices!.data!.prices!.isNotEmpty) {
                print(
                    '📅 [getDataBookingSummery] Nombre de prix par jour: ${getItemPrices!.data!.prices!.length}');
                debugPrint(
                    '📅 [getDataBookingSummery] Nombre de prix par jour: ${getItemPrices!.data!.prices!.length}');

                for (var i = 0; i < getItemPrices!.data!.prices!.length; i++) {
                  var priceItem = getItemPrices!.data!.prices![i];
                  print(
                      '📅 [getDataBookingSummery] Prix[$i] - Date: ${priceItem.date}, Price: ${priceItem.price}, Status: ${priceItem.status}');
                  debugPrint(
                      '📅 [getDataBookingSummery] Prix[$i] - Date: ${priceItem.date}, Price: ${priceItem.price}, Status: ${priceItem.status}');

                  // Vérifier si le prix est null ou vide
                  if (priceItem.price == null || priceItem.price!.isEmpty) {
                    print(
                        '⚠️ [getDataBookingSummery] ATTENTION: Prix vide ou null pour la date ${priceItem.date}');
                    debugPrint(
                        '⚠️ [getDataBookingSummery] ATTENTION: Prix vide ou null pour la date ${priceItem.date}');
                  } else {
                    // Essayer de parser le prix pour vérifier qu'il est valide
                    try {
                      double priceValue = double.parse(priceItem.price!);
                      if (priceValue == 0) {
                        print(
                            '⚠️ [getDataBookingSummery] ATTENTION: Prix = 0 pour la date ${priceItem.date}');
                        debugPrint(
                            '⚠️ [getDataBookingSummery] ATTENTION: Prix = 0 pour la date ${priceItem.date}');
                      }
                    } catch (e) {
                      print(
                          '❌ [getDataBookingSummery] ERREUR parsing prix "${priceItem.price}" pour date ${priceItem.date}: $e');
                      debugPrint(
                          '❌ [getDataBookingSummery] ERREUR parsing prix "${priceItem.price}" pour date ${priceItem.date}: $e');
                    }
                  }
                }
              } else {
                print(
                    '⚠️ [getDataBookingSummery] ATTENTION: Liste des prix par jour est vide ou null');
                debugPrint(
                    '⚠️ [getDataBookingSummery] ATTENTION: Liste des prix par jour est vide ou null');
              }

              print(
                  '💰 [getDataBookingSummery] ============================================');
              debugPrint(
                  '💰 [getDataBookingSummery] ============================================');
            } else {
              print(
                  '❌ [getDataBookingSummery] ERREUR: getItemPrices ou data est null après parsing');
              debugPrint(
                  '❌ [getDataBookingSummery] ERREUR: getItemPrices ou data est null après parsing');
            }
          } catch (e, stackTrace) {
            print('❌ [getDataBookingSummery] ERREUR lors du parsing JSON: $e');
            debugPrint(
                '❌ [getDataBookingSummery] ERREUR lors du parsing JSON: $e');
            debugPrint('❌ [getDataBookingSummery] StackTrace: $stackTrace');
            error.value = true;
            showErrorToastMessage("Erreur lors du traitement des données".tr);
          }
        } else {
          print(
              '❌ [getDataBookingSummery] ERREUR - Statut: ${response['status']}');
          debugPrint(
              '❌ [getDataBookingSummery] ERREUR - Statut: ${response['status']}');
          print(
              '❌ [getDataBookingSummery] Message d\'erreur: ${response['error']}');
          debugPrint(
              '❌ [getDataBookingSummery] Message d\'erreur: ${response['error']}');
          error.value = true;
          showErrorToastMessage(response['error'] as String? ?? "");
        }
      } else {
        print('❌ [getDataBookingSummery] ERREUR - Réponse nulle');
        debugPrint('❌ [getDataBookingSummery] ERREUR - Réponse nulle');
        error.value = true;
        showErrorToastMessage("Aucune réponse du serveur".tr);
      }
    } catch (e, stackTrace) {
      // ========== GESTION DES ERREURS ==========
      print('❌ [getDataBookingSummery] EXCEPTION CAPTURÉE: $e');
      debugPrint('❌ [getDataBookingSummery] EXCEPTION CAPTURÉE: $e');
      debugPrint('❌ [getDataBookingSummery] StackTrace: $stackTrace');

      error.value = true;
      showErrorToastMessage(
          "Une erreur est survenue lors du chargement des données".tr);
    } finally {
      // ========== GARANTIR L'ARRÊT DU LOADING ==========
      isLoading.value = false;
      print('🔄 [getDataBookingSummery] isLoading mis à false dans finally');
      debugPrint(
          '🔄 [getDataBookingSummery] isLoading mis à false dans finally');

      // ========== LOG AVANT UPDATE FINAL ==========
      print('🔄 [getDataBookingSummery] Appel de update() final');
      debugPrint('🔄 [getDataBookingSummery] Appel de update() final');
      safeUpdate();
      print('✅ [getDataBookingSummery] update() final effectué');
      debugPrint('✅ [getDataBookingSummery] update() final effectué');

      print('🏁 [getDataBookingSummery] Fin de la méthode');
      debugPrint('🏁 [getDataBookingSummery] Fin de la méthode');
      print(
          '🏁 [getDataBookingSummery] ========================================');
      debugPrint(
          '🏁 [getDataBookingSummery] ========================================');
    }
  }

  getWalletData() async {
    error.value = false;
    safeUpdate();

    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var resp = await httpPost(Config.getUserWallet, {});
    // if (resp != null) {
    //   walletModel = WalletModel.fromJson(resp);
    //   if (walletModel!.status == 200) {
    //   } else {
    //     error.value = true;
    //     safeUpdate();
    //     showErrorToastMessage(walletModel!.error);
    //   }
    // }

    try {
      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Return static wallet data
      Map<String, dynamic> mockResponse = {
        "status": 200,
        "message": "Wallet data retrieved successfully",
        "error": "",
        "data": {"wallet_balance": "150.00"}
      };

      walletModel = WalletModel.fromJson(mockResponse);
      if (walletModel!.status == 200) {
        // rien à faire, juste exposer walletModel dans le contrôleur
      } else {
        error.value = true;
        showErrorToastMessage(
            walletModel!.error ?? "Failed to load wallet data");
      }
    } catch (e) {
      error.value = true;
      showErrorToastMessage("Failed to load wallet data");
    } finally {
      safeUpdate();
    }
  }

  Future<void> fetchPaymentMethods() async {
    isLoadingPaymentMethods.value = true;
    paymentMethodModel = null;
    paymentMethodsList.clear(); // Vider la liste au début
    error.value = false;
    notifyPaymentMethodBody();

    try {
      // Appel API GET /api/v1/payment-methods
      var response = await httpGet(Config.getPaymentMethods, {});

      // ========== DIAGNOSTIC COMPLET DE LA STRUCTURE ==========
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('🔍 STRUCTURE COMPLETE : $response');
      debugPrint('🔍 TYPE DE RESPONSE : ${response.runtimeType}');

      if (response != null) {
        debugPrint(
            '🔍 Clés disponibles dans response: ${response.keys.toList()}');
        debugPrint(
            '🔍 response.containsKey("status"): ${response.containsKey("status")}');
        debugPrint(
            '🔍 response.containsKey("success"): ${response.containsKey("success")}');
        debugPrint(
            '🔍 response.containsKey("data"): ${response.containsKey("data")}');

        if (response.containsKey('status')) {
          debugPrint('🔍 response["status"]: ${response["status"]}');
        }
        if (response.containsKey('success')) {
          debugPrint('🔍 response["success"]: ${response["success"]}');
        }
        if (response.containsKey('data')) {
          debugPrint(
              '🔍 response["data"] type: ${response["data"].runtimeType}');
          debugPrint('🔍 response["data"] contenu: ${response["data"]}');

          if (response['data'] is List) {
            debugPrint(
                '🔍 response["data"] est une List avec ${(response['data'] as List).length} éléments');
          } else if (response['data'] is Map) {
            debugPrint(
                '🔍 response["data"] est un Map avec clés: ${(response['data'] as Map).keys.toList()}');
            if ((response['data'] as Map).containsKey('data')) {
              var innerData = (response['data'] as Map)['data'];
              debugPrint(
                  '🔍 response["data"]["data"] type: ${innerData.runtimeType}');
              debugPrint('🔍 response["data"]["data"] contenu: $innerData');
              if (innerData is List) {
                debugPrint(
                    '🔍 response["data"]["data"] est une List avec ${innerData.length} éléments');
              }
            }
          }
        }
      }
      debugPrint('═══════════════════════════════════════════════════════');
      // ========== FIN DIAGNOSTIC ==========

      // Log pour diagnostic
      print('Données reçues : ${jsonEncode(response)}');
      debugPrint('Données reçues : ${jsonEncode(response)}');

      // Vérifier si response contient 'success': true ou 'status': 200
      bool isSuccess = false;
      if (response != null) {
        if (response.containsKey('success') && response['success'] == true) {
          isSuccess = true;
          debugPrint('✅ Réponse avec success: true');
        } else if (response.containsKey('status') &&
            response['status'] == 200) {
          isSuccess = true;
          debugPrint('✅ Réponse avec status: 200');
        }
      }

      if (response != null && isSuccess) {
        // ========== CORRECTION : Utiliser la variable de classe, pas une variable locale ==========
        // Vider la liste de classe au début
        paymentMethodsList.clear();
        List<PaymentMethod> tempList = []; // Liste temporaire pour le modèle

        // Vérifier si data est directement une List
        if (response['data'] is List) {
          var list = response['data'] as List;
          debugPrint('📦 data est une List avec ${list.length} éléments');
          debugPrint(
              '📦 FORÇAGE DU MAPPING: Parcours de response["data"] (List)');

          // Mapping avec try-catch pour chaque élément - AJOUT DIRECT À LA LISTE DE CLASSE
          for (var item in list) {
            try {
              if (item is Map<String, dynamic>) {
                PaymentMethod mappedMethod = PaymentMethod.fromJson(item);
                // Ajouter directement à la liste de classe
                paymentMethodsList.add(mappedMethod);
                tempList
                    .add(mappedMethod); // Aussi dans tempList pour le modèle
                debugPrint(
                    '✅ Élément mappé et ajouté à paymentMethodsList (classe)');
              } else {
                debugPrint('⚠️ Élément ignoré (n\'est pas un Map): $item');
              }
            } catch (e, stackTrace) {
              debugPrint('❌ Erreur sur l\'élément: $item');
              debugPrint('❌ Erreur: $e');
              debugPrint('❌ StackTrace: $stackTrace');
              print('Erreur sur l\'élément: $item');
            }
          }

          paymentMethodModel = BookingPaymentMethodModel(
            status: response['status'] as int? ??
                (response['success'] == true ? 200 : null),
            message: response['message'] as String?,
            data: BookingPaymentMethodData(
              paymentMethods: tempList,
            ),
          );
        } else if (response['data'] is Map &&
            response['data']['data'] != null) {
          // Structure avec data.data (double nesting)
          var innerData = response['data']['data'];
          if (innerData is List) {
            debugPrint(
                '📦 data.data est une List avec ${innerData.length} éléments');
            debugPrint(
                '📦 FORÇAGE DU MAPPING: Parcours de response["data"]["data"] (List)');

            // Mapping avec try-catch pour chaque élément - AJOUT DIRECT À LA LISTE DE CLASSE
            for (var item in innerData) {
              try {
                if (item is Map<String, dynamic>) {
                  PaymentMethod mappedMethod = PaymentMethod.fromJson(item);
                  // Ajouter directement à la liste de classe
                  paymentMethodsList.add(mappedMethod);
                  tempList
                      .add(mappedMethod); // Aussi dans tempList pour le modèle
                  debugPrint(
                      '✅ Élément mappé et ajouté à paymentMethodsList (classe)');
                } else {
                  debugPrint('⚠️ Élément ignoré (n\'est pas un Map): $item');
                }
              } catch (e, stackTrace) {
                debugPrint('❌ Erreur sur l\'élément: $item');
                debugPrint('❌ Erreur: $e');
                debugPrint('❌ StackTrace: $stackTrace');
                print('Erreur sur l\'élément: $item');
              }
            }

            paymentMethodModel = BookingPaymentMethodModel(
              status: response['status'] as int? ??
                  (response['success'] == true ? 200 : null),
              message: response['message'] as String?,
              data: BookingPaymentMethodData(
                paymentMethods: tempList,
              ),
            );
          } else {
            // Structure normale avec data.payment_methods
            debugPrint('📦 data est un Map, utilisation de fromJson');
            paymentMethodModel = BookingPaymentMethodModel.fromJson(response);
            // Synchroniser après fromJson
            if (paymentMethodModel?.data?.paymentMethods != null) {
              paymentMethodsList.clear();
              paymentMethodsList
                  .addAll(paymentMethodModel!.data!.paymentMethods!);
              debugPrint(
                  '✅ Synchronisation après fromJson: ${paymentMethodsList.length} méthodes');
            }
          }
        } else if (response['data'] is Map) {
          // Structure normale avec data.payment_methods
          debugPrint('📦 data est un Map, utilisation de fromJson');
          paymentMethodModel = BookingPaymentMethodModel.fromJson(response);
          // Synchroniser après fromJson
          if (paymentMethodModel?.data?.paymentMethods != null) {
            paymentMethodsList.clear();
            paymentMethodsList
                .addAll(paymentMethodModel!.data!.paymentMethods!);
            debugPrint(
                '✅ Synchronisation après fromJson: ${paymentMethodsList.length} méthodes');
          }
        } else {
          debugPrint('⚠️ Structure de data non reconnue: ${response['data']}');
        }

        // Vérification que paymentMethodsList (classe) contient bien les données
        debugPrint(
            '🔍 VÉRIFICATION: paymentMethodsList (classe).length = ${paymentMethodsList.length}');
        print(
            '🔍 VÉRIFICATION: paymentMethodsList (classe).length = ${paymentMethodsList.length}');

        debugPrint(
            '📦 Nombre de méthodes après parsing: ${paymentMethodModel?.data?.paymentMethods?.length ?? 0}');
        debugPrint(
            '📦 Nombre de méthodes dans paymentMethodsList (classe): ${paymentMethodsList.length}');

        // ========== ASSURER LA SYNCHRONISATION (au cas où) ==========
        // Si paymentMethodsList est vide mais le modèle contient des données, synchroniser
        if (paymentMethodsList.isEmpty &&
            paymentMethodModel?.data?.paymentMethods != null &&
            paymentMethodModel!.data!.paymentMethods!.isNotEmpty) {
          paymentMethodsList.clear();
          paymentMethodsList.addAll(paymentMethodModel!.data!.paymentMethods!);
          debugPrint(
              '✅ SYNCHRO DE SECOURS : ${paymentMethodsList.length} méthodes ajoutées à paymentMethodsList');
          print(
              '✅ SYNCHRO DE SECOURS : ${paymentMethodsList.length} méthodes ajoutées à paymentMethodsList');
        }
        // ========== FIN SYNCHRONISATION ==========

        // Filtrer pour ne garder que les méthodes avec status: true
        // Filtrer directement paymentMethodsList (classe) et le modèle
        if (paymentMethodsList.isNotEmpty) {
          // Filtrer la liste de classe
          paymentMethodsList.removeWhere((method) => method.status != true);
          debugPrint(
              '✅ Filtrage paymentMethodsList (classe): ${paymentMethodsList.length} méthodes avec status: true');

          // Filtrer aussi le modèle pour cohérence
          if (paymentMethodModel?.data?.paymentMethods != null &&
              paymentMethodModel!.data!.paymentMethods!.isNotEmpty) {
            paymentMethodModel!.data!.paymentMethods = paymentMethodModel!
                .data!.paymentMethods!
                .where((method) => method.status == true)
                .toList();

            // Log de vérification de l'ID de la première méthode
            if (paymentMethodModel!.data!.paymentMethods!.isNotEmpty) {
              print(
                  'ID de la première méthode: ${paymentMethodModel!.data!.paymentMethods![0].id}');
              debugPrint(
                  '🆔 ID de la première méthode: ${paymentMethodModel!.data!.paymentMethods![0].id}');
              debugPrint(
                  '📦 Nombre final de méthodes après filtrage: ${paymentMethodModel!.data!.paymentMethods!.length}');
            }
          }
        }

        // Vérification finale
        debugPrint(
            '🔍 VÉRIFICATION FINALE: paymentMethodsList (classe).length = ${paymentMethodsList.length}');
        print(
            '🔍 VÉRIFICATION FINALE: paymentMethodsList (classe).length = ${paymentMethodsList.length}');

        // Rafraîchissement UI après parsing réussi - IMPORTANT pour GetBuilder
        debugPrint('🔄 Appel de update() pour rafraîchir l\'UI');
        notifyPaymentMethodBody();
      } else {
        error.value = true;
        debugPrint(
            '❌ Réponse invalide ou échec: status=${response?['status']}, success=${response?['success']}');
        showErrorToastMessage(response?['error'] ??
            response?['message'] ??
            'Erreur lors du chargement des méthodes de paiement'.tr);
      }
    } catch (e, stackTrace) {
      error.value = true;
      debugPrint('❌ [fetchPaymentMethods] Erreur globale: $e');
      debugPrint('❌ [fetchPaymentMethods] StackTrace: $stackTrace');
      showErrorToastMessage(
          'Erreur lors du chargement des méthodes de paiement'.tr);
    } finally {
      isLoadingPaymentMethods.value = false;
      notifyPaymentMethodBody();
    }
  }

  bookingMainFunction(
      itemId,
      totalDayNight,
      price,
      bookingForSomeOne,
      hostId,
      numberofguest,
      addDoorStepPrice,
      itemType,
      image,
      itemDetail,
      address,
      rating,
      tittle,
      [meta]) async {
    if (error.value == true) {
      showCustomSnackbar(
        title: 'Token does not match'.tr,
        message: 'Please login again'.tr,
        color: redColor,
        contentType: ContentType.warning,
      );
      return;
    }
    showLoading();
    dynamic couponCode;
    if (getItemPrices!.data!.couponCode == null) {
      couponCode = "";
    } else {
      couponCode = getItemPrices!.data!.couponCode;
    }
    var result = await bookMethod(
        "$itemId",
        startDate.value,
        endDate.value,
        "${totalDayNight - 1}",
        "$price",
        bookingForSomeOne,
        "${getItemPrices!.data!.priceBeforeDiscount}",
        "0",
        "0",
        "0",
        getItemPrices!.data!.grossPrice!,
        currency,
        'stripe',
        getItemPrices!.data!.walletAmount!.toString(),
        hostId,
        "$numberofguest",
        couponCode,
        getItemPrices!.data!.discountPrice!.toString(),
        getItemPrices!.data!.couponDiscount!.toString(),
        getItemPrices!.data!.discountType!,
        "0",
        addDoorStepPrice.toString(),
        meta);
    closeLoading();

    if (result != null) {
      if (result['data'] != null) {
        var paymentUrl = result['data']['payment_url'];
        var bookingId = result['data']['booking_id'];
        if (paymentUrl is String && bookingId is int) {
          if (webPlateForm) {
            Get.toNamed(WebRoutes.paymentScreen, arguments: {
              "url": paymentUrl,
              "bookingId": bookingId.toString(),
            })?.then((value) {
              if (value != null && value == "Paid") {
                safeUpdate();
                isPaymentSuccess.value = true;
              } else {
                safeUpdate();
                isPaymentSuccess.value = false;
              }
            });
          } else {
            // Logs de débogage pour vérifier les politiques d'annulation
            print('🛡️ [CHECK_POLICY] Title: ${itemDetail?.cancellationReasonTitle}');
            print('🛡️ [CHECK_POLICY] Desc count: ${itemDetail?.cancellationReasonDescription?.length}');
            debugPrint('🛡️ [CHECK_POLICY] Title: ${itemDetail?.cancellationReasonTitle}');
            debugPrint('🛡️ [CHECK_POLICY] Desc count: ${itemDetail?.cancellationReasonDescription?.length}');
            debugPrint('🛡️ [CHECK_POLICY] itemDetail is null: ${itemDetail == null}');
            if (itemDetail != null) {
              debugPrint('🛡️ [CHECK_POLICY] itemDetail.cancellationReasonTitle: ${itemDetail.cancellationReasonTitle}');
              debugPrint('🛡️ [CHECK_POLICY] itemDetail.cancellationReasonDescription: ${itemDetail.cancellationReasonDescription}');
            }
            // Log spécifique juste avant la navigation vers PaymentScreen
            print('🛡️ [DEBUG_CHECK] Title to send: ${itemDetail?.cancellationReasonTitle}');
            debugPrint('🛡️ [DEBUG_CHECK] Title to send: ${itemDetail?.cancellationReasonTitle}');
            debugPrint('🛡️ [DEBUG_CHECK] Description to send: ${itemDetail?.cancellationReasonDescription}');
            debugPrint('🛡️ [DEBUG_CHECK] itemDetail object: ${itemDetail?.toString()}');
            Get.offAll(() => PaymentScreen(
                  title: tittle,
                  rating: rating,
                  address: address,
                  itemDetails: itemDetail,
                  frontImage: image,
                  itemType: itemType,
                  isAddDoorStepPrice: addDoorStepPrice.toString(),
                  idFeatured: itemId,
                  fromBooking: true,
                  price: getItemPrices!.data!.grossPrice!,
                  url: paymentUrl,
                  bookingId: bookingId.toString(),
                ))?.then((value) {
              if (value == null) {
                return;
              }
              if (value == "Paid") {
                safeUpdate();
                isPaymentSuccess.value = true;
              } else {
                safeUpdate();
                isPaymentSuccess.value = false;
              }
            });
          }
        } else {}
      }
    }
  }

  bookMethod(
      String itemId,
      String checkIn,
      String checkOut,
      String totalDayNight,
      String pernight,
      String bookfor,
      String basePrice,
      String serviceCharge,
      String serviceMoney,
      String ivaText,
      String total,
      String currencyCode,
      String paymentMethod,
      String wallAmount,
      String hostId,
      String totalGuest,
      String couponCode,
      String discountPrice,
      String couponDiscount,
      String discountType,
      String cleaningCharges,
      String addDoorStepPrice,
      dynamic meta) async {
    meta ??= "";
    String startTimeForBackend = selectedStartTime.value;
    String endTimeForBackend = selectedEndTime.value;

    if (selectedStartTime.value.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'))) {
      startTimeForBackend = convert24To12(selectedStartTime.value);
      endTimeForBackend = convert24To12(selectedEndTime.value);
    }
    Map map = {
      "item_id": itemId,
      "check_in": checkIn,
      "check_out": checkOut,
      "total_day": totalDayNight,
      "per_day": pernight,
      "book_for": bookfor,
      "base_price": basePrice,
      "service_charge": "0",
      "security_money": "0",
      "iva_tax": "0",
      "total": total,
      "currency_code": currencyCode,
      "payment_method": paymentMethod,
      "wall_amt": wallAmount,
      "host_id": hostId,
      "total_guest": totalGuest,
      "coupon_code": couponCode,
      "discount_price": discountPrice,
      "coupon_discount": couponDiscount,
      "discount_type": discountType,
      "cleaning_charges": "0",
      "start_time": startTimeForBackend,
      "end_time": endTimeForBackend,
      "onlinepayment": "$paymentStatus",
      "doorStep_price": addDoorStepPrice,
      "doorStep_address": addDoorStepPrice != "0" ? doorStepAddress() : "",
      "meta": meta,
    };

    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpPost(Config.bookItem, map);

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Generate a mock booking ID
    int mockBookingId = DateTime.now().millisecondsSinceEpoch;

    // MOCK: Return static response data
    // NOTE: The payment_url contains "cs_test_mock" which is detected by _handleNavigation()
    // in payment_screen.dart to simulate payment success in offline mode.
    // TODO: After Node.js backend implementation, this URL will be a real Stripe checkout URL
    // that redirects to payment_success after actual payment processing.
    Map<String, dynamic> response = {
      "status": 200,
      "message": "Booking created successfully",
      "error": "",
      "data": {
        "booking_id": mockBookingId,
        "payment_url":
            "https://checkout.stripe.com/pay/cs_test_mock_${mockBookingId}",
        "booking_status": "pending"
      }
    };

    if (response != null) {
      if (response['status'] == 200) {
      } else {
        showErrorToastMessage("${response['error']}");
      }
    }
    return response;
  }

  // ========== FONCTION processBooking() POUR API NODE.JS PRODUCTION ==========
  /// Fonction async qui envoie une requête POST à l'API Node.js locale
  /// Gère les réponses 200 (succès avec booking_id et otp), 400/409 (erreurs)
  /// [vehicleId] : L'ID du véhicule depuis le widget (optionnel, utilise fallback)
  /// [widgetVehicleId] : L'ID du véhicule depuis widget.idFeatured (fallback final)
  Future<void> processBooking(
      {dynamic vehicleId, dynamic widgetVehicleId}) async {
    paymentFlowLog('STEP 1 — processBooking START',
        'vehicleId=$vehicleId, method=${selectedPaymentMethod?.name}');
    // On s'assure que le serveur connait l'appareil avant de continuer
    try {
      await ensurePlayerIdIsSynced();
      debugPrint('✅ [processBooking] Synchronisation Player ID terminée');
    } catch (e) {
      debugPrint('⚠️ [processBooking] Erreur lors de la synchronisation Player ID: $e');
      // Ne pas bloquer la réservation en cas d'erreur
    }
    
    // Prévenir les appels multiples
    if (isProcessingBooking.value) {
      paymentFlowLog('STEP 1 — ABORT already processing');
      debugPrint('⚠️ [processBooking] Déjà en cours, ignore l\'appel');
      return;
    }

    isProcessingBooking.value = true;
    paymentFlowLog('STEP 2 — isProcessingBooking=true, building request');

    try {
      // ========== 1. RÉCUPÉRATION DU TOKEN D'AUTHENTIFICATION ==========
      String? authToken = GetStorage().read('token') ?? token;
      if (authToken.isEmpty) {
        // Essayer de récupérer depuis UserData
        try {
          var userData = GetStorage().read('UserData');
          if (userData != null) {
            var userDataMap = jsonDecode(userData);
            if (userDataMap['data'] != null &&
                userDataMap['data']['token'] != null) {
              authToken = userDataMap['data']['token'].toString();
            }
          }
        } catch (e) {
          debugPrint(
              '❌ [processBooking] Erreur lors de la récupération du token: $e');
        }
      }

      if (authToken == null || authToken.isEmpty) {
        debugPrint('❌ [processBooking] Token d\'authentification manquant');
        Get.safeSnackbar(
          'Erreur d\'authentification'.tr,
          'Veuillez vous reconnecter'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: redColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        isProcessingBooking.value = false;
        return;
      }

      // ========== DEBUG: LOG DU TOKEN ENVOYÉ ==========
      print('🔑 Token envoyé : $authToken');
      debugPrint('🔑 Token envoyé : $authToken');

      // ========== 2. VALIDATION ET FALLBACK POUR L'ID DU VÉHICULE ==========
      // Fallback: vehicleId ?? idFeatured ?? widgetVehicleId
      dynamic finalVehicleId = vehicleId ?? idFeatured ?? widgetVehicleId;

      if (finalVehicleId == null || finalVehicleId.toString().isEmpty) {
        Get.safeSnackbar(
          'Erreur'.tr,
          'ID du véhicule manquant'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: redColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        isProcessingBooking.value = false;
        return;
      }

      // ========== 3. VALIDATION DES DATES ==========
      if (startDate.value.isEmpty || endDate.value.isEmpty) {
        Get.safeSnackbar(
          'Erreur'.tr,
          'Veuillez sélectionner les dates de réservation'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: redColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        isProcessingBooking.value = false;
        return;
      }

      // ========== 4. CONVERSION DES DATES EN ISO 8601 ==========
      DateTime checkInDate;
      DateTime checkOutDate;
      try {
        checkInDate = DateTime.parse(startDate.value);
        checkOutDate = DateTime.parse(endDate.value);
      } catch (e) {
        debugPrint('❌ [processBooking] Erreur de parsing des dates: $e');
        Get.safeSnackbar(
          'Erreur'.tr,
          'Format de date invalide'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: redColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        isProcessingBooking.value = false;
        return;
      }

      // ========== 4.1. VALIDATION "JOURS MINIMUM" (UX: blocage uniquement au paiement final) ==========
      String checkInIso = checkInDate.toIso8601String();
      String checkOutIso = checkOutDate.toIso8601String();

      // ========== 5. PRÉPARATION DES DONNÉES DE LA REQUÊTE ==========
      String startTimeForBackend = selectedStartTime.value;
      String endTimeForBackend = selectedEndTime.value;

      if (selectedStartTime.value.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'))) {
        startTimeForBackend = convert24To12(selectedStartTime.value);
        endTimeForBackend = convert24To12(selectedEndTime.value);
      }

      dynamic couponCode = "";
      if (getItemPrices!.data!.couponCode != null) {
        couponCode = getItemPrices!.data!.couponCode;
      }

      // ========== 6. FORMATAGE DU PRIX TOTAL AVEC FRAIS DE MÉTHODE DE PAIEMENT ==========
      // total_price en tant que double (numérique) et non String
      // Inclure les frais de la méthode de paiement sélectionnée
      double basePrice = 0.0;
      if (getItemPrices!.data!.grossPrice != null) {
        try {
          basePrice = double.parse(getItemPrices!.data!.grossPrice.toString());
        } catch (e) {
          debugPrint(
              '⚠️ [processBooking] Erreur parsing base_price: $e, utilisation de 0.0');
          basePrice = 0.0;
        }
      }

      // Calculer les frais de la méthode de paiement
      double feeAmount = 0.0;
      if (selectedPaymentMethod != null &&
          selectedPaymentMethod!.feePercentage != null) {
        double feePercentage = selectedPaymentMethod!.feePercentage!;
        feeAmount = basePrice * (feePercentage / 100);
        debugPrint(
            '💰 [processBooking] Frais de méthode de paiement: $feePercentage% = $feeAmount');
      }

      // Prix total = prix de base + frais de méthode de paiement
      double totalPriceDouble = basePrice + feeAmount;
      debugPrint(
          '💰 [processBooking] Prix de base: $basePrice, Frais: $feeAmount, Total: $totalPriceDouble');

      // ========== 7. FORMATAGE DU WALLET ==========
      // wall_amt: Si le wallet est activé, envoie la valeur numérique. Sinon, envoie 0 (en tant que double)
      double walletAmount = 0.0;
      if (getItemPrices!.data!.walletAmount != null) {
        try {
          double walletValue =
              double.parse(getItemPrices!.data!.walletAmount!.toString());
          if (walletValue > 0) {
            walletAmount = walletValue; // Valeur numérique si wallet activé
          } else {
            walletAmount = 0.0; // 0 en tant que double si wallet non utilisé
          }
        } catch (e) {
          debugPrint(
              '⚠️ [processBooking] Erreur parsing wallet_amount: $e, utilisation de 0.0');
          walletAmount = 0.0;
        }
      }

      // ========== 8. CONSTRUCTION DU BODY JSON ==========
      // Récupération de l'ID OneSignal au moment de la réservation
      String playerId = OneSignal.User.pushSubscription.id ?? "";
      print('🚀 [FLUTTER AUDIT] ID OneSignal détecté: "$playerId"');
      if (playerId.isEmpty) {
        print('⚠️ [FLUTTER AUDIT] ATTENTION : L\'ID est vide ! La notification échouera.');
      }
      print('🛡️ [BOOKING] Injection du PlayerID: $playerId');

      Map<String, dynamic> requestBody = {
        "item_id": finalVehicleId.toString(),
        "check_in": checkInIso, // ISO 8601 String
        "check_out": checkOutIso, // ISO 8601 String
        "total_price": totalPriceDouble, // Double
        "wall_amt": walletAmount, // Double (0 si wallet non utilisé)
        "meta": commonMetaData(), // String JSON
        "total_day": int.parse(getItemPrices!.data!.totalNights ?? "1") - 1,
        "per_day": getItemPrices!.data!.pricePerNight ?? "0",
        "book_for": "",
        "base_price": getItemPrices!.data!.priceBeforeDiscount ?? "0",
        "service_charge": "0",
        "security_money": "0",
        "iva_tax": "0",
        "currency_code": currency,
        "payment_method":
            selectedPaymentMethod?.name?.toLowerCase() ?? "stripe",
        "payment_method_id": selectedPaymentMethod?.id ?? null,
        "host_id": "",
        "total_guest": numberofguest,
        "coupon_code": couponCode,
        "discount_price": getItemPrices!.data!.discountPrice?.toString() ?? "0",
        "coupon_discount":
            getItemPrices!.data!.couponDiscount?.toString() ?? "0",
        "discount_type": getItemPrices!.data!.discountType ?? "",
        "cleaning_charges": "0",
        "start_time": startTimeForBackend,
        "end_time": endTimeForBackend,
        "onlinepayment": paymentStatus ?? "",
        "doorStep_price": addDoorStepPrice.toString(),
        "doorStep_address": addDoorStepPrice ? doorStepAddress() : "",
        "oneSignalPlayerId": playerId,
      };

      // ========== 9. CONSTRUCTION DE L'URL ==========
      // Utiliser Config.baseurl + Config.bookItem
      String url = '${Config.baseurl}${Config.bookItem}';

      // ========== 10. DEBUG LOGS ==========
      // Print du Body JSON complet et autres informations de debug
      String requestBodyJson = jsonEncode(requestBody);
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📤 [processBooking] URL FINALE: $url');
      debugPrint(
          '📤 [processBooking] x-auth-token: ${authToken.length > 20 ? "${authToken.substring(0, 20)}..." : authToken} (longueur: ${authToken.length})');
      debugPrint(
          '📤 [processBooking] item_id (MongoDB): ${finalVehicleId.toString()}');
      debugPrint('📤 [processBooking] check_in (ISO 8601): $checkInIso');
      debugPrint('📤 [processBooking] check_out (ISO 8601): $checkOutIso');
      debugPrint(
          '📤 [processBooking] total_price: $totalPriceDouble (type: double)');
      debugPrint('📤 [processBooking] wall_amt: $walletAmount (type: double)');
      debugPrint('📤 [processBooking] Request Body JSON complet:');
      debugPrint(requestBodyJson);
      debugPrint('═══════════════════════════════════════════════════════');

      // ========== 11. ENVOI DE LA REQUÊTE POST ==========
      paymentFlowLog('STEP 3 — POST book-item API…', url);
      final response = await http
          .post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': authToken,
        },
        body: jsonEncode(requestBody),
      )
          .timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('La requête a expiré');
        },
      );

      // ========== 11. DEBUG: PRINT STATUS CODE ET RÉPONSE BRUTE ==========
      debugPrint('═══════════════════════════════════════════════════════');
      debugPrint('📥 [processBooking] Status Code: ${response.statusCode}');
      debugPrint('📥 Réponse brute du serveur: ${response.body}');
      debugPrint(
          '📥 [processBooking] Response Body Length: ${response.body.length}');
      debugPrint('═══════════════════════════════════════════════════════'      );

      paymentFlowLog('STEP 4 — API response',
          'statusCode=${response.statusCode}, bodyLength=${response.body.length}');

      // ========== 12. PARSING JSON AVEC TRY-CATCH SPÉCIFIQUE ==========
      Map<String, dynamic> responseData;
      try {
        responseData = jsonDecode(response.body);
        debugPrint('✅ [processBooking] JSON parsing réussi');
      } catch (e, stackTrace) {
        debugPrint('❌ [processBooking] ERREUR DE PARSING JSON: $e');
        debugPrint('❌ [processBooking] StackTrace: $stackTrace');
        debugPrint('❌ [processBooking] Response body qui a causé l\'erreur:');
        debugPrint(response.body);
        Get.safeSnackbar(
          'Erreur de format'.tr,
          'Le serveur a renvoyé une réponse invalide. Veuillez réessayer.'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: redColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        isProcessingBooking.value = false;
        return;
      }

      // ========== 13. VÉRIFICATION DES CLÉS DE LA RÉPONSE ==========
      debugPrint('🔍 [processBooking] Vérification des clés de la réponse:');
      debugPrint(
          '   • responseData.containsKey("data"): ${responseData.containsKey("data")}');
      debugPrint(
          '   • responseData.containsKey("message"): ${responseData.containsKey("message")}');
      debugPrint(
          '   • responseData.containsKey("error"): ${responseData.containsKey("error")}');
      debugPrint(
          '   • responseData.containsKey("status"): ${responseData.containsKey("status")}');

      if (responseData.containsKey("data")) {
        debugPrint(
            '   • responseData["data"] type: ${responseData["data"].runtimeType}');
        if (responseData["data"] is Map) {
          Map<String, dynamic> dataMap = responseData["data"];
          debugPrint(
              '   • data.containsKey("booking_id"): ${dataMap.containsKey("booking_id")}');
          debugPrint(
              '   • data.containsKey("otp"): ${dataMap.containsKey("otp")}');
          if (dataMap.containsKey("booking_id")) {
            debugPrint(
                '   • data["booking_id"] value: ${dataMap["booking_id"]}');
            debugPrint(
                '   • data["booking_id"] is null: ${dataMap["booking_id"] == null}');
          }
          if (dataMap.containsKey("otp")) {
            debugPrint('   • data["otp"] value: ${dataMap["otp"]}');
            debugPrint('   • data["otp"] type: ${dataMap["otp"].runtimeType}');
          }
        }
      }

      // ========== 14. GESTION DES RÉPONSES ==========
      if (response.statusCode == 200) {
        debugPrint(
            '✅ [processBooking] Status Code 200 - Tentative de parsing du succès');

        // Vérifier si la clé 'data' existe
        if (!responseData.containsKey('data')) {
          debugPrint(
              '❌ [processBooking] ERREUR: responseData ne contient pas la clé "data"');
          debugPrint(
              '❌ [processBooking] Clés disponibles: ${responseData.keys.toList()}');
          Get.safeSnackbar(
            'Erreur de réponse'.tr,
            'La réponse du serveur est incomplète.'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: redColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          isProcessingBooking.value = false;
          return;
        }

        // Vérifier si 'data' est un Map
        if (responseData['data'] is! Map) {
          debugPrint(
              '❌ [processBooking] ERREUR: responseData["data"] n\'est pas un Map');
          debugPrint(
              '❌ [processBooking] Type de data: ${responseData["data"].runtimeType}');
          Get.safeSnackbar(
            'Erreur de format'.tr,
            'Format de réponse invalide.'.tr,
            snackPosition: SnackPosition.TOP,
            backgroundColor: redColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
          );
          isProcessingBooking.value = false;
          return;
        }

        Map<String, dynamic> dataMap = responseData['data'];

        // Succès : Parser la réponse (booking_id et codes OTP: otp.pickup et otp.drop)
        String? bookingId = dataMap['booking_id']?.toString();
        debugPrint('🔍 [processBooking] booking_id extrait: $bookingId');
        debugPrint(
            '🔍 [processBooking] booking_id is null: ${bookingId == null}');

        // Parser les codes OTP depuis responseData['data']['otp']
        Map<String, dynamic>? otpData;
        if (dataMap.containsKey('otp')) {
          if (dataMap['otp'] is Map) {
            otpData = Map<String, dynamic>.from(dataMap['otp']);
            debugPrint('🔍 [processBooking] otp data trouvé: $otpData');
          } else {
            debugPrint(
                '⚠️ [processBooking] otp existe mais n\'est pas un Map: ${dataMap["otp"].runtimeType}');
          }
        } else {
          debugPrint('⚠️ [processBooking] otp n\'existe pas dans data');
        }

        String? otpPickup = otpData?['pickup']?.toString();
        String? otpDrop = otpData?['drop']?.toString();
        debugPrint('🔍 [processBooking] otp.pickup: $otpPickup');
        debugPrint('🔍 [processBooking] otp.drop: $otpDrop');

        // Construire le message de succès avec les codes OTP
        String successMessage = 'booking_success_message'.tr;
        String instructionsMessage = '';

        if (bookingId != null) {
          successMessage +=
              '\n\n${'booking_id_label'.tr} 📋\n$bookingId';
        }

        // Afficher les codes OTP si disponibles
        if (otpPickup != null || otpDrop != null) {
          successMessage += '\n\n🔐 Codes OTP:';
          if (otpPickup != null) {
            successMessage += '\n   • Pickup: $otpPickup';
          }
          if (otpDrop != null) {
            successMessage += '\n   • Drop: $otpDrop';
          }
        }

        // Instructions selon la méthode de paiement
        if (selectedPaymentMethod != null) {
          String paymentMethodName =
              selectedPaymentMethod!.name ?? 'Méthode de paiement';
          if (paymentMethodName.toLowerCase().contains('cash') ||
              paymentMethodName.toLowerCase().contains('espèce')) {
            instructionsMessage =
                '\n\n💵 Paiement à la livraison:\nVous paierez lors de la récupération du véhicule.'
                    .tr;
          } else if (paymentMethodName
                  .toLowerCase()
                  .contains('digital wallet') ||
              paymentMethodName.toLowerCase().contains('paypal')) {
            instructionsMessage =
                '\n\n💳 Paiement en ligne:\nVotre paiement sera traité dans les prochaines minutes.'
                    .tr;
          }
        }

        // Afficher une boîte de dialogue de succès stylisée
        paymentFlowLog('STEP 5 — API 200 OK, opening success dialog',
            'bookingId=$bookingId');
        Get.dialog(
          barrierDismissible: false,
          Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icône de succès
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Titre
                  Text(
                    'booking_success_title'.tr,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Message principal
                  SingleChildScrollView(
                    child: Text(
                      successMessage + instructionsMessage,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Bouton OK
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        paymentFlowLog(
                            'STEP 6 — « Voir mes réservations » button TAP');
                        paymentFlowLog('STEP 6a — closing success dialog');
                        Get.back(); // Fermer le dialogue
                        paymentFlowLog(
                            'STEP 7 — dialog closed, calling _navigateToBookingsAfterPayment');
                        await _navigateToBookingsAfterPayment(
                          tabIndex: 0,
                          snackTitle: 'Succes'.tr,
                          snackMessage:
                              'Votre reservation est confirmee !'.tr,
                        );
                        paymentFlowLog(
                            'STEP 7b — returned from _navigateToBookingsAfterPayment');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: themeColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'view_my_bookings'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      } else if (response.statusCode == 400 || response.statusCode == 409) {
        // Erreur : Extraire le message depuis la réponse JSON
        String errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Une erreur est survenue'.tr;

        // Messages spécifiques selon le code d'erreur
        if (response.statusCode == 400) {
          errorMessage = responseData['message'] ?? 'Erreur de validation'.tr;
        } else if (response.statusCode == 409) {
          errorMessage = responseData['message'] ?? 'Véhicule déjà réservé'.tr;
        }

        debugPrint(
            '❌ [processBooking] Erreur ${response.statusCode}: $errorMessage');
        Get.safeSnackbar(
          'Erreur de réservation'.tr,
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: redColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        // Réinitialiser l'état pour que le bouton redevienne cliquable
        isProcessingBooking.value = false;
      } else {
        // Autre erreur
        String errorMessage = responseData['message'] ??
            responseData['error'] ??
            'Une erreur est survenue lors de la réservation'.tr;
        debugPrint(
            '❌ [processBooking] Erreur ${response.statusCode}: $errorMessage');
        Get.safeSnackbar(
          'Erreur'.tr,
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: redColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
        // Réinitialiser l'état pour que le bouton redevienne cliquable
        isProcessingBooking.value = false;
      }
    } catch (e, stackTrace) {
      paymentFlowLog('STEP ERR — processBooking exception', e);
      debugPrint('❌ [processBooking] Erreur: $e');
      debugPrint('❌ [processBooking] StackTrace: $stackTrace');
      Get.safeSnackbar(
        'Erreur de connexion'.tr,
        'Impossible de se connecter au serveur. Veuillez réessayer.'.tr,
        snackPosition: SnackPosition.TOP,
        backgroundColor: redColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      // Réinitialiser l'état immédiatement en cas d'erreur
      isProcessingBooking.value = false;
    } finally {
      // S'assurer que l'état est toujours réinitialisé même si tout s'est bien passé
      // (bien que cela devrait déjà être géré dans le cas de succès)
      if (isProcessingBooking.value) {
        isProcessingBooking.value = false;
      }
    }
  }
  // ========== FIN FONCTION processBooking() ==========

  void setExtensionPaymentContext(ExtensionPaymentContext? ctx) {
    extensionPaymentContext = ctx;
    if (ctx != null && ctx.currency.isNotEmpty) {
      currency = ctx.currency;
    }
  }

  double extensionCheckoutBaseAmount() {
    return extensionPaymentContext?.additionalAmount ?? 0.0;
  }

  bool isExtensionCheckoutActive() => extensionPaymentContext != null;

  bool _paymentMethodRequiresOnlineCheckout(PaymentMethod? method) {
    if (method == null) return false;
    final name = (method.name ?? '').toLowerCase();
    final type = (method.type ?? '').toLowerCase();
    if (type == 'online' || type.contains('online')) return true;
    return name.contains('stripe') ||
        name.contains('card') ||
        name.contains('carte') ||
        name.contains('paypal') ||
        name.contains('digital wallet');
  }

  Future<void> _finishExtensionAfterPayment(String paymentMethodId) async {
    final ctx = extensionPaymentContext;
    if (ctx == null) return;

    final recordController = Get.find<BookingRecordController>();
    final ok = await recordController.extendReservationConfirm(
      bookingId: ctx.bookingId,
      newEndDate: ctx.newEndDateIso,
      paymentMethodId: paymentMethodId,
    );
    isProcessingBooking.value = false;
    if (!ok) return;

    await _popThenRefreshBookings(
      bookingRecordType: 'ongoing',
      snackTitle: 'Succes'.tr,
      snackMessage: 'Reservation extended successfully'.tr,
    );
  }

  Future<void> processExtensionPayment() async {
    final ctx = extensionPaymentContext;
    if (ctx == null) {
      debugPrint('❌ [processExtensionPayment] contexte extension manquant');
      return;
    }
    if (isProcessingBooking.value) return;

    final paymentMethodId = selectedPaymentMethod?.id?.trim();
    if (paymentMethodId == null || paymentMethodId.isEmpty) {
      showErrorToastMessage('Error'.tr);
      return;
    }

    isProcessingBooking.value = true;
    final recordController = Get.find<BookingRecordController>();

    try {
      if (_paymentMethodRequiresOnlineCheckout(selectedPaymentMethod)) {
        var paymentUrl = ctx.paymentUrl?.trim() ?? '';
        if (paymentUrl.isEmpty) {
          final session =
              await recordController.extendReservationConfirmWithDetails(
            bookingId: ctx.bookingId,
            newEndDate: ctx.newEndDateIso,
            paymentMethodId: paymentMethodId,
          );
          paymentUrl = session?.paymentUrl?.trim() ?? '';
          if (paymentUrl.isEmpty) {
            isProcessingBooking.value = false;
            if (session?.success == true) {
              await _popThenRefreshBookings(
                bookingRecordType: 'ongoing',
                snackTitle: 'Succes'.tr,
                snackMessage: 'Reservation extended successfully'.tr,
              );
              return;
            }
            showErrorToastMessage('extension_online_payment_unavailable'.tr);
            return;
          }
        }

        isProcessingBooking.value = false;
        final paid = await Get.to<String?>(() => PaymentScreen(
              url: paymentUrl,
              bookingId: ctx.bookingId,
              price: ctx.additionalAmount,
              fromBooking: true,
              isExtension: true,
            ));
        if (paid != 'Paid') return;

        isProcessingBooking.value = true;
        await _finishExtensionAfterPayment(paymentMethodId);
        return;
      }

      await _finishExtensionAfterPayment(paymentMethodId);
    } catch (e, stackTrace) {
      debugPrint('❌ [processExtensionPayment] $e');
      debugPrint('❌ [processExtensionPayment] StackTrace: $stackTrace');
      showErrorToastMessage('Something went wrong'.tr);
      isProcessingBooking.value = false;
    }
  }

  var isenqablestarttime = false.obs;
  var isenableendTime = false.obs;
  RxString selectedStartTime = "".obs;
  RxString selectedEndTime = "".obs;
  RxString hindTimeStart = "".obs;
  RxString hindTimeSEnd = "".obs;
  RxInt currentdatebool = 1.obs;
  RxInt currentdateboospace = 1.obs;

  int? _resolveMinRentalDaysForBooking(dynamic itemDetails) {
    int? parse(dynamic d) {
      if (d == null) return null;
      try {
        final v = (d as dynamic).minRentalDays;
        if (v == null) return null;
        final n = int.tryParse(v.toString().trim());
        if (n == null || n < 1) return null;
        return n;
      } catch (_) {
        return null;
      }
    }

    final fromParam = parse(itemDetails);
    if (fromParam != null) return fromParam;

    try {
      return parse(spaceDetailController.itemInfo);
    } catch (_) {
      return null;
    }
  }

  // Wrapper public pour permettre à l'UI de valider avant navigation vers le paiement.
  int? resolveMinRentalDaysForBooking(dynamic itemDetails) =>
      _resolveMinRentalDaysForBooking(itemDetails);

  bool isEndTimeBeforeStartTime(String startTime, String endTime) {
    bool is24HourFormat =
        startTime.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$')) &&
            endTime.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'));

    if (is24HourFormat) {
      DateFormat dateFormat = DateFormat('HH:mm');
      DateTime startTimeDateTime = dateFormat.parse(startTime);
      DateTime endTimeDateTime = dateFormat.parse(endTime);
      return endTimeDateTime.isBefore(startTimeDateTime) ||
          endTimeDateTime == startTimeDateTime;
    } else {
      DateFormat dateFormat = DateFormat('h:mm a');
      DateTime startTimeDateTime = dateFormat.parse(startTime);
      DateTime endTimeDateTime = dateFormat.parse(endTime);
      return endTimeDateTime.isBefore(startTimeDateTime) ||
          endTimeDateTime == startTimeDateTime;
    }
  }

  /// Si l’utilisateur appuie sur « Suivant » sans calendrier (écran détail),
  /// on pose des dates/heures par défaut pour débloquer le tunnel de réservation.
  void _ensureDatesAndTimesForSummary(dynamic itemDetails) {
    final fmt = DateFormat('yyyy-MM-dd');
    final today = DateTime.now();
    final tomorrow =
        DateTime(today.year, today.month, today.day).add(const Duration(days: 1));
    final minBillable = _resolveMinRentalDaysForBooking(itemDetails) ?? 1;
    final nights = max(1, minBillable);

    if (startDate.value.isEmpty || endDate.value.isEmpty) {
      final checkIn = tomorrow;
      final checkOut = checkIn.add(Duration(days: nights));
      startDate.value = fmt.format(checkIn);
      endDate.value = fmt.format(checkOut);
    }

    if (selectedStartTime.value.isEmpty) {
      final slots = getManualTimeSlots24();
      selectedStartTime.value = slots.isNotEmpty ? slots.first : '09:00';
    }
    if (selectedEndTime.value.isEmpty) {
      final slots = getManualTimeSlots24();
      final idx18 = slots.indexWhere((e) => e == '18:00');
      final pick = idx18 >= 0
          ? slots[idx18]
          : (slots.length > 12
              ? slots[12]
              : (slots.isNotEmpty ? slots.last : '18:00'));
      selectedEndTime.value = pick;
    }
  }

  commonNavigateToBookingSummary(BuildContext context, idFeatured, itemDetails,
      address, frontimage, title, rating, itemtypes, price, addDoorStepPrice) {
    // Log pour vérifier que itemDetails contient les données de cancellation_reason
    print('🛡️ [NAV_BOOKING_SUMMARY] Title: ${itemDetails?.cancellationReasonTitle}');
    print('🛡️ [NAV_BOOKING_SUMMARY] CancellationReason: ${itemDetails?.cancellationReason}');
    print('🛡️ [NAV_BOOKING_SUMMARY] Description count: ${itemDetails?.cancellationReasonDescription?.length}');
    debugPrint('🛡️ [NAV_BOOKING_SUMMARY] itemDetails is null: ${itemDetails == null}');
    debugPrint('🛡️ [NAV_BOOKING_SUMMARY] Full itemDetails: ${itemDetails?.toString()}');
    chack == true;
    _ensureDatesAndTimesForSummary(itemDetails);

    if (startDate.value.isEmpty || endDate.value.isEmpty) {
      showErrorToastMessage("Select date to continue".tr);

      return;
    }

    if (selectedStartTime.value == "") {
      showErrorToastMessage("Select Start  time to continue".tr);
      return;
    }
    if (selectedEndTime.value == "") {
      showErrorToastMessage("Select  End time to continue".tr);
      return;
    }
    if (startDate.value == endDate.value) {
      if (RentalBillingDays.isEndTimeStrictlyBeforeStartTime(
          selectedStartTime.value, selectedEndTime.value)) {
        showErrorToastMessage("End time must be after Start time".tr);
        return;
      }
    }

    vehicleBookingTunnelComplete.value = true;

    final parsedIn = DateTime.tryParse(startDate.value)!;
    final parsedOut = DateTime.tryParse(endDate.value)!;
    final billableNights = calculateRentalDays(
      parsedIn,
      parsedOut,
      _parseStringToTimeOfDay(selectedStartTime.value),
      _parseStringToTimeOfDay(selectedEndTime.value),
    );
    if (webPlateForm) {
      Get.toNamed(WebRoutes.vehicleBookingSummaryScreen, arguments: {
        "idFeatured": idFeatured,
        "totalNight": billableNights,
        "itemDetails": itemDetails,
        "address": address,
        "rating": rating,
        "title": title,
        "frontImage": frontimage,
        "itemType": itemtypes,
        "price": price,
      });
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => VehicleBookingSummary(
              idFeatured: idFeatured,
              totalNight: billableNights,
              itemDetails: itemDetails,
              address: address,
              rating: rating,
              title: title,
              frontImage: frontimage,
              itemType: itemtypes,
              price: price,
              isAddDoorStepPrice: addDoorStepPrice),
        ),
      );
    }
  }

  late RxList<String> currenttimeSlots;
  late RxList<String> filteredTimeSlots;
  late RxList<String> filteredTimeSlotsEndTime;
  late List<String> avalibleSlots;
  RxString checkTheSelectedStartDate = "".obs;
  RxString checkTheSelectedEndDate = "".obs;
  bool isBetween(DateTime startTime, DateTime endTime) {
    DateTime currentTime = DateTime.now();
    if (currentTime.isAfter(startTime) && currentTime.isBefore(endTime)) {
      return true;
    }
    return false;
  }

  DateTime convertToDateTime(String timeString) {
    try {
      DateFormat format = DateFormat('HH:mm');
      return format.parse(timeString);
    } catch (e) {
      List<String> parts = timeString.split(':');
      int hours = int.parse(parts[0]);
      int minutes = int.parse(parts[1]);
      return DateTime(1, 1, 1, hours, minutes);
    }
  }

  /// Heures d'ouverture des agences : 09:00 à 22:00 (sans 22:30 ni 23:00).
  List<String> getManualTimeSlots24() {
    return getServiceHours();
  }

  List<String> getServiceHours() {
    final List<String> times = [];
    for (int i = 9; i <= 22; i++) {
      final String hour = i.toString().padLeft(2, '0');
      times.add('$hour:00');
      if (i < 22) {
        times.add('$hour:30');
      }
    }
    return times;
  }

  List<String> generateTimeSlots(DateTime selectedDate) {
    currenttimeSlots.clear();
    DateTime currentTime = DateTime.now();
    if (selectedDate.year == currentTime.year &&
        selectedDate.month == currentTime.month &&
        selectedDate.day == currentTime.day) {
      int remainingMinutes = 30 - (currentTime.minute % 30);
      currentTime = currentTime.add(Duration(minutes: remainingMinutes));
      final DateTime serviceStart = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        9,
        0,
      );
      final DateTime serviceEnd = DateTime(
        currentTime.year,
        currentTime.month,
        currentTime.day,
        22,
        0,
      );
      if (currentTime.isBefore(serviceStart)) {
        currentTime = serviceStart;
      }
      if (currentTime.isAfter(serviceEnd)) {
        return [];
      }
      while (currentTime.isBefore(serviceEnd) ||
          currentTime.isAtSameMomentAs(serviceEnd)) {
        String formattedTime = DateFormat('HH:mm').format(currentTime);
        currenttimeSlots.add(formattedTime);
        currentTime = currentTime.add(const Duration(minutes: 30));
      }
      return currenttimeSlots;
    } else {
      return getManualTimeSlots24();
    }
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  DateTime? _lastSelectionTime;
  DateTime? _lastAlertTime;
  final Duration _alertDebounceDuration = const Duration(minutes: 2);
  final Duration _debounceDuration = const Duration(milliseconds: 300);
  DateTime? previousStartDate;
  DateTime? previousEndDate;
  var nextStartTime = "".obs;
  var nextEndTime = "".obs;
  var handleTimeSlotsOnCurrentDate = false.obs;
  DateTime? _lastSnackbarShownTime;
  final Duration _snackbarDebounceDuration = const Duration(minutes: 1);

  void onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    vehicleBookingTunnelComplete.value = false;
    selectedStartTime.value = "";
    nextStartTime.value = "";
    nextEndTime.value = "";
    selectedEndTime.value = "";
    hindTimeStart.value = "";
    hindTimeSEnd.value = "";
    isDateAvailale.value = false;
    handleTimeSlotsOnCurrentDate.value = false;
    avalibleSlots.clear();
    // Ne pas appeler update() ici : rebuild synchrone du SfDateRangePicker (GetBuilder)
    // pouvait relancer onSelectionChanged → boucle inflateWidget / écran noir.
    final now = DateTime.now();
    if (_lastSelectionTime != null &&
        now.difference(_lastSelectionTime!) < _debounceDuration) {
      return;
    }
    _lastSelectionTime = now;
    if (args.value is PickerDateRange) {
      final DateTime? selectedStartDate = args.value.startDate as DateTime?;
      final DateTime? selectedEndDate = args.value.endDate as DateTime?;
      bool isStartDateAvailable = selectedStartDate != null &&
          availableDates.contains(selectedStartDate);
      bool isEndDateAvailable =
          selectedEndDate != null && availableDates.contains(selectedEndDate);
      if (!isStartDateAvailable ||
          (selectedEndDate != null && !isEndDateAvailable)) {
        _showUnavailableDateError(now);
        return;
      }
      if (selectedEndDate == null) {
        if (isStartDateAvailable) {
          startDate.value = DateFormat('yyyy-MM-dd').format(selectedStartDate);
          endDate.value = DateFormat('yyyy-MM-dd').format(selectedStartDate);
          previousStartDate = selectedStartDate;
          previousEndDate = selectedStartDate;
        } else {
          _showUnavailableDateError(now);
          startDate.value = previousStartDate != null
              ? DateFormat('yyyy-MM-dd').format(previousStartDate!)
              : '';
          endDate.value = previousEndDate != null
              ? DateFormat('yyyy-MM-dd').format(previousEndDate!)
              : '';
          return;
        }
      } else {
        if (isStartDateAvailable && isEndDateAvailable) {
          startDate.value = DateFormat('yyyy-MM-dd').format(selectedStartDate);
          endDate.value = DateFormat('yyyy-MM-dd').format(selectedEndDate);
          previousStartDate = selectedStartDate;
          previousEndDate = selectedEndDate;
        } else {
          _showUnavailableDateError(now);
          startDate.value = previousStartDate != null
              ? DateFormat('yyyy-MM-dd').format(previousStartDate!)
              : '';
          endDate.value = previousEndDate != null
              ? DateFormat('yyyy-MM-dd').format(previousEndDate!)
              : '';
          return;
        }
      }
      bool isStartDateToday = isToday(selectedStartDate);
      if (isStartDateToday) {
        DateTime startTime = DateTime(now.year, now.month, now.day, 23, 01);
        DateTime endTime = DateTime(now.year, now.month, now.day, 23, 59);
        bool isBetweenTimeRange = isBetween(startTime, endTime);
        if (isBetweenTimeRange) {
          if (_lastSnackbarShownTime == null ||
              now.difference(_lastSnackbarShownTime!) >
                  _snackbarDebounceDuration) {
            _lastSnackbarShownTime = now;
            showCustomSnackbar(
              title: 'Booking Unavailable'.tr,
              message:
                  'You cannot book the vehicle between 23:01 and 23:59.'.tr,
              color: redColor,
              contentType: ContentType.warning,
            );
          }
          currenttimeSlots.clear();
          avalibleSlots.clear();
          safeUpdate();
          return;
        }
      }
      checkDateApi(idFeatured: '$idFeatured').then((value) {
        if (value != null && value["data"] != null) {
          print("1");
          if (value["data"]["next_start_time"] != null) {
            print("2");
            nextStartTime.value =
                convert12To24(value["data"]["next_start_time"]);
            nextEndTime.value = convert12To24(value["data"]["next_end_time"]);
            debugPrint(
                'next_available_time_on_checkout: ${nextStartTime.value}');
          } else {
            print("3");
            nextStartTime.value = "00:00";
            nextEndTime.value = "11:30";
            debugPrint(
                'next_available_time_on_checkout is null, using fallback: ${nextStartTime.value}');
          }
          if (value["data"]["availability"] != null &&
              value["data"]["availability"]["next_start_time"] != null) {
            print("4");
            nextStartTime.value =
                convert12To24(value["data"]["availability"]["next_start_time"]);
            nextEndTime.value =
                convert12To24(value["data"]["availability"]["next_end_time"]);
            debugPrint(
                'next_start_time from availability: ${nextStartTime.value}');
          }
          if (isToday(selectedStartDate)) {
            print("5");
            compareAndGenerateSlots(
                selectedStartDate, nextStartTime.value, nextEndTime.value);
          } else {
            if (startDate.value == endDate.value) {
              curreentStatus.value = "SameDate";
              filterTimeSlotsfunctionSameDate(
                  nextStartTime.value, nextEndTime.value);
            } else {
              print("6");
              filterTimeSlotsfunctionSameDate(
                  nextStartTime.value, nextEndTime.value);
              curreentStatus.value = "otherDates";
            }
          }
          safeUpdate();
        } else {
          print("7");
          showErrorToastMessage(
              "Failed to fetch availability. Please try again.");
        }
      }).catchError((error) {
        print("8");
        debugPrint('Error in checkDateApi: $error');
        showErrorToastMessage(
            "An error occurred while checking availability.".tr);
        nextStartTime.value = "09:00";
        nextEndTime.value = "22:00";
        safeUpdate();
      });
      safeUpdate();
    }
  }

  void compareAndGenerateSlots(
      DateTime selectedStartDate, String nextStartTime, String nextEndTime) {
    DateTime parsedNextStartTime;
    if (nextStartTime.contains(RegExp(r'^[0-9]{1,2}:[0-9]{2}$'))) {
      DateFormat dateFormat24 = DateFormat('HH:mm');
      parsedNextStartTime = dateFormat24.parse(nextStartTime);
    } else {
      DateFormat dateFormat12 = DateFormat('h:mm a');
      parsedNextStartTime = dateFormat12.parse(nextStartTime);
    }

    DateTime nextStartTimeWithToday = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      parsedNextStartTime.hour,
      parsedNextStartTime.minute,
    );
    DateTime currentTime = DateTime.now();
    print("kljl${currentTime}");
    if (currentTime.isAfter(nextStartTimeWithToday)) {
      handleTimeSlotsOnCurrentDate.value = true;
      curreentStatus.value = "CurrentDate";
      generateTimeSlots(selectedStartDate);
    } else {
      curreentStatus.value = "CurrentDate";
      filterTimeSlotsfunctionSameDate(nextStartTime, nextEndTime);
    }
    safeUpdate();
  }

  void _showUnavailableDateError(DateTime now) {
    if (_lastAlertTime == null ||
        now.difference(_lastAlertTime!) >= _alertDebounceDuration) {
      showCustomSnackbar(
        title: 'Date Unavailable',
        message: 'The selected date is not available for booking.',
        color: Colors.red,
        contentType: ContentType.warning,
      );
      _lastAlertTime = now;
    }
  }

  List<String> filterTimeSlotsfunctionSameDate(
      String startTimeString, String endTimeString) {
    filteredTimeSlotsEndTime.clear();
    safeUpdate();
    List<String> manualTimeSlots = getManualTimeSlots24();

    DateTime startTime = convertToDateTime(startTimeString);
    DateTime endTime = convertToDateTime(endTimeString);
    int startIndex = manualTimeSlots
        .indexWhere((slot) => convertToDateTime(slot).isAfter(startTime));
    if (startIndex == -1) {
      startIndex = manualTimeSlots.length;
    }
    int endIndex = manualTimeSlots
        .lastIndexWhere((slot) => convertToDateTime(slot).isBefore(endTime));
    if (endIndex == -1) {
      endIndex = 0;
    }
    if (startIndex > endIndex) {
      int temp = startIndex;
      startIndex = endIndex;
      endIndex = temp;
    }

    filteredTimeSlotsEndTime.value = manualTimeSlots.sublist(
        max(0, startIndex), min(manualTimeSlots.length, endIndex + 1));
    safeUpdate();
    return filteredTimeSlotsEndTime;
  }

  clearMethod() {
    vehicleBookingTunnelComplete.value = false;
    isDateAvailale.value = false;
    startDate.value = "";
    endDate.value = "";
    dateRangePickerController.selectedRange = null;
    selectedStartTime.value = "";
    selectedEndTime.value = "";
    hindTimeStart.value = "";
    hindTimeSEnd.value = "";
    isenqablestarttime.value = false;
    isenableendTime.value = false;
    vehicleNoController.clear();
    safeUpdate();
  }

  String commonMetaData() {
    Map<String, dynamic> map = {
      "vehicle_no": vehicleNoController.text,
      "host_message": textControllerNotetoOwner.text,
    };

    String jsonString = jsonEncode(map);
    return jsonString;
  }

  void setDefaultTime() {
    List<String> startSlots = getSlotsStartTime();
    if (startSlots.isNotEmpty) {
      selectedStartTime.value = startSlots.first;
      isenqablestarttime.value = true;
    }

    List<String> endSlots = getSlotsEndTime();
    if (endSlots.isNotEmpty) {
      selectedEndTime.value = endSlots.last;
      isenableendTime.value = true;
    }
  }

  List<String> getSlotsStartTime() {
    switch (curreentStatus.value) {
      case "CurrentDate":
        if (handleTimeSlotsOnCurrentDate.value == true) {
          return currenttimeSlots;
        } else {
          return filteredTimeSlotsEndTime;
        }

      case "SameDate":
        return filteredTimeSlotsEndTime;
      case "otherDates":
        return filteredTimeSlotsEndTime;
      default:
        return getManualTimeSlots24();
    }
  }

  List<String> getSlotsEndTime() {
    switch (curreentStatus.value) {
      case "CurrentDate":
        if (startDate.value == endDate.value) {
          if (handleTimeSlotsOnCurrentDate.value == true) {
            return currenttimeSlots;
          } else {
            return filteredTimeSlotsEndTime;
          }
        } else {
          return getManualTimeSlots24();
        }
      case "SameDate":
        return filteredTimeSlotsEndTime;
      case "otherDates":
        if (startDate.value == endDate.value) {
          return filteredTimeSlotsEndTime;
        } else {
          return getManualTimeSlots24();
        }
      default:
        return getManualTimeSlots24();
    }
  }

  Widget startTime() {
    return Expanded(
      child: Obx(
        () => TimePickerPopup(
          hintText: "Start time".tr,
          timesList: getSlotsStartTime(),
          initialValue: selectedStartTime.value.isNotEmpty
              ? selectedStartTime.value
              : null,
          onSelected: (value) {
            isenqablestarttime.value = true;
            selectedStartTime.value = value;
            List<String> endSlots = getSlotsEndTime();
            int startIndex = getSlotsStartTime().indexOf(value);
            int endIndex = startIndex + 3;
            if (endIndex < endSlots.length) {
              selectedEndTime.value = endSlots[endIndex];
            } else {
              selectedEndTime.value = endSlots.last;
            }
            isenableendTime.value = true;
          },
          checkmarkColor: themeColor,
          format24Hour: true,
        ),
      ),
    );
  }

  Widget endTime() {
    return Expanded(
      child: Obx(
        () => TimePickerEndTime(
          hintText: "End time".tr,
          timesList: getSlotsEndTime(),
          initialValue:
              selectedEndTime.value.isNotEmpty ? selectedEndTime.value : null,
          onSelected: (value) {
            isenableendTime.value = true;
            selectedEndTime.value = value;
          },
          checkmarkColor: themeColor,
          format24Hour: true,
        ),
      ),
    );
  }

  String doorStepAddress() {
    AddAddressController addAddressController = Get.find();
    Map<String, dynamic> map = {
      "house_floor_number":
          addAddressController.houseFloorNumberController.text,
      "building_block_number":
          addAddressController.buildingBlockNumberController.text,
      "landmark": addAddressController.landmarkController.text,
      "full_address": addAddressController.fullAddressController.text,
      "city": addAddressController.cityController.text,
      "state": addAddressController.stateController.text,
      "country": addAddressController.countryController.text,
      "postal_code": addAddressController.postalCodeController.text,
      "doorstep_latitude": addAddressController.doorSteplatitude.value,
      "doorstep_longitude": addAddressController.doorSteplongitude.value,
    };
    String jsonString = jsonEncode(map);
    return jsonString;
  }

  String? vehicleType;
  String? vehicleModel;
  String? vehicleMake;
  String? vehicleYear;
  String? vehicleTransmission;
  String? vehicleOdometer;
  String? address;
  String? bookingTypeDetail;
  String? dateStart;
  String? bookingDetailType;
  String? bookingDetailMake;
  String? bookingDateStart;
  String? bookingDateEnd;
  String? jsonItemData;
  String? bookingType;
  String? boiatType;
  String? boatLength;
  String? boatYear;
  String? parkingType;

  void moduleBasedData({required Bookings bookings}) {
    try {
      String? bookingMeta = bookings.bookingMeta;
      String? jsonItemData = bookings.itemData;

      // Validate itemData before parsing
      if (jsonItemData == null ||
          jsonItemData.isEmpty ||
          jsonItemData.trim().isEmpty) {
        print(
            "⚠️ moduleBasedData: itemData is null or empty, skipping parsing");
        // Set default values to prevent null errors
        vehicleType = '';
        vehicleModel = '';
        vehicleMake = '';
        vehicleYear = '';
        vehicleTransmission = '';
        vehicleOdometer = '';
        address = "";
        return;
      }

      List<dynamic> decodedData = jsonDecode(jsonItemData);

      if (decodedData.isEmpty) {
        print("⚠️ moduleBasedData: decodedData is empty");
        vehicleType = '';
        vehicleModel = '';
        vehicleMake = '';
        vehicleYear = '';
        vehicleTransmission = '';
        vehicleOdometer = '';
        address = "";
        return;
      }

      if (bookingMeta != null && bookingMeta.isNotEmpty) {
        try {
          bookingMetaList = json.decode(bookingMeta);
        } catch (e) {
          print("⚠️ moduleBasedData: Error parsing bookingMeta: $e");
        }
      }

      bookingDateStart = "Trip Start";
      bookingDateEnd = "Trip end";
      bookingTypeDetail = "Vehicle Details";
      bookingDetailMake = "Model";
      bookingDetailType = "Type";
      bookingType = "Year";

      String itemInfoString = decodedData[0]['item_info'] ?? "";
      if (itemInfoString.isNotEmpty) {
        try {
          Map<String, dynamic> itemInfoVehicle = jsonDecode(itemInfoString);
          vehicleType = itemInfoVehicle['vehicleType'] ?? '';
          vehicleModel = itemInfoVehicle['model'] ?? '';
          vehicleMake = itemInfoVehicle['make_type'] ?? '';
          vehicleYear = itemInfoVehicle['year'] ?? '';
          vehicleTransmission = itemInfoVehicle['transmission'] ?? '';
          vehicleOdometer = itemInfoVehicle['odometer'] ?? '';
        } catch (e) {
          print("⚠️ moduleBasedData: Error parsing item_info: $e");
          vehicleType = '';
          vehicleModel = '';
          vehicleMake = '';
          vehicleYear = '';
          vehicleTransmission = '';
          vehicleOdometer = '';
        }
      } else {
        vehicleType = '';
        vehicleModel = '';
        vehicleMake = '';
        vehicleYear = '';
        vehicleTransmission = '';
        vehicleOdometer = '';
      }

      address = decodedData[0]['address'] ?? "";
    } catch (e, stackTrace) {
      print("❌ moduleBasedData: Error parsing itemData: $e");
      print("❌ StackTrace: $stackTrace");
      // Set default values to prevent null errors in UI
      vehicleType = '';
      vehicleModel = '';
      vehicleMake = '';
      vehicleYear = '';
      vehicleTransmission = '';
      vehicleOdometer = '';
      address = "";
    }
  }

  CalendarItemId? calendarItemId;
  ItemDates? itemDates;
  Future<void> fetchDataCalendar(id) async {
    print('🚀 TENTATIVE APPEL API CALENDRIER');
    isLoading.value = true;

    try {
      // ========== TRACEUR D'ADRESSE IP ==========
      debugPrint('🌐 [NETWORK] Base URL configurée : ${Config.baseurl}');
      debugPrint('🌐 [NETWORK] Endpoint : ${Config.getItemDates}');
      debugPrint('🌐 [NETWORK] Item ID : $id');

      // ========== TRACEUR D'URL ==========
      // Construire l'URL complète avec l'ID dans le path (pas en paramètre)
      String endpointWithId = "${Config.getItemDates}/$id";
      String fullUrl = '${Config.baseurl}$endpointWithId';
      debugPrint('🌐 [NETWORK] Appel vers : $fullUrl');

      // Vider les listes avant le chargement
      availableDates.clear();
      alreadySelectedList.clear();
      availableDatesPrice.clear();

      // Appel API réel - ID directement dans l'URL
      var response = await httpGet(endpointWithId, {});

      // ========== TRACEUR DE PAYLOAD ==========
      if (response != null && response is Map) {
        debugPrint(
            '💬 [SERVER_MSG] Message du serveur : ${response["message"] ?? "Aucun message"}');
        debugPrint('💬 [SERVER_MSG] Status : ${response["status"] ?? "N/A"}');
      }

      debugPrint('📡 Réponse brute API: $response');

      if (response != null && response is Map) {
        // Extraire directement depuis response['data'] sans passer par les modèles
        if (response['data'] != null && response['data'] is Map) {
          Map<String, dynamic> data = response['data'] as Map<String, dynamic>;

          // ========== EXTRACTION DES LISTES DIRECTEMENT DEPUIS DATA ==========
          List<dynamic>? available = data['available_dates'] as List<dynamic>?;
          List<dynamic>? booked = data['booked_dates'] as List<dynamic>?;
          List<dynamic>? notAvailable =
              data['not_available_dates'] as List<dynamic>?;

          // Récupérer le prix depuis data['price'] ou utiliser le prix par défaut du véhicule
          String basePrice = data['price']?.toString() ?? "0.00";
          double basePriceDouble = 0.0;
          try {
            basePriceDouble = double.parse(basePrice);
          } catch (e) {
            debugPrint('⚠️ [fetchDataCalendar] Erreur parsing basePrice: $e');
            basePriceDouble = 0.0;
          }

          debugPrint('💰 Prix extrait depuis API: $basePriceDouble');

          // ========== TRACEUR TEMPOREL ==========
          // Vérifier la première date reçue avant de parser
          if (available != null && available.isNotEmpty) {
            dynamic firstDateRaw = available[0];
            String? firstDateString;

            // Gérer si c'est un String directement ou un objet avec une clé 'date'
            if (firstDateRaw is String) {
              firstDateString = firstDateRaw;
            } else if (firstDateRaw is Map && firstDateRaw['date'] != null) {
              firstDateString = firstDateRaw['date'].toString();
            }

            if (firstDateString != null) {
              debugPrint(
                  '📅 [DATE_CHECK] La première date reçue est : $firstDateString');

              // ========== ALERTE DE DÉCALAGE ==========
              // Vérifier si la date contient '2024'
              if (firstDateString.contains("2024")) {
                debugPrint(
                    '🚨 [CRITICAL] ════════════════════════════════════════════════════');
                debugPrint(
                    '🚨 [CRITICAL] ALERTE CRITIQUE : Le serveur envoie encore du MOCK 2024 !');
                debugPrint(
                    '🚨 [CRITICAL] Première date reçue : $firstDateString');
                debugPrint('🚨 [CRITICAL] Vérifie ton déploiement Node.js.');
                debugPrint(
                    '🚨 [CRITICAL] Vérifie que le serveur a bien redémarré.');
                debugPrint(
                    '🚨 [CRITICAL] Vérifie que les données mockées ont été supprimées.');
                debugPrint(
                    '🚨 [CRITICAL] ════════════════════════════════════════════════════');
              }
            }
          }

          // ========== PARSING DES DATES DISPONIBLES ==========
          if (available != null) {
            debugPrint('📊 Nombre de dates disponibles: ${available.length}');
            for (var dateItem in available) {
              String? dateString;

              // Gérer si c'est un String directement ou un objet avec une clé 'date'
              if (dateItem is String) {
                dateString = dateItem;
              } else if (dateItem is Map && dateItem['date'] != null) {
                dateString = dateItem['date'].toString();
              }

              if (dateString != null) {
                try {
                  DateTime parsedDate = DateTime.parse(dateString);
                  // Normaliser la date (sans heure) pour faciliter la comparaison
                  DateTime normalizedDate = DateTime(
                      parsedDate.year, parsedDate.month, parsedDate.day);
                  availableDates.add(normalizedDate);

                  // Utiliser le prix de l'item si disponible, sinon le basePrice
                  double priceForDate = basePriceDouble;
                  if (dateItem is Map && dateItem['price'] != null) {
                    try {
                      priceForDate = (dateItem['price'] as num).toDouble();
                    } catch (e) {
                      debugPrint(
                          '⚠️ [fetchDataCalendar] Erreur parsing prix de date: $e');
                    }
                  }

                  availableDatesPrice.add(priceForDate);
                  debugPrint(
                      '✅ Date ajoutée à availableDates: $normalizedDate, prix: $priceForDate');
                } catch (e) {
                  debugPrint(
                      '⚠️ [fetchDataCalendar] Erreur parsing date available: $dateString, erreur: $e');
                }
              }
            }
            debugPrint(
                '📋 Total dates disponibles après parsing: ${availableDates.length}');
          }

          // ========== PARSING DES DATES RÉSERVÉES ==========
          if (booked != null) {
            debugPrint('📊 Nombre de dates réservées: ${booked.length}');
            for (var dateItem in booked) {
              String? dateString;

              // Gérer si c'est un String directement ou un objet avec une clé 'date'
              if (dateItem is String) {
                dateString = dateItem;
              } else if (dateItem is Map && dateItem['date'] != null) {
                dateString = dateItem['date'].toString();
              }

              if (dateString != null) {
                try {
                  DateTime parsedDate = DateTime.parse(dateString);
                  // Normaliser la date (sans heure) pour faciliter la comparaison
                  DateTime normalizedDate = DateTime(
                      parsedDate.year, parsedDate.month, parsedDate.day);
                  alreadySelectedList.add(normalizedDate);
                  debugPrint('🔒 Date réservée ajoutée: $normalizedDate');
                } catch (e) {
                  debugPrint(
                      '⚠️ [fetchDataCalendar] Erreur parsing date booked: $dateString, erreur: $e');
                }
              }
            }
          }

          // ========== PARSING DES DATES NON DISPONIBLES ==========
          if (notAvailable != null) {
            debugPrint(
                '📊 Nombre de dates non disponibles: ${notAvailable.length}');
            for (var dateItem in notAvailable) {
              String? dateString;

              // Gérer si c'est un String directement ou un objet avec une clé 'date'
              if (dateItem is String) {
                dateString = dateItem;
              } else if (dateItem is Map && dateItem['date'] != null) {
                dateString = dateItem['date'].toString();
              }

              if (dateString != null) {
                try {
                  DateTime parsedDate = DateTime.parse(dateString);
                  // Normaliser la date (sans heure) pour faciliter la comparaison
                  DateTime normalizedDate = DateTime(
                      parsedDate.year, parsedDate.month, parsedDate.day);
                  alreadySelectedList.add(normalizedDate);
                  debugPrint('🚫 Date non disponible ajoutée: $normalizedDate');
                } catch (e) {
                  debugPrint(
                      '⚠️ [fetchDataCalendar] Erreur parsing date not_available: $dateString, erreur: $e');
                }
              }
            }
          }

          // Logs de résumé final
          debugPrint('📋 Total dates disponibles: ${availableDates.length}');
          debugPrint(
              '📋 Total dates bloquées (réservées + non disponibles): ${alreadySelectedList.length}');
          debugPrint(
              '💰 Total prix dans availableDatesPrice: ${availableDatesPrice.length}');
          debugPrint('✅ fetchDataCalendar: Parsing terminé avec succès');
        } else {
          debugPrint(
              '⚠️ [fetchDataCalendar] response["data"] est null ou n\'est pas un Map');
        }
      } else {
        debugPrint(
            '⚠️ [fetchDataCalendar] response est null ou n\'est pas un Map');
      }
    } catch (e, stackTrace) {
      debugPrint(
          '❌ [fetchDataCalendar] Erreur lors de la récupération des dates: $e');
      debugPrint('❌ [fetchDataCalendar] StackTrace: $stackTrace');
    } finally {
      isLoading.value = false;
      debugPrint(
          '🔄 [fetchDataCalendar] isLoading mis à false, appel de update()');
      safeUpdate();
      debugPrint(
          '✅ [fetchDataCalendar] update() appelé - UI devrait se rafraîchir');
    }
  }

  final TextEditingController otpController = TextEditingController();
  final TextEditingController dropOtpController = TextEditingController();
  var showhideisReturn = false.obs;
  var dropoffshowHise = false.obs;

  /// Miroir non-Rx de [showhideisReturn] — lu par GetBuilder action (pas Obx).
  bool hideReturnPanel = false;

  static String actionIdFor(int index) => 'action_$index';

  void setHideReturnPanel(bool hidden, {int maxCells = 25}) {
    hideReturnPanel = hidden;
    showhideisReturn.value = hidden;
    notifyBookingActions(maxCells);
  }

  void notifyBookingAction(int index) {
    if (NavigationGuard.isNavigating) return;
    safeUpdate([actionIdFor(index)]);
  }

  void notifyBookingActions(int count) {
    if (NavigationGuard.isNavigating || count <= 0) return;
    safeUpdate(List.generate(count, (i) => actionIdFor(i)));
  }

  void _setDropoffPanelHidden(bool hidden) {
    if (NavigationGuard.isNavigating) return;
    dropoffshowHise.value = hidden;
  }

  final RxBool isMarkingReturnedDirectLoading = false.obs;
  final RxString markingReturnedDirectBookingId = ''.obs;

  /// Clôture une location LIVE côté vendeur sans code OTP drop.
  Future<bool> markOrderAsReturnedDirect(
    String bookingId, {
    VoidCallback? onSuccess,
  }) async {
    if (bookingId.isEmpty) {
      showErrorToastMessage('Invalid booking'.tr);
      return false;
    }
    if (isMarkingReturnedDirectLoading.value) return false;

    isMarkingReturnedDirectLoading.value = true;
    markingReturnedDirectBookingId.value = bookingId;

    try {
      final response = await httpPost(
        Config.markBookingReturnedDirect,
        {'booking_id': bookingId},
      );

      final statusCode = response is Map
          ? int.tryParse('${response['status']}') ?? 0
          : 0;

      if (response != null && statusCode == 200) {
        final message = response is Map
            ? (response['message']?.toString() ??
                'Véhicule retourné avec succès !')
            : 'Véhicule retourné avec succès !';
        Get.safeSnackbar(
          'Succès'.tr,
          message,
          snackStyle: SnackStyle.FLOATING,
          backgroundColor: Colors.green.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          borderRadius: 10,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        onSuccess?.call();
        safeUpdate();
        return true;
      }

      final errorMsg = response is Map
          ? (response['error']?.toString() ??
              response['message']?.toString() ??
              'Failed to mark vehicle as returned'.tr)
          : 'Failed to mark vehicle as returned'.tr;
      Get.safeSnackbar(
        'Erreur'.tr,
        errorMsg,
        snackStyle: SnackStyle.FLOATING,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    } catch (e) {
      Get.safeSnackbar(
        'Erreur'.tr,
        e.toString(),
        snackStyle: SnackStyle.FLOATING,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return false;
    } finally {
      isMarkingReturnedDirectLoading.value = false;
      markingReturnedDirectBookingId.value = '';
    }
  }
  Future<String> updateItemReceivedStatus({required String bookingId, String? otp}) async {
    setHideReturnPanel(false);
    showLoading();
    String result = "no";
    try {
      print('🚀 [PICKUP_FLOW] Envoi du code Pickup au serveur...');
      print('🚀 [DEBUG_FLUTTER] Envoi du Pickup OTP: $otp');

      var map = {
        "booking_id": bookingId,
        "is_item_received": "1",
        "pick_otp": otp ?? otpController.text,
      };

      // NOTE: User requested to use updateItemReturnedStatus endpoint for pickup flow logic
      var response = await httpPost(Config.updateItemReturnedStatus, map);
      print('📥 [OTP_SERVER_RESPONSE] Response: $response');

      closeLoading();
      if (response != null && response["status"] == 200) {
        String? isItemReceived =
            response["data"]["booking_extension"]["is_item_received"];
        if (isItemReceived == "1") {
          setHideReturnPanel(true);
          result = "yes";
          showToastMessage(response["message"]);
          safeUpdate();
        }
      } else {
        print('❌ [OTP_ERROR] Erreur API : ${response != null ? response['error'] : 'Réponse nulle'}');
        showErrorToastMessage(response != null ? response['error'] : "Erreur de connexion");
      }
    } catch (e) {
      closeLoading();
      print("Error in OTP verification: $e");
      showErrorToastMessage("Something went wrong, please try again.");
    }
    safeUpdate();
    return result;
  }

  Future<String> updateItemDeliverStatus({required String bookingId, String? otp}) async {
    _setDropoffPanelHidden(false);
    showLoading();
    String result = "error";
    try {
      print('📡 [OTP_VALIDATION] Envoi OTP : $otp pour le booking : $bookingId');

      var map = {
        "booking_id": bookingId,
        "is_item_returned": "1",
        "drop_otp": otp ?? dropOtpController.text,
      };

      var response = await httpPost(Config.updateItemReturnedStatus, map);
      
      print('📥 [OTP_SERVER_RESPONSE] Response: $response');

      closeLoading();
      
      if (response != null && response["status"] == 200) {
        var isItemDelivered =
            response["data"]["booking_extension"]["is_item_delivered"];
        showToastMessage(response["message"]);
        result = isItemDelivered == "1" ? "no" : "yes";
        _setDropoffPanelHidden(true);
        safeUpdate();
      } else {
        print('❌ [OTP_ERROR] Erreur API : ${response != null ? response['error'] : 'Réponse nulle'}');
        showErrorToastMessage(response != null ? response['error'] : "Erreur de connexion");
      }
    } catch (e) {
      closeLoading();
      print("Error in OTP verification: $e");
      showErrorToastMessage("OTP verification failed.");
    }
    return result;
  }

  clearBookingData() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      hideReturnPanel = false;
      showhideisReturn.value = false;
      _setDropoffPanelHidden(false);
      otpController.clear();
      dropOtpController.clear();
      safeUpdate();
    });
  }

  Future<void> updateBookingStatusIfExists({
    required String bookingId,
    required String hostId,
    required String userId,
    required String newStatus,
  }) async {
    try {
      // ========== VALIDATION DES PARAMÈTRES ==========
      if (bookingId.isEmpty || hostId.isEmpty || userId.isEmpty || newStatus.isEmpty) {
        print("⚠️ [FIREBASE] Paramètres invalides - bookingId: $bookingId, hostId: $hostId, userId: $userId, newStatus: $newStatus");
        return;
      }

      // ========== VALIDATION DES CHEMINS FIREBASE ==========
      // Vérifier que les IDs ne contiennent pas de caractères invalides pour les chemins Firebase
      final invalidChars = RegExp(r'[\.\$#\[\]/]');
      if (invalidChars.hasMatch(bookingId) || invalidChars.hasMatch(hostId) || invalidChars.hasMatch(userId)) {
        print("⚠️ [FIREBASE] IDs contiennent des caractères invalides pour Firebase - bookingId: $bookingId, hostId: $hostId, userId: $userId");
        return;
      }

      final database = FirebaseDatabase.instance.ref().child("chatList");
      
      // ========== MISE À JOUR POUR L'UTILISATEUR ==========
      try {
        final currentUserChatRef =
            database.child(userId).child("${bookingId}_$hostId");
        
        // Timeout pour éviter le freeze
        final currentUserChatSnapshot = await currentUserChatRef.once().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print("⚠️ [FIREBASE] Timeout lors de la lecture du chemin utilisateur: ${bookingId}_$hostId");
            throw TimeoutException("Firebase read timeout for user chat");
          },
        );
        
        if (currentUserChatSnapshot.snapshot.exists) {
          await currentUserChatRef.update({'bookingStatus': newStatus}).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print("⚠️ [FIREBASE] Timeout lors de la mise à jour du statut pour l'utilisateur: $userId");
              throw TimeoutException("Firebase update timeout for user chat");
            },
          );
          print("✅ [FIREBASE] Updated booking status to $newStatus for user: $userId");
        } else {
          print("ℹ️ [FIREBASE] Chat node does not exist for user: $userId, skipping update");
        }
      } catch (e) {
        print("❌ [FIREBASE] Erreur lors de la mise à jour pour l'utilisateur $userId: $e");
        // Continue avec la mise à jour pour le host même si celle de l'utilisateur échoue
      }

      // ========== MISE À JOUR POUR LE HOST ==========
      try {
        final hostUserChatRef =
            database.child(hostId).child("${bookingId}_$userId");
        
        // Timeout pour éviter le freeze
        final hostUserChatSnapshot = await hostUserChatRef.once().timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            print("⚠️ [FIREBASE] Timeout lors de la lecture du chemin host: ${bookingId}_$userId");
            throw TimeoutException("Firebase read timeout for host chat");
          },
        );
        
        if (hostUserChatSnapshot.snapshot.exists) {
          await hostUserChatRef.update({'bookingStatus': newStatus}).timeout(
            const Duration(seconds: 5),
            onTimeout: () {
              print("⚠️ [FIREBASE] Timeout lors de la mise à jour du statut pour le host: $hostId");
              throw TimeoutException("Firebase update timeout for host chat");
            },
          );
          print("✅ [FIREBASE] Updated booking status to $newStatus for host: $hostId");
        } else {
          print("ℹ️ [FIREBASE] Chat node does not exist for host: $hostId, skipping update");
        }
      } catch (e) {
        print("❌ [FIREBASE] Erreur lors de la mise à jour pour le host $hostId: $e");
        // Ne pas propager l'erreur pour éviter le freeze de l'application
      }
    } catch (e, stackTrace) {
      print("❌ [FIREBASE] Erreur générale lors de la mise à jour du statut de réservation: $e");
      print("📋 [FIREBASE] Stack trace: $stackTrace");
      // Ne pas propager l'erreur pour éviter le freeze de l'application
    }
  }

  SignatureDataResponse? signatureDataResponse;
  Future<SignatureDataResponse?> singnatureApi(
      String id, bool showloading) async {
    if (showloading == true) {
      showLoading();
    }
    signatureDataResponse = null;
    try {
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var responce = await httpGet(Config.getDigitalSingnature, {"booking_id": "${id}"});

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static signature data
      Map<String, dynamic> mockResponse = {
        "success": 200,
        "message": "Digital signature data retrieved successfully",
        "data": {
          "booking_id": id.toString(),
          "user_signed": 1,
          "vendor_signed": 1,
          "user_signature_url": {
            "url": "https://example.com/signatures/user_signature.png",
            "thumb": "https://example.com/signatures/user_signature_thumb.png",
            "preview":
                "https://example.com/signatures/user_signature_preview.png"
          },
          "vendor_signature_url": {
            "url": "https://example.com/signatures/vendor_signature.png",
            "thumb":
                "https://example.com/signatures/vendor_signature_thumb.png",
            "preview":
                "https://example.com/signatures/vendor_signature_preview.png"
          }
        }
      };

      var responce = mockResponse;
      // ========== END MOCK DATA ==========

      if (responce != null && responce["success"] == 200) {
        signatureDataResponse = SignatureDataResponse.fromJson(responce);
        if (showloading == true) {
          closeLoading();
        }
        return signatureDataResponse;
      } else {
        if (showloading == true) {
          closeLoading();
        }
        return null;
      }
    } catch (e) {
      print('Error fetching signature data: $e');
      if (showloading == true) {
        closeLoading();
      }
      return null;
    }
  }

  Future<String> updateItemDeliverStatusHost(
      {required String bookingId}) async {
    var isItemDelivered;
    String result;

    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpPost(Config.updateItemDeliveredStatus,
    //     {"booking_id": bookingId, "is_item_delivered": "1"});

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Static success response
    Map<String, dynamic> mockResponse = {
      "status": 200,
      "message": "Item delivered status updated successfully",
      "error": "",
      "data": {
        "booking_extension": {"is_item_delivered": "1"}
      }
    };

    var response = mockResponse;
    // ========== END MOCK DATA ==========
    if (response["status"] == 200) {
      isItemDelivered =
          response["data"]["booking_extension"]["is_item_delivered"];
      showToastMessage(response["message"]);
      result = isItemDelivered == "1" ? "no" : "yes";
    } else {
      showErrorToastMessage(response['error']);
      result = "yes";
    }
    return result;
  }

  // ========== FONCTION DE DIAGNOSTIC POUR CONFIRMER UNE RÉSERVATION ==========
  Future<Map<String, dynamic>?> confirmBookingByHost({required String bookingId}) async {
    print('--- 🔎 DIAGNOSTIC API START ---');
    print('1️⃣ Destination: ${Config.confirmBookingByHost}');
    print('2️⃣ Payload: {"booking_id": "$bookingId"}');
    
    try {
      final response = await httpPost(
        Config.confirmBookingByHost,
        {"booking_id": bookingId},
      );
      
      print('3️⃣ Response Type: ${response.runtimeType}');
      print('4️⃣ Response Data: $response');
      
      if (response != null && response is Map) {
        if (response['status'] == 200) {
          print('✅ SUCCÈS LOGIQUE: Statut mis à jour dans l\'UI');
          print('   - Message: ${response['message']}');
          print('   - Data: ${response['data']}');
        } else {
          print('⚠️ ERREUR SERVEUR (JSON): ${response['message'] ?? response['error']}');
          print('   - Status: ${response['status']}');
          print('   - Error: ${response['error']}');
        }
      } else {
        print('❌ ERREUR: Réponse invalide ou null');
        print('   - Response: $response');
      }
      
      print('--- 🔎 DIAGNOSTIC API END ---');
      return response != null && response is Map ? Map<String, dynamic>.from(response) : null;
    } catch (e) {
      print('🚨 CRASH RÉSEAU/FLUTTER: $e');
      print('   - StackTrace: ${StackTrace.current}');
      print('--- 🔎 DIAGNOSTIC API END ---');
      return null;
    }
  }
}
