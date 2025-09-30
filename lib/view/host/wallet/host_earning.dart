import 'package:flutter/cupertino.dart';
import 'package:get/utils.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/vendor_earning_model_dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';

class HostEarning extends StatefulWidget {
  const HostEarning({super.key});

  @override
  State<HostEarning> createState() => _HostEarningState();
}

class _HostEarningState extends State<HostEarning> {
  final DateRangePickerController _datePickerController =
      DateRangePickerController();
  final DateRangePickerController customDatePickerController =
      DateRangePickerController();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String totalEarning = "0.0";
  String totalBooking = "0";
  final List<String> _rangeOptions = [
    "Today",
    "Last 7 Days",
    "Last 30 Days",
    "This Month",
    "Custom",
  ];
  String _selectedRange = 'Today';
  DateTime? _startDate;
  DateTime? _endDate;
  bool isLoading = false;
  int offset = 0;
  int limit = 10;

  VendorEarning? vendorEarningModel;
  List<VendorBookings> list = [];

  @override
  void initState() {
    super.initState();
    _setDateRange('Today');
    getData(isRefresh: true);
  }

  Future<void> getData({bool isRefresh = false}) async {
    setState(() {
      isLoading = true;
    });

    var mapData = {
      'offset': "$offset",
      'limit': "$limit",
      'startDate':
          DateFormat('yyyy-MM-dd').format(_startDate ?? DateTime.now()),
      'endDate': DateFormat('yyyy-MM-dd').format(_endDate ?? DateTime.now()),
    };

    try {
      final response = await httpPost(Config.getVendorEarings, mapData);
      if (response != null) {
        vendorEarningModel = VendorEarning.fromJson(response);

        setState(() {
          if (isRefresh) {
            list.clear();
          }

          if (vendorEarningModel?.data?.vendorBookings != null) {
            list.addAll(vendorEarningModel!.data!.vendorBookings!);
          }

          offset = vendorEarningModel?.data?.offset ?? offset;
          totalEarning =
              (vendorEarningModel?.data?.totalEarnings ?? 0).toStringAsFixed(1);
          totalBooking =
              (vendorEarningModel?.data?.totalBookings ?? 0).toString();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch earnings'.tr)),
        );
      }
      // ignore: empty_catches
    } catch (e) {
    } finally {
      setState(() {
        isLoading = false;
      });
      if (isRefresh) {
        _refreshController.refreshCompleted();
      } else {
        if (vendorEarningModel?.data?.offset == -1) {
          _refreshController.loadNoData();
        } else {
          _refreshController.loadComplete();
        }
      }
    }
  }

  void _setDateRange(String range) {
    DateTime now = DateTime.now();
    setState(() {
      _selectedRange = range;
      switch (range) {
        case 'Today':
          _startDate = now;
          _endDate = now;
          break;
        case 'Last 7 Days':
          _startDate = now.subtract(const Duration(days: 6));
          _endDate = now;
          break;
        case 'Last 30 Days':
          _startDate = now.subtract(const Duration(days: 29));
          _endDate = now;
          break;
        case 'This Month':
          _startDate = DateTime(now.year, now.month, 1);
          _endDate = now;
          break;
        case 'Custom':
          _showCustomDateRangePicker();
          return;
      }
      offset = 0;
      list.clear();
    });
    getData(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final date = _datePickerController.displayDate ?? DateTime.now();
    final locale = Get.locale?.languageCode ?? 'en';
    final monthName = getMonthName(date.month, locale: locale);
    final yearText = convertToLocaleDigits(
      date.year.toString(),
    );
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        enablePullUp: vendorEarningModel?.data?.offset != -1,
        onRefresh: () async {
          offset = 0;
          getData(isRefresh: true);
        },
        onLoading: () async {
          offset += limit;
          getData();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: getColorBasedOnActiveModuleid(),
                      ),
                      onPressed: () {
                        final newDate = DateTime(date.year, date.month - 1, 1);
                        _datePickerController.displayDate = newDate;
                        setState(() {});
                      },
                    ),

                    Text("$monthName $yearText", style: heading2(context)),

                    // Next button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: getColorBasedOnActiveModuleid(),
                      ),
                      onPressed: () {
                        final newDate = DateTime(date.year, date.month + 1, 1);
                        _datePickerController.displayDate = newDate;
                        setState(() {});
                      },
                    ),
                  ],
                ),
                Container(
                  color: notifires.getbgcolor,
                  alignment: Alignment.center,
                  height: 130,
                  child: SfDateRangePicker(
                    backgroundColor: notifires.getbgcolor,
                    controller: _datePickerController,
                    view: DateRangePickerView.month,
                    selectionMode: DateRangePickerSelectionMode.single,
                    initialSelectedDate: _startDate,
                    showNavigationArrow: true,
                    allowViewNavigation: false,
                    headerHeight: 0,
                    headerStyle: DateRangePickerHeaderStyle(
                      backgroundColor: notifires.getbgcolor,
                      textAlign: TextAlign.center,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    monthViewSettings: const DateRangePickerMonthViewSettings(
                      numberOfWeeksInView: 1,
                      enableSwipeSelection: false,
                      dayFormat: '',
                      viewHeaderHeight: 0,
                    ),
                    maxDate: DateTime.now(),
                    enablePastDates: true,
                    showTodayButton: false,
                    selectionColor: Colors.transparent,
                    startRangeSelectionColor: Colors.transparent,
                    endRangeSelectionColor: Colors.transparent,
                    rangeSelectionColor: Colors.transparent,
                    onSelectionChanged:
                        (DateRangePickerSelectionChangedArgs args) {
                      if (args.value is DateTime) {
                        setState(() {
                          _selectedRange = 'Custom';
                          _startDate = args.value;
                          _endDate = args.value;
                          _datePickerController.selectedDate = args.value;
                          offset = 0;
                          list.clear();
                        });
                        getData(isRefresh: true);
                      }
                    },
                    cellBuilder: (context, cellDetails) {
                      final isSelected = isSameDate(
                          _datePickerController.selectedDate, cellDetails.date);
                      final now = DateTime.now();
                      final today = DateTime(now.year, now.month, now.day);
                      final isTodayOrPast = !cellDetails.date.isAfter(today);
                      return IgnorePointer(
                        ignoring: !isTodayOrPast,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected && isTodayOrPast
                                ? themeColor
                                : isTodayOrPast
                                    ? Colors.transparent
                                    : grey5,
                            border: Border.all(
                              color: isTodayOrPast
                                  ? themeColor.withOpacity(0.3)
                                  : notifires.getBoxColor,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                getWeekdayName(cellDetails.date.weekday,
                                    locale: locale),
                                style: regular2(context),
                              ),
                              Text(
                                convertToLocaleDigits(
                                    cellDetails.date.day.toString()),
                                style: regular2(context).copyWith(
                                  color: isSelected && isTodayOrPast
                                      ? whiteColor
                                      : isTodayOrPast
                                          ? notifires.getwhiteblackcolor
                                          : notifires.getGrey4Whitecolor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (_startDate != null && _endDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_startDate.toString() !=
                                    _endDate.toString())
                                  Text(
                                    "From".tr,
                                    style: regular(context),
                                  ),
                                Text(
                                  DateFormat('dd MMM yyyy').format(_startDate!),
                                  style: regular(context),
                                ),
                              ],
                            ),
                          ),
                        if (_startDate.toString() != _endDate.toString())
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "To".tr, // Added translation
                                  style: regular(context),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy').format(_endDate!),
                                  style: regular(context),
                                ),
                              ],
                            ),
                          ),
                        GestureDetector(
                          onTap: () {
                            showMenu(
                              color: notifires.getbgcolor,
                              context: context,
                              position: const RelativeRect.fromLTRB(
                                  100, 200, 16, 100),
                              items: _rangeOptions.map((option) {
                                IconData iconData;
                                switch (option) {
                                  case 'Today':
                                    iconData = Icons.today;
                                    break;
                                  case 'Last 7 Days':
                                    iconData = Icons.calendar_view_week;
                                    break;
                                  case 'Last 30 Days':
                                    iconData = Icons.calendar_month;
                                    break;
                                  case 'This Month':
                                    iconData = Icons.date_range;
                                    break;
                                  case 'Custom':
                                    iconData = Icons.edit_calendar;
                                    break;
                                  default:
                                    iconData = Icons.calendar_today;
                                }
                                return PopupMenuItem<String>(
                                  value: option,
                                  child: Row(
                                    children: [
                                      Icon(iconData, color: themeColor),
                                      const SizedBox(width: 10),
                                      Text(
                                        option.tr, // Added translation
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                notifires.getGrey1Whitecolor),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ).then((val) {
                              if (val != null) _setDateRange(val);
                            });
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: notifires.getBoxColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.filter_list,
                                    color: getColorBasedOnActiveModuleid()),
                                const SizedBox(width: 10),
                                Text(
                                  _selectedRange.tr, // Added translation
                                  style: regular2(context),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (isLoading) LinearProgressIndicator(color: themeColor),
                const SizedBox(height: 20),
                if (!isLoading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCard(
                        "$currency ${vendorEarningModel?.data?.totalEarnings ?? 0}",
                        "Total Earnings".tr, // Added translation
                      ),
                      const SizedBox(width: 12),
                      _buildCard(
                        "${vendorEarningModel?.data?.totalBookings ?? 0}",
                        "Total Bookings".tr, // Added translation
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                if (!isLoading)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Recent Transactions".tr, // Added translation
                          style: regular2(context),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                if (!isLoading)
                  vendorEarningModel == null
                      ? Center(
                          child:
                              Text("No data available".tr)) // Added translation
                      : list.isEmpty
                          ? Center(
                              child: Text("No transactions found"
                                  .tr)) // Added translation
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              separatorBuilder: (context, index) =>
                                  Divider(color: grey5),
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final VendorBookings data = list[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Add navigation logic if needed
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 15),
                                    decoration: BoxDecoration(
                                      color: notifires.getBoxColor,
                                      borderRadius: BorderRadius.circular(12.0),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              (data.status ?? ""),
                                              style: regular2(
                                                  context), // Added translation and capitalization

                                              softWrap: true,
                                            ),
                                            Text(
                                              "Booking Id ${data.id}",
                                              style: regular2(
                                                  context), // Added translation and capitalization

                                              softWrap: true,
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  data.checkIn ?? "",
                                                  style: regular(context)
                                                      .copyWith(fontSize: 12),
                                                  softWrap: true,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              "$currency ${data.vendorCommission ?? '0'}",
                                              style: heading1(context).copyWith(
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard(String value, String label) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: notifires.getBoxColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.tr, // Added translation
            style: regular2(context).copyWith(fontSize: 18),
          ),
          const SizedBox(height: 5),
          Text(
            label.tr, // Added translation
            style: regular(context),
          ),
        ],
      ),
    );
  }

  bool isSameDate(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showCustomDateRangePicker() {
    showModalBottomSheet(
      backgroundColor: notifires.getbgcolor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        DateTime? tempStart;
        DateTime? tempEnd;

        return StatefulBuilder(
          builder: (context, setModalState) {
            final date =
                customDatePickerController.displayDate ?? DateTime.now();
            final locale = Get.locale?.languageCode ?? 'en';
            final monthName = getMonthName(date.month, locale: locale);
            final yearText = convertToLocaleDigits(date.year.toString());
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Select Custom Date Range".tr, // Added translation
                    style: heading2(context).copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    color: notifires.getboxcolor,
                    height: 400,
                    child: SfDateRangePicker(
                      headerStyle: const DateRangePickerHeaderStyle(),
                      monthCellStyle: DateRangePickerMonthCellStyle(
                        todayTextStyle: TextStyle(color: themeColor),
                        weekendTextStyle: TextStyle(color: themeColor),
                      ),
                      monthViewSettings: DateRangePickerMonthViewSettings(
                        dayFormat:
                            '', // Remove default 'EEE' to use custom cellBuilder for weekdays
                        viewHeaderStyle: DateRangePickerViewHeaderStyle(
                          textStyle:
                              TextStyle(color: notifires.getwhiteblackcolor),
                        ),
                        viewHeaderHeight: 40, // Add height for weekday headers
                      ),
                      backgroundColor: notifires.getboxcolor,
                      maxDate: DateTime(
                          DateTime.now().year,
                          DateTime.now().month + 1,
                          0), // Restrict navigation to current month
                      controller: customDatePickerController,
                      selectionMode: DateRangePickerSelectionMode.range,
                      startRangeSelectionColor: Colors.transparent,
                      endRangeSelectionColor: Colors.transparent,
                      rangeSelectionColor: Colors.transparent,
                      selectionColor: Colors.transparent,
                      allowViewNavigation: false, // Prevent manual navigation
                      navigationDirection:
                          DateRangePickerNavigationDirection.horizontal,
                      onViewChanged: (DateRangePickerViewChangedArgs args) {
                        final DateTime visibleDate =
                            args.visibleDateRange.startDate!;
                        final DateTime now = DateTime.now();
                        final DateTime maxDate = DateTime(now.year,
                            now.month + 1, 0); // Last day of current month
                        if (visibleDate.isAfter(maxDate)) {
                          // Prevent navigation to future months
                          customDatePickerController.displayDate = maxDate;
                        }
                      },
                      onSelectionChanged:
                          (DateRangePickerSelectionChangedArgs args) {
                        if (args.value is PickerDateRange) {
                          final PickerDateRange range = args.value;
                          setModalState(() {
                            if (range.startDate != null &&
                                range.endDate != null) {
                              tempStart = range.startDate!;
                              tempEnd = range.endDate!;
                            }
                          });

                          if (tempStart != null && tempEnd != null) {
                            setState(() {
                              _selectedRange = 'Custom';
                              _startDate = tempStart;
                              _endDate = tempEnd;
                              offset = 0;
                              list.clear();
                            });
                            getData(isRefresh: true);
                            Navigator.pop(context);
                          }
                        }
                      },
                      cellBuilder: (context, details) {
                        final now = DateTime.now();
                        final today = DateTime(now.year, now.month, now.day);
                        final isToday = isSameDate(details.date, today);
                        final range = customDatePickerController.selectedRange;
                        bool isSelected = false;

                        if (range != null) {
                          DateTime? start = range.startDate;
                          DateTime? end = range.endDate ??
                              start; // If only one date selected
                          if (start != null && end != null) {
                            if (isSameDate(details.date, start) ||
                                isSameDate(details.date, end) ||
                                (details.date.isAfter(start) &&
                                    details.date.isBefore(end))) {
                              isSelected = true;
                            }
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? getColorBasedOnActiveModuleid()
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                getWeekdayName(details.date.weekday,
                                    locale: Get.locale?.languageCode ?? 'en'),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                          ? themeColor
                                          : notifires.getwhiteblackcolor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                convertToLocaleDigits("${details.date.day}"),
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : isToday
                                          ? themeColor
                                          : notifires.getwhiteblackcolor,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  // SfDateRangePicker(
                  //   controller: customDatePickerController,
                  //   selectionMode: DateRangePickerSelectionMode.range,
                  //   showActionButtons: true,
                  //   maxDate: DateTime.now(),
                  //   onSelectionChanged:
                  //       (DateRangePickerSelectionChangedArgs args) {
                  //     if (args.value is PickerDateRange) {
                  //       final PickerDateRange range = args.value;
                  //       setModalState(() {
                  //         if (range.startDate != null &&
                  //             range.endDate != null) {
                  //           tempStart = range.startDate!;
                  //           tempEnd = range.endDate!;
                  //         }
                  //       });
                  //     }
                  //   },
                  //   onCancel: () => Navigator.pop(context),
                  //   onSubmit: (val) {
                  //     if (tempStart != null && tempEnd != null) {
                  //       setState(() {
                  //         _selectedRange = 'Custom';
                  //         _startDate = tempStart;
                  //         _endDate = tempEnd;
                  //         offset = 0;
                  //         list.clear(); // Clear list instead of transactionList
                  //       });
                  //       getData(
                  //           isRefresh:
                  //               true);
                  //       Navigator.pop(context);
                  //     }
                  //   },
                  // ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _datePickerController.dispose();
    customDatePickerController.dispose();
    super.dispose();
  }
}
