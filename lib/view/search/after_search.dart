import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/controller/home_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/items_model.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/utils/vehicle_common_widgets.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/itemdetail/vehicle/view_on_map_screen.dart';
import '../../controller/search_controller.dart';
import '../../customwidget/data_not_found.dart';
import '../../customwidget/project_color.dart';
import '../../utils/common_widget.dart';
import '../../work_space.dart';
import '../../customwidget/search_wizard.dart';

class AfterSearch extends StatefulWidget {
  final dynamic checkIn, checkout, guest, cityName, slat, slong, mode;
  List? itemList;
  AfterSearch(
      {super.key,
      this.checkIn,
      this.checkout,
      this.guest,
      this.cityName,
      this.slat,
      this.slong,
      this.mode,
      this.itemList});

  @override
  State<AfterSearch> createState() => _AfterSearchState();
}

class _AfterSearchState extends State<AfterSearch> {
  dynamic temdidforsearch = 0;
  HomeController homeController = Get.find();
  int currentIndex = -1;
  SearchControllerHome filterController = Get.find();
  RefreshController refreshController = RefreshController();
  ItemModel? itemModel;
  List<dynamic> list = [];
  bool execption = false;
  bool showloading = false;

  /// Durée demandée (jours calendaires inclusifs), alignée sur [BookingController.getDaysInBetween].
  int? _calculateRequestedDays() {
    String s = generalScopeController.startDateCustomDate.value.toString().trim();
    String e = generalScopeController.endDateCustomDate.value.toString().trim();
    if (s.isEmpty) s = widget.checkIn?.toString().trim() ?? '';
    if (e.isEmpty) e = widget.checkout?.toString().trim() ?? '';
    if (s.isEmpty || e.isEmpty) return null;
    final start = DateTime.tryParse(s);
    final end = DateTime.tryParse(e);
    if (start == null || end == null) return null;
    final sd = DateTime(start.year, start.month, start.day);
    final ed = DateTime(end.year, end.month, end.day);
    final inclusive = ed.difference(sd).inDays + 1;
    return inclusive < 1 ? 1 : inclusive;
  }

  void _removeItemsExceedingMinRentalDays(List<dynamic> items) {
    final rd = _calculateRequestedDays();
    if (rd == null) return;
    items.removeWhere((item) {
      final min = item is Items
          ? item.parsedMinRentalDays
          : item is ItemsData
              ? item.parsedMinRentalDays
              : 1;
      return min > rd;
    });
  }

  void _applyMinRentalDaysFilterAfterSearch() {
    final rd = _calculateRequestedDays();
    if (rd == null) return;
    _removeItemsExceedingMinRentalDays(list);
    filterController.searchFilterList
        .removeWhere((item) => item.parsedMinRentalDays > rd);
  }

  onLoading() {
    setState(() {});
    onLoadingdata();
    setState(() {});
  }

  Future<void> searchMethod() async {
    showloading = false;
    filterController.offset = 0;
    itemModel = null;
    list = [];
    // Nettoyer aussi la liste globale de filtres pour éviter les doublons
    filterController.searchFilterList.clear();
    setState(() {});
    try {
      String price =
          "${filterController.startRange.value}-${filterController.endRage.value}";
      var result = await filterController.searchItems(
        '',
        filterController.selectedtypesvalues.toString(),
        filterController.sendvalueInApiforrecentValue.value == true
            ? filterController.setpriceforrecentvalue
            : price,
        "0",
        "0",
        filterController.featuresvalues.toString(),
        "10",
        generalScopeController.startDateCustomDate.value.toString(),
        generalScopeController.endDateCustomDate.value.toString(),
        activeModuleId.value == 1 ? widget.guest : "0",
        "${widget.slat}",
        "${widget.slong}",
        context,
        filterController.maketypeFunction(),
      );
      itemModel = ItemModel.fromJson(result);
      final initialItems = itemModel!.data?.items ?? [];
      list.addAll(initialItems);
      filterController.searchFilterList.addAll(initialItems);
      _applyMinRentalDaysFilterAfterSearch();

      // DEBUG: vérifier la taille exacte retournée par l'API
      print("🔎 [SEARCH] Initial items count: ${initialItems.length}");

      // Si le backend ne gère pas encore la pagination (moins que le limit),
      // désactiver explicitement le chargement supplémentaire
      const int pageLimit = 10;
      if (initialItems.length < pageLimit) {
        filterController.offset = -1;
      } else {
        filterController.offset = itemModel!.data!.offset ?? -1;
      }

      setState(() {});
      refreshController.loadComplete();
      refreshController.refreshCompleted();
    } catch (error) {
      execption = true;
      setState(() {});
    }
  }

  Future<void> onLoadingdata() async {
    filterController.desildetoSendparametersBasedOnPage.value = false;
    execption = false;
    setState(() {});
    try {
      String price =
          "${filterController.startRange.value}-${filterController.endRage.value}";
      var result = await filterController.searchItems(
        '',
        filterController.selectedtypesvalues.toString(),
        filterController.sendvalueInApiforrecentValue.value == true
            ? filterController.setpriceforrecentvalue
            : price,
        "0",
        "0",
        filterController.featuresvalues.toString(),
        "10",
        widget.checkIn ?? '',
        widget.checkout ?? '',
        activeModuleId.value == 1 ? widget.guest : "0",
        widget.slat ?? '',
        widget.slong ?? '',
        context,
        filterController.maketypeFunction(),
      );

      var data = result['data'];
      // Supporter data = { items: [...] } (ancien schéma) et data = [...] (nouveau)
      List<dynamic> rawItems;
      num? newOffset;
      if (data is List) {
        rawItems = data;
        newOffset = -1;
      } else {
        rawItems = (data['items'] as List<dynamic>?) ?? [];
        newOffset = data['offset'] ?? -1;
      }

      final convertedItems = rawItems.map((item) {
        return ItemsData.fromJson(item as Map<String, dynamic>);
      }).toList();

      final rd = _calculateRequestedDays();
      if (rd != null) {
        convertedItems.removeWhere((item) => item.parsedMinRentalDays > rd);
      }

      // DEBUG: pagination
      print(
          "🔎 [SEARCH] Pagination fetched ${convertedItems.length} items (prev total: ${list.length})");

      const int pageLimit = 10;

      if (filterController.offset != -1 && convertedItems.isNotEmpty) {
        list.addAll(convertedItems);
        filterController.offset = newOffset ?? -1;
      } else {
        // Plus de données : couper la pagination
        filterController.offset = -1;
      }

      // Si le backend renvoie moins que le limit, arrêter la pagination
      if (convertedItems.length < pageLimit) {
        filterController.offset = -1;
      }

      setState(() {});
      refreshController.loadComplete();
      refreshController.refreshCompleted();
    } catch (error) {
      execption = true;
      setState(() {});
      refreshController.loadFailed();
    }
  }

  onRefresh() {
    itemModel = null;
    list = [];
    setState(() {});
    filterController.offset = 0;
    searchMethod();
  }

  @override
  void initState() {
    super.initState();
    handleSearchFordetail = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      filterController.sendvalueInApiforrecentValue.value = false;
      filterController.desildetoSendparametersBasedOnPage.value = false;
      currentIndex = -1;
    });

    if (generalScopeController.homeSearchLocation.value != "All Locations") {
      currentTabIndexforLocation = 1;
    }
    handleDirectBooking = true;
    if (widget.itemList != null) {
      showloading = true;

      list = List<dynamic>.from(widget.itemList!);
      _removeItemsExceedingMinRentalDays(list);
      filterController.offset = widget.itemList!.length;
    } else {
      itemModel = null;
      searchMethod();
    }
  }

  @override
  void dispose() {
    filterController.disposeFunction();
    super.dispose();
  }

  stateSetter(fn) => setState(() {});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: AppBar(
          scrolledUnderElevation: 1,
          backgroundColor: getColorBasedOnActiveModuleid(),
          elevation: 1,
          automaticallyImplyLeading: false,
          centerTitle: false,
          toolbarHeight: 130,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  _openBottomSheet(context);
                                },
                                child: Icon(
                                  Icons.location_on_outlined,
                                  size: 20,
                                  color: whiteColor,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Obx(
                                () => GestureDetector(
                                  onTap: () {
                                    _openBottomSheet(context);
                                  },
                                  child: Text(
                                    generalScopeController.homeSearchLocation
                                                .value.length >
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
                                      color: whiteColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      overflow: generalScopeController
                                                  .homeSearchLocation
                                                  .value
                                                  .length >
                                              20
                                          ? TextOverflow.ellipsis
                                          : TextOverflow.visible,
                                    ),
                                    maxLines: generalScopeController
                                                .homeSearchLocation
                                                .value
                                                .length >
                                            20
                                        ? 2
                                        : 1,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                size: 20,
                                color: whiteColor,
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  _openBottomSheetforvehicleType(context);
                                },
                                child: Icon(
                                  Icons.merge_type_sharp,
                                  size: 20,
                                  color: whiteColor,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Obx(
                                () => GestureDetector(
                                  onTap: () {
                                    _openBottomSheetforvehicleType(context);
                                  },
                                  child: Text(
                                    filterController.globalItemTypNamee.value ==
                                            ""
                                        ? "All".tr
                                        : filterController
                                            .globalItemTypNamee.value,
                                    style: regular3(context).copyWith(
                                      color: whiteColor,
                                      fontSize: 13,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    maxLines: 1,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _openBottomSheetforvehicleType(context);
                                },
                                child: Icon(
                                  Icons.arrow_drop_down,
                                  size: 20,
                                  color: whiteColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              filterController.aftersearch = true;
                              openSearchWizard(context, onSearch: () {
                                onRefresh();
                              });
                            },
                            child: Container(
                              height: 50,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                color: notifires.getbgcolor,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: notifires.getGrey2Whitecolor),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      filterController.globalItemType.value =
                                          temdidforsearch;
                                      Get.offNamed(WebRoutes.homeMain);
                                      generalController.currentIndex.value = 0;
                                      setState(() {});
                                    },
                                    icon: Icon(
                                      Icons.arrow_back,
                                      color: getColorBasedOnActiveModuleid(),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Obx(
                                    () {
                                      return Expanded(
                                        child: Text(
                                          generalScopeController
                                                  .homeSearchLocation
                                                  .value
                                                  .isEmpty
                                              ? "All Locations".tr
                                              : (generalScopeController
                                                          .homeSearchLocation
                                                          .value
                                                          .length >
                                                      25
                                                  ? "${generalScopeController.homeSearchLocation.value.substring(0, 25 - 3)}..."
                                                  : generalScopeController
                                                      .homeSearchLocation
                                                      .value),
                                          style: regular3(context).copyWith(
                                            color: notifires.getGrey1Whitecolor,
                                            fontSize: 14,
                                            overflow: TextOverflow
                                                .ellipsis, // Handles text overflow properly
                                          ),
                                          maxLines: 1,
                                        ),
                                      );
                                    },
                                  ),
                                  const Spacer(),
                                  Container(
                                    height: 40,
                                    width: 150,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: notifires.getGrey2Whitecolor),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Obx(
                                            () => Text(
                                              filterController.startDate.value
                                                      .isNotEmpty
                                                  ? "${filterController.startDate.value}-${filterController.startTimeSearch.value} "
                                                  : '',
                                              style: regular3(context).copyWith(
                                                color: notifires
                                                    .getGrey1Whitecolor,
                                                fontSize: 10,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4.0),
                                          child: Container(
                                            width: 2,
                                            height: 25,
                                            color: grey4,
                                          ),
                                        ),
                                        Expanded(
                                          child: Obx(
                                            () => Text(
                                              filterController
                                                      .endDates.value.isNotEmpty
                                                  ? "${filterController.endDates.value}-${filterController.endTimeSearch.value} "
                                                  : '',
                                              style: regular3(context).copyWith(
                                                color: notifires
                                                    .getGrey1Whitecolor,
                                                fontSize: 10,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 45,
                width: double.maxFinite,
                child: Row(
                  children: [
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        if (webPlateForm) {
                          Get.offNamed(
                            WebRoutes.viewOnMapScreen,
                            arguments: {
                              'title': "View map".tr,
                              'list': list,
                            },
                          );
                        } else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewOnMapScreen(
                                      title: "View map".tr, list: list)));
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.map,
                              color: whiteColor,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              "Map".tr,
                              style:
                                  heading3(context).copyWith(color: whiteColor),
                            ),
                          ],
                        ),
                      ),
                    )),
                    Container(
                      width: 1,
                      height: 30,
                      color: notifires.getGrey4Whitecolor,
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        showPopUpScreenForShort(
                            context,
                            ShortBy(
                              options: const [
                                "Cheapest Price",
                                "Nearest Location",
                                "Highest Ranked",
                                "Newest",
                              ],
                              selectedOption:
                                  filterController.selectredeShortByvalue.value,
                              onOptionSelected: (String value) {
                                filterController.selectredeShortByvalue.value =
                                    value;
                                searchMethod();
                              },
                            ));
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Stack(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sports_rugby,
                                  color: whiteColor,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Sort".tr,
                                  style: heading3(context)
                                      .copyWith(color: whiteColor),
                                ),
                              ],
                            ),
                            filterController.selectredeShortByvalue.value != ""
                                ? Positioned(
                                    top: 0,
                                    right: 5,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: redColor,
                                        shape: BoxShape
                                            .circle, // Makes it a circle
                                      ),
                                      height: 8,
                                      width: 8,
                                    ),
                                  )
                                : const SizedBox()
                          ],
                        ),
                      ),
                    )),
                    Container(
                      width: 1,
                      height: 30,
                      color: notifires.getGrey4Whitecolor,
                    ),
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        filterController.routeBasedOnmoduleId(
                            context, onRefresh);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        child: Stack(children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.filter_alt_sharp,
                                color: whiteColor,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Text(
                                "Filter".tr,
                                style: heading3(context)
                                    .copyWith(color: whiteColor),
                              ),
                            ],
                          ),
                          filterController.maketypesValus.isNotEmpty ||
                                  filterController
                                      .selectedtypesvalues.isNotEmpty ||
                                  filterController.featuresvalues.isNotEmpty ||
                                  filterController.odometerValues.isNotEmpty ||
                                  filterController
                                      .selectedModelYear.isNotEmpty ||
                                  filterController
                                      .selectedFuelTypes.isNotEmpty ||
                                  filterController.selectedTransmissions
                                      .isNotEmpty // NOUVEAU: Badge pour transmission
                              ? Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: redColor,
                                      shape:
                                          BoxShape.circle, // Makes it a circle
                                    ),
                                    height: 8,
                                    width: 8,
                                  ),
                                )
                              : const SizedBox()
                        ]),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
              child: SmartRefresher(
                controller: refreshController,
                onRefresh: onRefresh,
                onLoading: onLoading,
                // N'activer le "load more" que s'il reste potentiellement des données
                // ET que la première page a atteint le nombre maximal d'éléments.
                enablePullUp:
                    filterController.offset != -1 && list.length >= 10,
                child: execption == true
                    ? buildNoDataWidget(
                        context,
                        "SomeThing Went Wrong".tr,
                      )
                    : itemModel == null && showloading == false
                        ? verticleShimmerWidgetBookable()
                        : list.isEmpty
                            ? Center(
                                child: buildNoDataWidget(
                                    context, filterController.dataNotFound.tr),
                              )
                            : itemVerticalView(
                                list, false, false, stateSetter, true),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openBottomSheet(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    // Garder la liste complète des objets Location pour accéder aux coordonnées
    final allLocations = homeController.homeDataModel!.data!.locations!;
    final RxList<Location> filteredLocations = RxList<Location>(allLocations);

    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: Get.height / 1.5,
          color: notifires.getbgcolor,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Location".tr,
                    style: heading3(context),
                  ),
                  const Spacer(),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.close,
                      color: notifires.getwhiteblackcolor,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              // Search Box
              TextField(
                style: regular3(context).copyWith(
                  color: notifires.getGrey1Whitecolor,
                  fontSize: 13,
                  overflow: TextOverflow.ellipsis,
                ),
                controller: searchController,
                decoration: InputDecoration(
                    hintText: "Search location...".tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    fillColor: notifires.getbgcolor,
                    filled: true),
                onChanged: (value) {
                  filteredLocations.value = allLocations
                      .where((location) =>
                          location.cityName != null &&
                          location.cityName!
                              .toLowerCase()
                              .contains(value.toLowerCase()))
                      .toList();
                },
              ),
              // Filtered List
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    itemCount: filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = filteredLocations[index];
                      final cityName = location.cityName ?? '';
                      return SizedBox(
                        height: 40,
                        child: ListTile(
                          title: Text(
                            cityName,
                            style: regular3(context).copyWith(
                              color: notifires.getGrey1Whitecolor,
                              fontSize: 13,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          trailing:
                              generalScopeController.homeSearchLocation.value ==
                                      cityName
                                  ? Icon(Icons.check,
                                      color: getColorBasedOnActiveModuleid())
                                  : null,
                          onTap: () {
                            // Nettoyer les coordonnées (retirer ° N, ° W, ° S, ° E)
                            String cleanLat = (location.latitude ?? '')
                                .replaceAll(RegExp(r'[°\s]'), '')
                                .replaceAll('N', '')
                                .replaceAll('S', '')
                                .trim();
                            String cleanLng = (location.longitude ?? '')
                                .replaceAll(RegExp(r'[°\s]'), '')
                                .replaceAll('E', '')
                                .replaceAll('W', '')
                                .trim();

                            print("🏙️ VILLE SÉLECTIONNÉE:");
                            print("   - cityName: '$cityName'");
                            print(
                                "   - lat: '${location.latitude}' -> '$cleanLat'");
                            print(
                                "   - lng: '${location.longitude}' -> '$cleanLng'");

                            // Mettre à jour le nom de la ville
                            generalScopeController.homeSearchLocation.value =
                                cityName;
                            generalScopeController
                                .textEditingControllerCity.text = cityName;

                            // Mettre à jour les coordonnées NETTOYÉES
                            slatsearch = cleanLat;
                            sLongSearch = cleanLng;

                            // Mettre à jour setCity dans le SearchController
                            filterController.setCity = cityName;

                            Navigator.pop(context);
                            onRefresh();
                          },
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openBottomSheetforvehicleType(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    final RxList<dynamic> filteredVehicleTypes = RxList<dynamic>(
      homeController.itemTypeModel?.data?.itemTypes ?? [],
    );

    showModalBottomSheet(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: Get.height / 1.5,
          color: notifires.getbgcolor,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Vehicle Type".tr,
                    style: heading3(context),
                  ),
                  const Spacer(),
                  const SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Icon(
                      Icons.close,
                      color: notifires.getwhiteblackcolor,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 5,
              ),
              // Search Box
              SizedBox(
                height: 60,
                child: TextField(
                  style: regular3(context).copyWith(
                    color: notifires.getGrey1Whitecolor,
                    fontSize: 13,
                    overflow: TextOverflow.ellipsis,
                  ),
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search vehicle type...".tr,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    filteredVehicleTypes.value = homeController
                            .itemTypeModel?.data?.itemTypes
                            ?.where((item) => item.name!
                                .toLowerCase()
                                .contains(value.toLowerCase()))
                            .toList() ??
                        [];
                  },
                ),
              ),
              // Filtered List
              Expanded(
                child: Obx(
                  () => ListView.separated(
                    itemCount: filteredVehicleTypes.length,
                    itemBuilder: (context, index) {
                      final dynamic option = filteredVehicleTypes[index].id;
                      return Transform.translate(
                        offset: const Offset(-10, 2),
                        child: SizedBox(
                          height: 40,
                          child: ListTile(
                            title: Text(
                              "${filteredVehicleTypes[index].name}",
                              style: regular3(context).copyWith(
                                color: notifires.getGrey1Whitecolor,
                                fontSize: 13,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            trailing:
                                filterController.globalItemType.value == option
                                    ? Icon(Icons.check,
                                        color: getColorBasedOnActiveModuleid())
                                    : null,
                            onTap: () {
                              filterController.globalItemType.value = option;
                              filterController.globalItemTypNamee.value =
                                  filteredVehicleTypes[index].name;
                              GetStorage().write("selectedVehicleType", option);
                              GetStorage().write("selectedVehicleTypeName",
                                  filteredVehicleTypes[index].name);
                              GetStorage().remove("homeData");
                              Navigator.pop(context);
                              filterController.submitMethod(context);
                            },
                          ),
                        ),
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
