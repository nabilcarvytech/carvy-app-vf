import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/home_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/model/items_model.dart';
import 'package:carvy/helper/city_name_helper.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/rental_billing_days.dart';
import 'package:carvy/utils/rolling_calendar_bounds.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:get/get.dart';
import 'package:carvy/view/itemdetail/vehicle/view_on_map_screen.dart';
import '../../api/config.dart';
import '../../controller/search_controller.dart';
import '../../utils/vehicle_common_widgets.dart';
import '../../work_space.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late HomeController homeController;
  late SearchControllerHome _searchController;
  late FocusNode _focusNode;
  List<Items>? list = [];
  ItemModel? itemModel;
  bool showAll = false;

  @override
  void initState() {
    super.initState();
    if (handleSearchFordetail == true) {
      currentTabIndexforLocation = 1;
    }
    homeController = Get.find();
    _searchController = Get.find();
    _focusNode = FocusNode();
    generalScopeController.textEditingControllerCity.addListener(clear);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
      _searchController.sendvalueInApiforrecentValue.value = false;
    });
  }

  RentalBillingSummary? _vehicleSearchScreenRentalSummary() {
    if (activeModuleId.value != 2) return null;
    final s = generalScopeController.startDateCustomDate.value.trim();
    final e = generalScopeController.endDateCustomDate.value.trim();
    if (s.isEmpty || e.isEmpty) return null;
    final startD = DateTime.tryParse(s);
    final endD = DateTime.tryParse(e);
    if (startD == null || endD == null) return null;
    return RentalBillingDays.compute(
      startDate: startD,
      endDate: endD,
      startTime: RentalBillingDays.parseTimeOfDayFromSlot(
          _searchController.startTimeSearch.value),
      endTime: RentalBillingDays.parseTimeOfDayFromSlot(
          _searchController.endTimeSearch.value),
    );
  }

  Future<void> searchMethod() async {
    itemModel = null;
    list = [];
    setState(() {});
    showLoading();
    try {
      final price = _searchController.resolveSearchPriceParam();
      var result = await _searchController.searchItems(
        '',
        _searchController.selectedtypesvalues.toString(),
        price,
        '0',
        '0',
        _searchController.featuresvalues.toString(),
        "1000",
        generalScopeController.startDateCustomDate.value.toString(),
        generalScopeController.endDateCustomDate.value.toString(),
        activeModuleId.value == 1 ? "0" : "0",
        "$slatsearch",
        "$sLongSearch",
        context,
        _searchController.maketypeFunction(),
      );

      itemModel = ItemModel.fromJson(result);
      list!.addAll(itemModel!.data!.items!);
      _searchController.searchFilterList.addAll(itemModel!.data!.items!);
      _searchController.offset = itemModel!.data!.offset!;
      setState(() {
        if (list!.isNotEmpty) {
          closeLoading();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => ViewOnMapScreen(title: "", list: list),
            ),
          );
        } else {
          closeLoading();
          showErrorToastMessage("Data not found!".tr);
        }
      });
    } catch (error) {
      closeLoading();
    }
  }

  void clear() {
    if (generalScopeController.textEditingControllerCity.text.isEmpty) {
      sLongSearch = "";
      slatsearch = "";
      generalScopeController.slat = "";
      generalScopeController.sLong = "";
      generalScopeController.textEditingControllerCity.clear();
      generalScopeController.homeSearchLocation.value = "";
    }
  }

  @override
  void dispose() {
    generalScopeController.textEditingControllerCity.removeListener(clear);
    _focusNode.dispose();
    super.dispose();
  }

  void search() {
    if (slatsearch.toString().isNotEmpty && sLongSearch.toString().isNotEmpty) {
      if (_searchController.hitApiOnMap == true) {
        searchMethod();
      } else if (_searchController.startDate.value == "" &&
          _searchController.endDates.value == "") {
        setState(() {
          FocusManager.instance.primaryFocus?.unfocus();
          currentTabIndexforLocation = 1;
        });
      } else if (generalScopeController.homeSearchLocation.value != "") {
        _searchController.submitMethod(context);
      }
    } else {
      _searchController.submitMethod(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          appBar: AppBar(
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            backgroundColor: notifires.getbgcolor,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () {
                  _searchController.clearFilter();
                },
                icon: Icon(
                  size: 27,
                  Icons.delete_forever,
                  color: notifires.getGrey2Whitecolor,
                ),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 9, right: 9),
            child: IndexedStack(
              index: currentTabIndexforLocation,
              children: [
                ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Where'.tr,
                            style: heading2Grey1(context).copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: notifires.getwhiteblackcolor,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 40,
                            child: Stack(
                              alignment: Alignment.centerRight,
                              children: [
                                GooglePlaceAutoCompleteTextField(
                                  textStyle: regular2(context),
                                  boxDecoration: BoxDecoration(
                                      color: notifires.getboxcolor,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: notifires.getGrey2Whitecolor,
                                          width: 1)),
                                  isLatLngRequired: true,
                                  textEditingController: generalScopeController
                                      .textEditingControllerCity,
                                  googleAPIKey: Config.googleKey,
                                  countries: null,
                                  inputDecoration: InputDecoration(
                                      prefixIcon: Icon(
                                        Icons.search,
                                        color: notifires.getgreycolor,
                                      ),
                                      contentPadding: const EdgeInsets.only(
                                          left: 10, top: 2, right: 10),
                                      hintStyle: regular3(context),
                                      hintText: "Search location".tr,
                                      border: InputBorder.none),
                                  getPlaceDetailWithLatLng:
                                      (Prediction prediction) {
                                    setState(() {
                                      slatsearch = prediction.lat.toString();
                                      sLongSearch = prediction.lng.toString();
                                      _searchController.getPlaceDetailFromId(
                                          prediction.placeId);
                                      _searchController
                                          .setBoolForCurrentLocation
                                          .value = false;
                                      generalScopeController.citySelected =
                                          generalScopeController
                                              .textEditingControllerCity.text;
                                      generalScopeController
                                          .textEditingControllerCity
                                          .text = prediction.description!;
                                      generalScopeController.homeSearchLocation
                                          .value = prediction.description!;
                                      generalScopeController
                                              .textEditingControllerCity
                                              .selection =
                                          TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: prediction
                                                      .description!.length));
                                      FocusScope.of(context).unfocus();
                                      search();
                                    });
                                  },
                                  itemClick: (Prediction prediction) {},
                                  itemBuilder:
                                      (context, index, Prediction prediction) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: notifires.getboxcolor,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 0, vertical: 0),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 2),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.location_on,
                                                  color: notifires.getgreycolor,
                                                ),
                                                const SizedBox(width: 7),
                                                Expanded(
                                                  child: Text(
                                                    prediction.description ??
                                                        "",
                                                    style: normalAirBk.copyWith(
                                                        color: notifires
                                                            .getwhiteblackcolor),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Divider(
                                            color: notifires.getgreycolor,
                                            thickness: 1,
                                          ),
                                          const SizedBox(height: 5),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                GestureDetector(
                                  onTap: () {
                                    generalScopeController
                                        .textEditingControllerCity
                                        .clear();
                                    generalScopeController.citySelected = "";
                                    generalScopeController
                                        .homeSearchLocation.value = "";
                                    slatsearch = "";
                                    sLongSearch = "";
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    color: Colors.transparent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              _searchController
                                  .getUserLocationForBetterSearch(context)
                                  .then((_) {
                                if (_searchController.hitApiOnMap == true) {
                                  searchMethod();
                                }
                              });
                            },
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        getColorBasedOnActiveModuleid()
                                            .withOpacity(0.2),
                                        getColorBasedOnActiveModuleid()
                                            .withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(CupertinoIcons.location),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Around Current Location'.tr,
                                        style: heading2Grey1(context).copyWith(
                                          fontSize: 15,
                                          color: notifires.getwhiteblackcolor,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "Tap here".tr,
                                        style: regular3(context).copyWith(
                                          fontSize: 13,
                                          color: notifires.getGrey1Whitecolor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                textAlign: TextAlign.start,
                                'Popular Regions'.tr,
                                style: heading2Grey1(context).copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: notifires.getwhiteblackcolor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Obx(
                            () => homeController.homeDataLoading.value == true
                                ? Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<
                                                  Color>(
                                              getColorBasedOnActiveModuleid()),
                                          strokeWidth: 2,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Discovering destinations...'.tr,
                                          style: regular3(context).copyWith(
                                            color: notifires.getGrey1Whitecolor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: showAll
                                        ? homeController.homeDataModel!.data!
                                            .locations!.length
                                        : (homeController.homeDataModel!.data!
                                                    .locations!.length >
                                                8
                                            ? 8
                                            : homeController.homeDataModel!
                                                .data!.locations!.length),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 4,
                                      mainAxisExtent: 85,
                                      mainAxisSpacing: 12,
                                      crossAxisSpacing: 12,
                                    ),
                                    itemBuilder: (context, index) {
                                      final location = homeController
                                          .homeDataModel!
                                          .data!
                                          .locations![index];
                                      final isSelected = generalScopeController
                                              .homeSearchLocation.value ==
                                          location.cityName;
                                      return AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 250),
                                        curve: Curves.easeInOut,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSelected
                                                ? getColorBasedOnActiveModuleid()
                                                : notifires.getGrey2Whitecolor
                                                    .withOpacity(0.3),
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                  isSelected ? 0.12 : 0.06),
                                              blurRadius: isSelected ? 10 : 6,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                          gradient: isSelected
                                              ? LinearGradient(
                                                  colors: [
                                                    getColorBasedOnActiveModuleid()
                                                        .withOpacity(0.15),
                                                    Colors.transparent,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                )
                                              : null,
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            onTap: () {
                                              if (location.latitude != null &&
                                                  location.longitude != null) {
                                                // Nettoyer les coordonnées (retirer ° N, ° W, etc.)
                                                String cleanLat = location
                                                    .latitude!
                                                    .replaceAll(
                                                        RegExp(r'[°\s]'), '')
                                                    .replaceAll('N', '')
                                                    .replaceAll('S', '')
                                                    .trim();
                                                String cleanLng = location
                                                    .longitude!
                                                    .replaceAll(
                                                        RegExp(r'[°\s]'), '')
                                                    .replaceAll('E', '')
                                                    .replaceAll('W', '')
                                                    .trim();

                                                slatsearch = cleanLat;
                                                sLongSearch = cleanLng;
                                                // Mettre à jour setCity pour le filtre API
                                                _searchController.setCity =
                                                    location.cityName ?? '';
                                                generalScopeController
                                                    .homeSearchLocation
                                                    .value = location.cityName!;
                                                generalScopeController
                                                    .textEditingControllerCity
                                                    .text = location.cityName!;
                                                search();
                                              } else {
                                                slatsearch = "";
                                                sLongSearch = "";
                                              }
                                            },
                                            splashColor:
                                                getColorBasedOnActiveModuleid()
                                                    .withOpacity(0.3),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Stack(
                                                children: [
                                                  myNetworkImage(
                                                    "${location.image}",
                                                  ),
                                                  Positioned.fill(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          stops: const [
                                                            0.7,
                                                            1.0
                                                          ],
                                                          colors: [
                                                            Colors.transparent,
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.8),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0,
                                                    child: Container(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8),
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter,
                                                          colors: [
                                                            Colors.transparent,
                                                            Colors.black
                                                                .withOpacity(
                                                                    0.9),
                                                          ],
                                                        ),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(3),
                                                            decoration:
                                                                BoxDecoration(
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.2),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                            ),
                                                            child: Icon(
                                                              Icons.place,
                                                              color: whiteColor,
                                                              size: 10,
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Expanded(
                                                            child: Text(
                                                              CityNameHelper
                                                                  .displayName(
                                                                location
                                                                    .cityName,
                                                              ),
                                                              style: boldstyle(
                                                                      context)
                                                                  .copyWith(
                                                                color:
                                                                    whiteColor,
                                                                fontSize: 11,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              softWrap: true,
                                                            ),
                                                          ),
                                                          if (isSelected)
                                                            Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(2),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color:
                                                                    getColorBasedOnActiveModuleid(),
                                                                shape: BoxShape
                                                                    .circle,
                                                              ),
                                                              child: Icon(
                                                                Icons.check,
                                                                color:
                                                                    whiteColor,
                                                                size: 12,
                                                              ),
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
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  showAll = !showAll;
                                });
                              },
                              icon: Icon(
                                showAll ? Icons.expand_less : Icons.expand_more,
                                size: 18,
                                color: getColorBasedOnActiveModuleid(),
                              ),
                              label: Text(
                                showAll ? "See Less".tr : "See More".tr,
                                style: regular2(context).copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: getColorBasedOnActiveModuleid(),
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: getColorBasedOnActiveModuleid()
                                      .withOpacity(0.3),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor:
                                    notifires.getboxcolor.withOpacity(0.5),
                                elevation: 1,
                                shadowColor: getColorBasedOnActiveModuleid()
                                    .withOpacity(0.1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          currentTabIndexforLocation = 1;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: notifires.getboxcolor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color:
                                  notifires.getGrey2Whitecolor.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: notifires.getboxcolor.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: getColorBasedOnActiveModuleid()
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: getColorBasedOnActiveModuleid(),
                                    size: 20,
                                  ),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Obx(() {
                                    final hasRange = _searchController
                                                .startDate.value.isNotEmpty &&
                                            _searchController
                                                .endDates.value.isNotEmpty;
                                    final gsStart = generalScopeController
                                        .startDateCustomDate.value;
                                    final gsEnd = generalScopeController
                                        .endDateCustomDate.value;
                                    final vehicleSummary =
                                        activeModuleId.value == 2 &&
                                                hasRange &&
                                                gsStart.isNotEmpty &&
                                                gsEnd.isNotEmpty
                                            ? _vehicleSearchScreenRentalSummary()
                                            : null;
                                    final hasExtra =
                                        vehicleSummary?.hasExtraDay ?? false;

                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hasRange
                                              ? "Selected Date Range".tr
                                              : "Select your dates".tr,
                                          style: regular2(context).copyWith(
                                            fontSize: 12,
                                            color: notifires
                                                .getGrey1Whitecolor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (!hasRange)
                                          Text(
                                            "Tap to select dates".tr,
                                            style: regular3(context).copyWith(
                                              fontSize: 14,
                                              color: notifires
                                                  .getwhiteblackcolor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )
                                        else if (activeModuleId.value == 2)
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${_searchController.startDate.value} ${_searchController.startTimeSearch.value} - ',
                                                  style: regular3(context)
                                                      .copyWith(
                                                    fontSize: 14,
                                                    color: notifires
                                                        .getwhiteblackcolor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              Flexible(
                                                child:
                                                    VehicleReturnDateWithBillingBadgeRow(
                                                  dateText:
                                                      '${_searchController.endDates.value} ${_searchController.endTimeSearch.value}',
                                                  textAlign: TextAlign.start,
                                                  isExtraDay: hasExtra,
                                                  emphasizeOvertime: hasExtra,
                                                ),
                                              ),
                                            ],
                                          )
                                        else
                                          Text(
                                            "${_searchController.startDate.value} ${_searchController.startTimeSearch.value} - ${_searchController.endDates.value} ${_searchController.endTimeSearch.value}",
                                            style:
                                                regular3(context).copyWith(
                                              fontSize: 14,
                                              color: notifires
                                                  .getwhiteblackcolor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                      ],
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                ListView(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (handleSearchFordetail == true) {
                          return;
                        }
                        setState(() {
                          currentTabIndexforLocation = 0;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: notifires.getboxcolor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                notifires.getGrey2Whitecolor.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: notifires.getboxcolor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: getColorBasedOnActiveModuleid()
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.location_on,
                                  color: getColorBasedOnActiveModuleid(),
                                  size: 20,
                                ),
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Expanded(
                                child: Obx(() => Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Location".tr,
                                          style: regular2(context).copyWith(
                                            fontSize: 12,
                                            color: notifires.getGrey1Whitecolor,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          generalScopeController
                                                      .homeSearchLocation
                                                      .value
                                                      .length >
                                                  20
                                              ? "${generalScopeController.homeSearchLocation.value.substring(0, 17)}..."
                                              : generalScopeController
                                                      .homeSearchLocation
                                                      .value
                                                      .isEmpty
                                                  ? "All location".tr
                                                  : generalScopeController
                                                      .homeSearchLocation.value,
                                          style: regular3(context).copyWith(
                                            fontSize: 14,
                                            color:
                                                getColorBasedOnActiveModuleid(),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 550,
                      decoration: BoxDecoration(
                        color: notifires.getboxcolor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: notifires.getGrey2Whitecolor.withOpacity(0.3),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            SizedBox(
                              height: 550,
                              child: SfDateRangePicker(
                                startRangeSelectionColor: Colors.transparent,
                                endRangeSelectionColor: Colors.transparent,
                                rangeSelectionColor: Colors.transparent,
                                selectionColor: Colors.transparent,
                                navigationDirection: DateRangePickerNavigationDirection.vertical,
                                navigationMode: DateRangePickerNavigationMode.scroll,
                                enableMultiView: true,
                                backgroundColor: Colors.white,
                                headerStyle: DateRangePickerHeaderStyle(
                                  backgroundColor: Colors.white,
                                  textAlign: TextAlign.left,
                                  textStyle: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                monthCellStyle: DateRangePickerMonthCellStyle(
                                  todayTextStyle: TextStyle(
                                    color: getColorBasedOnActiveModuleid(),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  weekendTextStyle: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                  ),
                                  textStyle: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 16,
                                  ),
                                  disabledDatesTextStyle:
                                      RollingCalendarBounds.disabledDateTextStyle(),
                                ),
                                monthViewSettings:
                                    DateRangePickerMonthViewSettings(
                                  dayFormat: "EEE",
                                  viewHeaderHeight: 50,
                                  viewHeaderStyle:
                                      DateRangePickerViewHeaderStyle(
                                    backgroundColor: Colors.white,
                                    textStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                minDate: RollingCalendarBounds.firstDate(),
                                maxDate: RollingCalendarBounds.lastDate(),
                                enablePastDates: false,
                                onViewChanged: (args) {
                                  RollingCalendarBounds.clampPickerView(
                                    args,
                                    _searchController
                                        .dateRangePickerControllerCustom,
                                  );
                                },
                                controller: _searchController
                                    .dateRangePickerControllerCustom,
                                selectionMode:
                                    DateRangePickerSelectionMode.range,
                                onSelectionChanged: (args) {
                                  _searchController
                                      .onSelectionChangedCustomDatePicker(args);
                                  if (args.value is PickerDateRange &&
                                      args.value.startDate != null &&
                                      args.value.endDate != null) {}
                                },
                                cellBuilder: (context, details) {
                                  final isDisabled =
                                      !RollingCalendarBounds.isSelectable(
                                          details.date);
                                  final range = _searchController
                                      .dateRangePickerControllerCustom
                                      .selectedRange;
                                  bool isStartDate = false;
                                  bool isEndDate = false;
                                  bool isInRange = false;
                                  
                                  if (range != null) {
                                    DateTime? start = range.startDate;
                                    DateTime? end = range.endDate;

                                    if (start != null) {
                                      isStartDate = isSameDate(details.date, start);
                                    }
                                    if (end != null) {
                                      isEndDate = isSameDate(details.date, end);
                                    }
                                    if (start != null && end != null) {
                                      isInRange = details.date.isAfter(start) &&
                                          details.date.isBefore(end);
                                    }
                                  }
                                  
                                  final bool isSelected = isStartDate || isEndDate || isInRange;
                                  final primaryColor = getColorBasedOnActiveModuleid();
                                  
                                  return Container(
                                    height: 65,
                                    margin: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: (isStartDate || isEndDate)
                                          ? primaryColor // Dark blue circle for start/end
                                          : isInRange
                                              ? primaryColor.withOpacity(0.15) // Very light blue for in-between
                                              : Colors.transparent,
                                      shape: BoxShape.circle, // Circular shape like Airbnb
                                      border: isDisabled
                                          ? Border.all(
                                              color: Colors.grey.shade300,
                                              width: 1,
                                            )
                                          : null,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      convertToLocaleDigits(
                                          "${details.date.day}"),
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: (isStartDate || isEndDate)
                                            ? FontWeight.bold
                                            : FontWeight.w600,
                                        color: isDisabled
                                            ? Colors.grey.shade400
                                            : (isStartDate || isEndDate)
                                                ? Colors.white // White text for start/end
                                                : isInRange
                                                    ? primaryColor // Primary color for in-between
                                                    : Colors.black87, // Black for normal days
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: notifires.getbgcolor,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Start Time".tr,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  notifires.getwhiteblackcolor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Obx(() {
                                            final startSlots =
                                                getSlotsStartTime();
                                            final si = startSlots.indexOf(
                                                _searchController
                                                    .startTimeSearch.value);
                                            final startIndex =
                                                si >= 0 ? si : 0;

                                            return SizedBox(
                                              height: 120,
                                              child: CupertinoPicker(
                                                scrollController:
                                                    FixedExtentScrollController(
                                                  initialItem: startIndex,
                                                ),
                                                itemExtent: 40,
                                                onSelectedItemChanged: (index) {
                                                  _searchController
                                                      .startTimeSearch
                                                      .value = startSlots[index];
                                                  if (activeModuleId.value ==
                                                          2 &&
                                                      _searchController
                                                              .startDate.value ==
                                                          _searchController
                                                              .endDates.value) {
                                                    if (_searchController
                                                        .isEndTimeStrictlyBeforeStartTime(
                                                      _searchController
                                                          .startTimeSearch.value,
                                                      _searchController
                                                          .endTimeSearch.value,
                                                    )) {
                                                      _searchController
                                                              .endTimeSearch
                                                              .value =
                                                          _searchController
                                                              .startTimeSearch
                                                              .value;
                                                    }
                                                  }
                                                },
                                                children: startSlots
                                                    .map((time) => Center(
                                                          child: Text(
                                                            time,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: notifires
                                                                  .getwhiteblackcolor,
                                                            ),
                                                          ),
                                                        ))
                                                    .toList(),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            "End Time".tr,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color:
                                                  notifires.getwhiteblackcolor,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Obx(() {
                                            final endSlots = getSlotsEndTime();
                                            final ei = endSlots.indexOf(
                                                _searchController
                                                    .endTimeSearch.value);
                                            final endIndex =
                                                ei >= 0 ? ei : 0;
                                            return SizedBox(
                                              height: 120,
                                              child: CupertinoPicker(
                                                scrollController:
                                                    FixedExtentScrollController(
                                                  initialItem: endIndex,
                                                ),
                                                itemExtent: 40,
                                                onSelectedItemChanged: (index) {
                                                  _searchController
                                                      .endTimeSearch
                                                      .value = endSlots[index];
                                                },
                                                children: endSlots
                                                    .map((time) => Center(
                                                          child: Text(
                                                            time,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: notifires
                                                                  .getwhiteblackcolor,
                                                            ),
                                                          ),
                                                        ))
                                                    .toList(),
                                              ),
                                            );
                                          }),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 8),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: SafeArea(
            child: Obx(() {
              final summary = _vehicleSearchScreenRentalSummary();
              final showBanner =
                  activeModuleId.value == 2 && summary != null;
              return Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (showBanner) ...[
                      VehicleRentalBillableDaysInfoBanner(
                        totalBillableDays: summary!.totalDays,
                        hasOvertimeDay: summary.hasExtraDay,
                      ),
                      const SizedBox(height: 10),
                    ],
                    CustomsButtons(
                      backgroundColor: getColorBasedOnActiveModuleid(),
                      text: "Search".tr,
                      onPressed: () {
                        if (handleSearchFordetail == true) {
                          Get.back();
                          return;
                        }
                        search();
                      },
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  List<String> getSlotsStartTime() {
    switch (_searchController.curreentStatus.value) {
      case "CurrebtDate":
        if (_searchController.handleTimeSlotsOnCurrentDate.value == true) {
          return _searchController.currenttimeSlots;
        } else {
          return _searchController.filteredTimeSlotsEndTime;
        }
      case "StartCurrentEndOther":
        return _searchController.currenttimeSlots;
      case "SameDate":
        return _searchController.filteredTimeSlotsEndTime;
      case "otherDates":
        return _searchController.filteredTimeSlotsEndTime;
      default:
        return _searchController.searchPickerBaselineSlots();
    }
  }

  List<String> getSlotsEndTime() {
    switch (_searchController.curreentStatus.value) {
      case "CurrebtDate":
        if (_searchController.startDate.value ==
            _searchController.endDates.value) {
          if (_searchController.handleTimeSlotsOnCurrentDate.value == true) {
            return _searchController.currenttimeSlots;
          } else {
            return _searchController.filteredTimeSlotsEndTime;
          }
        } else {
          return _searchController.searchPickerBaselineSlots();
        }
      case "SameDate":
        return _searchController.filteredTimeSlotsEndTime;
      case "otherDates":
        if (_searchController.startDate.value ==
            _searchController.endDates.value) {
          return _searchController.filteredTimeSlotsEndTime;
        } else {
          return _searchController.searchPickerBaselineSlots();
        }
      default:
        return _searchController.searchPickerBaselineSlots();
    }
  }
}
