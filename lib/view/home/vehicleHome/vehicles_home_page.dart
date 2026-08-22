import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/city_name_helper.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:carvy/view/home/location_screen.dart';
import 'package:carvy/view/home/top_categories.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/itemdetail/vehicle/view_on_map_screen.dart';
import 'package:carvy/view/search/after_search.dart';
import 'package:carvy/view/search/vehicle/vehicle_filter.dart';
import 'package:carvy/customwidget/search_wizard.dart';
import '../../../controller/search_controller.dart';
import '../../../controller/home_controller.dart';
import '../../../customwidget/custom_active_module_id_widget.dart';
import '../../../customwidget/project_bar.dart';
import '../../../customwidget/project_color.dart';
import '../../../utils/common_widget.dart';
import '../../../utils/safe_navigation.dart';
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
  final ScrollController scrollController = ScrollController();

  /// Espace sous la barre d'état (accueil + barre compacte épinglée).
  static const double _kHomeHeaderTopGap = 12.0;
  static const double _kHomeHeaderHorizontalPadding = 16.0;

  @override
  void initState() {
    super.initState();
    handleBoackfromPayment = false;
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrapHomePage());
  }

  @override
  void dispose() {
    scrollController.dispose();
    homeController.disposeFunctionVehicle();
    super.dispose();
  }

  Future<void> _bootstrapHomePage() async {
    if (!mounted) return;

    generalController.myBookingTabIndex.value = 0;
    final storedType = GetStorage().read("selectedVehicleType");
    filterController.globalItemType.value =
        storedType != null ? storedType.toString() : '0';
    filterController.globalItemTypNamee.value =
        GetStorage().read("selectedVehicleTypeName") ?? "";

    await homeController.getDataItemType();
    if (!mounted) return;
    await fetchData();
  }

  double _homeHeaderTopInset(BuildContext context) =>
      MediaQuery.paddingOf(context).top + _kHomeHeaderTopGap;

  double _collapsedHomeHeaderHeight(BuildContext context) =>
      _homeHeaderTopInset(context) + kToolbarHeight;

  /// Progression du collapse du header : 0 = déployé, 1 = replié.
  /// Calculé depuis les contraintes du [LayoutBuilder] — pas de notifier externe.
  double _headerCollapseProgress(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final double expandedHeight = _expandedHomeHeaderExtent(context);
    final double collapsedHeight = _collapsedHomeHeaderHeight(context);
    final double range = expandedHeight - collapsedHeight;
    if (range <= 0) return 1.0;
    return ((expandedHeight - constraints.biggest.height) / range)
        .clamp(0.0, 1.0);
  }

  Widget _buildExpandedHeaderContent(BuildContext context, double opacity) {
    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomCenter,
            colors: [
              Color.lerp(themeColor, const Color(0xFF0D1B4A), 0.28) ?? themeColor,
              themeColor,
              Color.lerp(themeColor, Colors.white, 0.14) ?? themeColor,
            ],
            stops: const [0.0, 0.42, 1.0],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(35),
            bottomRight: Radius.circular(35),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: _homeHeaderTopInset(context)),
            SizedBox(
              height: kToolbarHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: _kHomeHeaderHorizontalPadding,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(),
                    profilePhotoOnHomeScreen(context),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: _kHomeHeaderHorizontalPadding,
              ),
              child: customSearchContainer(context, () {
                filterController.submitMethod(context);
              }, false),
            ),
          ],
        ),
      ),
    );
  }

  stateSetter(fn) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  /// Ouvre la carte unifiée (géoloc, marqueurs véhicules, zoom limité, bottom sheet).
  Future<void> _openHomeMap() async {
    filterController.hitApiOnMap = false;
    filterController.searchFilterList.clear();

    if (webPlateForm) {
      Get.toNamed(
        WebRoutes.viewOnMapScreen,
        arguments: {
          'title': 'Map'.tr,
          'list': <dynamic>[],
        },
      );
      return;
    }

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewOnMapScreen(
          title: 'Map'.tr,
          list: const [],
        ),
      ),
    );
  }

  /// Même feuille de filtres que sur le flux recherche (prix, assurance, marques, etc.).
  void _openVehicleFilterSheet(BuildContext context) {
    filterController.prepareFilterSheetOpen();
    showPopUpScreen(
      context,
      VehicleFilter(
        mode: false,
        forHome: true,
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
    print('🚩 [BOUTON_TRI] Appel de fetchData()...');
    safePopAndAction(context, () {
      fetchData();
    });
  }

  Future<void> fetchData() async {
    try {
      handleSearchFordetail = false;
      handleDirectBooking = false;
      getUserDataLocallyToHandleTheState();
      homeController.homeDataModel = null;
      homeController.update();
      filterController.hitApiOnMap = false;
      await generalController.fetchGeneralSettings();
      await homeController.apibasedonModuleid();
      if (scrollController.hasClients) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {
            scrollController.jumpTo(0);
          }
        });
      }
    } catch (e) {
      debugPrint("Fetch data error: $e");
    }
  }

  Future<void> onRefresh() async {
    GetStorage().remove("homeData");
    GetStorage().remove("vehicleTypeHome");
    GetStorage().remove("vehiclemake");
    GetStorage().remove("generalSettings");
    await fetchData();
  }

  /// Hauteur du header bleu mobile (bloc large).
  double _expandedHomeHeaderExtent(BuildContext context) =>
      280.0 + _kHomeHeaderTopGap;

  Widget _buildCompactStickySearchBar(BuildContext context) {
    final Color hintColor = Colors.grey.shade600;
    final TextStyle valueStyle = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade900,
    );
    final TextStyle hintStyle = TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w400,
      color: hintColor,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          openSearchWizard(
            context,
            onSearch: () => filterController.submitMethod(context),
          );
        },
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(() {
                  final loc = generalScopeController.homeSearchLocation.value;
                  final city =
                      generalScopeController.textEditingControllerCity.text;
                  final bool isHint = loc.isEmpty && city.isEmpty;
                  final String label =
                      loc.isNotEmpty
                          ? loc
                          : (city.isNotEmpty ? city : 'search_destination'.tr);
                  return Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 18,
                        color: isHint ? hintColor : themeColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: isHint ? hintStyle : valueStyle,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                width: 1,
                height: 22,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: Obx(() {
                  final String s = filterController.startDate.value;
                  final String e = filterController.endDates.value;
                  final bool isHint = s.isEmpty || e.isEmpty;
                  final String label =
                      isHint ? 'search_dates'.tr : '$s – $e';
                  return Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: isHint ? hintColor : themeColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: isHint ? hintStyle : valueStyle,
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(width: 4),
              Icon(Icons.search, size: 22, color: themeColor),
            ],
          ),
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildSectionSliver({
    required String sectionName,
    required Widget child,
  }) {
    if (!_isSectionActive(sectionName)) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(
      key: ValueKey<String>('home-sliver-$sectionName'),
      child: child,
    );
  }

  Widget _buildOffstageSection({
    required String sectionName,
    required Widget child,
  }) {
    if (!_isSectionActive(sectionName)) {
      return const SizedBox.shrink();
    }
    return child;
  }

  SliverAppBar _buildHomeSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: _expandedHomeHeaderExtent(context),
      floating: false,
      snap: false,
      pinned: true,
      elevation: 0,
      forceElevated: true,
      scrolledUnderElevation: 0,
      clipBehavior: Clip.hardEdge,
      backgroundColor: const Color(0xFF1A3A8A),
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      toolbarHeight: kToolbarHeight + _kHomeHeaderTopGap,
      titleSpacing: 0,
      centerTitle: true,
      title: const SizedBox.shrink(),
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          final double collapse = _headerCollapseProgress(context, constraints);
          final double topInset = _homeHeaderTopInset(context);

          return Stack(
            fit: StackFit.expand,
            children: [
              _buildExpandedHeaderContent(context, 1.0 - collapse),
              Positioned(
                top: topInset,
                left: _kHomeHeaderHorizontalPadding,
                right: _kHomeHeaderHorizontalPadding,
                height: kToolbarHeight,
                child: Opacity(
                  opacity: collapse,
                  child: IgnorePointer(
                    ignoring: collapse < 0.05,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: _buildCompactStickySearchBar(context),
                          ),
                        ),
                        profilePhotoOnHomeScreen(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final notifires = Provider.of<ColorNotifires>(context, listen: true);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: notifires.getbgcolor,
      appBar: kIsWeb ? const CustomAppBarHeaders() : null,
      body: GetBuilder<HomeController>(
        builder: (controller) {
          if (kIsWeb) {
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
                HomeFilterBar(),
                const SizedBox(height: 10),
                Expanded(
                  child: RefreshIndicator(
                    color: getColorBasedOnActiveModuleid(),
                    onRefresh: onRefresh,
                    child: ListView(
                      controller: scrollController,
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: ClampingScrollPhysics(),
                      ),
                      children: [
                        _buildOffstageSection(
                          sectionName: 'VehicleType',
                          child: _buildVehicleTypeSection(
                            context,
                            notifires,
                            stateSetter,
                          ),
                        ),
                        _buildOffstageSection(
                          sectionName: 'PopularRegion',
                          child: _buildPopularRegionSection(context, notifires),
                        ),
                        _buildOffstageSection(
                          sectionName: 'VehiclesNearYou',
                          child: _buildVehiclesNearYouSection(
                            context,
                            notifires,
                            stateSetter,
                          ),
                        ),
                        _buildOffstageSection(
                          sectionName: 'Make',
                          child: _buildMakeSection(context, notifires),
                        ),
                        _buildOffstageSection(
                          sectionName: 'BecomeHost',
                          child: _buildBecomeHostSection(context, notifires),
                        ),
                        _buildOffstageSection(
                          sectionName: 'MostViewed',
                          child: _buildMostViewedSection(
                            context,
                            notifires,
                            stateSetter,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return RefreshIndicator(
            color: getColorBasedOnActiveModuleid(),
            onRefresh: onRefresh,
            child: CustomScrollView(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: ClampingScrollPhysics(),
                ),
                slivers: [
                  _buildHomeSliverAppBar(context),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _HomeFilterBarPinnedDelegate(
                    backgroundColor: notifires.getbgcolor,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 8),
                      child: HomeFilterBar(),
                    ),
                  ),
                ),
                _buildSectionSliver(
                  sectionName: 'VehicleType',
                  child: _buildVehicleTypeSection(
                    context,
                    notifires,
                    stateSetter,
                  ),
                ),
                _buildSectionSliver(
                  sectionName: 'PopularRegion',
                  child: _buildPopularRegionSection(context, notifires),
                ),
                _buildSectionSliver(
                  sectionName: 'VehiclesNearYou',
                  child: _buildVehiclesNearYouSection(
                    context,
                    notifires,
                    stateSetter,
                  ),
                ),
                _buildSectionSliver(
                  sectionName: 'Make',
                  child: _buildMakeSection(context, notifires),
                ),
                _buildSectionSliver(
                  sectionName: 'BecomeHost',
                  child: _buildBecomeHostSection(context, notifires),
                ),
                _buildSectionSliver(
                  sectionName: 'MostViewed',
                  child: _buildMostViewedSection(
                    context,
                    notifires,
                    stateSetter,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
          );
        },
      ),
    );
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
        const SizedBox(height: 13),
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
              onTap: _openHomeMap,
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
                final homeData = homeController.homeDataModel?.data;
                final locations = homeData?.locations;
                if (locations == null || locations.isEmpty) return;
                filterController.clearFilter();
                filterController.setDefaultDates(
                  startDateCustomDate:
                      generalScopeController.startDateCustomDate,
                  endDateCustomDate: generalScopeController.endDateCustomDate,
                  startDate: filterController.startDate,
                  endDates: filterController.endDates,
                );
                Get.to(
                  () => LocationScreen(list: locations),
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
            final homeData = homeController.homeDataModel?.data;
            if (homeData == null) {
              return const SizedBox.shrink();
            }
            final locations = homeData.locations ?? [];

            if (locations.isNotEmpty) {
              return homeLocations(locations, notifires);
            } else {
              return const SizedBox();
            }
          }
        }),
        const SizedBox(height: 13),
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
                final homeData = homeController.homeDataModel?.data;
                final nearbyItems = homeData?.nearbyItems;
                if (nearbyItems == null || nearbyItems.isEmpty) return;
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
                  () => AfterSearch(itemList: nearbyItems),
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
            final homeData = homeController.homeDataModel?.data;
            if (homeData == null) {
              return const SizedBox.shrink();
            }
            final items = homeData.nearbyItems ?? [];

            if (items.isNotEmpty) {
              return Padding(
                padding:
                    const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
                child: vehicalHorizontalViewNearYou(
                    items, stateSetter, notifires),
              );
            } else {
              return const SizedBox();
            }
          }
        }),
        const SizedBox(height: 13),
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
                final makes =
                    homeController.homeDataModel?.data?.makes ?? [];
                if (makes.isEmpty) return;
                if (webPlateForm) {
                  Get.toNamed(WebRoutes.topCategory,
                      arguments: {'title': "Make".tr});
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => TopCategories(
                        title: "Make".tr,
                        list: makes,
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
                  homeController.homeDataModel?.data?.makes ?? [];

              if (vehicleMake.isNotEmpty) {
                return vehicalCategory(vehicleMake, notifires);
              } else {
                return const SizedBox();
              }
            }
          }),
        ),
        const SizedBox(height: 13),
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
            final homeData = homeController.homeDataModel?.data;
            if (homeData == null) {
              return const SizedBox.shrink();
            }
            final items = homeData.mostViewedItems ?? [];
            return Padding(
              padding: const EdgeInsets.all(12),
              child: vehicalVerticalView(items, true, false, stateSetter),
            );
          }
        }),
        const SizedBox(height: 13),
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
                          (filteredVehicleTypes[index].name ?? '')
                              .toString()
                              .trim()
                              .tr,
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
                          safePopAndAction(context, () {
                            homeController.onVehicleHomeScreenRefresh();
                          });
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
    final homeData = homeController.homeDataModel?.data;
    final allLocations = homeData?.locations;
    if (allLocations == null || allLocations.isEmpty) {
      return;
    }
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
                      final displayCity =
                          CityNameHelper.displayName(cityName);
                      return SizedBox(
                        height: 40,
                        child: ListTile(
                          title: Text(
                            displayCity,
                            style: regular3(context).copyWith(
                              color: notifires.getGrey1Whitecolor,
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                          trailing:
                              generalScopeController.homeSearchLocation.value ==
                                      cityName
                                  ? Icon(Icons.check,
                                      color: getColorBasedOnActiveModuleid())
                                  : null,
                          onTap: () {
                            filterController.applyCityLocationSelectionFromLocation(
                              location,
                            );
                            safePopAndAction(context, () {
                              filterController.submitMethod(context);
                            });
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

/// Garde la barre [Map / Tri / Filtre] collée en dessous de la zone bleue quand le header défile.
///
/// Hauteur fixe avec marge iOS/macOS : le contenu réel (padding + boutons + ombre)
/// peut dépasser ~90 px sur Apple à cause du text scaling et des métriques de police.
/// Sans contrainte explicite, layoutExtent > paintExtent et le viewport plante.
class _HomeFilterBarPinnedDelegate extends SliverPersistentHeaderDelegate {
  _HomeFilterBarPinnedDelegate({
    required this.backgroundColor,
    required this.child,
  });

  final Color backgroundColor;
  final Widget child;

  /// Padding vertical du [SliverPersistentHeader] (top 10 + bottom 8).
  static const double _kOuterPaddingVertical = 18.0;

  /// Hauteur estimée de [HomeFilterBar] (boutons + marges internes).
  static const double _kFilterBarContentHeight = 72.0;

  /// Marge de sécurité pour variations de pixels iOS/macOS (DPR, police, ombre).
  static const double _kIosSafetyMargin = 20.0;

  static const double _kPinnedHeight =
      _kOuterPaddingVertical + _kFilterBarContentHeight + _kIosSafetyMargin;

  @override
  double get minExtent => _kPinnedHeight;

  @override
  double get maxExtent => _kPinnedHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: _kPinnedHeight,
      child: Material(
        color: backgroundColor,
        elevation: 0,
        clipBehavior: Clip.hardEdge,
        child: Align(
          alignment: Alignment.topCenter,
          child: child,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _HomeFilterBarPinnedDelegate oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor;
  }
}
