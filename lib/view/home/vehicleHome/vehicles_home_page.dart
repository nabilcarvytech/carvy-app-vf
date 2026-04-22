import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:carvy/view/home/location_screen.dart';
import 'package:carvy/view/home/top_categories.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/search/after_search.dart';
import 'package:carvy/view/search/vehicle/vehicle_filter.dart';
import '../../../controller/search_controller.dart';
import '../../../controller/home_controller.dart';
import '../../../customwidget/custom_active_module_id_widget.dart';
import '../../../customwidget/project_bar.dart';
import '../../../customwidget/project_color.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/theme_style.dart';
import '../../../utils/vehicle_common_widgets.dart';
import '../../../work_space.dart';

class VehicleHomePage extends StatefulWidget {
  const VehicleHomePage({super.key});

  @override
  State<VehicleHomePage> createState() => _VehicleHomePageState();
}

class _VehicleHomePageState extends State<VehicleHomePage>
    with AutomaticKeepAliveClientMixin {
  HomeController homeController = Get.find();
  SearchControllerHome filterController = Get.find();
  final RefreshController refreshController = RefreshController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    handleBoackfromPayment = false;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      generalController.myBookingTabIndex.value = 0;
      homeController.getDataItemType();
      final storedType = GetStorage().read("selectedVehicleType");
      filterController.globalItemType.value =
          storedType != null ? storedType.toString() : '0';
      filterController.globalItemTypNamee.value =
          GetStorage().read("selectedVehicleTypeName") ?? "";
      fetchData();
    });
    scrollController.addListener(() {});
  }

  @override
  void dispose() {
    refreshController.dispose();
    scrollController.dispose();
    homeController.disposeFunctionVehicle();
    super.dispose();
  }

  stateSetter(fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  /// Même feuille de filtres que sur le flux recherche (prix, assurance, marques, etc.).
  void _openVehicleFilterSheet(BuildContext context) {
    showPopUpScreen(
      context,
      VehicleFilter(
        mode: false,
        onRefresh: () {
          fetchData();
        },
      ),
    );
  }

  // Ouvre la bottom sheet de tri pour la Home
  void _showSortBottomSheet(BuildContext context) {
    final Color primary = getColorBasedOnActiveModuleid();

    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final options = <String>[
          "Cheapest Price",
          "Nearest Location",
          "Highest Ranked",
          "Newest",
        ];

        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  "Sort By".tr,
                  style: heading3(context).copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    children: options.map((label) {
                      final bool isSelected =
                          filterController.selectredeShortByvalue.value ==
                              label;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          label.tr,
                          style: regular3(context).copyWith(
                            fontSize: 15,
                            color: isSelected
                                ? primary
                                : notifires.getGrey1Whitecolor,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: primary,
                              )
                            : null,
                        onTap: () async {
                          await _onSortOptionSelected(context, label);
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Gère la sélection d'une option de tri
  Future<void> _onSortOptionSelected(BuildContext context, String label) async {
    print('🚩 [BOUTON_TRI] Clic détecté sur : $label');

    filterController.selectredeShortByvalue.value = label;

    // Gestion spécifique pour "Nearest Location" : si pas de coordonnée, on récupère la localisation
    if (label == "Nearest Location") {
      final bool hasLat =
          (slatsearch != null && slatsearch.toString().isNotEmpty);
      final bool hasLng =
          (sLongSearch != null && sLongSearch.toString().isNotEmpty);

      if (!hasLat || !hasLng) {
        await filterController.getUserLocationForBetterSearch(context);
      }
    }

    Navigator.of(context).pop();

    print('🚩 [BOUTON_TRI] Appel de fetchData()...');
    fetchData();
  }

  void fetchData() async {
    try {
      handleSearchFordetail = false;
      handleDirectBooking = false;
      getUserDataLocallyToHandleTheState();
      homeController.homeDataModel = null;
      if (mounted) setState(() {});
      filterController.hitApiOnMap = false;
      await generalController.fetchGeneralSettings();
      await homeController.apibasedonModuleid();
      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }
    } catch (e) {
      print("Fetch data error: $e");
    } finally {
      refreshController.refreshCompleted(); // Ensure completion
    }
  }

  void onLoading() {
    fetchData();
  }

  bool handlescroll = false;

  Future<void> onRefresh() async {
    if (handlescroll) return;
    setState(() => handlescroll = true);
    try {
      GetStorage().remove("homeData");
      GetStorage().remove("vehicleTypeHome");
      GetStorage().remove("vehiclemake");
      GetStorage().remove("generalSettings");
      await generalController.fetchGeneralSettings();
      await homeController.getDataItemType();
      await homeController.getHomeData();
    } catch (e) {
      print("Refresh error: $e");
      refreshController.refreshFailed();
      return;
    } finally {
      if (mounted) {
        setState(() => handlescroll = false);
        refreshController.refreshCompleted();
        if (scrollController.hasClients) {
          scrollController.jumpTo(0);
        }
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final notifires = Provider.of<ColorNotifires>(context, listen: true);
    const double spacingHeight = 13.0;

    bool _isSectionActive(String section) {
      bool isActive;
      switch (section) {
        case 'VehicleType':
          isActive = showhideItemType != "Inactive";
          break;
        case 'PopularRegion':
          isActive = showHidePopularRegion != "Inactive" &&
              filterController.globalItemType.value == 0;
          break;
        case 'VehiclesNearYou':
          isActive = showHideNrarYou != "Inactive" &&
              filterController.globalItemType.value == 0;
          break;
        case 'Make':
          isActive = showHideMake != "Inactive" &&
              filterController.globalItemType.value == 0;
          break;
        case 'BecomeHost':
          isActive = showHideBecomeHost != "Inactive" &&
              filterController.globalItemType.value == 0;
          break;
        case 'MostViewed':
          isActive = showHideMustView != "Inactive";
          break;
        default:
          isActive = false;
      }

      return isActive;
    }

    Widget dynamicSpacer(String currentSection, String nextSection) {
      bool isCurrentActive = _isSectionActive(currentSection);
      bool isNextActive = _isSectionActive(nextSection);
      if (isCurrentActive && isNextActive) {
        return const SizedBox(height: spacingHeight);
      }
      return const SizedBox.shrink();
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: notifires.getbgcolor,
        appBar: kIsWeb
            ? const CustomAppBarHeaders()
            : AppBar(
                automaticallyImplyLeading: false,
                scrolledUnderElevation: 0,
                title: Column(
                  children: [
                    Row(
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
                              generalScopeController
                                          .homeSearchLocation.value.length >
                                      20
                                  ? "${generalScopeController.homeSearchLocation.value.substring(0, 17)}..."
                                  : generalScopeController
                                          .homeSearchLocation.value.isEmpty
                                      ? "All location".tr
                                      : generalScopeController
                                          .homeSearchLocation.value,
                              style: regular3(context).copyWith(
                                color: whiteColor,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                overflow: generalScopeController
                                            .homeSearchLocation.value.length >
                                        20
                                    ? TextOverflow.ellipsis
                                    : TextOverflow.visible,
                              ),
                              maxLines: generalScopeController
                                          .homeSearchLocation.value.length >
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
                              filterController.globalItemTypNamee.value.isEmpty
                                  ? "All".tr
                                  : filterController.globalItemTypNamee.value,
                              style:
                                  heading3(context).copyWith(color: whiteColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                        Padding(
                          padding: const EdgeInsets.only(left: 6, right: 6),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _openVehicleFilterSheet(context),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.28),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.filter_alt,
                                      size: 18,
                                      color: whiteColor,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      'Filter'.tr,
                                      style: regular3(context).copyWith(
                                        color: whiteColor,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        profilePhotoOnHomeScreen(context),
                      ],
                    ),
                  ],
                ),
                backgroundColor: themeColor,
              ),
        body: GetBuilder<HomeController>(
          builder: (controller) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(35),
                        bottomLeft: Radius.circular(35),
                      ),
                    ),
                    child: customSearchContainer(context, () {
                      filterController.submitMethod(context);
                    }, false),
                  ),
                ),
                const SizedBox(height: 10),
                // Barre de filtres fixe (Map / Sort / Filter)
                HomeFilterBar(),
                const SizedBox(height: 10),
                Expanded(
                  child: SmartRefresher(
                    controller: refreshController,
                    enablePullDown: true,
                    enablePullUp: false,
                    header: ClassicHeader(
                        height: 100.0,
                        completeDuration: const Duration(milliseconds: 500),
                        releaseText: 'Release to refresh',
                        refreshingText: 'Refreshing...',
                        idleText: 'Pull down to refresh',
                        failedText: 'Refresh failed',
                        completeText: 'Refresh completed',
                        refreshingIcon: Container(
                          width: 24.0,
                          height: 24.0,
                          padding: const EdgeInsets.all(2.0),
                          decoration: BoxDecoration(
                            color: getColorBasedOnActiveModuleid(),
                            shape: BoxShape.circle,
                          ),
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2.0,
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                        textStyle: regular2(context)),
                    onRefresh: onRefresh,
                    child: ListView.builder(
                      controller: scrollController,
                      physics: const ClampingScrollPhysics(),
                      itemCount: _calculateItemCount(),
                      itemBuilder: (context, index) {
                        return _buildSection(
                            index, notifires, stateSetter, context);
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
    );
  }

  int _calculateItemCount() {
    int count = 0;
    if (_isSectionActive('VehicleType')) count += 2;
    if (_isSectionActive('PopularRegion')) count += 2;
    if (_isSectionActive('VehiclesNearYou')) count += 2;
    if (_isSectionActive('Make')) count += 2;
    if (_isSectionActive('BecomeHost')) count += 2;
    if (_isSectionActive('MostViewed')) count += 2;
    count += 1;

    return count;
  }

  bool _isSectionActive(String section) {
    bool isActive;
    switch (section) {
      case 'VehicleType':
        isActive = showhideItemType != "Inactive";
        break;
      case 'PopularRegion':
        isActive = showHidePopularRegion != "Inactive" &&
            filterController.globalItemType.value == '0';
        break;
      case 'VehiclesNearYou':
        isActive = showHideNrarYou != "Inactive" &&
            filterController.globalItemType.value == '0';
        break;
      case 'Make':
        isActive = showHideMake != "Inactive" &&
            filterController.globalItemType.value == '0';
        break;
      case 'BecomeHost':
        isActive = showHideBecomeHost != "Inactive" &&
            filterController.globalItemType.value == '0';
        break;
      case 'MostViewed':
        isActive = showHideMustView != "Inactive";
        break;
      default:
        isActive = false;
    }

    return isActive;
  }

  Widget dynamicSpacer(String currentSection, String nextSection) {
    bool isCurrentActive = _isSectionActive(currentSection);
    bool isNextActive = _isSectionActive(nextSection);
    if (isCurrentActive && isNextActive) {
      return const SizedBox(height: 13.0);
    }
    return const SizedBox.shrink();
  }

  Widget _buildSection(int index, ColorNotifires notifires,
      StateSetter stateSetter, BuildContext context) {
    int currentIndex = 0;

    if (_isSectionActive('VehicleType')) {
      if (index == currentIndex) {
        return _buildVehicleTypeSection(context, notifires, stateSetter);
      }
      currentIndex++;
      if (index == currentIndex) {
        return dynamicSpacer('VehicleType', 'PopularRegion');
      }
      currentIndex++;
    }

    if (_isSectionActive('PopularRegion')) {
      if (index == currentIndex) {
        return _buildPopularRegionSection(context, notifires);
      }
      currentIndex++;
      if (index == currentIndex) {
        return dynamicSpacer('PopularRegion', 'VehiclesNearYou');
      }
      currentIndex++;
    }

    if (_isSectionActive('VehiclesNearYou')) {
      if (index == currentIndex) {
        return _buildVehiclesNearYouSection(context, notifires, stateSetter);
      }
      currentIndex++;
      if (index == currentIndex) {
        return dynamicSpacer('VehiclesNearYou', 'Make');
      }
      currentIndex++;
    }

    if (_isSectionActive('Make')) {
      if (index == currentIndex) {
        return _buildMakeSection(context, notifires);
      }
      currentIndex++;
      if (index == currentIndex) {
        return dynamicSpacer('Make', 'BecomeHost');
      }
      currentIndex++;
    }

    if (_isSectionActive('BecomeHost')) {
      if (index == currentIndex) {
        return _buildBecomeHostSection(context, notifires);
      }
      currentIndex++;
      if (index == currentIndex) {
        return dynamicSpacer('BecomeHost', 'MostViewed');
      }
      currentIndex++;
    }

    if (_isSectionActive('MostViewed')) {
      if (index == currentIndex) {
        return _buildMostViewedSection(context, notifires, stateSetter);
      }
      currentIndex++;
      if (index == currentIndex) {
        return dynamicSpacer('MostViewed', '');
      }
      currentIndex++;
    }

    return const SizedBox(height: 20);
  }

  Widget _buildVehicleTypeSection(
      BuildContext context, ColorNotifires notifires, StateSetter stateSetter) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: Dimensions.paddingSizeLarge),
            Expanded(
              flex: 9,
              child: InkWell(
                onTap: () {},
                child: Text("${'Vehicle Type'.tr} ::",
                    style: heading2Grey1(context)),
              ),
            ),
            const Spacer(),
            const SizedBox(width: Dimensions.paddingSizeLarge),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (homeController.isloadingType.value == true) {
            return boxLocation();
          } else {
            final vehicleType = homeController.vehicleListItemType;

            if (vehicleType.isNotEmpty) {
              return vehicleTypeWidget(vehicleType, notifires, stateSetter);
            } else {
              return const SizedBox(height: 56.0);
            }
          }
        }),
      ],
    );
  }

  /// Barre d'actions rapide (Map, Sort, Filter) pour la Home
  /// Style adapté au thème de la page d'accueil (fond blanc, coins arrondis, ombre légère).
  Widget HomeFilterBar() {
    final Color primary = getColorBasedOnActiveModuleid();

    Widget buildAction({
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: primary),
                const SizedBox(width: 6),
                Text(
                  label.tr,
                  style: regular3(context).copyWith(
                    color: primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            buildAction(
              icon: Icons.map_outlined,
              label: "Map",
              onTap: () {
                print("Open Map");
              },
            ),
            const SizedBox(
              height: 32,
              child: VerticalDivider(
                thickness: 0.8,
              ),
            ),
            buildAction(
              icon: Icons.swap_vert,
              label: "Sort",
              onTap: () {
                _showSortBottomSheet(context);
              },
            ),
            const SizedBox(
              height: 32,
              child: VerticalDivider(
                thickness: 0.8,
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () => _openVehicleFilterSheet(context),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.filter_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Filter'.tr,
                        style: regular3(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularRegionSection(
      BuildContext context, ColorNotifires notifires) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: Dimensions.paddingSizeLarge),
            Expanded(
              flex: 9,
              child: Text("${'Popular Region'.tr} ::",
                  style: heading2Grey1(context)),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                filterController.clearFilter();
                filterController.setDefaultDates(
                  startDateCustomDate:
                      generalScopeController.startDateCustomDate,
                  endDateCustomDate: generalScopeController.endDateCustomDate,
                  startDate: filterController.startDate,
                  endDates: filterController.endDates,
                );
                Get.to(
                  () => LocationScreen(
                      list: homeController.homeDataModel!.data!.locations),
                  transition: Transition.fadeIn,
                );
              },
              child: Text(
                'See All'.tr,
                style: regular2(context)
                    .copyWith(color: getColorBasedOnActiveModuleid()),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeLarge),
          ],
        ),
        Obx(() {
          if (homeController.homeDataLoading.value == true) {
            return rectangleLocation();
          } else {
            final locations =
                homeController.homeDataModel?.data!.locations ?? [];

            if (locations.isNotEmpty) {
              return homeLocations(locations, notifires);
            } else {
              return const SizedBox();
            }
          }
        }),
      ],
    );
  }

  Widget _buildVehiclesNearYouSection(
      BuildContext context, ColorNotifires notifires, StateSetter stateSetter) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            const SizedBox(width: Dimensions.paddingSizeLarge),
            Expanded(
              flex: 9,
              child: Text(
                "${'Vehicles Near You'.tr} ::",
                style: heading2Grey1(context)
                    .copyWith(overflow: TextOverflow.ellipsis),
                maxLines: 1,
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () async {
                filterController.clearFilter();
                filterController.setDefaultDates(
                  startDateCustomDate:
                      generalScopeController.startDateCustomDate,
                  endDateCustomDate: generalScopeController.endDateCustomDate,
                  startDate: filterController.startDate,
                  endDates: filterController.endDates,
                );
                filterController.selectredeShortByvalue.value =
                    "Nearest Location";
                Get.to(
                  () => AfterSearch(
                      itemList:
                          homeController.homeDataModel!.data!.nearbyItems),
                  transition: Transition.fadeIn,
                );
              },
              child: Text(
                'See All'.tr,
                style: regular2(context).copyWith(
                    color: getColorBasedOnActiveModuleid(), fontSize: 14),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeLarge),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (homeController.homeDataLoading.value == true) {
            return sliderShimmer();
          } else {
            final items = homeController.homeDataModel?.data?.nearbyItems ?? [];

            if (items.isNotEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return vehicalHorizontalViewNearYou(
                        items, stateSetter, notifires);
                  },
                ),
              );
            } else {
              return const SizedBox();
            }
          }
        }),
      ],
    );
  }

  Widget _buildMakeSection(BuildContext context, ColorNotifires notifires) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: Dimensions.paddingSizeLarge),
            Text("${'Make'.tr} ::", style: heading2Grey1(context)),
            const Spacer(),
            InkWell(
              onTap: () {
                if (webPlateForm) {
                  Get.toNamed(WebRoutes.topCategory,
                      arguments: {'title': "Make".tr});
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => TopCategories(
                        title: "Make".tr,
                        list: homeController.homeDataModel!.data!.makes!,
                      ),
                    ),
                  );
                }
              },
              child: Text(
                'See All'.tr,
                style: regular2(context).copyWith(
                    color: getColorBasedOnActiveModuleid(), fontSize: 14),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeLarge),
          ],
        ),
        const SizedBox(height: 15),
        Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
          child: Obx(() {
            if (homeController.isloadingType.value == true) {
              return topCateforyBoatShimmer();
            } else {
              final vehicleMake =
                  homeController.homeDataModel?.data!.makes ?? [];

              if (vehicleMake.isNotEmpty) {
                return vehicalCategory(vehicleMake, notifires);
              } else {
                return const SizedBox();
              }
            }
          }),
        ),
      ],
    );
  }

  Widget _buildBecomeHostSection(
      BuildContext context, ColorNotifires notifires) {
    return Obx(() {
      return generalController.hasGeneralDataforBanner.value == true
          ? SizedBox(
              height: 180,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge),
                child: shimmerContainer(),
              ),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
              child: Card(
                elevation: 5,
                child: Container(
                  height: 188,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/click_rent_drive.png'),
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            );
    });
  }

  Widget _buildMostViewedSection(
      BuildContext context, ColorNotifires notifires, StateSetter stateSetter) {
    return Column(
      children: [
        const SizedBox(height: 5),
        Row(
          children: [
            const SizedBox(width: Dimensions.paddingSizeLarge),
            Expanded(
              flex: 9,
              child: Text(
                "${'Highest Ranked'.tr} ::",
                style: heading2Grey1(context)
                    .copyWith(overflow: TextOverflow.ellipsis),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () {
                filterController.clearFilter();
                filterController.selectredeShortByvalue.value =
                    "Highest Ranked";
                filterController.setDefaultDates(
                  startDateCustomDate:
                      generalScopeController.startDateCustomDate,
                  endDateCustomDate: generalScopeController.endDateCustomDate,
                  startDate: filterController.startDate,
                  endDates: filterController.endDates,
                );
                final mostViewedItems =
                    homeController.homeDataModel?.data?.mostViewedItems;

                if (mostViewedItems != null) {
                  Get.to(
                    () => AfterSearch(itemList: mostViewedItems),
                    transition: Transition.fadeIn,
                  );
                } else {
                  showErrorToastMessage("Data Not Found");
                }
              },
              child: Text(
                'See All'.tr,
                style: regular2(context).copyWith(
                    color: getColorBasedOnActiveModuleid(), fontSize: 14),
              ),
            ),
            const SizedBox(width: Dimensions.paddingSizeLarge),
          ],
        ),
        const SizedBox(height: 5),
        Obx(() {
          if (homeController.homeDataLoading.value == true) {
            return verticleShimmerWidgetBookable();
          } else {
            final items =
                homeController.homeDataModel?.data!.mostViewedItems ?? [];
            return Padding(
              padding: const EdgeInsets.all(12),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return vehicalVerticalView(items, true, false, stateSetter);
                },
              ),
            );
          }
        }),
      ],
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
              const SizedBox(height: 5),
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
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: BorderSide(color: notifires.getBoxColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Dimensions.radiusDefault),
                      borderSide: BorderSide(color: notifires.getBoxColor),
                    ),
                    fillColor: notifires.getGrey5Whitecolor,
                    filled: true,
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
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: filteredVehicleTypes.length,
                    itemBuilder: (context, index) {
                      final dynamic option = filteredVehicleTypes[index].id;

                      return ListTile(
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
                          homeController.homeDataModel = null;
                          GetStorage().remove("homeData");
                          homeController.onVehicleHomeScreenRefresh();
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
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

                            print("🏙️ VILLE SÉLECTIONNÉE (HOME):");
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
                            filterController.submitMethod(context);
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
}
