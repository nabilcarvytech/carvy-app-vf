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

  /// Ancre le badge « Min. X jours » au-dessus du premier jour sélectionné.
  final LayerLink _minDaysBadgeLink = LayerLink();
  
  /// Incrémenté à chaque chargement réussi pour forcer un remount Syncfusion.
  int _calendarDataEpoch = 0;

  bool _isStartDateCell(DateTime cellDate) {
    DateTime? start;
    if (bookingController.startDate.value.isNotEmpty) {
      start = DateTime.tryParse(bookingController.startDate.value);
    }
    start ??=
        bookingController.dateRangePickerController.selectedRange?.startDate;
    if (start == null) return false;
    return start.year == cellDate.year &&
        start.month == cellDate.month &&
        start.day == cellDate.day;
  }

  Future<void> getData() async {
    print('📅 getData() appelé avec idFeatured: ${widget.idFeatured}');
    try {
      await bookingController.fetchDataCalendar(widget.idFeatured);
      print('✅ fetchDataCalendar terminé');
      if (!mounted) return;
      // Force un nouveau SfDateRangePicker : les cellBuilder Syncfusion ne se
      // rafraîchissent pas toujours via GetBuilder seul.
      setState(() {
        _calendarDataEpoch++;
      });
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
          bookingController.dateRangePickerController.selectedRange =
              PickerDateRange(start, end);
          bookingController.dateRangePickerController.displayDate = start;
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
                if (controller.isLoading.value) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: LinearProgressIndicator(
                      color: getColorBasedOnActiveModuleid(),
                    ),
                  );
                }
                return Stack(
                      children: [
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
                                  onPressed: () {
                                    final newDate =
                                        DateTime(date.year, date.month - 1, 1);
                                    bookingController.dateRangePickerController
                                        .displayDate = newDate;
                                    setState(() {});
                                  },
                                ),
                                Text("$monthName $yearText",
                                    style: heading2(context)),
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_forward_ios,
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                  onPressed: () {
                                    final newDate =
                                        DateTime(date.year, date.month + 1, 1);
                                    bookingController.dateRangePickerController
                                        .displayDate = newDate;
                                    setState(() {});
                                  },
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
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      SfDateRangePicker(
                                        key: ValueKey(
                                          'availability_cal_${widget.idFeatured}_$_calendarDataEpoch',
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
                                        headerStyle:
                                            DateRangePickerHeaderStyle(
                                          backgroundColor: whiteColor,
                                          textAlign: TextAlign.center,
                                          textStyle: TextStyle(
                                            color: blackColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: whiteColor,
                                        allowViewNavigation: false,
                                        controller: bookingController
                                            .dateRangePickerController,
                                        selectionMode:
                                            DateRangePickerSelectionMode.range,
                                        onSelectionChanged: (args) =>
                                            bookingController
                                                .onSelectionChanged(
                                          args,
                                          itemDetails: widget.itemDetails,
                                        ),
                                        startRangeSelectionColor:
                                            Colors.transparent,
                                        endRangeSelectionColor:
                                            Colors.transparent,
                                        rangeSelectionColor:
                                            Colors.transparent,
                                        selectionColor: Colors.transparent,
                                        cellBuilder: (context, cellDetails) {
                                          final cell =
                                              _CalendarAvailabilityCell(
                                            cellDetails: cellDetails,
                                            bookingController:
                                                bookingController,
                                            hideDailyPriceForCell:
                                                _hideDailyPriceForCell,
                                          );
                                          if (minDays <= 1 ||
                                              !_isStartDateCell(
                                                  cellDetails.date)) {
                                            return cell;
                                          }
                                          return CompositedTransformTarget(
                                            link: _minDaysBadgeLink,
                                            child: cell,
                                          );
                                        },
                                      ),
                                      Positioned(
                                        left: 0,
                                        top: 0,
                                        child: Obx(() {
                                          final hasSelection =
                                              bookingController
                                                  .startDate.value.isNotEmpty;
                                          if (!hasSelection || minDays <= 1) {
                                            return const SizedBox.shrink();
                                          }
                                          return CompositedTransformFollower(
                                            link: _minDaysBadgeLink,
                                            showWhenUnlinked: false,
                                            targetAnchor: Alignment.topCenter,
                                            followerAnchor:
                                                Alignment.bottomCenter,
                                            offset: const Offset(0, -2),
                                            child: IgnorePointer(
                                              child: _MinRentalStartBadge(
                                                days: minDays,
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ],
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
                                                color: pc1.withOpacity(.4),
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

  const _CalendarAvailabilityCell({
    required this.cellDetails,
    required this.bookingController,
    required this.hideDailyPriceForCell,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final cellDate = DateTime(
      cellDetails.date.year,
      cellDetails.date.month,
      cellDetails.date.day,
    );

    final isDateAvailable = bookingController.availableDates.any((d) =>
        d.year == cellDate.year &&
        d.month == cellDate.month &&
        d.day == cellDate.day);

    final isInAlreadySelectedList =
        bookingController.alreadySelectedList.any((d) =>
            d.year == cellDate.year &&
            d.month == cellDate.month &&
            d.day == cellDate.day);

    String? priceText;
    if (!hideDailyPriceForCell(cellDate) && isDateAvailable) {
      var index = -1;
      for (var i = 0; i < bookingController.availableDates.length; i++) {
        final d = bookingController.availableDates[i];
        if (d.year == cellDate.year &&
            d.month == cellDate.month &&
            d.day == cellDate.day) {
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
    final isPastOrUnavailable = (cellDate.isBefore(today) && cellDate != today) ||
        outsideWindow ||
        !isDateAvailable;

    Color cellColor = Colors.transparent;
    if (isPastOrUnavailable) {
      cellColor = Colors.grey.withOpacity(0.2);
    } else if (isInAlreadySelectedList) {
      cellColor = pc1.withOpacity(.4);
    } else if (bookingController.startDate.value.isNotEmpty) {
      final start = DateTime.tryParse(bookingController.startDate.value);
      if (start != null &&
          start.year == cellDate.year &&
          start.month == cellDate.month &&
          start.day == cellDate.day) {
        cellColor = greenback;
      }
    }
    if (cellColor == Colors.transparent &&
        bookingController.endDate.value.isNotEmpty) {
      final end = DateTime.tryParse(bookingController.endDate.value);
      if (end != null &&
          end.year == cellDate.year &&
          end.month == cellDate.month &&
          end.day == cellDate.day) {
        cellColor = greenback;
      }
    }
    if (cellColor == Colors.transparent &&
        bookingController.startDate.value.isNotEmpty &&
        bookingController.endDate.value.isNotEmpty) {
      final start = DateTime.tryParse(bookingController.startDate.value);
      final end = DateTime.tryParse(bookingController.endDate.value);
      if (start != null &&
          end != null &&
          start.isBefore(cellDate) &&
          end.isAfter(cellDate)) {
        cellColor = greenback;
      }
    }

    return Container(
      margin: const EdgeInsets.all(1),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: grey5),
        color: cellColor,
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              convertToLocaleDigits(cellDetails.date.day.toString()),
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'InterMedium',
                color: isPastOrUnavailable
                    ? Colors.grey.shade600
                    : isInAlreadySelectedList
                        ? Colors.white
                        : isDateAvailable
                            ? Colors.black
                            : Colors.grey.shade600,
                decoration: isPastOrUnavailable
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            if (priceText != null)
              Text(
                convertToLocaleDigits(priceText),
                style: regular(context).copyWith(
                  fontSize: 9,
                  color: isPastOrUnavailable ? Colors.grey.shade500 : grey2,
                ),
              ),
          ],
        ),
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
