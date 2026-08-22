import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/controller/add_address_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:get/get.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/rolling_calendar_bounds.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/myaccount/addaddress/pick_address_with_map.dart';
import 'package:carvy/work_space.dart';
import '../../../controller/booking_controller.dart';
import '../../../customwidget/miscellaneous_project_elements.dart';
import '../../../model/vehicle_home_model.dart';
import '../../../view/itemdetail/vehicle/vehicle_select_time_screen.dart';

class VehicleCheckAvailability extends StatefulWidget {
  final dynamic idFeatured;
  final ItemInfo? itemDetails;
  final String? frontImage;
  final String? address;
  final String? rating;
  final String? itemType;
  final String? title;
  final String? price;
  final dynamic cleanvalue;
  const VehicleCheckAvailability({
    super.key,
    this.idFeatured,
    this.itemDetails,
    this.address,
    this.rating,
    this.itemType,
    this.title,
    this.price,
    this.frontImage,
    this.cleanvalue,
  });

  @override
  State<VehicleCheckAvailability> createState() =>
      _VehicleCheckAvailabilityState();
}

class _VehicleCheckAvailabilityState extends State<VehicleCheckAvailability> {
  late BookingController bookingController;
  AddAddressController addAddressController = Get.find();

  /// Remount contrôlé du picker (ex. bouton Effacer) — pas après fetch API.
  int _calendarDataEpoch = 0;

  /// Force le cellBuilder à relire startDate/endDate après chaque sélection.
  int _selectionEpoch = 0;

  /// Invalide le cache Syncfusion des cellules après fetch ou changement de mois.
  int _availabilityDataEpoch = 0;

  void _bumpAvailabilityDataEpoch() {
    _availabilityDataEpoch++;
  }

  void _navigateCalendarMonth(int monthDelta) {
    final current = bookingController.dateRangePickerController.displayDate ??
        DateTime.now();
    bookingController.dateRangePickerController.displayDate =
        DateTime(current.year, current.month + monthDelta, 1);
    setState(_bumpAvailabilityDataEpoch);
  }

  Future<void> getData() async {
    print('📅 getData() appelé avec idFeatured: ${widget.idFeatured}');
    try {
      await bookingController.fetchDataCalendar(widget.idFeatured);
      print('✅ fetchDataCalendar terminé');
      // Ne PAS remonter SfDateRangePicker (ValueKey / _calendarDataEpoch) :
      // Syncfusion crash si le RenderObject est détruit pendant drawCustomcellSelection.
      // On force uniquement le re-rendu des cellules via _availabilityDataEpoch.
      if (mounted) {
        setState(_bumpAvailabilityDataEpoch);
      }
    } catch (e) {
      print('❌ Erreur dans getData(): $e');
    }
  }
  /// Dernier jour sélectionné = jour de restitution : pas de prix sous la date (multi‑jours).
  bool _hideDailyPriceForCell(DateTime cellDate) {
    if (bookingController.startDate.value.isEmpty ||
        bookingController.endDate.value.isEmpty) {
      return false;
    }
    final s = DateTime.tryParse(bookingController.startDate.value);
    final e = DateTime.tryParse(bookingController.endDate.value);
    if (s == null || e == null) return false;
    final sd = DateTime(s.year, s.month, s.day);
    final ed = DateTime(e.year, e.month, e.day);
    if (sd == ed) return false;
    final cd =
        DateTime(cellDate.year, cellDate.month, cellDate.day);
    return cd == ed;
  }

  void _openSelectTimeScreen() {
    if (!bookingController.validateMinRentalDaysForDateSelection(
      widget.itemDetails,
    )) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleSelectTimeScreen(
          idFeatured: widget.idFeatured,
          itemDetails: widget.itemDetails,
          frontImage: widget.frontImage,
          address: widget.address,
          rating: widget.rating,
          itemType: widget.itemType,
          title: widget.title,
          price: widget.price,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    print('🔄 initState() de VehicleCheckAvailability appelé');

    // S'assurer que le contrôleur est initialisé
    try {
      bookingController = Get.find<BookingController>();
      print('✅ BookingController trouvé via Get.find()');
    } catch (e) {
      print('⚠️ BookingController non trouvé, création avec Get.put()');
      bookingController = Get.put(BookingController());
    }

    // Masquer le calendrier dès le 1er frame (évite cellules figées sans prix).
    bookingController.isLoading.value = true;
    bookingController.availableDates.clear();
    bookingController.availableDatesPrice.clear();
    bookingController.alreadySelectedList.clear();
    bookingController.idFeatured = widget.idFeatured;
    bookingController.calendarSelectionItemDetails = widget.itemDetails;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('📋 addPostFrameCallback exécuté');
      addAddressController.getDoorStepAddressp(false);

      if (widget.cleanvalue == null) {
        bookingController.clearMethod();
        bookingController.isDateAvailale.value = false;
        bookingController.addDoorStepPrice = false;
        bookingController.selectedStartTime.value = "";
        bookingController.selectedEndTime.value = "";
        bookingController.hindTimeStart.value = "";
        bookingController.hindTimeSEnd.value = "";
        bookingController.isenqablestarttime.value = false;
        bookingController.isenableendTime.value = false;
      } else {
        final start = DateTime.tryParse(bookingController.startDate.value);
        final end = DateTime.tryParse(bookingController.endDate.value);
        if (start != null && end != null) {
          bookingController.dateRangePickerController.displayDate = start;
          // selectedRange après le 1er frame du picker (évite paint sur peer mort).
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            bookingController.dateRangePickerController.selectedRange =
                PickerDateRange(start, end);
          });
          bookingController.isDateAvailale.value = true;
          print(
              '📅 Préremplissage calendrier: ${bookingController.startDate.value} -> ${bookingController.endDate.value}');
        }
      }
      // clearMethod() peut avoir vidé les listes — garder le loader actif.
      bookingController.isLoading.value = true;
      bookingController.idFeatured = widget.idFeatured;
      print('📞 Appel de getData() depuis addPostFrameCallback');
      getData();
    });
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    final date = bookingController.dateRangePickerController.displayDate ??
        DateTime.now();
    final locale = Get.locale?.languageCode ?? 'en';
    final monthName = getMonthName(date.month, locale: locale);
    final yearText = convertToLocaleDigits(
      date.year.toString(),
    );
    return Align(
      alignment: Alignment.center,
      child: Container(
        color: notifires.getbgnextcolor,
        width: Dimensions.containerWidth,
        child: Scaffold(
            bottomNavigationBar: Obx(
              () => bookingController.isDateAvailale.value == false
                  ? const SizedBox()
                  : SafeArea(
                      child: SizedBox(
                        height: 70,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                            onPressed: _openSelectTimeScreen,
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
                                  "Next".tr,
                                  style: heading2(context)
                                      .copyWith(color: bgColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            backgroundColor: notifires.getbgcolor,
            appBar: AppBar(
              leadingWidth: 80,
              centerTitle: true,
              scrolledUnderElevation: 0,
              backgroundColor: notifires.getbgcolor,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton.icon(
                    onPressed: () {
                      bookingController.clearMethod();
                      // Remount Syncfusion pour effacer toute sélection visuelle.
                      setState(() {
                        _calendarDataEpoch++;
                      });
                    },
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      color: getColorBasedOnActiveModuleid(),
                      size: 22,
                    ),
                    label: Text(
                      'Clear'.tr,
                      style: regular2(context).copyWith(
                        color: getColorBasedOnActiveModuleid(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(0, 40),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ),
              ],
              leading: backButton(),
              title: Text(
                'Check Availability'.tr,
                style: heading2Grey1(context).copyWith(),
              ),
            ),
            body: GetBuilder<BookingController>(
              builder: (controller) {
                // Ne jamais remplacer le calendrier par un seul loader : démonter
                // SfDateRangePicker pendant un fetch provoque le crash Syncfusion
                // (drawCustomcellSelection / native peer collected).
                return Stack(
                      children: [
                        if (controller.isLoading.value)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: LinearProgressIndicator(
                              color: getColorBasedOnActiveModuleid(),
                            ),
                          ),
                        SingleChildScrollView(
                            child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(children: [
                            Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Row(
                                children: [
                                  Text("Select Date".tr,
                                      style: heading2(context).copyWith()),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back_ios,
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                  onPressed: () => _navigateCalendarMonth(-1),
                                ),
                                Text("$monthName $yearText",
                                    style: heading2(context)),
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                  onPressed: () => _navigateCalendarMonth(1),
                                ),
                              ],
                            ),
                            GetBuilder<BookingController>(
                              builder: (controller) {
                                final minDays = bookingController
                                        .resolveMinRentalDaysForBooking(
                                            widget.itemDetails) ??
                                    1;
                                return Container(
                                  height: 400,
                                  clipBehavior: Clip.none,
                                  padding: const EdgeInsets.only(left: 8, right: 8),
                                  margin: const EdgeInsets.all(0),
                                  decoration: BoxDecoration(
                                    color: whiteColor,
                                    borderRadius: BorderRadius.circular(0),
                                  ),
                                  child: RepaintBoundary(
                                    child: SfDateRangePicker(
                                      key: ValueKey(
                                        'availability_cal_${widget.idFeatured}_'
                                        '$_calendarDataEpoch',
                                      ),
                                      minDate:
                                          RollingCalendarBounds.firstDate(),
                                      maxDate:
                                          RollingCalendarBounds.lastDate(),
                                      enablePastDates: false,
                                      onViewChanged: (args) {
                                        RollingCalendarBounds.clampPickerView(
                                          args,
                                          bookingController
                                              .dateRangePickerController,
                                        );
                                      },
                                      headerHeight: 0,
                                      headerStyle: DateRangePickerHeaderStyle(
                                        backgroundColor: whiteColor,
                                        textAlign: TextAlign.center,
                                        textStyle: TextStyle(
                                          color: blackColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      monthViewSettings:
                                          DateRangePickerMonthViewSettings(
                                        dayFormat: 'EEE',
                                        showTrailingAndLeadingDates: false,
                                        viewHeaderStyle:
                                            DateRangePickerViewHeaderStyle(
                                          textStyle: TextStyle(
                                            color:
                                                notifires.getGrey3Whitecolor,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      backgroundColor: whiteColor,
                                      allowViewNavigation: false,
                                      controller: bookingController
                                          .dateRangePickerController,
                                      selectionMode:
                                          DateRangePickerSelectionMode.range,
                                      onSelectionChanged: (args) {
                                        bookingController.onSelectionChanged(
                                          args,
                                          itemDetails: widget.itemDetails,
                                        );
                                        if (mounted) {
                                          setState(() {
                                            _selectionEpoch++;
                                          });
                                        }
                                      },
                                      startRangeSelectionColor:
                                          Colors.transparent,
                                      endRangeSelectionColor:
                                          Colors.transparent,
                                      rangeSelectionColor: Colors.transparent,
                                      selectionColor: Colors.transparent,
                                      cellBuilder: (context, cellDetails) {
                                        return _CalendarAvailabilityCell(
                                          key: ValueKey(
                                            '${cellDetails.date.year}-'
                                            '${cellDetails.date.month}-'
                                            '${cellDetails.date.day}-'
                                            '$_selectionEpoch-'
                                            '$_availabilityDataEpoch',
                                          ),
                                          cellDetails: cellDetails,
                                          bookingController: bookingController,
                                          hideDailyPriceForCell:
                                              _hideDailyPriceForCell,
                                          minRentalDays: minDays,
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Row(
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              child: Container(
                                                height: 10,
                                                width: 10,
                                                color: Colors.grey
                                                    .withOpacity(0.35),
                                              )),
                                          const SizedBox(width: 5),
                                          Text(
                                            "Not Available".tr,
                                            style: regular2(context).copyWith(
                                                color: notifires
                                                    .getGrey3Whitecolor),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      ),
                                      Row(
                                        children: [
                                          ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(40),
                                              child: Container(
                                                  height: 10,
                                                  width: 10,
                                                  color: greenback)),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            "Selected for Booking".tr,
                                            style: regular2(context).copyWith(
                                                color: notifires
                                                    .getGrey3Whitecolor),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 6,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text("Trip Start date".tr,
                                        style: heading3(context)),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 6),
                                      child: Text("Trip end date".tr,
                                          style: heading3(context)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      height: 55,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: notifires.getBoxColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/images/Calendar.svg",
                                            height: 25,
                                            width: 25,
                                            colorFilter: ColorFilter.mode(
                                              getColorBasedOnActiveModuleid(),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Obx(
                                            () => Text(
                                                bookingController.startDate
                                                        .toString()
                                                        .isNotEmpty
                                                    ? '${bookingController.startDate}'
                                                    : '---',
                                                style:
                                                    regular2(context).copyWith(
                                                  color: notifires
                                                      .getwhiteblackcolor,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Container(
                                      height: 55,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: notifires.getBoxColor,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          SvgPicture.asset(
                                            "assets/images/Calendar.svg",
                                            height: 25,
                                            width: 25,
                                            colorFilter: ColorFilter.mode(
                                              getColorBasedOnActiveModuleid(),
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Obx(
                                            () => Text(
                                                bookingController.endDate
                                                        .toString()
                                                        .isNotEmpty
                                                    ? '${bookingController.endDate}'
                                                    : '---',
                                                style:
                                                    regular2(context).copyWith(
                                                  color: notifires
                                                      .getwhiteblackcolor,
                                                )),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            widget.itemDetails!.doorStepPrice == "null" ||
                                    widget.itemDetails!.doorStepPrice == null
                                ? const SizedBox()
                                : widget.itemDetails!.doorStepPrice
                                                .toString() ==
                                            "0" ||
                                        widget.itemDetails!.doorStepPrice
                                                .toString() ==
                                            ""
                                    ? const SizedBox()
                                    : Row(
                                        children: [
                                          Checkbox(
                                              checkColor: Colors.white,
                                              activeColor:
                                                  getColorBasedOnActiveModuleid(),
                                              side: BorderSide(
                                                  color: notifires
                                                      .getGrey3Whitecolor,
                                                  width: 2),
                                              value: bookingController
                                                  .addDoorStepPrice,
                                              onChanged: (value) {
                                                if (widget.itemDetails!
                                                        .doorStepPrice
                                                        .toString() ==
                                                    "0") {
                                                  showErrorToastMessage(
                                                      "Cannot add Doorstep price because it is zero."
                                                          .tr);
                                                  return;
                                                }
                                                setState(() {
                                                  bookingController
                                                          .addDoorStepPrice =
                                                      !bookingController
                                                          .addDoorStepPrice;
                                                });
                                              }),
                                          Text(
                                            "${"Add Doorstep Price".tr} : $currency ${widget.itemDetails?.doorStepPrice.toString()}",
                                            style: regular2(context),
                                          )
                                        ],
                                      ),
                            const SizedBox(),
                            bookingController.addDoorStepPrice == false
                                ? const SizedBox()
                                : Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Obx(
                                          () => addAddressController
                                                      .fulladdress.value ==
                                                  ""
                                              ? Expanded(
                                                  child: Text(
                                                    "Add Address to get doorstep service"
                                                        .tr,
                                                    style: regular(context)
                                                        .copyWith(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          getColorBasedOnActiveModuleid(),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines:
                                                        2, // Keeps address compact
                                                  ),
                                                )
                                              : Expanded(
                                                  child: Text(
                                                    addAddressController
                                                            .fulladdress
                                                            .value
                                                            .isNotEmpty
                                                        ? addAddressController
                                                            .fulladdress.value
                                                        : "${addAddressController.addressLabelController.text.isNotEmpty ? "${addAddressController.addressLabelController.text} · " : ""}${addAddressController.fullAddressController.text}",
                                                    style: regular(context)
                                                        .copyWith(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color:
                                                          getColorBasedOnActiveModuleid(),
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(width: 10),
                                        GestureDetector(
                                          onTap: () {
                                            addAddressController
                                                .preventDate.value = true;
                                            showPopUpScreen(
                                                context,
                                                PickAddressWitjhMap(
                                                  isback: "back",
                                                ));
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color:
                                                  getColorBasedOnActiveModuleid(),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: GetStorage().read(
                                                        "customerAddress") ==
                                                    null
                                                ? const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 20,
                                                  )
                                                : const Icon(
                                                    Icons.edit,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            const SizedBox(
                              height: 96,
                            ),
                          ]),
                        )),
                        Obx(
                          () => bookingController.isDateChecking.value == true
                              ? Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              color:
                                                  getColorBasedOnActiveModuleid(),
                                            ),
                                            child:
                                                const CircularProgressIndicator(
                                                    color: Colors.white)),
                                      ],
                                    ),
                                  ],
                                )
                              : const SizedBox(),
                        ),
                      ],
                    );
              },
            ),
        ),
      ),
    );
  }
}

/// Cellule calendrier : lit les listes du [BookingController] à chaque build
/// (pas de FutureBuilder — il figeait le 1er rendu sans prix/disponibilités).
class _CalendarAvailabilityCell extends StatelessWidget {
  final DateRangePickerCellDetails cellDetails;
  final BookingController bookingController;
  final bool Function(DateTime) hideDailyPriceForCell;
  final int minRentalDays;

  const _CalendarAvailabilityCell({
    super.key,
    required this.cellDetails,
    required this.bookingController,
    required this.hideDailyPriceForCell,
    required this.minRentalDays,
  });

  DateTime? _parseDay(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;
    return DateTime(parsed.year, parsed.month, parsed.day);
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Date de départ effective : picker Syncfusion en priorité, puis [startDate].
  DateTime? _resolveSelectedStartDate() {
    final range = bookingController.dateRangePickerController.selectedRange;
    final fromPicker = range?.startDate;
    if (fromPicker != null) {
      return _dateOnly(fromPicker);
    }
    if (bookingController.startDate.value.isNotEmpty) {
      return _parseDay(bookingController.startDate.value);
    }
    return null;
  }

  /// Date de fin effective : picker Syncfusion en priorité, puis [endDate].
  DateTime? _resolveSelectedEndDate() {
    final range = bookingController.dateRangePickerController.selectedRange;
    final fromPicker = range?.endDate;
    if (fromPicker != null) {
      return _dateOnly(fromPicker);
    }
    if (bookingController.endDate.value.isNotEmpty) {
      return _parseDay(bookingController.endDate.value);
    }
    return null;
  }

  bool _isInSelectedRange(DateTime cellDate) {
    final start = _resolveSelectedStartDate();
    if (start == null) return false;
    final end = _resolveSelectedEndDate();
    if (end == null) {
      return _sameDay(cellDate, start);
    }
    return !cellDate.isBefore(start) && !cellDate.isAfter(end);
  }

  bool _isRangeStartCell(DateTime cellDate) {
    final start = _resolveSelectedStartDate();
    return start != null && _sameDay(cellDate, start);
  }

  bool _isRangeEndCell(DateTime cellDate) {
    final start = _resolveSelectedStartDate();
    final end = _resolveSelectedEndDate();
    if (start == null || end == null || _sameDay(start, end)) return false;
    return _sameDay(cellDate, end);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final cellDate = DateTime(
      cellDetails.date.year,
      cellDetails.date.month,
      cellDetails.date.day,
    );

    final isDateAvailable = bookingController.availableDates.any(
      (d) => _sameDay(d, cellDate),
    );

    final isInAlreadySelectedList = bookingController.alreadySelectedList.any(
      (d) => _sameDay(d, cellDate),
    );

    String? priceText;
    if (!hideDailyPriceForCell(cellDate) && isDateAvailable) {
      var index = -1;
      for (var i = 0; i < bookingController.availableDates.length; i++) {
        final d = bookingController.availableDates[i];
        if (_sameDay(d, cellDate)) {
          index = i;
          break;
        }
      }

      if (index != -1 && index < bookingController.availableDatesPrice.length) {
        final priceValue = bookingController.availableDatesPrice[index];
        double? price;
        if (priceValue is String) {
          price = double.tryParse(priceValue.replaceAll(',', ''));
        } else if (priceValue is int || priceValue is double) {
          price = priceValue.toDouble();
        }
        if (price != null) {
          priceText = '$currency ${price.toInt()}';
          if (priceText.length > 8) {
            priceText = priceText.substring(0, 8);
          }
        }
      }
      priceText ??= 'MAD 1000';
    }

    final today = DateTime(now.year, now.month, now.day);
    final outsideWindow = !RollingCalendarBounds.isWithinWindow(cellDate);
    final isPast = cellDate.isBefore(today);
    final isUnavailable = isPast ||
        outsideWindow ||
        !isDateAvailable ||
        isInAlreadySelectedList;

    // Le cellBuilder remplace le rendu Syncfusion : plage visible ici.
    final isInSelectedRange = _isInSelectedRange(cellDate);
    final isRangeStart = _isRangeStartCell(cellDate);
    final isRangeEnd = _isRangeEndCell(cellDate);
    final isRangeMiddle = isInSelectedRange && !isRangeStart && !isRangeEnd;

    final Color cellColor;
    if (isRangeStart || isRangeEnd) {
      cellColor = greenback;
    } else if (isRangeMiddle) {
      cellColor = greenback.withOpacity(0.38);
    } else if (isUnavailable) {
      cellColor = Colors.grey.withOpacity(0.18);
    } else {
      cellColor = Colors.white;
    }

    final dayTextColor = isRangeStart || isRangeEnd
        ? Colors.white
        : isRangeMiddle
            ? const Color(0xFF1B5E20)
            : isUnavailable
                ? Colors.grey.shade500
                : Colors.black;

    final showMinDaysBadge = isRangeStart && minRentalDays > 1;

    return SizedBox.expand(
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isInSelectedRange
                    ? greenback.withOpacity(isRangeMiddle ? 0.55 : 1)
                    : isUnavailable
                        ? Colors.grey.shade300
                        : grey5,
              ),
              color: cellColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  convertToLocaleDigits(cellDetails.date.day.toString()),
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'InterMedium',
                    color: dayTextColor,
                    decoration: isUnavailable && !isInSelectedRange
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),
                if (priceText != null)
                  Text(
                    convertToLocaleDigits(priceText),
                    style: regular(context).copyWith(
                      fontSize: 9,
                      color: isRangeStart || isRangeEnd
                          ? Colors.white.withOpacity(0.9)
                          : isRangeMiddle
                              ? const Color(0xFF2E7D32)
                              : isUnavailable
                                  ? Colors.grey.shade400
                                  : grey2,
                    ),
                  ),
              ],
            ),
          ),
          if (showMinDaysBadge)
            Positioned(
              top: -26,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: _MinRentalStartBadge(days: minRentalDays),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Badge ancré au-dessus du premier jour de la plage sélectionnée.
class _MinRentalStartBadge extends StatelessWidget {
  final int days;
  const _MinRentalStartBadge({required this.days});

  @override
  Widget build(BuildContext context) {
    final color = getColorBasedOnActiveModuleid();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            'calendar_min_days_badge'.trParams({
              'days': days.toString(),
            }),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(10, 6),
          painter: _DownArrowPainter(color),
        ),
      ],
    );
  }
}

class _DownArrowPainter extends CustomPainter {
  final Color color;
  _DownArrowPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _DownArrowPainter oldDelegate) =>
      oldDelegate.color != color;
}
