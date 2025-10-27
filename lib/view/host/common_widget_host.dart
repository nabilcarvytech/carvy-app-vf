import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/custom_bottom_sheet.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/add_rules_model.dart';
import 'package:carvy/model/booking_model.dart';
import 'package:carvy/model/cancellation_policies_model.dart';
import 'package:carvy/model/cancellation_reason_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/utils/vehicle_common_widgets.dart';
import 'package:carvy/view/chat/conversation_screen.dart';
import 'package:carvy/view/digitalsignatuecommon/digital_singnature.dart';
import 'package:carvy/view/host/host_e_receipt.dart';
import 'package:carvy/view/host/hostsearch/host_search_screen.dart';
import 'package:carvy/view/itemdetail/vehicle/vehicle_detail_screen.dart';
import 'package:carvy/work_space.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/vehicle_home_model.dart';

class EditContainer extends StatelessWidget {
  final String? subtitle;
  final VoidCallback? onTap;
  final String? title;
  final Icon? icon;
  final Color? bgcolor;
  final ScreenMode? mode;
  final EditOptions? op1;
  final EditOptions? op2;
  final EditOptions? op3;

  const EditContainer(
      {super.key,
      this.icon,
      this.onTap,
      this.subtitle,
      this.bgcolor,
      this.title,
      this.mode,
      this.op1,
      this.op2,
      this.op3});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: Dimensions.paddingSizeDefault,
            vertical: Dimensions.paddingSizeDefault),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: bgcolor,
            // border: Border.all(color: notifires.getwhiteblackcolor),
            borderRadius: BorderRadius.circular(12)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              SvgPicture.asset(
                "assets/images/capture.svg",
                colorFilter: ColorFilter.mode(
                    notifires.getGrey1Whitecolor, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                    overflow: TextOverflow.ellipsis,
                    // 'Describe your place',
                    title ?? "",
                    style: heading3Grey1(context)),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            // "Beds, bathrooms, amenities and \nmore..",
            subtitle ?? "",
            style: regular2(context),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              Divider(
                color: notifires.getGrey5Whitecolor,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: onTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Edit'.tr,
                        style: boldstyle(context).copyWith(
                            color: getColorBasedOnActiveModuleid(),
                            decoration: TextDecoration.underline,
                            decorationColor: getColorBasedOnActiveModuleid())),
                    const SizedBox(width: 5),
                  ],
                ),
              )
            ],
          )
        ]),
      ),
    );
  }
}

class BottomHosts extends StatefulWidget {
  final VoidCallback? onTap;
  final double? progress;
  final String? txt;
  final String? backButtontxt;
  final VoidCallback? backOnPressed;
  const BottomHosts({
    super.key,
    this.onTap,
    this.txt,
    this.backButtontxt,
    this.backOnPressed,
    this.progress,
  });

  @override
  State<BottomHosts> createState() => _BottomHostsState();
}

class _BottomHostsState extends State<BottomHosts> {
  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 100,
      padding: const EdgeInsets.all(0),
      shadowColor: const Color.fromARGB(1, 230, 14, 14),
      color: notifires.getbgcolor,
      surfaceTintColor: notifires.getbgcolor,
      child: Column(
        children: [
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 17, right: 15),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    child: GestureDetector(
                      onTap: widget.backOnPressed,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: getColorBasedOnActiveModuleid()),
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            color: getColorBasedOnActiveModuleid()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset("assets/images/arrowback.svg"),
                            const SizedBox(width: 20),
                            Text(
                              widget.backButtontxt ?? "",
                              style:
                                  heading2(context).copyWith(color: whiteColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 60,
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    child: GestureDetector(
                      onTap: widget.onTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: Dimensions.paddingSizeDefault,
                            vertical: Dimensions.paddingSizeSmall),
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: getColorBasedOnActiveModuleid()),
                            borderRadius:
                                BorderRadius.circular(Dimensions.radiusDefault),
                            color: getColorBasedOnActiveModuleid()),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.txt ?? "",
                              style:
                                  heading2(context).copyWith(color: whiteColor),
                            ),
                            const SizedBox(width: 20),
                            SvgPicture.asset("assets/images/arrowNext.svg")
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppText extends StatelessWidget {
  final String? txt;
  const AppText({super.key, this.txt});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: Padding(
        padding: const EdgeInsets.only(left: 18),
        child: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: featuresBoxHost()),
      ),
      backgroundColor: notifires.getAppBarcolor,
      surfaceTintColor: notifires.getAppBarcolor,
      flexibleSpace: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 25, top: 65),
                child: Text(
                  txt ?? "",
                  softWrap: true,
                  style: heading1(context),

                  // textAlign: TextAlign.left,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class CustomDropdownHost extends StatefulWidget {
  final List options;
  final String hintText;
  final Function(String) onSelected;
  final Color checkmarkColor;
  final String? heading;
  final ScreenMode? mode;
  final dynamic selectedEditInitialValue;
  final bool? removeAll;
  final bool? clearDataonVehgicletype;

  const CustomDropdownHost({
    super.key,
    this.mode,
    this.heading,
    required this.options,
    required this.onSelected,
    required this.checkmarkColor,
    this.hintText = 'Select One',
    this.selectedEditInitialValue,
    this.removeAll,
    this.clearDataonVehgicletype,
  });

  @override
  CustomDropdownHostState createState() => CustomDropdownHostState();
}

class CustomDropdownHostState extends State<CustomDropdownHost> {
  String? selectedValue;
  int? selectedId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Ensure that getValue is called after build
      getValue();
    });
  }

  @override
  void didUpdateWidget(CustomDropdownHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options != oldWidget.options ||
        widget.selectedEditInitialValue != oldWidget.selectedEditInitialValue ||
        widget.clearDataonVehgicletype != oldWidget.clearDataonVehgicletype) {
      getValue();
    }
  }

  void getValue() {
    setState(() {
      if (widget.clearDataonVehgicletype == true) {
        selectedValue = null;
        selectedId = null;
      } else {
        String? result;
        for (var element in widget.options) {
          if (element.id.toString() == widget.selectedEditInitialValue) {
            result = element.name;
            selectedId = element.id;
            break;
          }
        }
        selectedValue = result;
      }
    });
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: notifires.getbgcolor,
      shape: const BeveledRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        List<dynamic> filteredOptions = List.from(widget.options);

        if (widget.removeAll == true) {
          filteredOptions
              .removeWhere((element) => element.name.contains("All"));
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(color: greyColor2.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Text(
                    widget.heading ?? "",
                    style: heading3Grey1(context),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: notifires.getwhiteblackcolor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: filteredOptions.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isSelected = filteredOptions[index].id == selectedId;
                  return Container(
                    color: isSelected ? Colors.transparent : Colors.transparent,
                    child: ListTile(
                      title: Text(
                        filteredOptions[index].name,
                        style: regular2(context),
                      ),
                      trailing: (widget.mode == ScreenMode.edit ||
                              widget.mode == ScreenMode.add)
                          ? (isSelected
                              ? Icon(Icons.check, color: widget.checkmarkColor)
                              : null)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedValue = filteredOptions[index].name;
                          selectedId = filteredOptions[index].id;
                        });
                        widget.onSelected(filteredOptions[index].id.toString());
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _openBottomSheet(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: notifires.getBoxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedValue ?? widget.hintText.tr,
                style: regular2(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: notifires.getwhiteblackcolor,
            ),
          ],
        ),
      ),
    );
  }
}

void showBookingOverlapBottomSheet(List bookingDetails, nexttimeSlot) {
  Get.bottomSheet(
    Container(
      height: Get.height / 2,
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Booking Overlap Detected'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.orange, // Less alarming tone
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'The selected time slots are booked. Please choose another time. The next available slot is shown below.'
                .tr,
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: bookingDetails.length,
              itemBuilder: (context, index) {
                final booking = bookingDetails[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10.0,
                          runSpacing: 5.0,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today,
                                    color: Colors.orange),
                                const SizedBox(width: 10),
                                Text(
                                  'Date: ${booking["date"]}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.orange),
                                const SizedBox(width: 10),
                                Text(
                                  'Booked: ${booking["start_time"]} - ${booking["end_time"]}',
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, color: Colors.green),
              const SizedBox(width: 10),
              Text(
                'Next Available After: ${nexttimeSlot ?? "Not specified"}',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          SizedBox(height: 10),
          CustomsButtons(
            text: "Choose Another Time".tr,
            backgroundColor: themeColor,
            onPressed: () {
              Get.back();
            },
          ),
        ],
      ),
    ),
    isScrollControlled: true,
  );
}

class CustomDropdownHostLocation extends StatefulWidget {
  final List options;
  final String hintText;
  final Function(List<dynamic> selected) onSelected;
  final Color checkmarkColor;
  final String? heading;
  final ScreenMode? mode;
  final dynamic selectedEditInitialValue;

  const CustomDropdownHostLocation(
      {super.key,
      this.mode,
      this.heading,
      required this.options,
      required this.onSelected,
      required this.checkmarkColor,
      this.hintText = 'Select One',
      this.selectedEditInitialValue});

  @override
  CustomDropdownHostLocationState createState() =>
      CustomDropdownHostLocationState();
}

class CustomDropdownHostLocationState
    extends State<CustomDropdownHostLocation> {
  @override
  void initState() {
    super.initState();
    setState(() {});
    getValue();
    getCode();
    addItemsHostController.selectedCityShortName = getCode();
    setState(() {});
  }

  AddItemsHostController addItemsHostController = Get.find();
  String? selectedValue;
  String? selectedCountryCode;

  int? selectedId;
  String? valuePlace;

  String? getValue() {
    String? result;
    if (selectedId == null) {
      for (var element in widget.options) {
        if (element.id.toString() == widget.selectedEditInitialValue) {
          setState(() {
            result = element.name;
          });
        }
      }
      return result;
    } else {
      for (var element in widget.options) {
        if (element.id.toString() == selectedId.toString()) {
          setState(() {
            result = element.name;
          });
          break;
        }
      }
      return result;
    }
  }

  String? getCode() {
    String? countryCode;
    if (selectedId == null) {
      for (var element in widget.options) {
        if (element.id.toString() == widget.selectedEditInitialValue) {
          setState(() {
            countryCode = element.countryCode;
          });
        }
      }
      return countryCode;
    } else {
      for (var element in widget.options) {
        if (element.id.toString() == selectedId.toString()) {
          setState(() {
            countryCode = element.countryCode;
          });
          break;
        }
      }
      return countryCode;
    }
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: notifires.getbgcolor,
      shape: const BeveledRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(color: greyColor2.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Text(
                    widget.heading ?? "",
                    style: heading3Grey1(context),
                  ),
                  const Spacer(),
                  InkWell(
                      onTap: (() {
                        Navigator.pop(context);
                      }),
                      child: Icon(
                        Icons.close,
                        color: notifires.getwhiteblackcolor,
                      ))
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: widget.options.length,
                itemBuilder: (BuildContext context, int index) {
                  bool? isselected = widget.options[index].id.toString() ==
                          widget.selectedEditInitialValue &&
                      selectedId == null;
                  bool isSelected = widget.options[index].id == selectedId;
                  valuePlace = widget.options[index].id.toString() ==
                          widget.selectedEditInitialValue
                      ? widget.options[index].name
                      : "";

                  return Container(
                    color: isSelected ? Colors.transparent : Colors.transparent,
                    child: ListTile(
                      title: Text(
                        widget.options[index].name,
                        style: regular2(context),
                      ),
                      trailing: (widget.mode == ScreenMode.edit)
                          ? (isselected
                              ? Icon(Icons.check, color: widget.checkmarkColor)
                              : isSelected
                                  ? Icon(Icons.check,
                                      color: widget.checkmarkColor)
                                  : null)
                          : (widget.mode == ScreenMode.add)
                              ? (isSelected
                                  ? Icon(Icons.check,
                                      color: widget.checkmarkColor)
                                  : null)
                              : null,
                      onTap: () {
                        setState(() {
                          selectedValue = widget.options[index].name;
                          selectedCountryCode =
                              widget.options[index].countryCode;
                          selectedId = widget.options[index].id;
                        });
                        widget.onSelected([
                          widget.options[index].id.toString(),
                          widget.options[index].countryCode.toString(),
                          widget.options[index].latitude ?? '', // Add latitude
                          widget.options[index].longitude?.toString() ??
                              '', // Add longitude
                        ]);

                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          _openBottomSheet(context);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          decoration: BoxDecoration(
            color: notifires.getBoxColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: widget.mode == ScreenMode.add
                    ? Text(
                        selectedValue ?? widget.hintText.tr,
                        style: regular2(context),
                        overflow: TextOverflow.ellipsis,
                      )
                    : Text(
                        getValue() ?? selectedValue ?? widget.hintText,
                        style: regular2(context),
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              Icon(
                Icons.arrow_drop_down,
                color: notifires.getwhiteblackcolor,
              ),
            ],
          ),
        ));
  }
}

class CustomDropdownHostYears extends StatefulWidget {
  final List<int>? years;
  final String hintText;
  final Function(int)? onSelected;
  final Color? checkmarkColor;
  final String? heading;
  final ScreenMode? mode;

  const CustomDropdownHostYears(
      {super.key,
      this.heading,
      this.years,
      this.onSelected,
      this.checkmarkColor,
      this.hintText = 'Select One',
      this.mode});

  @override
  CustomDropdownHostYearsState createState() => CustomDropdownHostYearsState();
}

class CustomDropdownHostYearsState extends State<CustomDropdownHostYears> {
  int? selectedYear;
  AddItemsHostController addItemsHostController = Get.find();

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      backgroundColor: notifires.getbgcolor,
      shape: const BeveledRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.heading != null)
              Container(
                decoration: BoxDecoration(
                    color: greyColor2.withOpacity(0.3), border: Border.all()),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Row(
                  children: [
                    Text(
                      widget.heading ?? "",
                      style: heading3Grey1(context),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.close,
                        color: notifires.getwhiteblackcolor,
                      ),
                    )
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.years!.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isSelected = widget.years![index] == selectedYear;
                  bool isMark = widget.years![index].toString() ==
                      addItemsHostController.selectedYear;

                  return Container(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.transparent, 
                    child: ListTile(
                      title: Text(
                        widget.years![index].toString(),
                        style: regular2(context),
                      ),
                      trailing: (widget.mode == ScreenMode.edit)
                          ? (isMark && selectedYear == null
                              ? Icon(Icons.check, color: widget.checkmarkColor)
                              : isSelected
                                  ? Icon(Icons.check,
                                      color: widget.checkmarkColor)
                                  : null)
                          : (widget.mode == ScreenMode.add)
                              ? (isSelected
                                  ? Icon(Icons.check,
                                      color: widget.checkmarkColor)
                                  : null)
                              : null,
                      onTap: () {
                        setState(() {
                          selectedYear = widget.years![index];
                        });
                        widget.onSelected!(widget.years![index]);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: notifires.getBoxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: widget.mode == ScreenMode.add
                  ? Text(
                      selectedYear == null
                          ? widget.hintText
                          : selectedYear.toString(),
                      style: regular2(context),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      selectedYear == null
                          ? addItemsHostController.selectedYear.toString()
                          : selectedYear.toString(),
                      style: regular2(context),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: notifires.getwhiteblackcolor,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDropdownHostVehicle extends StatefulWidget {
  final List options;
  final String hintText;
  final Function(String) onSelected;
  final Color checkmarkColor;
  final String? heading;
  // Add the required color for the checkmark

  const CustomDropdownHostVehicle({
    super.key,
    this.heading,
    required this.options,
    required this.onSelected,
    required this.checkmarkColor, // Make this required
    this.hintText = 'Select One',
  });

  @override
  CustomDropdownHostVehicleState createState() =>
      CustomDropdownHostVehicleState();
}

class CustomDropdownHostVehicleState extends State<CustomDropdownHostVehicle> {
  AddItemsHostController addItemsHostController = Get.find();
  String? selectedValue;

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      backgroundColor: notifires.getbgcolor,
      shape: const BeveledRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(color: greyColor2.withOpacity(0.4)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Text(
                    widget.heading ?? "",
                    style: heading3Grey1(context),
                  ),
                  const Spacer(),
                  InkWell(
                      onTap: (() {
                        Navigator.pop(context);
                      }),
                      child: Icon(
                        Icons.close,
                        color: notifires.getwhiteblackcolor,
                      ))
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: widget.options.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isSelected = widget.options[index].name == selectedValue;

                  return Container(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.transparent, // Highlight the selected item
                    child: ListTile(
                      title: Text(
                        widget.options[index].name,
                        style: regular2(context),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check,
                              color: widget
                                  .checkmarkColor) // Use the required checkmark color
                          : null,
                      onTap: () {
                        setState(() {
                          selectedValue = widget.options[index].name;
                        });
                        widget.onSelected(widget.options[index].id.toString());

                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            ),
            // ListTile(
            //   title: Text('Cancel', textAlign: TextAlign.center),
            //   onTap: () {
            //     Navigator.pop(
            //         context); // Close the bottom sheet when cancel is tapped
            //   },
            // ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedValue ?? widget.hintText,
                style: regular2(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}

class CustomCheckboxHost extends StatefulWidget {
  final ListTileControlAffinity controlAffinity; // Change here
  final List<String> options;
  final Function(List<String>) onSelectionChanged;
  final String showMoreText;
  final String showLessText;

  const CustomCheckboxHost({
    super.key,
    required this.controlAffinity, // Change here
    required this.options,
    required this.onSelectionChanged,
    this.showMoreText = 'Show More',
    this.showLessText = 'Show Less',
  });

  @override
  CustomCheckboxHostState createState() => CustomCheckboxHostState();
}

class CustomCheckboxHostState extends State<CustomCheckboxHost> {
  final List<String> _selectedItems = [];
  bool _showMore = false; // State to manage show more/less

  @override
  Widget build(BuildContext context) {
    int itemsToShow = _showMore || widget.options.length <= 5
        ? widget.options.length
        : 5; // Items to show based on showMore
    return Column(
      children: [
        // List of Checkboxes
        ListView.builder(
          shrinkWrap:
              true, // Important to ensure that ListView sizes itself to the number of children
          physics:
              const NeverScrollableScrollPhysics(), // Disables independent scrolling of the ListView
          itemCount: itemsToShow,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              checkColor: whiteColor,
              activeColor: getColorBasedOnActiveModuleid(),
              contentPadding: const EdgeInsets.all(0),
              title: Text(
                widget.options[index],
                style: smallHeadingAirMd.copyWith(
                    color: notifires.getwhiteblackcolor),
              ),
              value: _selectedItems.contains(widget.options[index]),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    _selectedItems.add(widget.options[index]);
                  } else {
                    _selectedItems.remove(widget.options[index]);
                  }
                  widget.onSelectionChanged(_selectedItems);
                });
              },
              controlAffinity: widget.controlAffinity,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            );
          },
        ),
        // Show More/Less button
        if (widget.options.length >
            5) // Only show if there are more than 5 items.
          TextButton(
            child: Text(
              _showMore ? widget.showLessText : widget.showMoreText,
              style: smallHeadingAirMd.copyWith(
                  color: notifires.getwhiteblackcolor),
            ),
            onPressed: () {
              setState(() {
                _showMore = !_showMore; // Toggle the _showMore state
              });
            },
          ),
      ],
    );
  }
}

showBottomSheetDescription(
    BuildContext context, CancellationPolicies cancellationPolicies) async {
  showModalBottomSheet(
    showDragHandle: true,
    backgroundColor: notifires.getboxcolor,
    //  isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (BuildContext context) {
      return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16),
        child: ListView(
          children: [
            Text(
              textAlign: TextAlign.justify,
              "${cancellationPolicies.name}",
              style: heading2Grey1(context),
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              // textAlign: TextAlign.justify,
              "${cancellationPolicies.description}",
              style: regular2(context),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      );
    },
  );
}

String staticContantforHost() {
  if (activeModuleId.value == 1) {
    return "rent_property".tr;
  } else if (activeModuleId.value == 2) {
    return "rent_vehicle".tr;
  } else if (activeModuleId.value == 3) {
    return "rent_boat".tr;
  } else if (activeModuleId.value == 4) {
    return "rent_parking".tr;
  } else if (activeModuleId.value == 5) {
    return "rent_products".tr;
  } else if (activeModuleId.value == 6) {
    return "rent_space".tr;
  }

  return "";
}

class Addproperty extends StatelessWidget {
  final String? title;
  final String? subTitle;
  final String? btnTxt;
  final VoidCallback? onTap;
  const Addproperty(
      {super.key, this.btnTxt, this.subTitle, this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          height: 10,
        ),
        activeModuleId.value == 1
            ? Image.asset(
                "assets/images/villas.png",
                height: 110,
                color: notifires.getwhiteblackcolor,
              )
            : activeModuleId.value == 2
                ? Image.asset(
                    "assets/images/vehicleAdd.png",
                    height: 110,
                    color: notifires.getwhiteblackcolor,
                  )
                : activeModuleId.value == 3
                    ? Image.asset(
                        "assets/images/yart.png",
                        height: 110,
                      )
                    : activeModuleId.value == 4
                        ? Image.asset(
                            "assets/images/parking.png",
                            height: 110,
                            color: notifires.getwhiteblackcolor,
                          )
                        : activeModuleId.value == 5
                            ? Image.asset(
                                "assets/images/productAddimage.png",
                                height: 110,
                                color: notifires.getwhiteblackcolor,
                              )
                            : activeModuleId.value == 6
                                ? Image.asset(
                                    "assets/images/villas.png",
                                    height: 110,
                                    color: notifires.getwhiteblackcolor,
                                  )
                                : Container(), // Default case, can be replaced with appropriate widget or null

        Text(
          title!,
          style: heading3Grey1(context)
              .copyWith(color: notifires.getwhiteblackcolor),
          textAlign: TextAlign.center,
          softWrap: true,
        ),
        const SizedBox(height: 10),
        Text(
          subTitle!,
          style:
              regular2(context).copyWith(color: notifires.getwhiteblackcolor),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: Get.width / 2,
          child: CustomsButtons(
              text: truncatetext("$btnTxt".tr, 15),
              backgroundColor: getColorBasedOnActiveModuleid(),
              onPressed: onTap!),
        )
      ],
    ));
  }
}

class ServiceTypeDropDown extends StatefulWidget {
  final List<String> options;
  final String hintText;
  final String? initialValue;
  final Function(String) onSelected;
  final Color checkmarkColor;
  final String? heading;
  final ScreenMode? mode;

  const ServiceTypeDropDown({
    super.key,
    this.heading,
    this.initialValue,
    required this.options,
    this.mode,
    required this.onSelected,
    required this.checkmarkColor,
    this.hintText = 'Select One',
  });

  @override
  State<ServiceTypeDropDown> createState() => _ServiceTypeDropDownState();
}

class _ServiceTypeDropDownState extends State<ServiceTypeDropDown> {
  AddItemsHostController addItemsHostController = Get.find();
  String? selectedValue;

  @override
  void initState() {
    super.initState();
    selectedValue = widget.initialValue;
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      backgroundColor: notifires.getbgcolor,
      shape: const BeveledRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: greyColor.withOpacity(0.4),
                border: Border.all(color: greyColor),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Text(
                    widget.heading ?? "",
                    style: heading3Grey1(context),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: notifires.getwhiteblackcolor,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: widget.options.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isSelected = widget.options[index] == selectedValue;

                  return Container(
                    color: Colors.transparent,
                    child: ListTile(
                      title: Text(
                        widget.options[index],
                        style: regular2(context),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: widget.checkmarkColor)
                          : null,
                      onTap: () {
                        setState(() {
                          selectedValue = widget.options[index];
                          widget.onSelected(widget.options[index]);
                        });
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.only(left: 15, right: 20),
        decoration: BoxDecoration(
          color: notifires.getBoxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                selectedValue ?? widget.hintText,
                style: regular2(context),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: notifires.getwhiteblackcolor,
            ),
          ],
        ),
      ),
    );
  }
}

class CustomDropdownHost2 extends StatefulWidget {
  final List options;
  final String hintText;

  final Function(String) onSelected;
  final Color checkmarkColor;
  final String? heading;
  final ScreenMode? mode;
  // Add the required color for the checkmark

  const CustomDropdownHost2({
    super.key,
    this.heading,
    required this.options,
    this.mode,
    required this.onSelected,
    required this.checkmarkColor, // Make this required
    this.hintText = 'Select One',
  });

  @override
  CustomDropdownHost2State createState() => CustomDropdownHost2State();
}

class CustomDropdownHost2State extends State<CustomDropdownHost2> {
  AddItemsHostController addItemsHostController = Get.find();
  String? selectedValue;

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      useSafeArea: true,
      backgroundColor: notifires.getbgcolor,
      shape: const BeveledRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  color: greyColor.withOpacity(0.4),
                  border: Border.all(color: greyColor)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Text(
                    widget.heading ?? "",
                    style: heading3Grey1(context),
                  ),
                  const Spacer(),
                  InkWell(
                      onTap: (() {
                        Navigator.pop(context);
                      }),
                      child: Icon(
                        Icons.close,
                        color: notifires.getwhiteblackcolor,
                      ))
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: widget.options.length,
                itemBuilder: (BuildContext context, int index) {
                  bool isSelected = widget.options[index].name == selectedValue;
                  bool isMark = widget.options[index].name ==
                      addItemsHostController.selectTransmission;

                  return Container(
                    color: isSelected
                        ? Colors.transparent
                        : Colors.transparent, // Highlight the selected item
                    child: ListTile(
                      title: Text(
                        widget.options[index].name,
                        style: regular2(context),
                      ),
                      trailing: (widget.mode == ScreenMode.edit)
                          ? (isMark
                              ? Icon(Icons.check, color: widget.checkmarkColor)
                              : isSelected
                                  ? Icon(Icons.check,
                                      color: widget.checkmarkColor)
                                  : null)
                          : (widget.mode == ScreenMode.add)
                              ? (isSelected
                                  ? Icon(Icons.check,
                                      color: widget.checkmarkColor)
                                  : null)
                              : null,
                      onTap: () {
                        setState(() {
                          selectedValue = widget.options[index].name;

                          widget.onSelected(
                              widget.options[index].name.toString());
                        });

                        Navigator.pop(context);
                      },
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            ),
            // ListTile(
            //   title: Text('Cancel', textAlign: TextAlign.center),
            //   onTap: () {
            //     Navigator.pop(
            //         context); // Close the bottom sheet when cancel is tapped
            //   },
            // ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        decoration: BoxDecoration(
          color: notifires.getBoxColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: widget.mode == ScreenMode.add
                  ? Text(
                      selectedValue ?? widget.hintText.tr,
                      style: TextStyle(
                        color: notifires
                            .getwhiteblackcolor, // Update with your desired style
                      ),
                      overflow: TextOverflow.ellipsis,
                    )
                  : Text(
                      addItemsHostController.selectTransmission ??
                          selectedValue ??
                          widget.hintText,
                      style: regular2(context),
                      overflow: TextOverflow.ellipsis,
                    ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: notifires.getwhiteblackcolor,
            ),
          ],
        ),
      ),
    );
  }
}

Row featuresBoxHost() {
  return Row(
    children: [
      Container(
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: greyColor2.withOpacity(0.3),
            // color: lightBackColor,
            border: Border.all(width: 1.0, color: greyColor2.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(20.0)),
        child: Icon(Icons.arrow_back_ios_new,
            size: 24, color: notifires.getwhiteblackcolor),
      ),
    ],
  );
}

class LineContainer extends StatelessWidget {
  const LineContainer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: 10,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: notifires.getwhiteblackcolor,
            width: 2.0,
          ),
        ),
        // borderRadius: BorderRadius.only(
        //     topLeft: Radius.circular(20), topRight: Radius.circular(20)   )
      ),
    );
  }
}

class CheckBoxHost extends StatefulWidget {
  final AddRules? currentRule;
  final bool? isSelected;

  const CheckBoxHost({super.key, this.currentRule, this.isSelected});

  @override
  State<CheckBoxHost> createState() => _CheckBoxHostState();
}

class _CheckBoxHostState extends State<CheckBoxHost> {
  AddItemsHostController addItemsHostController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: Transform.scale(
        scale: 1.5,
        child: Checkbox(
          activeColor: getColorBasedOnActiveModuleid(),
          side: BorderSide(color: getColorBasedOnActiveModuleid(), width: 1),
          onChanged: (value) {
            setState(() {
              if (value == true) {
                addItemsHostController.selectedRulesList
                    .add(widget.currentRule?.id);
              } else {
                addItemsHostController.selectedRulesList
                    .remove(widget.currentRule?.id);
              }
            });
          },
          value: addItemsHostController.selectedRulesList
              .contains(widget.currentRule?.id),
        ),
      ),
    );
  }
}

class RadioBtnHost extends StatefulWidget {
  final CancellationPolicies currentRule;

  const RadioBtnHost({super.key, required this.currentRule});
  @override
  State<RadioBtnHost> createState() => _RadioBtnHostState();
}

class _RadioBtnHostState extends State<RadioBtnHost> {
  AddItemsHostController addItemsHostController = Get.find();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: 20,
        height: 20,
        child: Transform.scale(
          scale: 1.25,
          child: Radio(
            activeColor: themeColor,
            value: widget.currentRule.id,
            onChanged: (value) {
              addItemsHostController.selectedRadio =
                  widget.currentRule.id!.toInt();
              setState(() {});
            },
            groupValue: addItemsHostController.selectedRadio,
          ),
        ));
  }
}

class DiscountPrize extends StatefulWidget {
  final ScreenMode mode;

  const DiscountPrize({super.key, required this.mode});

  @override
  State<DiscountPrize> createState() => _DiscountPrizeState();
}

class _DiscountPrizeState extends State<DiscountPrize> {
  AddItemsHostController addItemsHostController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelNames(labelname: 'Weekly discount'.tr),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                currency,
                style: regular3(context),
              ),
            ),
            const SizedBox(
              width: 25,
            ),
            SizedBox(
              width: 90,
              height: 60,
              child: TextFieldRefsForDiscount(
                onChange: (value) {
                  TextEditingController controller =
                      widget.mode == ScreenMode.edit
                          ? addItemsHostController
                              .textEditingControllerEditWeekDiscount
                          : addItemsHostController
                              .textEditingControllerWeekDiscount;

                  addItemsHostController.cleanNumericInput(controller, value!);
                  return null;
                },
                onTap: () {
                  setState(() {
                    addItemsHostController.numerictype = true;
                  });
                },
                txt: '',
                textEditingControllerCommon: widget.mode == ScreenMode.add
                    ? addItemsHostController.textEditingControllerWeekDiscount
                    : addItemsHostController
                        .textEditingControllerEditWeekDiscount,
                inputType: TextInputType.number,
                inputAlignment: TextAlign.start,
  
                validator: (value) {
  
                  if (value!.length > 1) {
                    if (value.startsWith("0")) {
                      String cleanedValue = value.substring(1, value.length);
                      if (widget.mode == ScreenMode.add) {
                        addItemsHostController.textEditingControllerWeekDiscount
                            .text = cleanedValue;
                        addItemsHostController.textEditingControllerWeekDiscount
                            .selection = TextSelection.fromPosition(
                          TextPosition(
                            offset: addItemsHostController
                                .textEditingControllerWeekDiscount.text.length,
                          ),
                        );
                      } else if (widget.mode == ScreenMode.edit) {
                        addItemsHostController
                            .textEditingControllerEditWeekDiscount
                            .text = cleanedValue;
                        addItemsHostController
                            .textEditingControllerEditWeekDiscount
                            .selection = TextSelection.fromPosition(
                          TextPosition(
                            offset: addItemsHostController
                                .textEditingControllerEditWeekDiscount
                                .text
                                .length,
                          ),
                        );
                      }
                    }
                  }

                  return null; // No validation error
                },
              ),
            ),
            const SizedBox(
              width: 50,
            ),
            Expanded(
              child: Container(
                height: 51,
                padding: const EdgeInsets.only(
                    left: 12, right: 16, top: 5, bottom: 5),
                decoration: BoxDecoration(
                    color: notifires.getBoxColor,
                    borderRadius: BorderRadius.circular(12)),
                child: DropdownButton<String>(
                  iconEnabledColor: notifires.getwhiteblackcolor,
                  dropdownColor: notifires.getblackwhitecolor,
                  style: TextStyle(color: notifires.getwhiteblackcolor),
                  underline: const SizedBox(),
                  isExpanded: true,
                  items: ['percent', 'fixed'].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.tr),
                    );
                  }).toList(),
                  onChanged: (value) {
                    addItemsHostController.selectedWeeklyDiscountType = value!;
                    setState(() {});
                  },
                  value: addItemsHostController.selectedWeeklyDiscountType,
                  // style: Normal_air_bk.copyWith(
                  //     color: notifires.getwhiteblackcolor),
                  hint: Text(
                    "Select Discount".tr,
                    style: normalAirBk.copyWith(
                        color: notifires.getwhiteblackcolor),
                  ),
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
          ],
        ),
        const SizedBox(height: 10),
        const LabelNames(labelname: 'Monthly discount'),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 50,
              alignment: Alignment.center,
              child: Text(
                currency,
                style: regular3(context),
              ),
            ),
            const SizedBox(
              width: 25,
            ),
            SizedBox(
              width: 90,
              height: 60,
              child: TextFieldRefsForDiscount(
                txt: '',
                onChange: (value) {
                  TextEditingController controller =
                      widget.mode == ScreenMode.edit
                          ? addItemsHostController
                              .textEditingControllerEditMonthDiscount
                          : addItemsHostController
                              .textEditingControllerMonthDiscount;

                  addItemsHostController.cleanNumericInput(controller, value!);
                  return null;
                },
                onTap: () {
                  setState(() {
                    addItemsHostController.numerictype = true;
                  });
                },
                textEditingControllerCommon: widget.mode == ScreenMode.add
                    ? addItemsHostController.textEditingControllerMonthDiscount
                    : addItemsHostController
                        .textEditingControllerEditMonthDiscount,
                inputType: TextInputType.number,
                inputAlignment: TextAlign.start,
                validator: (value) {
                  // Handling leading zeros and numeric input validation
                  if (value != null && value.length > 1) {
                    if (value.startsWith("0")) {
                      // If the value starts with a 0, remove it
                      String cleanedValue = value.substring(1);

                      if (widget.mode == ScreenMode.add) {
                        addItemsHostController
                            .textEditingControllerMonthDiscount
                            .text = cleanedValue;
                        addItemsHostController
                            .textEditingControllerMonthDiscount
                            .selection = TextSelection.fromPosition(
                          TextPosition(
                              offset: addItemsHostController
                                  .textEditingControllerMonthDiscount
                                  .text
                                  .length),
                        );
                      } else if (widget.mode == ScreenMode.edit) {
                        addItemsHostController
                            .textEditingControllerEditMonthDiscount
                            .text = cleanedValue;
                        addItemsHostController
                            .textEditingControllerEditMonthDiscount
                            .selection = TextSelection.fromPosition(
                          TextPosition(
                              offset: addItemsHostController
                                  .textEditingControllerEditMonthDiscount
                                  .text
                                  .length),
                        );
                      }
                    }
                  }

                  return null; // No validation error
                },
              ),
            ),
            const SizedBox(
              width: 50,
            ),
            Expanded(
              child: Container(
                height: 52,
                padding: const EdgeInsets.only(
                    left: 12, right: 16, top: 5, bottom: 5),
                decoration: BoxDecoration(
                    color: notifires.getBoxColor,
                    borderRadius: BorderRadius.circular(10)),
                child: DropdownButton<String>(
                  iconEnabledColor: notifires.getwhiteblackcolor,
                  dropdownColor: notifires.getblackwhitecolor,
                  style: TextStyle(color: notifires.getwhiteblackcolor),
                  underline: const SizedBox(),
                  isExpanded: true,
                  items: ['percent', 'fixed'].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value.tr),
                    );
                  }).toList(),
                  onChanged: (value) {
                    addItemsHostController.selectedMonthlyDiscountType = value!;
                    setState(() {});
                  },
                  value: addItemsHostController.selectedMonthlyDiscountType,
                  hint: Text("Select Discount".tr),
                ),
              ),
            ),
            const SizedBox(
              width: 15,
            ),
          ],
        ),
      ],
    );
  }
}

bool isStartDateMatchingCurrentDate(String? startDate) {
  if (startDate == null) {
    return false;
  }

  try {
    // Parse startDate in dd-MM-yyyy format
    final dateFormat = DateFormat('dd-MM-yyyy');
    final parsedStartDate = dateFormat.parse(startDate);

    // Get the current date (July 4, 2025, 4:05 PM IST)
    final currentDate = DateTime.now();

    // Compare year, month, and day
    return parsedStartDate.year == currentDate.year &&
        parsedStartDate.month == currentDate.month &&
        parsedStartDate.day == currentDate.day;
  } catch (e) {
    debugPrint('Error parsing startDate: $e, startDate: $startDate');
    return false;
  }
}

myBookingHostListWidget(
  List<Bookings> list,
  btnText,
  StateSetter setState,
  bool fromPropBooking,
  String listType,
  onItemCancelled,
) {
  innerMethod(BuildContext context, index) async {
    if (btnText == "Reject") {
      showLoading();
      var response =
          await httpGet(Config.getCancelReasons, {"userType": "host"});
      closeLoading();
      if (response != null) {
        CancellationReasonModel model =
            CancellationReasonModel.fromJson(response);
        await showModalBottomSheet(
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
                  // title: Text('Are you sure?'.tr,style: TextStyle(color: CustomTheme.theamColor,fontSize: 16, fontFamily: FontStyles.gilroyMedium, fontWeight: FontWeight.w700),),
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
                        Text(
                          'Do you want to cancel this Order?'.tr,
                          textAlign: TextAlign.center,
                          style: regular2(context),
                        ),
                        // Text('Would you like to approve of this message?'),
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
                                      var resp = await httpPost(
                                          Config.cancelBookingByHost, {
                                        "booking_id": "${list[index].id}",
                                        "cancellation_reasion": "$value"
                                      });
                                      closeLoading();
                                      if (resp['status'] == 200) {
                                        bookingController
                                            .updateBookingStatusIfExists(
                                          bookingId: list[index].id.toString(),
                                          hostId: list[index].userid.toString(),
                                          userId: userId.toString(),
                                          newStatus: "Declined",
                                        );

                                        showToastMessage(resp['message']);
                                        onItemCancelled(index);
                                        setState(() {});
                                      } else {
                                        showErrorToastMessage(resp['error']);
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
                                            // fontFamily:
                                            // FontStyles.gilroyMedium,
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
      }
    } else if (btnText == "Add Review".tr) {
      if (list[index].reviewStatus != null && list[index].reviewStatus != "0") {
        await showModalBottomSheet(
          isDismissible: true,
          showDragHandle: true,
          enableDrag: true,
          context: context,
          builder: (context) {
            return bottomSheetHostReviewed(
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
            return bottomSheetHostReview(list[index].id, count, fromPropBooking,
                list[index], setState, context);
          },
        );
      }
    }
  }

  Future<String> updateItemDeliverStatus({required String bookingId}) async {
    showLoading();
    var isItemDelivered;
    String result;
    var response = await httpPost(Config.updateItemDeliveredStatus,
        {"booking_id": bookingId, "is_item_delivered": "1"});
    closeLoading();
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

  Future<String> updateItemReturnedStatus({required String bookingId}) async {
    showLoading();
    var isItemReturned;
    String result;
    var response = await httpPost(Config.updateItemReturnedStatus,
        {"booking_id": bookingId, "is_item_returned": "1"});
    closeLoading();
    if (response["status"] == 200) {
      isItemReturned =
          response["data"]["booking_extension"]["is_item_returned"];
      showToastMessage(response["message"]);
      result = isItemReturned == "1" ? "no" : "yes";
    } else {
      showErrorToastMessage(response['error']);
      result = "yes";
    }
    return result;
  }

  return ListView.builder(
      shrinkWrap: true,
      itemCount: list.length,
      itemBuilder: (context, index) {
        var itemData = jsonDecode(list[index].itemData);
        String address = itemData[0]['address'] ?? '';
        dynamic latitude = itemData[0]['latitude'] ?? 'N/A'.tr;
        dynamic longitude = itemData[0]['longitude'] ?? 'N/A'.tr;
        String? startDate = list[index].checkIn;
        bool isMatching = isStartDateMatchingCurrentDate(startDate);
        String? totalNights =
            "${list[index].currencyCode} ${list[index].total}";
        Map<String, dynamic> itemInfoMap = jsonDecode(itemData[0]['item_info']);
        ItemInfo? itemInfoData;
        itemInfoData = ItemInfo.fromJson(itemInfoMap);
        dynamic proType = itemData[0]['item_type'] ?? 'N/A'.tr;
        dynamic image = itemData[0]['image'] ?? 'N/A'.tr;

        return Padding(
          padding:
              const EdgeInsets.only(left: 13, right: 13, bottom: 10, top: 10),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (builder) => HostEreciept(
                            bookings: list[index],
                            fromPropBooking: fromPropBooking,
                            conformBooking:
                                listType == "UpComing" ? "UpComing" : "",
                          ))).then((value) {
                if (value != null) {
                  list[index].statusSetter = value;
                  setState(() {});
                }
              });
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
                  GestureDetector(
                    onTap: () {
                      if (list[index].userName == null) {
                        showErrorToastMessage("User not found");
                        return;
                      }

                      showPopUpScreen(
                          context,
                          VehicleDetailSScreen(
                            id: list.elementAt(index).id,
                            itemInfo: itemInfoData!,
                            rating: list[index].rating,
                            title: list[index].propTitle,
                            address: address,
                            latitute: latitude,
                            longtitute: longitude,
                            frontImage: image,
                            itemType: proType,
                            price: list[index].perNight,
                          ));
                    },
                    child: Stack(
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
                        Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                              padding: const EdgeInsets.only(
                                  left: 8, right: 8, top: 4, bottom: 4),
                              decoration: BoxDecoration(
                                  color: getColorBasedOnActiveModuleid()
                                      .withOpacity(.8),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text("#${list[index].token}",
                                  style: regular2(context)
                                      .copyWith(color: whiteColor)),
                            )),
                        listType == "Cancelled"
                            ? SizedBox()
                            : Positioned(
                                bottom: 10,
                                right: 10,
                                child: InkWell(
                                  onTap: () {
                                    Get.to(() => ConversationScreen(
                                          bookingStatus:
                                              '${list[index].status}',
                                          bookingId: '${list[index].id}',
                                          image: image,
                                          title: list[index].propTitle!,
                                          conversationId:
                                              "${list[index].userid}_${list[index].id}_${list[index].hostId}",
                                          from: "${list[index].userName}",
                                          senderId: "$userId",
                                          reciverId: "${list[index].userid}",
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
                                      Icons.chat_bubble_outline, // Chat icon
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ),
                        listType == "UpComing"
                            ? Positioned(
                                bottom: 0,
                                left: 0,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 4, bottom: 4),
                                  decoration: BoxDecoration(
                                      color: getColorBasedOnActiveModuleid()
                                          .withOpacity(.8),
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                      "Pickup OTP : ${list[index].pickOtp}",
                                      style: regular2(context)
                                          .copyWith(color: whiteColor)),
                                ))
                            : listType == "Ongoing"
                                ? Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 8, right: 8, top: 4, bottom: 4),
                                      decoration: BoxDecoration(
                                          color: getColorBasedOnActiveModuleid()
                                              .withOpacity(.8),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                          "Drop OTP : ${list[index].dropOtp}",
                                          style: regular2(context)
                                              .copyWith(color: whiteColor)),
                                    ))
                                : const SizedBox(),
                      ],
                    ),
                  ),
                  Column(
                    children: [
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
                                            borderRadius:
                                                BorderRadius.circular(6)),
                                        padding: EdgeInsets.all(5),
                                        child: Text(
                                          "${itemInfoData.vehicleType}",
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
                                        style:
                                            heading3Grey1(context).copyWith(),
                                      ),
                                      const Spacer(),
                                      Text(
                                        totalNights.tr,
                                        style: boldstyle(context).copyWith(
                                            color:
                                                getColorBasedOnActiveModuleid(),
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
                                  style: regular2(context).copyWith(
                                      overflow: TextOverflow.ellipsis),
                                ),
                                Spacer(),
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 8, right: 8, top: 4, bottom: 4),
                                  decoration: BoxDecoration(
                                      color:
                                          list[index].status == "Confirmed" ||
                                                  list[index].status == "Live"
                                              ? greensColor
                                              : list[index].status == "Pending"
                                                  ? yellowColor
                                                  : list[index].status ==
                                                          "Completed"
                                                      ? blueColor
                                                      : redColor,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: list[index].status == "Confirmed" ||
                                          list[index].status == "Live" ||
                                          list[index].status == "Pending" ||
                                          list[index].status == "Declined" &&
                                              listType == "UpComing" ||
                                          listType == "Previous"
                                      ? Text("${list[index].status}",
                                          style: regular(context)
                                              .copyWith(color: whiteColor))
                                      : listType == 'Cancelled'
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  color: redColor,
                                                  border: Border.all(
                                                    color: redColor,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(4.0),
                                                child: Text(
                                                    '${list[index].status}',
                                                    style: regular(context)
                                                        .copyWith(
                                                            color: whiteColor)),
                                              ),
                                            )
                                          : const SizedBox(),
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
                                    " ${DateTimeFormatter.to24HourFormat(list[index].checkIn)}".tr,
                                    style: regular2(context).copyWith(),
                                  ),
                                ),
                                Spacer(),
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "${DateTimeFormatter.to24HourFormat(list[index].checkOut)}".tr,
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
                                          list[index].userName == null
                                              ? "user Not Found".tr
                                              : "${list[index].userName}",
                                          style: regular2(context),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                list[index].userName != null &&
                                        list[index].userName!.isNotEmpty
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            size: 18,
                                            color:
                                                getColorBasedOnActiveModuleid(),
                                          ),
                                          const SizedBox(width: 10),
                                          InkWell(
                                            onTap: () => launchUrl(Uri.parse(
                                                'tel:${list[index].userPhoneCountry}${list[index].userNumber}')),
                                            child: Text(
                                              "${list[index].userPhoneCountry} ${list[index].userNumber!}",
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
                                          "${itemInfoData.transmission}",
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
                                          "${itemInfoData.fuelType}",
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
                      /////////
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
                                list[index].securityMoney != null &&
                                        list[index].securityMoney != "0.00"
                                    ? eReceiptWidget(
                                        name: "Security Money".tr,
                                        value:
                                            "${list[index].currencyCode} ${list[index].securityMoney}",
                                      )
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
                              ],
                            ),
                          ],
                        ),
                      ),

//// threeeeeee
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
                                list[index].status == "Confirmed"
                                    ? const SizedBox()
                                    : list[index].status == "Declined" &&
                                            listType == "UpComing"
                                        ? const SizedBox()
                                        : list[index].status == "Confirmed" ||
                                                list[index].status ==
                                                        "Pending" &&
                                                    listType == "UpComing"
                                            ? Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    if (list[index].userName ==
                                                        null) {
                                                      showErrorToastMessage(
                                                          "user not found");
                                                      return;
                                                    }
                                                    if (list[index].status ==
                                                        "Confirmed") {
                                                      return;
                                                    }
                                                    try {
                                                      showLoading();
                                                      var responce =
                                                          await httpPost(
                                                              Config
                                                                  .getItemDetails,
                                                              {
                                                            "item_id":
                                                                "${list[index].itemid}"
                                                          });
                                                      if (responce != null &&
                                                          responce["status"] ==
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
                                                      // Handle any exceptions
                                                    }

                                                    if (list[index].status ==
                                                        "Pending") {
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        showDialog<void>(
                                                          context: context,
                                                          builder: (BuildContext
                                                              context) {
                                                            return AlertDialog(
                                                              backgroundColor:
                                                                  notifires
                                                                      .getboxcolor,
                                                              content:
                                                                  SingleChildScrollView(
                                                                child: ListBody(
                                                                  children: <Widget>[
                                                                    const Icon(
                                                                      Icons
                                                                          .error,
                                                                      size: 75,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                    Text(
                                                                      'Do you want to Accept this Order?'
                                                                          .tr
                                                                          .tr,
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style: regular2(
                                                                          context),
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
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              margin: const EdgeInsets.only(left: 8, right: 8),
                                                                              padding: const EdgeInsets.all(10),
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(
                                                                                  color: notifires.getGrey2Whitecolor,
                                                                                ),
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              ),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  "No".tr,
                                                                                  style: boldstyle(context),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Expanded(
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              BookingController bookingController = Get.find();
                                                                              Navigator.pop(context);
                                                                              showLoading();
                                                                              var resp = await httpPost(
                                                                                Config.confirmBookingByHost,
                                                                                {
                                                                                  "booking_id": "${list[index].id}"
                                                                                },
                                                                              );
                                                                              closeLoading();
                                                                              if (resp['status'] == 200) {
                                                                                showToastMessage(resp['message']);
                                                                                list[index].statusSetter = "Confirmed";

                                                                                bookingController.updateBookingStatusIfExists(
                                                                                  bookingId: list[index].id.toString(),
                                                                                  hostId: list[index].userid.toString(),
                                                                                  userId: userId.toString(),
                                                                                  newStatus: "Confirmed",
                                                                                );

                                                                                setState(() {});
                                                                              } else {
                                                                                showToastMessage(resp['error']);
                                                                              }
                                                                            },
                                                                            child:
                                                                                Container(
                                                                              margin: const EdgeInsets.only(left: 8, right: 8),
                                                                              padding: const EdgeInsets.all(10),
                                                                              decoration: BoxDecoration(
                                                                                border: Border.all(
                                                                                  color: getColorBasedOnActiveModuleid(),
                                                                                ),
                                                                                color: getColorBasedOnActiveModuleid(),
                                                                                borderRadius: BorderRadius.circular(10),
                                                                              ),
                                                                              child: Center(
                                                                                child: Text(
                                                                                  "Yes".tr,
                                                                                  style: boldstyle(context).copyWith(
                                                                                    color: Colors.white,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    const SizedBox(
                                                                      height: 8,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            );
                                                          },
                                                        );
                                                      });
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 9,
                                                              bottom: 9),
                                                      decoration: BoxDecoration(
                                                          border: Border.all(
                                                              color: list[index]
                                                                          .status ==
                                                                      "Confirmed"
                                                                  ? greensColor
                                                                  : yellowColor),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                          color: list[index]
                                                                      .status ==
                                                                  "Confirmed"
                                                              ? greensColor
                                                              : yellowColor),
                                                      child: Text(
                                                          list[index].status ==
                                                                  "Confirmed"
                                                              ? "Confirmed".tr
                                                              : "Accept".tr,
                                                          style: boldstyle(
                                                                  context)
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize:
                                                                      14)),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                list[index].status == "Confirmed" &&
                                        listType == "UpComing"
                                    ? const SizedBox()
                                    : list[index].status == "Declined"
                                        ? const SizedBox()
                                        : listType == 'UpComing' &&
                                                isMatching == true
                                            ? const SizedBox()
                                            : listType == 'Cancelled'
                                                ? const SizedBox()
                                                : listType == 'Ongoing'
                                                    ? const SizedBox()
                                                    : list[index]
                                                                .isItemReturned ==
                                                            1
                                                        ? Expanded(
                                                            child: InkWell(
                                                              onTap: () async {
                                                                if (list[index]
                                                                        .userName ==
                                                                    null) {
                                                                  showErrorToastMessage(
                                                                      "host not found");
                                                                  return;
                                                                }

                                                                try {
                                                                  showLoading();
                                                                  var responce =
                                                                      await httpPost(
                                                                          Config
                                                                              .getItemDetails,
                                                                          {
                                                                        "item_id":
                                                                            "${list[index].itemid}"
                                                                      });
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
                                                                  // Handle any exceptions
                                                                }

                                                                innerMethod(
                                                                    context,
                                                                    index);
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        right:
                                                                            10),
                                                                child: Container(
                                                                    alignment: Alignment.center,
                                                                    padding: const EdgeInsets.only(
                                                                      top: 10,
                                                                      bottom:
                                                                          10,
                                                                    ),
                                                                    decoration: BoxDecoration(
                                                                      // color: btnText == "Cancel" ? RedColor:yelloColor,
                                                                      color: btnText ==
                                                                              "Cancelled"
                                                                          ? const Color
                                                                              .fromARGB(
                                                                              128,
                                                                              128,
                                                                              128,
                                                                              128)
                                                                          : btnText == "Cancel"
                                                                              ? Colors.red
                                                                              : list[index].reviewStatus != null && list[index].reviewStatus != "0"
                                                                                  ? Colors.blue
                                                                                  : themeColor,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10),
                                                                    ),
                                                                    child: Center(
                                                                        // child: Text("Cancel"),
                                                                        child: Text(
                                                                      list[index].reviewStatus != null &&
                                                                              list[index].reviewStatus ==
                                                                                  "1"
                                                                          ? "View Review"
                                                                              .tr
                                                                          : "$btnText"
                                                                              .tr,
                                                                      style: boldstyle(context).copyWith(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              14),
                                                                    ))),
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox(),
                                listType == "Ongoing"
                                    ? const SizedBox()
                                    : listType == 'Cancelled'
                                        ? const SizedBox()
                                        : listType == 'Previous'
                                            ? const SizedBox()
                                            : Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    if (list[index].userName ==
                                                        null) {
                                                      showErrorToastMessage(
                                                          "user not found");
                                                      return;
                                                    }

                                                    try {
                                                      showLoading();
                                                      var responce =
                                                          await httpPost(
                                                              Config
                                                                  .getItemDetails,
                                                              {
                                                            "item_id":
                                                                "${list[index].itemid}"
                                                          });
                                                      if (responce != null &&
                                                          responce["status"] ==
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
                                                      // Handle any exceptions
                                                    }

                                                    innerMethod(context, index);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: Container(
                                                        alignment:
                                                            Alignment.center,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          top: 10,
                                                          bottom: 10,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          // color: btnText == "Cancel" ? RedColor:yelloColor,
                                                          color: btnText ==
                                                                  "Cancelled"
                                                              ? const Color
                                                                  .fromARGB(128,
                                                                  128, 128, 128)
                                                              : btnText ==
                                                                      "Reject"
                                                                  ? Colors.red
                                                                  : list[index].reviewStatus !=
                                                                              null &&
                                                                          list[index].reviewStatus !=
                                                                              "0"
                                                                      ? Colors
                                                                          .blue
                                                                      : themeColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        child: Center(
                                                            // child: Text("Cancel"),
                                                            child: Text(
                                                          list[index].reviewStatus !=
                                                                      null &&
                                                                  list[index]
                                                                          .reviewStatus ==
                                                                      "1"
                                                              ? "View Review".tr
                                                              : "$btnText".tr,
                                                          style: boldstyle(
                                                                  context)
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14),
                                                        ))),
                                                  ),
                                                ),
                                              ),
                                list[index].status == "Confirmed"
                                    ? listType == 'UpComing' &&
                                            list[index].isItemDeliveredButton ==
                                                "yes"
                                        ? Expanded(
                                            child: InkWell(
                                              onTap: () async {
                                                print(digitalsingnature);
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
                                                        result.success == 200) {
                                                      if (result.data
                                                              .vendorSigned ==
                                                          0) {
                                                        showModalBottomSheet<
                                                            String>(
                                                          context: context,
                                                          backgroundColor:
                                                              notifires
                                                                  .getbgcolor,
                                                          isScrollControlled:
                                                              true,
                                                          shape:
                                                              const RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .vertical(
                                                              top: Radius
                                                                  .circular(20),
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
                                                                          MainAxisSize
                                                                              .min,
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        Text(
                                                                          'Vehicle Delivery Confirmation'
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
                                                                                12),
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            // Bullet points
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
                                                                        const SizedBox(
                                                                            height:
                                                                                20),
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

                                                        return;
                                                      }

                                                      // Check if vendor has signed
                                                      if (result.data
                                                              .vendorSigned ==
                                                          0) {
                                                        showErrorToastMessage(
                                                          "${list[index].hostName} has not signed yet. Please wait for their signature before proceeding.",
                                                        );
                                                        return;
                                                      }
                                                    } else {
                                                      showErrorToastMessage(
                                                          "Failed to fetch signature data. Please try again.");
                                                    }
                                                  } catch (e, stacktrace) {
                                                    print('Error in onTap: $e');
                                                    print(
                                                        'Stacktrace: $stacktrace');
                                                    showErrorToastMessage(
                                                        "An error occurred. Please try again.");
                                                  }
                                                }

                                                showDialog<void>(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          notifires.getboxcolor,
                                                      content:
                                                          SingleChildScrollView(
                                                        child: ListBody(
                                                          children: <Widget>[
                                                            const Icon(
                                                              Icons.error,
                                                              size: 75,
                                                              color: Colors.red,
                                                            ),
                                                            Text(
                                                              'Do you want to deliver this vehicle?'
                                                                  .tr,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: regular2(
                                                                  context),
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
                                                                  child:
                                                                      InkWell(
                                                                    onTap: () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8,
                                                                          right:
                                                                              8),
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              notifires.getGrey2Whitecolor,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          "No".tr,
                                                                          style:
                                                                              boldstyle(context),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  child:
                                                                      InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      Navigator.pop(
                                                                          context);
                                                                      final value = await updateItemDeliverStatus(
                                                                          bookingId: list[index]
                                                                              .id
                                                                              .toString());
                                                                      list[index]
                                                                              .isItemDeliveredSetter =
                                                                          value;
                                                                      setState(
                                                                          () {});
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      margin: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8,
                                                                          right:
                                                                              8),
                                                                      padding: const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              getColorBasedOnActiveModuleid(),
                                                                        ),
                                                                        color:
                                                                            getColorBasedOnActiveModuleid(),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                      ),
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          "Yes"
                                                                              .tr,
                                                                          style:
                                                                              boldstyle(context).copyWith(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 8,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              },
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10),
                                                child: Container(
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 9, bottom: 9),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          color:
                                                              getColorBasedOnActiveModuleid()),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color:
                                                          getColorBasedOnActiveModuleid()),
                                                  child: Text("Is Deliver?".tr,
                                                      style: boldstyle(context)
                                                          .copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14)),
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox()
                                    : const SizedBox(),
                                list[index].status == "Completed"
                                    ? listType == 'Previous' &&
                                            list[index].isItemReturned == 1
                                        ? SizedBox()
                                        : const SizedBox()
                                    : const SizedBox(),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            listType != 'Cancelled' &&
                                    listType != 'UpComing' &&
                                    digitalsingnature == "Active"
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (builder) =>
                                              DigitalSignature(
                                            bookings: list[index],
                                            fromPropBooking: fromPropBooking,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      height: 45,
                                      alignment: Alignment.center,
                                      padding: const EdgeInsets.only(
                                          left: 10,
                                          right: 10,
                                          top: 0,
                                          bottom: 0),
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
                                  )
                                : const SizedBox(),
                            listType != 'Cancelled' && listType != 'UpComing'
                                ? SizedBox(
                                    height: 10,
                                  )
                                : const SizedBox(),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => HostEreciept(
                                              bookings: list[index],
                                              fromPropBooking: fromPropBooking,
                                              conformBooking:
                                                  listType == "UpComing"
                                                      ? "UpComing"
                                                      : "",
                                            ))).then((value) {
                                  if (value != null) {
                                    list[index].statusSetter = value;
                                    setState(() {});
                                  }
                                });
                              },
                              child: Container(
                                height: 45,
                                alignment: Alignment.center,
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 0, bottom: 0),
                                decoration: BoxDecoration(
                                  border: Border.all(color: greensColor),
                                  borderRadius: BorderRadius.circular(13),
                                  color: greensColor,
                                ),
                                child: Text(
                                  "Reciept".tr,
                                  style: boldstyle(context).copyWith(
                                    color: whiteColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      });
}

bottomSheetHostReviewed(rating, text) {
  return SingleChildScrollView(
    child: Column(
      children: [
        // Title: Review by you
        Text(
          "Review by you".tr,
          style: heading02.copyWith(color: grey1),
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

        // Divider line
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

        // Star rating
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
            // color: CustomTheme.theamColor,
          ),
          onRatingUpdate: (rating) {},
        ),
        const SizedBox(
          height: 10,
        ),

        // Review text
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
          child: Text(
            text,
            style: heading03.copyWith(color: grey2),
          ),
        ),

        const SizedBox(
          height: 50,
        ),
      ],
    ),
  );
}

TextEditingController textEditingControllerReview = TextEditingController();
bottomSheetHostReview(id, count, bool fromPropBooking, Bookings bookings,
    StateSetter setState, context) {
  return Container(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    // height: 600,
    child: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Leave a Review".tr,
            style: TextStyle(
                fontSize: 20,
                // fontFamily: FontStyles.gilroyBold,
                color: getColorBasedOnActiveModuleid()),
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
                  // fontFamily: FontStyles.gilroyMedium,
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
                color: notifires.getblackwhitecolor,
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
                    // fontFamily: FontStyles.gilroyMedium,
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
                  // fontFamily: FontStyles.gilroyMedium,
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
                    '$count/150   ',
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
                      color: getColorBasedOnActiveModuleid().withOpacity(.3)),
                  child: Text("Maybe Later".tr,
                      style: const TextStyle(
                          // color: ThemeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
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
                  var response = await httpPost(Config.giveReviewByHost, {
                    "rating":
                        "${generalScopeController.selectedRatingValue.value.toInt()}",
                    "message": textEditingControllerReview.text,
                    "booking_id": '$id'
                  });

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
                      color: getColorBasedOnActiveModuleid()),
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

class Avability extends StatelessWidget {
  final Color color;
  final Color borderColor;
  const Avability({super.key, required this.color, required this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
          color: color,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
    );
  }
}

// asalystic overviewwidget
// Widget analyticOverview(
//     String imageapath, String tttle, String subtittle, BuildContext context) {
//   return Card(
//     color: notifires.getblackwhitecolor,
//     child: Padding(
//       padding: const EdgeInsets.only(left: 8, right: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const SizedBox(
//             height: 10,
//           ),
//           SizedBox(
//             height: 30,
//             width: 30,
//             child: Card(
//               child: SvgPicture.asset(imageapath),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.only(left: 7),
//             child: Text(tttle.tr, style: heading2(context)),
//           ),
//           Text(subtittle.tr, style: regular2(context)),
//         ],
//       ),
//     ),
//   );
// }

Widget analyticOverview(
    String imageapath, String tttle, String subtittle, BuildContext context) {
  return Container(
    height: 70,
    decoration: BoxDecoration(
        color: notifires.getBoxColor, borderRadius: BorderRadius.circular(15)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            height: 40,
            width: 40,
            child: Card(
              child: SvgPicture.asset(imageapath),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tttle.tr,
                  style:
                      heading2(context).copyWith(fontWeight: FontWeight.bold)),
              Text(subtittle.tr, style: regular2(context)),
            ],
          ),
        ],
      ),
    ),
  );
}

void searchForHost(BuildContext context) {
  if (webPlateForm) {
    Get.toNamed(WebRoutes.hostSearch);
    return;
  }
  showModalBottomSheet(
    useRootNavigator: true,
    backgroundColor: notifires.getblackwhitecolor,
    isScrollControlled: true,
    useSafeArea: true,
    context: context,
    builder: (BuildContext context) {
      return const HostSearchScreen();
    },
  );
}

Future showPopUpScreen(BuildContext context, var className) {
  return showModalBottomSheet(
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(15), topLeft: Radius.circular(15))),
    useSafeArea: true,
    context: context,
    builder: (BuildContext context) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: className,
          ),
          Positioned(
              right: 5,
              top: 10,
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ))
        ],
      );
    },
  );
}

Future showPopUpScreenForShort(BuildContext context, var className) {
  return showModalBottomSheet(
    constraints:
        const BoxConstraints.expand(width: double.infinity, height: 350),
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(15), topLeft: Radius.circular(15))),
    useSafeArea: true,
    context: context,
    builder: (BuildContext context) {
      return Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: className,
          ),
          Positioned(
              left: 0,
              right: 0,
              top: 10,
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.cancel_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ))
        ],
      );
    },
  );
}

String staticContantforHostDeleteMsg() {
  if (activeModuleId.value == 1) {
    return "Property".tr;
  } else if (activeModuleId.value == 2) {
    return "Vehicle".tr;
  } else if (activeModuleId.value == 3) {
    return "Boat".tr;
  } else if (activeModuleId.value == 4) {
    return "Parking".tr;
  } else if (activeModuleId.value == 5) {
    return "Bookable".tr;
  } else if (activeModuleId.value == 6) {
    return "Space".tr;
  }

  return "";
}
