import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../controller/add_address_controller.dart';
import '../../../controller/booking_controller.dart';
import '../../../controller/kyc_controller.dart';
import '../../../customwidget/miscellaneous_project_elements.dart';
import '../../../customwidget/project_color.dart';
import '../../../model/vehicle_home_model.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/rental_billing_days.dart';
import '../../../utils/theme_style.dart';
import '../../../view/host/common_widget_host.dart';
import '../../../view/kyc/user_kyc.dart';
import '../../../work_space.dart';

/// Écran « Sélectionner l’heure » après le calendrier (stepper Emplacement → Date → Heure).
class VehicleSelectTimeScreen extends StatefulWidget {
  final dynamic idFeatured;
  final ItemInfo? itemDetails;
  final String? frontImage;
  final String? address;
  final String? rating;
  final String? itemType;
  final String? title;
  final String? price;

  const VehicleSelectTimeScreen({
    super.key,
    this.idFeatured,
    this.itemDetails,
    this.frontImage,
    this.address,
    this.rating,
    this.itemType,
    this.title,
    this.price,
  });

  @override
  State<VehicleSelectTimeScreen> createState() =>
      _VehicleSelectTimeScreenState();
}

class _VehicleSelectTimeScreenState extends State<VehicleSelectTimeScreen> {
  late BookingController bookingController;
  AddAddressController addAddressController = Get.find();
  KycController kycController = Get.find();

  /// Grille 09:00–20:30 (référence stable pour les scroll controllers).
  late final List<String> _cachedVehicleSlots =
      RentalBillingDays.vehicleSearchTimeSlotsHHmm();

  late final FixedExtentScrollController _startScrollController;
  late final FixedExtentScrollController _endScrollController;

  /// Après le premier frame : évite un `onSelectedItemChanged` fantôme au montage.
  bool _startPickerReady = false;

  /// Tant que l'utilisateur n'a pas touché au picker retour, le scroll retour suit la prise en charge.
  bool _endTimeManuallyTouched = false;

  TimeOfDay _parseToTimeOfDay(String value) {
    if (value.isEmpty) return const TimeOfDay(hour: 9, minute: 0);
    try {
      if (RegExp(r'^[0-9]{1,2}:[0-9]{2}$').hasMatch(value)) {
        final p = value.split(':');
        return TimeOfDay(
          hour: int.parse(p[0]),
          minute: int.parse(p[1]),
        );
      }
      final dt = DateFormat('h:mm a').parse(value);
      return TimeOfDay(hour: dt.hour, minute: dt.minute);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  /// Identifiant attendu par `DateFormat.yMMMEd` (évite LocaleDataException si symboles non chargés).
  String _symbolLocaleIdForDateFormat() {
    final l = Get.locale;
    if (l == null) return 'fr_FR';
    final c = l.countryCode;
    if (c != null && c.isNotEmpty) return '${l.languageCode}_$c';
    switch (l.languageCode) {
      case 'fr':
        return 'fr_FR';
      case 'en':
        return 'en_US';
      case 'es':
        return 'es_ES';
      case 'ar':
        return 'ar';
      default:
        return 'fr_FR';
    }
  }

  /// Date de retour lisible au-dessus de l'heure de fin (ex. sam. 30 mai 2026).
  String _formatReturnDateHeading(DateTime d) {
    final sym = _symbolLocaleIdForDateFormat();
    try {
      return DateFormat('EEE d MMMM y', sym).format(d);
    } catch (_) {
      try {
        final code = Get.locale?.languageCode ?? 'fr';
        return DateFormat('EEE d MMMM y', code).format(d);
      } catch (_) {
        return _formatBookingDateDisplay(d);
      }
    }
  }

  /// Format d’affichage des dates de réservation ; ne jamais appeler `format` sur une date null.
  String _formatBookingDateDisplay(DateTime? d) {
    if (d == null) return '---';
    final sym = _symbolLocaleIdForDateFormat();
    try {
      return DateFormat.yMMMEd(sym).format(d);
    } catch (_) {
      try {
        final code = Get.locale?.languageCode ?? 'fr';
        return DateFormat.yMMMEd(code).format(d);
      } catch (_) {
        return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      }
    }
  }

  List<String> _vehicleBookingTimeSlots() => _cachedVehicleSlots;

  bool _sameCalendarBookingDay() {
    final a = bookingController.startDate.value;
    final b = bookingController.endDate.value;
    return a.isNotEmpty && b.isNotEmpty && a == b;
  }

  void _syncInitialVehicleBookingTimes() {
    final slots = _vehicleBookingTimeSlots();
    if (slots.isEmpty) return;
    var s = bookingController.selectedStartTime.value;
    var e = bookingController.selectedEndTime.value;
    if (s.isEmpty || !slots.contains(s)) {
      s = slots.first;
      bookingController.selectedStartTime.value = s;
      bookingController.hindTimeStart.value = s;
    }
    if (!_endTimeManuallyTouched || e.isEmpty || !slots.contains(e)) {
      e = s;
      bookingController.selectedEndTime.value = e;
      bookingController.hindTimeSEnd.value = e;
      _endTimeManuallyTouched = false;
    }
  }

  bool _canContinueBookingTimes() {
    final slots = _vehicleBookingTimeSlots();
    final s = bookingController.selectedStartTime.value;
    final e = bookingController.selectedEndTime.value;
    if (s.isEmpty || e.isEmpty) return false;
    if (!slots.contains(s) || !slots.contains(e)) return false;
    if (_sameCalendarBookingDay() &&
        RentalBillingDays.isEndTimeStrictlyBeforeStartTime(s, e)) {
      return false;
    }
    return true;
  }

  void _onBookingStartIndexChanged(int index, List<String> slots) {
    if (index < 0 || index >= slots.length) return;
    final v = slots[index];
    bookingController.selectedStartTime.value = v;
    bookingController.hindTimeStart.value = v;
    if (!_startPickerReady) return;
    if (!_endTimeManuallyTouched && _endScrollController.hasClients) {
      if (_endScrollController.selectedItem != index) {
        _endScrollController.animateToItem(
          index,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
        );
      }
      bookingController.selectedEndTime.value = v;
      bookingController.hindTimeSEnd.value = v;
    }
  }

  void _onBookingEndIndexChanged(int index, List<String> slots) {
    if (index < 0 || index >= slots.length) return;
    _endTimeManuallyTouched = true;
    final v = slots[index];
    bookingController.selectedEndTime.value = v;
    bookingController.hindTimeSEnd.value = v;
  }

  Widget _buildTimeSelectionContent(
    BuildContext context,
    ColorNotifires notifires,
  ) {
    final slots = _vehicleBookingTimeSlots();
    return Obx(
      () {
        DateTime? startD;
        DateTime? endD;
        if (bookingController.startDate.value.isNotEmpty) {
          startD = DateTime.tryParse(bookingController.startDate.value);
        }
        if (bookingController.endDate.value.isNotEmpty) {
          endD = DateTime.tryParse(bookingController.endDate.value);
        }
        final startRx = bookingController.selectedStartTime.value;
        final endRx = bookingController.selectedEndTime.value;
        final hasTimes = startRx.isNotEmpty && endRx.isNotEmpty;
        final canShowTotals = startD != null && endD != null && hasTimes;
        final heureDebut = _parseToTimeOfDay(startRx);
        final heureFin = _parseToTimeOfDay(endRx);
        final billing = canShowTotals
            ? RentalBillingDays.compute(
                startDate: startD!,
                endDate: endD!,
                startTime: heureDebut,
                endTime: heureFin,
              )
            : null;
        final isExtraDay = billing?.hasExtraDay ?? false;
        final isOvertime = isExtraDay;
        final totalLocationAffiche = billing?.totalDays ?? 1;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _StepperHeader(
              locationDone: true,
              dateDone: startD != null && endD != null,
              timeDone: startRx.isNotEmpty && endRx.isNotEmpty,
            ),
            const SizedBox(height: 28),
            Text(
              'Select Date'.tr,
              style: heading2(context),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatBookingDateDisplay(startD),
                    style: regular2(context).copyWith(
                      color: notifires.getGrey3Whitecolor,
                    ),
                  ),
                ),
                Text(
                  '→',
                  style: regular2(context),
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: VehicleReturnDateWithBillingBadgeRow(
                      dateText: _formatBookingDateDisplay(endD),
                      textAlign: TextAlign.end,
                      isExtraDay: isExtraDay,
                      emphasizeOvertime: isOvertime,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (endD != null) ...[
              VehicleReturnDateWithBillingBadgeRow(
                dateText: _formatReturnDateHeading(endD),
                textAlign: TextAlign.start,
                isExtraDay: isExtraDay,
                emphasizeOvertime: isOvertime,
                idleFontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              const SizedBox(height: 12),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Pick-up time'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: notifires.getwhiteblackcolor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: notifires.getGrey3Whitecolor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CupertinoPicker(
                          scrollController: _startScrollController,
                          itemExtent: 40,
                          onSelectedItemChanged: (i) =>
                              _onBookingStartIndexChanged(i, slots),
                          children: slots
                              .map(
                                (time) => Center(
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: notifires.getwhiteblackcolor,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Drop-off time'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: notifires.getwhiteblackcolor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: notifires.getGrey3Whitecolor.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CupertinoPicker(
                          scrollController: _endScrollController,
                          itemExtent: 40,
                          onSelectedItemChanged: (i) =>
                              _onBookingEndIndexChanged(i, slots),
                          children: slots
                              .map(
                                (time) => Center(
                                  child: Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: notifires.getwhiteblackcolor,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (canShowTotals)
              VehicleRentalBillableDaysInfoBanner(
                totalBillableDays: totalLocationAffiche,
                hasOvertimeDay: isOvertime,
              ),
          ],
        );
      },
    );
  }

  Future<void> _confirm(BuildContext context) async {
    if (bookingController.selectedStartTime.value.isEmpty ||
        bookingController.selectedEndTime.value.isEmpty) {
      showErrorToastMessage("Select Start  time to continue".tr);
      return;
    }
    if (bookingController.startDate.value ==
        bookingController.endDate.value) {
      if (RentalBillingDays.isEndTimeStrictlyBeforeStartTime(
          bookingController.selectedStartTime.value,
          bookingController.selectedEndTime.value)) {
        showErrorToastMessage("End time must be after Start time".tr);
        return;
      }
    }
    if (bookingController.addDoorStepPrice == true) {
      if (addAddressController.fulladdress.value == "") {
        addAddressController.preventDate.value = true;
        addAddressAlert(context);
        return;
      }
    }

    if (kycController.shouldRequireKycBeforeBooking) {
      Get.to(() => const UserKyc());
      return;
    }

    bookingController.commonNavigateToBookingSummary(
      context,
      widget.idFeatured,
      widget.itemDetails,
      widget.address,
      widget.frontImage,
      widget.title,
      widget.rating,
      widget.itemType,
      widget.price,
      bookingController.addDoorStepPrice
          ? widget.itemDetails?.doorStepPrice
          : "0",
    );
  }

  @override
  void initState() {
    super.initState();
    bookingController = Get.find<BookingController>();
    bookingController.isenqablestarttime.value = true;
    bookingController.isenableendTime.value = true;
    final s = bookingController.selectedStartTime.value;
    final e = bookingController.selectedEndTime.value;
    _endTimeManuallyTouched =
        e.isNotEmpty && s.isNotEmpty && e != s;
    _syncInitialVehicleBookingTimes();

    final slots = _vehicleBookingTimeSlots();
    final idx09 = slots.indexOf('09:00');
    final initIdx = idx09 >= 0 ? idx09 : 0;
    bookingController.selectedStartTime.value = slots[initIdx];
    bookingController.hindTimeStart.value = slots[initIdx];
    if (!_endTimeManuallyTouched) {
      bookingController.selectedEndTime.value = slots[initIdx];
      bookingController.hindTimeSEnd.value = slots[initIdx];
    }
    final s2 = bookingController.selectedStartTime.value;
    final e2 = bookingController.selectedEndTime.value;
    _endTimeManuallyTouched =
        e2.isNotEmpty && s2.isNotEmpty && e2 != s2;

    final startIdx = slots.indexOf(s2) >= 0 ? slots.indexOf(s2) : initIdx;
    final endIdx = !_endTimeManuallyTouched
        ? startIdx
        : (slots.indexOf(e2) >= 0 ? slots.indexOf(e2) : startIdx);

    _startScrollController =
        FixedExtentScrollController(initialItem: startIdx);
    _endScrollController = FixedExtentScrollController(initialItem: endIdx);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _startPickerReady = true;
      }
      addAddressController.getDoorStepAddressp(false);
    });
  }

  @override
  void dispose() {
    _startScrollController.dispose();
    _endScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Align(
      alignment: Alignment.center,
      child: Container(
        color: notifires.getbgnextcolor,
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          appBar: AppBar(
            leadingWidth: 80,
            centerTitle: true,
            scrolledUnderElevation: 0,
            backgroundColor: notifires.getbgcolor,
            elevation: 0,
            leading: backButton(),
            title: Text(
              'Select time'.tr,
              style: heading2Grey1(context).copyWith(),
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: SizedBox(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Obx(
                  () => ElevatedButton(
                    onPressed: _canContinueBookingTimes()
                        ? () => _confirm(context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getColorBasedOnActiveModuleid(),
                      disabledBackgroundColor:
                          notifires.getgreycolor.withOpacity(0.35),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Continue'.tr,
                          style: heading2(context).copyWith(
                            color: _canContinueBookingTimes()
                                ? bgColor
                                : notifires.getGrey3Whitecolor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimeSelectionContent(context, notifires),
                if (widget.itemDetails?.doorStepPrice != null &&
                    widget.itemDetails!.doorStepPrice.toString() != 'null' &&
                    widget.itemDetails!.doorStepPrice.toString() != '0' &&
                    widget.itemDetails!.doorStepPrice.toString().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Row(
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          activeColor: getColorBasedOnActiveModuleid(),
                          side: BorderSide(
                            color: notifires.getGrey3Whitecolor,
                            width: 2,
                          ),
                          value: bookingController.addDoorStepPrice,
                          onChanged: (value) {
                            setState(() {
                              bookingController.addDoorStepPrice =
                                  !bookingController.addDoorStepPrice;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            '${'Add Doorstep Price'.tr} : $currency ${widget.itemDetails?.doorStepPrice}',
                            style: regular2(context),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperHeader extends StatelessWidget {
  final bool locationDone;
  final bool dateDone;
  final bool timeDone;

  const _StepperHeader({
    required this.locationDone,
    required this.dateDone,
    required this.timeDone,
  });

  @override
  Widget build(BuildContext context) {
    final accent = getColorBasedOnActiveModuleid();
    Widget step(String labelKey, bool done, bool active) {
      return Expanded(
        child: Column(
          children: [
            Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? accent : (active ? accent : grey3),
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              labelKey.tr,
              textAlign: TextAlign.center,
              style: regular2(context).copyWith(
                fontSize: 11,
                color: active ? accent : grey3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        step('Location', locationDone, false),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(height: 2, color: accent.withOpacity(0.35)),
          ),
        ),
        step('Dates', dateDone, false),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Container(height: 2, color: accent.withOpacity(0.35)),
          ),
        ),
        step('Select time', timeDone, true),
      ],
    );
  }
}

