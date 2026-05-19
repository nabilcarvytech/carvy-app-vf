import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/custom_check_box.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/utils/vehicle_common_widgets.dart';
import 'package:carvy/work_space.dart';

class VehicleFilter extends StatefulWidget {
  final bool? mode;
  final bool? forsearch;
  final bool? forHome;
  final VoidCallback? onRefresh;
  final VoidCallback? onMapRefresh;
  const VehicleFilter(
      {super.key,
      this.mode,
      this.onRefresh,
      this.forsearch,
      this.onMapRefresh,
      this.forHome});
  @override
  State<VehicleFilter> createState() => _VehicleFilterState();
}

class _VehicleFilterState extends State<VehicleFilter> {
  SearchControllerHome filterController = Get.find();
  RangeValues currentRangeValues = const RangeValues(40, 1000);
  static const double _uiMaxPriceLimit = 20000.0;

  late final TextEditingController _minPriceController;
  late final TextEditingController _maxPriceController;
  bool _syncingPriceFieldsFromSlider = false;

  double get _sliderMinBound =>
      parseDoubleValue(minPricerange?.toString()) ?? 10.0;
  double? parseDoubleValue(String? stringValue) {
    if (stringValue != null && stringValue.isNotEmpty) {
      try {
        return double.parse(stringValue);
      } catch (e) {}
    }
    return null;
  }

  double height = 13;
  List<dynamic> years = [];
  List<dynamic> generateYearsList() {
    dynamic currentYear = DateTime.now().year;
    // Afficher seulement les 6 dernières années
    for (int i = currentYear; i >= currentYear - 5; i--) {
      years.add(i);
    }
    return years;
  }

// Copy
  void validateRangeValues() {
    double minPrice = double.parse("${minPricerange!}");
    double maxPrice = _uiMaxPriceLimit;

    double startValue = filterController.startRange.value;
    double endValue = filterController.endRage.value;

    startValue = startValue < minPrice ? minPrice : startValue;
    startValue = startValue > maxPrice ? maxPrice : startValue;

    endValue = endValue < minPrice ? minPrice : endValue;
    endValue = endValue > maxPrice ? maxPrice : endValue;

    currentRangeValues = RangeValues(startValue, endValue);
  }

  @override
  void initState() {
    super.initState();
    _minPriceController = TextEditingController();
    _maxPriceController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      generateYearsList();
      final double minPrice = double.tryParse("$minPricerange") ?? 0.0;
      final double effectiveMaxPrice = _uiMaxPriceLimit;

      currentRangeValues = RangeValues(
        minPrice,
        effectiveMaxPrice,
      );
      String startRangeString = currentRangeValues.start.toStringAsFixed(0);
      String endRangeString = currentRangeValues.end.toStringAsFixed(0);
      filterController.startRange.value = double.parse(startRangeString);
      filterController.endRage.value = double.parse(endRangeString);

      _syncingPriceFieldsFromSlider = true;
      _minPriceController.text = startRangeString;
      _maxPriceController.text = endRangeString;
      _syncingPriceFieldsFromSlider = false;

      filterController.filterApiBasedOnModule();
      filterController.dataChangedBasedOnModuleid();
      setState(() {});
    });
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  /// Validation clavier : pas de défaut si champ vide ; clamp [min, max] seulement ici.
  void _commitPriceRangeFromKeyboard() {
    _commitPriceRangeFromInputs(applyDefaultsForEmpty: false);
  }

  /// Bouton Appliquer : champs vides → défauts (min API / 10, max 20 000), puis clamp.
  void _commitPriceRangeForApply() {
    _commitPriceRangeFromInputs(applyDefaultsForEmpty: true);
  }

  void _commitPriceRangeFromInputs({required bool applyDefaultsForEmpty}) {
    if (!mounted) return;

    final minRaw = _minPriceController.text.trim();
    final maxRaw = _maxPriceController.text.trim();

    double start = currentRangeValues.start;
    double end = currentRangeValues.end;

    if (applyDefaultsForEmpty) {
      final minParsed = minRaw.isEmpty ? null : double.tryParse(minRaw);
      final maxParsed = maxRaw.isEmpty ? null : double.tryParse(maxRaw);
      start = (minParsed ?? _sliderMinBound).clamp(_sliderMinBound, _uiMaxPriceLimit);
      end = (maxParsed ?? _uiMaxPriceLimit).clamp(_sliderMinBound, _uiMaxPriceLimit);
      if (start > end) {
        start = end;
      }
    } else {
      bool touched = false;
      if (minRaw.isNotEmpty) {
        final p = double.tryParse(minRaw);
        if (p != null) {
          start = p.clamp(_sliderMinBound, _uiMaxPriceLimit);
          touched = true;
        }
      }
      if (maxRaw.isNotEmpty) {
        final p = double.tryParse(maxRaw);
        if (p != null) {
          end = p.clamp(_sliderMinBound, _uiMaxPriceLimit);
          touched = true;
        }
      }
      if (!touched) {
        return;
      }
      if (start > end) {
        start = end;
      }
    }

    setState(() {
      currentRangeValues = RangeValues(start, end);
      filterController.startRange.value = start;
      filterController.endRage.value = end;
    });

    final minStr = start.round().toString();
    final maxStr = end.round().toString();

    if (applyDefaultsForEmpty) {
      _setPriceFieldTextIfChanged(_minPriceController, minStr);
      _setPriceFieldTextIfChanged(_maxPriceController, maxStr);
    } else {
      if (minRaw.isNotEmpty) {
        _setPriceFieldTextIfChanged(_minPriceController, minStr);
      }
      if (maxRaw.isNotEmpty) {
        _setPriceFieldTextIfChanged(_maxPriceController, maxStr);
      }
    }
  }

  void _setPriceFieldTextIfChanged(
    TextEditingController c,
    String newText,
  ) {
    if (c.text == newText) return;
    _syncingPriceFieldsFromSlider = true;
    c.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
    _syncingPriceFieldsFromSlider = false;
  }

  void _updatePriceFieldsFromSlider(RangeValues values) {
    final minStr = values.start.round().toString();
    final maxStr = values.end.round().toString();
    _syncingPriceFieldsFromSlider = true;
    if (_minPriceController.text != minStr) {
      _minPriceController.value = TextEditingValue(
        text: minStr,
        selection: TextSelection.collapsed(offset: minStr.length),
      );
    }
    if (_maxPriceController.text != maxStr) {
      _maxPriceController.value = TextEditingValue(
        text: maxStr,
        selection: TextSelection.collapsed(offset: maxStr.length),
      );
    }
    _syncingPriceFieldsFromSlider = false;
  }

  InputDecoration _priceFieldDecoration(BuildContext context, String label) {
    final borderColor = notifires.getwhiteblackcolor.withOpacity(0.22);
    return InputDecoration(
      labelText: label,
      suffixText: 'MAD',
      suffixStyle: regular3(context).copyWith(
        color: notifires.getGrey2Whitecolor,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: notifires.getblackwhitecolor,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: getColorBasedOnActiveModuleid(),
          width: 1.4,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          appBar: AppBar(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20))),
            backgroundColor: notifires.getBoxColor,
            scrolledUnderElevation: 0,
            title: Text(
              "Filter".tr,
              style: heading2Grey1(context),
            ),
            automaticallyImplyLeading: false,
            actions: [
              Container(
                padding: const EdgeInsets.only(right: 16),
                child: Center(
                  child: InkWell(
                      onTap: () {
                        filterController.clearFilter();
                        final double minPrice = double.tryParse("$minPricerange") ?? 0.0;
                        final double maxPrice = _uiMaxPriceLimit;
                        currentRangeValues = RangeValues(minPrice, maxPrice);
                        filterController.startRange.value = minPrice;
                        filterController.endRage.value = maxPrice;
                        filterController.selectedModelYear = [];
                        _updatePriceFieldsFromSlider(currentRangeValues);
                        setState(() {});
                      },
                      child: Text(
                        "Clear".tr,
                        style: regular2(context)
                            .copyWith(color: getColorBasedOnActiveModuleid()),
                      )),
                ),
              )
            ],
          ),
          body: GetBuilder<SearchControllerHome>(
            // Use GetBuilder
            builder: (controller) {
              return filterUi(context, controller);
            },
          ),
          bottomNavigationBar: Obx(
            () => filterController.isLoadingVehicle.value
                ? const SizedBox()
                : SafeArea(
                    child: Container(
                      padding: const EdgeInsets.only(
                          left: 25, right: 25, bottom: 10, top: 10),
                      height: 70,
                      child: CustomsButtons(
                        onPressed: () {
                          _commitPriceRangeForApply();
                          if (widget.mode == true) {
                            filterController.submitMethod(context);
                            return;
                          }
                          filterController.applyFiltersFromSheet(
                            context,
                            navigateToSearchResults: widget.forHome == true,
                            onMapRefresh: widget.forsearch == true
                                ? widget.onMapRefresh
                                : null,
                            refreshResults: widget.forHome != true &&
                                    widget.forsearch != true
                                ? widget.onRefresh
                                : null,
                          );
                        },
                        text: widget.mode == true ? 'Filters'.tr : "Apply".tr,
                        backgroundColor: getColorBasedOnActiveModuleid(),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget filterUi(context, controller) {
    return controller.isLoadingVehicle.value
        ? filterScreenShimmer()
        : Row(
            children: [
              Expanded(
                  child: Container(
                      height: double.maxFinite,
                      alignment: Alignment.topCenter,
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 15,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Price range".tr,
                                      style: heading2Grey1(context),
                                    ),
                                    const SizedBox(height: 12),
                                    Obx(
                                      () => generalController
                                                  .hasGeneralData.value ==
                                              true
                                          ? const Center(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 24),
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            )
                                          : Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            _minPriceController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        textInputAction:
                                                            TextInputAction
                                                                .next,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                        style: regular2(
                                                            context),
                                                        decoration:
                                                            _priceFieldDecoration(
                                                          context,
                                                          'Min'.tr,
                                                        ),
                                                        onEditingComplete:
                                                            _commitPriceRangeFromKeyboard,
                                                        onFieldSubmitted: (_) {
                                                          _commitPriceRangeFromKeyboard();
                                                          FocusScope.of(context)
                                                              .nextFocus();
                                                        },
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: TextFormField(
                                                        controller:
                                                            _maxPriceController,
                                                        keyboardType:
                                                            TextInputType
                                                                .number,
                                                        textInputAction:
                                                            TextInputAction
                                                                .done,
                                                        inputFormatters: [
                                                          FilteringTextInputFormatter
                                                              .digitsOnly,
                                                        ],
                                                        style: regular2(
                                                            context),
                                                        decoration:
                                                            _priceFieldDecoration(
                                                          context,
                                                          'Max'.tr,
                                                        ),
                                                        onEditingComplete:
                                                            _commitPriceRangeFromKeyboard,
                                                        onFieldSubmitted: (_) {
                                                          _commitPriceRangeFromKeyboard();
                                                          FocusScope.of(context)
                                                              .unfocus();
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Transform.scale(
                                                  scale: 1.07,
                                                  child: RangeSlider(
                                                    values: currentRangeValues,
                                                    activeColor:
                                                        getColorBasedOnActiveModuleid(),
                                                    inactiveColor: Colors.grey,
                                                    max: _uiMaxPriceLimit,
                                                    min: _sliderMinBound,
                                                    labels: RangeLabels(
                                                      filterController
                                                          .startRange.value
                                                          .toInt()
                                                          .toString(),
                                                      filterController
                                                          .endRage.value
                                                          .toInt()
                                                          .toString(),
                                                    ),
                                                    onChanged:
                                                        (RangeValues values) {
                                                      setState(() {
                                                        currentRangeValues =
                                                            values;
                                                        filterController
                                                                .startRange
                                                                .value =
                                                            values.start;
                                                        filterController
                                                                .endRage
                                                                .value =
                                                            values.end;
                                                      });
                                                      _updatePriceFieldsFromSlider(
                                                          values);
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                // Politique d'annulation
                                Text(
                                  "Politique d'annulation".tr,
                                  style: heading2Grey1(context),
                                ),
                                const SizedBox(height: 8),
                                Obx(() {
                                  final refundable = filterController.isRefundableOnly.value;
                                  return Wrap(
                                    spacing: 8,
                                    children: [
                                      ChoiceChip(
                                        label: Text('Toutes'.tr),
                                        selected: !refundable,
                                        onSelected: (v) {
                                          if (v) {
                                            filterController.isRefundableOnly.value = false;
                                            setState(() {});
                                          }
                                        },
                                      ),
                                      ChoiceChip(
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.payments_outlined, size: 16),
                                            const SizedBox(width: 6),
                                            Text('Remboursable'.tr),
                                          ],
                                        ),
                                        selected: refundable,
                                        onSelected: (v) {
                                          if (v) {
                                            filterController.isRefundableOnly.value = true;
                                            setState(() {});
                                          }
                                        },
                                      ),
                                    ],
                                  );
                                }),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                // Type d'assurance
                                Text(
                                  "Type d'assurance".tr,
                                  style: heading2Grey1(context),
                                ),
                                const SizedBox(height: 10),
                                Obx(() {
                                  final sel = filterController.selectedInsurance.value;
                                  Color activeColor = const Color(0xFF27489E);
                                  return Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(12),
                                          onTap: () {
                                            // Toggle: si déjà sélectionné, désélectionner
                                            if (sel == 'BASIC') {
                                              filterController.selectedInsurance.value = '';
                                            } else {
                                              filterController.selectedInsurance.value = 'BASIC';
                                            }
                                            setState(() {});
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 180),
                                            curve: Curves.easeInOut,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            decoration: BoxDecoration(
                                              color: sel == 'BASIC' ? activeColor : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: sel == 'BASIC' ? activeColor : Colors.grey.shade400,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.security, size: 18, color: sel == 'BASIC' ? Colors.white : Colors.black87),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'BASIC'.tr,
                                                  style: TextStyle(
                                                    color: sel == 'BASIC' ? Colors.white : Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(12),
                                          onTap: () {
                                            if (sel == 'FULL') {
                                              filterController.selectedInsurance.value = '';
                                            } else {
                                              filterController.selectedInsurance.value = 'FULL';
                                            }
                                            setState(() {});
                                          },
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 180),
                                            curve: Curves.easeInOut,
                                            padding: const EdgeInsets.symmetric(vertical: 14),
                                            decoration: BoxDecoration(
                                              color: sel == 'FULL' ? activeColor : Colors.transparent,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: sel == 'FULL' ? activeColor : Colors.grey.shade400,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.security, size: 18, color: sel == 'FULL' ? Colors.white : Colors.black87),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'FULL'.tr,
                                                  style: TextStyle(
                                                    color: sel == 'FULL' ? Colors.white : Colors.black87,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Make Type".tr,
                                  style: heading2Grey1(context),
                                ),
                                // NOUVEAU: Widget BrandMultiSelect avec recherche
                                if (filterController
                                        .makeTypeModel?.data?.makes !=
                                    null)
                                  BrandMultiSelect(
                                    makes: filterController
                                        .makeTypeModel!.data!.makes!,
                                  ),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Features".tr,
                                  style: heading2Grey1(context),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyCustomCheckBox(
                                        initialValue: filterController
                                                .amenitiesModelVehicle
                                                ?.data
                                                ?.amenities
                                                ?.map((itemType) => itemType.id)
                                                .toList() ??
                                            [],
                                        options: filterController
                                                .amenitiesModelVehicle
                                                ?.data
                                                ?.amenities
                                                ?.map(
                                                    (itemType) => itemType.name)
                                                .toList() ??
                                            [],
                                        searchHintText: "Search features..",
                                        isOdometer: false,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Odometers".tr,
                                  style: heading2Grey1(context),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyCustomCheckBox(
                                        initialValue: filterController
                                                .odometerModelVehicle
                                                ?.data
                                                ?.odometerList
                                                ?.map((itemType) => itemType.id)
                                                .toList() ??
                                            [],
                                        options: filterController
                                                .odometerModelVehicle
                                                ?.data
                                                ?.odometerList
                                                ?.map((itemType) => itemType.name)
                                                .toList() ??
                                            [],
                                        searchHintText: "Search features..",
                                        isOdometer: true,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "Model year".tr,
                                  style: heading2Grey1(context),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      MyCustomCheckBoxModelYear(
                                        initialValue: years,
                                        options: years,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                // NOUVEAU: Filtre type de carburant
                                Text(
                                  "Fuel Type".tr,
                                  style: heading2Grey1(context),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (filterController.fuelTypeModelFilter !=
                                          null)
                                        MyCustomCheckBoxFuelType(
                                          fuelTypes: filterController
                                              .fuelTypeModelFilter!.fuelTypes,
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                buildDividervehicle(),
                                const SizedBox(
                                  height: 15,
                                ),
                                // NOUVEAU: Filtre transmission
                                Text(
                                  "Transmission".tr,
                                  style: heading2Grey1(context),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (filterController
                                                  .transmissionModelFilter !=
                                              null &&
                                          filterController
                                                  .transmissionModelFilter!
                                                  .data !=
                                              null)
                                        MyCustomCheckBoxTransmission(
                                          transmissions: filterController
                                                  .transmissionModelFilter!
                                                  .data!
                                                  .options ??
                                              [],
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 30,
                                ),
                              ]),
                        ),
                      )))
            ],
          );
  }
}
