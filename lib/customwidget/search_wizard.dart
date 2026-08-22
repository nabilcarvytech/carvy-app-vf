import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/controller/home_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/utils/rental_billing_days.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/helper/city_name_helper.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/rolling_calendar_bounds.dart';
import 'package:carvy/work_space.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:intl/intl.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SEARCH WIZARD - Recherche en 3 étapes: Location → Date → Time
// ═══════════════════════════════════════════════════════════════════════════

/// Construit une [Location] pour préremplir le wizard depuis la fiche véhicule :
/// correspondance avec les régions de l'accueil si possible, sinon ville + coordonnées.
Location? buildInitialLocationForVehicle({
  required String? city,
  String? vehicleLat,
  String? vehicleLng,
  List<Location>? homeRegions,
}) {
  final trimmed = city?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;

  if (homeRegions != null) {
    final lower = trimmed.toLowerCase();
    for (final loc in homeRegions) {
      if ((loc.cityName ?? '').trim().toLowerCase() == lower) return loc;
    }
    for (final loc in homeRegions) {
      final name = (loc.cityName ?? '').toLowerCase();
      if (name.contains(lower) || lower.contains(name)) return loc;
    }
  }

  return Location(
    cityName: trimmed,
    latitude: vehicleLat,
    longitude: vehicleLng,
  );
}

void openSearchWizard(
  BuildContext context, {
  VoidCallback? onSearch,
  Location? initialLocation,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SearchWizardBottomSheet(
      onSearch: onSearch,
      initialLocation: initialLocation,
    ),
  );
}

class SearchWizardBottomSheet extends StatefulWidget {
  final VoidCallback? onSearch;
  final Location? initialLocation;

  const SearchWizardBottomSheet({
    super.key,
    this.onSearch,
    this.initialLocation,
  });

  @override
  State<SearchWizardBottomSheet> createState() =>
      _SearchWizardBottomSheetState();
}

class _SearchWizardBottomSheetState extends State<SearchWizardBottomSheet> {
  final SearchControllerHome filterController = Get.find();
  final HomeController homeController = Get.find();

  late int _currentStep; // 0: Location, 1: Date, 2: Time
  final TextEditingController _searchController = TextEditingController();
  List<Location> _filteredLocations = [];
  List<Location> _allLocations = [];

  // Date selection
  DateTime? _startDate;
  DateTime? _endDate;

  // Time selection : grille via SearchController (véhicule 09:00–20:30).
  String _startTime = "09:00";
  String _endTime = "09:00";
  bool _returnTimeUserTouched = false;

  String get _dateLocale => Get.locale?.languageCode ?? 'fr';

  String _formatWizardDate(DateTime date, {String pattern = 'MMM d'}) {
    return DateFormat(pattern, _dateLocale).format(date);
  }

  @override
  void initState() {
    super.initState();
    if (activeModuleId.value != 2) {
      _endTime = "10:00";
    }
    _currentStep = widget.initialLocation != null ? 1 : 0;
    _loadLocations();
    _searchController.addListener(_filterLocations);

    if (widget.initialLocation != null) {
      _applyLocationSelection(widget.initialLocation!);
    } else {
      // Charger la valeur sélectionnée seulement si ce n'est pas "All location"
      final currentLocation = generalScopeController.homeSearchLocation.value;
      if (currentLocation.isNotEmpty &&
          currentLocation != "All location".tr &&
          currentLocation != "All location") {
        _searchController.text = currentLocation;
      }
    }
    // Sinon, laisser la barre vide pour voir toutes les locations
  }

  void _applyLocationSelection(Location location) {
    filterController.applyCityLocationSelectionFromLocation(location);
    _searchController.text = location.cityName ?? '';
  }

  void _loadLocations() {
    if (homeController.homeDataModel?.data?.locations != null) {
      _allLocations = homeController.homeDataModel!.data!.locations!;
      _filteredLocations = _allLocations;
    }
  }

  void _filterLocations() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = _allLocations;
      } else {
        _filteredLocations = _allLocations
            .where((loc) => (loc.cityName ?? '').toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      _performSearch();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _selectLocation(Location location) {
    setState(() {
      _applyLocationSelection(location);
    });
  }

  void _performSearch() {
    // Sauvegarder les valeurs
    if (_startDate != null) {
      filterController.startDate.value =
          _formatWizardDate(_startDate!, pattern: 'MMM d, E');
      generalScopeController.startDateCustomDate.value =
          DateFormat('yyyy-MM-dd').format(_startDate!);
    }
    if (_endDate != null) {
      filterController.endDates.value =
          _formatWizardDate(_endDate!, pattern: 'MMM d, E');
      generalScopeController.endDateCustomDate.value =
          DateFormat('yyyy-MM-dd').format(_endDate!);
    }

    filterController.startTimeSearch.value = _startTime;
    filterController.endTimeSearch.value = _endTime;

    Navigator.pop(context);

    if (widget.onSearch != null) {
      widget.onSearch!();
    } else {
      filterController.submitMethod(context);
    }
  }

  RentalBillingSummary? _vehicleWizardRentalSummary() {
    if (activeModuleId.value != 2 || _startDate == null || _endDate == null) {
      return null;
    }
    return RentalBillingDays.compute(
      startDate: _startDate!,
      endDate: _endDate!,
      startTime: RentalBillingDays.parseTimeOfDayFromSlot(_startTime),
      endTime: RentalBillingDays.parseTimeOfDayFromSlot(_endTime),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return generalScopeController.homeSearchLocation.value.isNotEmpty;
      case 1:
        return _startDate != null && _endDate != null;
      case 2:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: notifires.getbgcolor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // ─────────────────────────────────────────────────────────────
          // HEADER avec indicateur d'étapes
          // ─────────────────────────────────────────────────────────────
          _buildHeader(),

          // ─────────────────────────────────────────────────────────────
          // CONTENU de l'étape actuelle
          // ─────────────────────────────────────────────────────────────
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildStepContent(),
            ),
          ),

          // ─────────────────────────────────────────────────────────────
          // BOUTONS Navigation
          // ─────────────────────────────────────────────────────────────
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final steps = [
      {'icon': Icons.location_on_rounded, 'label': 'Location'.tr},
      {'icon': Icons.calendar_today_rounded, 'label': 'Date'.tr},
      {'icon': Icons.access_time_rounded, 'label': 'Time'.tr},
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: notifires.getbgcolor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Poignée
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: notifires.getgreycolor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Indicateur d'étapes
          Row(
            children: List.generate(3, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted || isActive
                              ? getColorBasedOnActiveModuleid()
                              : notifires.getgreycolor.withOpacity(0.3),
                        ),
                      ),
                    Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isActive || isCompleted
                                ? getColorBasedOnActiveModuleid()
                                : notifires.getgreycolor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCompleted
                                ? Icons.check_rounded
                                : steps[index]['icon'] as IconData,
                            color: isActive || isCompleted
                                ? Colors.white
                                : notifires.getgreycolor,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          steps[index]['label'] as String,
                          style: regular2(context).copyWith(
                            color: isActive
                                ? getColorBasedOnActiveModuleid()
                                : notifires.getgreycolor,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    if (index < 2)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? getColorBasedOnActiveModuleid()
                              : notifires.getgreycolor.withOpacity(0.3),
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildLocationStep();
      case 1:
        return _buildDateStep();
      case 2:
        return _buildTimeStep();
      default:
        return const SizedBox();
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ÉTAPE 1: Sélection de la location
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildLocationStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Where do you want to go?'.tr,
            style: heading2Grey1(context).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Barre de recherche
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: notifires.getgreycolor.withOpacity(0.25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              style: regular2(context).copyWith(color: Colors.black87),
              decoration: InputDecoration(
                hintText: 'Search location...'.tr,
                hintStyle:
                    regular2(context).copyWith(color: Colors.grey.shade500),
                prefixIcon: Container(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.search_rounded,
                    color: getColorBasedOnActiveModuleid(),
                  ),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded,
                            color: Colors.grey.shade500),
                        onPressed: () {
                          _searchController.clear();
                          // Ne pas effacer la sélection, juste le texte de recherche
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Popular Regions'.tr,
            style: regular2(context).copyWith(
              color: notifires.getgreycolor,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 12),

          // Grille des locations avec images
          Expanded(
            child: _filteredLocations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_off_rounded,
                            size: 48, color: notifires.getgreycolor),
                        const SizedBox(height: 12),
                        Text(
                          'No locations found'.tr,
                          style: regular2(context)
                              .copyWith(color: notifires.getgreycolor),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: _filteredLocations.length,
                    itemBuilder: (context, index) {
                      final location = _filteredLocations[index];
                      final isSelected =
                          generalScopeController.homeSearchLocation.value ==
                              location.cityName;

                      return GestureDetector(
                        onTap: () {
                          _selectLocation(location);
                          setState(() {});
                        },
                        child: Stack(
                          children: [
                            // Image de la ville
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: isSelected
                                    ? Border.all(
                                        color: getColorBasedOnActiveModuleid(),
                                        width: 3,
                                      )
                                    : null,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Image
                                    location.image != null &&
                                            location.image!.isNotEmpty
                                        ? Image.network(
                                            location.image!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                Container(
                                              color:
                                                  getColorBasedOnActiveModuleid()
                                                      .withOpacity(0.3),
                                              child: Icon(
                                                Icons.location_city_rounded,
                                                color: Colors.white,
                                                size: 40,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            color:
                                                getColorBasedOnActiveModuleid()
                                                    .withOpacity(0.3),
                                            child: Icon(
                                              Icons.location_city_rounded,
                                              color: Colors.white,
                                              size: 40,
                                            ),
                                          ),
                                    // Overlay gradient
                                    Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            Colors.transparent,
                                            Colors.black.withOpacity(0.7),
                                          ],
                                        ),
                                      ),
                                    ),
                                    // Nom de la ville
                                    Positioned(
                                      left: 8,
                                      right: 8,
                                      bottom: 8,
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              CityNameHelper.displayName(
                                                location.cityName,
                                              ),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              textAlign: TextAlign.start,
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Badge de sélection
                            if (isSelected)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: getColorBasedOnActiveModuleid(),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Bouton "See More" si nécessaire
          if (_allLocations.length > 6 &&
              _filteredLocations.length == _allLocations.length)
            TextButton.icon(
              onPressed: () {
                // Afficher toutes les locations
              },
              icon: Icon(Icons.expand_more,
                  color: getColorBasedOnActiveModuleid()),
              label: Text(
                'See More'.tr,
                style: TextStyle(
                  color: getColorBasedOnActiveModuleid(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ÉTAPE 2: Sélection de la date
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDateStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select dates'.tr,
            style: heading2Grey1(context).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Afficher les dates sélectionnées
          if (_startDate != null && _endDate != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: getColorBasedOnActiveModuleid().withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.date_range_rounded,
                      color: getColorBasedOnActiveModuleid(), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatWizardDate(_startDate!)} - ${_formatWizardDate(_endDate!)}',
                    style: regular2(context).copyWith(
                      color: getColorBasedOnActiveModuleid(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          // Calendrier
          Expanded(
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              minDate: RollingCalendarBounds.firstDate(),
              maxDate: RollingCalendarBounds.lastDate(),
              enablePastDates: false,
              navigationDirection: DateRangePickerNavigationDirection.vertical,
              navigationMode: DateRangePickerNavigationMode.scroll,
              enableMultiView: true,
              backgroundColor: Colors.white,
              headerStyle: DateRangePickerHeaderStyle(
                textStyle: heading2Grey1(context).copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
                backgroundColor: Colors.white,
              ),
              selectionColor: getColorBasedOnActiveModuleid(),
              startRangeSelectionColor: getColorBasedOnActiveModuleid(),
              endRangeSelectionColor: getColorBasedOnActiveModuleid(),
              rangeSelectionColor: getColorBasedOnActiveModuleid()
                  .withOpacity(0.15), // Very light blue for in-between dates
              todayHighlightColor: getColorBasedOnActiveModuleid(),
              selectionTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              rangeTextStyle: TextStyle(
                color: getColorBasedOnActiveModuleid(),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle: regular2(context).copyWith(
                  fontSize: 16,
                  color: Colors.black,
                ),
                todayTextStyle: regular2(context).copyWith(
                  color: getColorBasedOnActiveModuleid(),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                disabledDatesTextStyle:
                    RollingCalendarBounds.disabledDateTextStyle(fontSize: 16),
              ),
              monthViewSettings: DateRangePickerMonthViewSettings(
                viewHeaderHeight: 50,
                viewHeaderStyle: DateRangePickerViewHeaderStyle(
                  backgroundColor: Colors.white,
                  textStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  setState(() {
                    _startDate = args.value.startDate;
                    _endDate = args.value.endDate ?? args.value.startDate;
                    _returnTimeUserTouched = false;
                    if (activeModuleId.value == 2) {
                      _startTime = "09:00";
                      _endTime = "09:00";
                    } else {
                      _startTime = "09:00";
                      _endTime = "10:00";
                    }
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ÉTAPE 3: Sélection de l'heure
  // ═══════════════════════════════════════════════════════════════════════════

  void _onPickupTimeChanged(String newPickupTime) {
    setState(() {
      _startTime = newPickupTime;
      if (!_returnTimeUserTouched) {
        _endTime = newPickupTime;
      } else if (filterController.isEndTimeStrictlyBeforeStartTime(
          newPickupTime, _endTime)) {
        _endTime = newPickupTime;
      }
    });
  }

  Widget _buildTimeStep() {
    final timeSlots = filterController.searchPickerBaselineSlots();

    int startIndex = timeSlots.indexOf(_startTime);
    if (startIndex < 0) startIndex = 0;

    int endIndex = timeSlots.indexOf(_endTime);
    if (endIndex < 0) endIndex = 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select time'.tr,
            style: heading2Grey1(context).copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Résumé de la sélection
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: getColorBasedOnActiveModuleid().withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        color: getColorBasedOnActiveModuleid(), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        generalScopeController.homeSearchLocation.value,
                        style: regular2(context).copyWith(
                            fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.date_range_rounded,
                        color: getColorBasedOnActiveModuleid(), size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Builder(
                        builder: (context) {
                          final summary = _vehicleWizardRentalSummary();
                          final hasExtra = summary?.hasExtraDay ?? false;
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${_formatWizardDate(_startDate!)} - ',
                                style: regular2(context).copyWith(fontSize: 13),
                              ),
                              Flexible(
                                child: VehicleReturnDateWithBillingBadgeRow(
                                  dateText: _formatWizardDate(_endDate!),
                                  textAlign: TextAlign.start,
                                  isExtraDay: hasExtra,
                                  emphasizeOvertime: hasExtra,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Message d'information sur la confirmation des horaires
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              'out_of_hours_warning'.tr,
              textAlign: TextAlign.center,
              style: regular2(context).copyWith(
                fontSize: 12,
                color: notifires.getgreycolor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          // Spacer pour pousser les pickers vers le bas
          const Spacer(),

          // Wheel Pickers côte à côte
          Row(
            children: [
              // Pick-up Time Wheel
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Pick-up time'.tr,
                      style: regular2(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: notifires.getGrey1Whitecolor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTimeWheelPicker(
                      timeSlots: timeSlots,
                      initialIndex: startIndex,
                      onSelect: (time) => _onPickupTimeChanged(time),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Drop-off Time Wheel (filtré)
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'Drop-off time'.tr,
                      style: regular2(context).copyWith(
                        fontWeight: FontWeight.w600,
                        color: notifires.getGrey1Whitecolor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildTimeWheelPicker(
                      timeSlots: timeSlots,
                      initialIndex: endIndex,
                      onSelect: (time) => setState(() {
                        _returnTimeUserTouched = true;
                        _endTime = time;
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Spacer en bas
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTimeWheelPicker({
    required List<String> timeSlots,
    required int initialIndex,
    required Function(String) onSelect,
  }) {
    final FixedExtentScrollController scrollController =
        FixedExtentScrollController(initialItem: initialIndex);

    return Container(
      height: 180, // Hauteur réduite
      decoration: BoxDecoration(
        color: notifires.getGrey3Whitecolor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Highlight pour l'élément sélectionné
          Center(
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: getColorBasedOnActiveModuleid().withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // Wheel Picker
          ListWheelScrollView.useDelegate(
            controller: scrollController,
            itemExtent: 40, // Plus compact
            perspective: 0.004,
            diameterRatio: 1.3,
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              onSelect(timeSlots[index]);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: timeSlots.length,
              builder: (context, index) {
                final isSelected = scrollController.hasClients
                    ? scrollController.selectedItem == index
                    : initialIndex == index;

                return Center(
                  child: Text(
                    timeSlots[index],
                    style: TextStyle(
                      fontSize: isSelected ? 16 : 13,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? notifires.getGrey1Whitecolor
                          : notifires.getgreycolor,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final rentalSummary = _vehicleWizardRentalSummary();
    final showRentalBanner =
        _currentStep == 2 && activeModuleId.value == 2 && rentalSummary != null;

    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: notifires.getbgcolor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (showRentalBanner) ...[
            VehicleRentalBillableDaysInfoBanner(
              totalBillableDays: rentalSummary!.totalDays,
              hasOvertimeDay: rentalSummary.hasExtraDay,
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
          // Bouton Retour
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: notifires.getgreycolor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Back'.tr,
                  style: regular2(context).copyWith(
                    color: notifires.getGrey1Whitecolor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          if (_currentStep > 0) const SizedBox(width: 12),

          // Bouton Suivant/Rechercher
          Expanded(
            flex: _currentStep == 0 ? 1 : 2,
            child: ElevatedButton(
              onPressed: _canProceed() ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: getColorBasedOnActiveModuleid(),
                disabledBackgroundColor:
                    notifires.getgreycolor.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _currentStep == 2 ? 'Search'.tr : 'Next'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _currentStep == 2
                        ? Icons.search_rounded
                        : Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
            ],
          ),
        ],
      ),
    );
  }
}
