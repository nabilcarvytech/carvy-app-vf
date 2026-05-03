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

  /// Tant que l'utilisateur n'a pas choisi explicitement l'heure de fin, elle reste synchronisée sur l'heure de début.
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

  String _format24(TimeOfDay t) {
    final dt = DateTime(0, 1, 1, t.hour, t.minute);
    try {
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    }
  }

  /// Écart calendaire pur (sans majoration dépassement horaire).
  int _joursInitiauxCalendar(DateTime? dateDebut, DateTime? dateFin) {
    if (dateDebut == null || dateFin == null) return 0;
    final d0 = DateTime(dateDebut.year, dateDebut.month, dateDebut.day);
    final d1 = DateTime(dateFin.year, dateFin.month, dateFin.day);
    return d1.difference(d0).inDays;
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

  /// Date de fin + badge « +1j facturé » si dépassement horaire (date calendaire inchangée).
  Widget _endDateLineWithBadge({
    required BuildContext context,
    required String dateText,
    required TextAlign textAlign,
    required bool isExtraDay,
    required bool isOvertime,
    FontWeight idleFontWeight = FontWeight.normal,
    double? fontSize,
  }) {
    final carvyBlue = getColorBasedOnActiveModuleid();
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: textAlign == TextAlign.end
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            style: regular2(context).copyWith(
              color: isOvertime ? carvyBlue : Colors.grey,
              fontSize: fontSize,
              fontWeight:
                  isOvertime ? FontWeight.bold : idleFontWeight,
            ),
            child: Text(
              dateText,
              textAlign: textAlign,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (isExtraDay) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: carvyBlue,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              '+1j facturé',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ),
        ],
      ],
    );
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

  Future<void> _pickTime(BuildContext context, bool isStart) async {
    final initial =
        _parseToTimeOfDay(isStart ? bookingController.selectedStartTime.value : bookingController.selectedEndTime.value);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (ctx, child) {
        return MediaQuery(
          data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
          child: Theme(
            data: Theme.of(ctx).copyWith(
              colorScheme: ColorScheme.light(
                primary: getColorBasedOnActiveModuleid(),
              ),
            ),
            child: child ?? const SizedBox(),
          ),
        );
      },
    );
    if (picked == null) return;
    final formatted = _format24(picked);
    if (isStart) {
      bookingController.selectedStartTime.value = formatted;
      bookingController.hindTimeStart.value = formatted;
      if (!_endTimeManuallyTouched) {
        bookingController.selectedEndTime.value = formatted;
        bookingController.hindTimeSEnd.value = formatted;
      }
    } else {
      _endTimeManuallyTouched = true;
      bookingController.selectedEndTime.value = formatted;
      bookingController.hindTimeSEnd.value = formatted;
    }
    if (mounted) setState(() {});
  }

  Widget _buildTimeSelectionContent(
    BuildContext context,
    ColorNotifires notifires,
  ) {
    DateTime? startD;
    DateTime? endD;
    if (bookingController.startDate.value.isNotEmpty) {
      startD = DateTime.tryParse(bookingController.startDate.value);
    }
    if (bookingController.endDate.value.isNotEmpty) {
      endD = DateTime.tryParse(bookingController.endDate.value);
    }
    final startT = bookingController.selectedStartTime.value;
    final endT = bookingController.selectedEndTime.value;
    final hasTimes = startT.isNotEmpty && endT.isNotEmpty;
    final canShowTotals = startD != null && endD != null && hasTimes;
    final joursInitiaux = _joursInitiauxCalendar(startD, endD);
    final heureDebut = _parseToTimeOfDay(startT);
    final heureFin = _parseToTimeOfDay(endT);
    final timeStart = heureDebut.hour + (heureDebut.minute / 60.0);
    final timeEnd = heureFin.hour + (heureFin.minute / 60.0);
    final isExtraDay = hasTimes && (timeEnd > timeStart);
    final isOvertime = isExtraDay;
    final totalLocationBrut = isOvertime ? joursInitiaux + 1 : joursInitiaux;
    final totalLocationAffiche = totalLocationBrut < 1 ? 1 : totalLocationBrut;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _StepperHeader(
          locationDone: true,
          dateDone: startD != null && endD != null,
          timeDone: startT.isNotEmpty && endT.isNotEmpty,
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
                child: _endDateLineWithBadge(
                  context: context,
                  dateText: _formatBookingDateDisplay(endD),
                  textAlign: TextAlign.end,
                  isExtraDay: isExtraDay,
                  isOvertime: isOvertime,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          'Start time'.tr,
          style: heading3(context),
        ),
        const SizedBox(height: 8),
        _TimeRow(
          label: startT.isEmpty ? '---' : startT,
          onTap: () => _pickTime(context, true),
          notifires: notifires,
        ),
        const SizedBox(height: 20),
        if (endD != null) ...[
          _endDateLineWithBadge(
            context: context,
            dateText: _formatReturnDateHeading(endD),
            textAlign: TextAlign.start,
            isExtraDay: isExtraDay,
            isOvertime: isOvertime,
            idleFontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          const SizedBox(height: 6),
        ],
        Text(
          ' End time'.tr,
          style: heading3(context),
        ),
        const SizedBox(height: 8),
        _TimeRow(
          label: endT.isEmpty ? '---' : endT,
          onTap: () => _pickTime(context, false),
          notifires: notifires,
        ),
        const SizedBox(height: 10),
        if (canShowTotals)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Container(
              key: ValueKey('rental-total-$totalLocationAffiche-$isOvertime'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue, width: 0.8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total : $totalLocationAffiche jours de location',
                          style: regular2(context).copyWith(
                            color: Colors.blue.shade900,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isOvertime) ...[
                          const SizedBox(height: 4),
                          Text(
                            '(Incluant 1 jour pour dépassement horaire)',
                            style: regular2(context).copyWith(
                              color: Colors.blue.shade900,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _confirm(BuildContext context) async {
    if (bookingController.selectedStartTime.value.isEmpty ||
        bookingController.selectedEndTime.value.isEmpty) {
      showErrorToastMessage("Select Start  time to continue".tr);
      return;
    }
    if (bookingController.startDate.value == bookingController.endDate.value) {
      if (bookingController.isEndTimeBeforeStartTime(
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

    final kycStatus = kycController.activeStatus.value.toLowerCase();
    if ((kycStatus == "none" || kycStatus == "no" || kycStatus.isEmpty) &&
        !kycController.hasSkippedInSession.value) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addAddressController.getDoorStepAddressp(false);
    });
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
                child: ElevatedButton(
                  onPressed: () => _confirm(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getColorBasedOnActiveModuleid(),
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
                        style: heading2(context).copyWith(color: bgColor),
                      ),
                    ],
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

class _TimeRow extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final dynamic notifires;

  const _TimeRow({
    required this.label,
    required this.onTap,
    required this.notifires,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: notifires.getBoxColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: regular2(context).copyWith(
                    color: notifires.getwhiteblackcolor,
                    fontSize: 15,
                  ),
                ),
              ),
              Icon(Icons.access_time, color: getColorBasedOnActiveModuleid()),
            ],
          ),
        ),
      ),
    );
  }
}
