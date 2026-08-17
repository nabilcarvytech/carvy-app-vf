import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/controller/view_map_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/helper/map_privacy_helper.dart';
import 'package:carvy/model/items_model.dart';
import 'package:carvy/services/location_service.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/itemdetail/vehicle/vehicle_detail_screen.dart';
import 'package:carvy/work_space.dart';
import '../../../customwidget/custom_active_module_id_widget.dart';
import '../../../customwidget/project_color.dart';
import '../../../model/vehicle_home_model.dart';
import '../../../utils/theme_style.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carvy/customwidget/search_wizard.dart';

class ViewOnMapScreen extends StatefulWidget {
  final String? title;
  final List<dynamic>? list;
  const ViewOnMapScreen({super.key, this.title, this.list});

  @override
  State<ViewOnMapScreen> createState() => _ViewOnMapScreenState();
}

class _ViewOnMapScreenState extends State<ViewOnMapScreen> {
  /// Zoom max pour masquer l'emplacement exact (quartier, pas la rue).
  static const double _kVehicleMapMaxZoom =
      MapPrivacyHelper.vehicleMapMaxZoom;
  static const double _kVehicleMapInitialZoom =
      MapPrivacyHelper.vehicleMapInitialZoom;
  static const MinMaxZoomPreference _kVehicleMapZoomPreference =
      MinMaxZoomPreference(3.0, _kVehicleMapMaxZoom);

  GoogleMapController? googleMapController;
  MapViewController mapViewController = Get.put(MapViewController());
  late final PageController pageController;
  SearchControllerHome searchControllerHome = Get.find();
  /// Fallback Maroc — évite le centrage par défaut sur Mountain View (Californie).
  LatLng mylatlng = const LatLng(31.7917, -7.0926);
  Set<Marker> markers = {};
  final Map<String, LatLng> _obfuscatedPositions = {};
  LatLng? _userLatLng;
  bool _cameraInitialized = false;
  bool _pendingCameraInit = false;
  /// Masque la carte brute jusqu'à GPS + caméra prêts (évite le saut de centrage).
  bool _isMapInitializing = true;
  /// N'instancie GoogleMap qu'une fois le centre initial connu.
  bool _mapReadyToBuild = false;
  ItemModel? itemModel;
  bool visibleList = false;
  LatLng? _lastApiCallLocation;
  LatLng? _lastLocationWithResults;
  List<dynamic> items = [];
  bool _userMovingMap = false;
  bool _isClampingZoom = false;
  CarouselSliderController carouselController = CarouselSliderController();
  Timer? _debounce;
  CameraPosition? _currentCameraPosition;
  int currentIndex = 0;
  final ScrollController _scrollController = ScrollController();
  double _currentPage = 0;
  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    // Liste complète : args de navigation, sinon résultats de recherche globaux.
    if (widget.list != null && widget.list!.isNotEmpty) {
      items = List.from(widget.list!);
    } else if (searchControllerHome.searchFilterList.isNotEmpty) {
      items = List.from(searchControllerHome.searchFilterList);
    } else {
      items = [];
    }
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      searchControllerHome.desildetoSendparametersBasedOnPage.value = true;
      await _bootstrapMap();
    });
  }

  /// Parse lat/lng depuis Items / ItemsData (string, num, ou vide).
  LatLng? _parseItemLatLng(dynamic location) {
    try {
      final latRaw = location.latitude;
      final lngRaw = location.longitude;
      final latitude = latRaw is num
          ? latRaw.toDouble()
          : double.tryParse(latRaw?.toString().trim() ?? '');
      final longitude = lngRaw is num
          ? lngRaw.toDouble()
          : double.tryParse(lngRaw?.toString().trim() ?? '');
      if (latitude == null || longitude == null) return null;
      if (latitude == 0 && longitude == 0) return null;
      if (latitude < -90 || latitude > 90) return null;
      if (longitude < -180 || longitude > 180) return null;
      return LatLng(latitude, longitude);
    } catch (_) {
      return null;
    }
  }

  LatLng _displayPositionForItem(dynamic location) {
    final id = location.id?.toString() ?? location.hashCode.toString();
    final cached = _obfuscatedPositions[id];
    if (cached != null) return cached;

    final exact = _parseItemLatLng(location);
    if (exact == null) {
      return mylatlng;
    }

    final obfuscated = MapPrivacyHelper.obfuscateCoordinates(
      exact.latitude,
      exact.longitude,
      id,
    );
    _obfuscatedPositions[id] = obfuscated;
    return obfuscated;
  }

  Future<void> _bootstrapMap() async {
    _pendingCameraInit = true;

    // 1) Position utilisateur (pin bleu)
    await _ensureUserLocation(requestPermission: true);

    // 2) Liste véhicules : args → état recherche → API autour du centre
    if (items.isEmpty &&
        searchControllerHome.searchFilterList.isNotEmpty) {
      items = List.from(searchControllerHome.searchFilterList);
    }
    if (items.isEmpty) {
      await _fetchVehiclesForMap();
    }

    if (items.isNotEmpty) {
      visibleList = true;
      final withCoords =
          items.where((e) => _parseItemLatLng(e) != null).toList();
      final anchor = withCoords.isNotEmpty ? withCoords.first : items.first;
      mylatlng = _displayPositionForItem(anchor);
      _lastApiCallLocation = mylatlng;
      _lastLocationWithResults = mylatlng;
    }

    // Centre initial = GPS utilisateur (sinon premier véhicule / fallback).
    if (_userLatLng != null) {
      mylatlng = _userLatLng!;
    }

    // 3) Une seule injection atomique des markers (véhicules + user)
    await setMarkers();

    if (!mounted) return;
    // Monte GoogleMap seulement maintenant, déjà ciblée sur mylatlng.
    setState(() {
      _mapReadyToBuild = true;
    });

    // Si le contrôleur existe déjà (cas rare), finaliser le centrage tout de suite.
    if (googleMapController != null) {
      await _centerMapOnUserAndVehicles(requestPermission: false);
      _finishMapInitialization();
    }
  }

  void _finishMapInitialization() {
    if (!mounted || !_isMapInitializing) return;
    setState(() {
      _isMapInitializing = false;
    });
  }

  Future<void> _ensureUserLocation({required bool requestPermission}) async {
    if (_userLatLng != null) return;
    if (!requestPermission) return;
    final position =
        await LocationService.getCurrentPositionWithChecks(context);
    if (position == null) return;
    _userLatLng = LatLng(position.latitude, position.longitude);
    _prepareUserLocationMarker(_userLatLng!);
  }

  void _prepareUserLocationMarker(LatLng userLatLng) {
    currentLocationMarker = Marker(
      markerId: const MarkerId('current_location'),
      position: userLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      consumeTapEvents: true,
      onTap: () {},
    );
  }

  /// Charge les véhicules disponibles si la carte s'ouvre sans liste.
  Future<void> _fetchVehiclesForMap() async {
    final lat = _userLatLng?.latitude.toString() ??
        (slatsearch?.isNotEmpty == true ? slatsearch : null) ??
        mylatlng.latitude.toString();
    final lng = _userLatLng?.longitude.toString() ??
        (sLongSearch?.isNotEmpty == true ? sLongSearch : null) ??
        mylatlng.longitude.toString();

    try {
      final price = searchControllerHome.resolveSearchPriceParam();
      final result = await searchControllerHome.searchItems(
        '',
        searchControllerHome.selectedtypesvalues.toString(),
        price,
        "${activeModuleId.value == 1 ? searchControllerHome.selectedBeds : '0'}",
        "${activeModuleId.value == 1 ? searchControllerHome.selectedBathroom : '0'}",
        searchControllerHome.featuresvalues.toString(),
        "1000",
        generalScopeController.startDateCustomDate.value.toString(),
        generalScopeController.endDateCustomDate.value.toString(),
        activeModuleId.value == 1 ? "0" : "0",
        lat,
        lng,
        context,
        "${activeModuleId.value == 2 ? searchControllerHome.maketypeFunction() : activeModuleId.value == 5 ? searchControllerHome.bookablemetadata() : ''}",
      );
      itemModel = ItemModel.fromJson(result);
      final newItems = itemModel?.data?.items ?? [];
      if (newItems.isEmpty) return;
      items = List.from(newItems);
      searchControllerHome.searchFilterList
        ..clear()
        ..addAll(newItems);
      searchControllerHome.offset = itemModel!.data!.offset!;
    } catch (e) {
      debugPrint('Map vehicle fetch failed: $e');
    }
  }

  Future<void> _applyCameraToPoints(
    List<LatLng> points, {
    bool instant = false,
  }) async {
    if (points.isEmpty) {
      await _moveOrAnimateCamera(
        CameraUpdate.newLatLngZoom(
          mylatlng,
          _clampedMapZoom(_kVehicleMapInitialZoom),
        ),
        instant: instant,
      );
      return;
    }

    if (points.length == 1) {
      mylatlng = points.first;
      await _moveOrAnimateCamera(
        CameraUpdate.newLatLngZoom(
          mylatlng,
          _clampedMapZoom(_kVehicleMapInitialZoom),
        ),
        instant: instant,
      );
      return;
    }

    final bounds = MapPrivacyHelper.boundsForPoints(points);
    await _moveOrAnimateCamera(
      CameraUpdate.newLatLngBounds(bounds, 80),
      instant: instant,
    );
  }

  Future<void> _moveOrAnimateCamera(
    CameraUpdate update, {
    required bool instant,
  }) async {
    final controller = googleMapController;
    if (controller == null) return;
    if (instant) {
      await controller.moveCamera(update);
      await _enforceMaxZoom();
    } else {
      await _animateMapCamera(update);
    }
  }

  Future<void> _centerMapOnUserAndVehicles({
    required bool requestPermission,
  }) async {
    await _ensureUserLocation(requestPermission: requestPermission);
    if (_userLatLng != null) {
      _prepareUserLocationMarker(_userLatLng!);
    }

    final points = <LatLng>[];
    if (_userLatLng != null) {
      points.add(_userLatLng!);
    }
    for (final item in items) {
      if (_parseItemLatLng(item) != null) {
        points.add(_displayPositionForItem(item));
      }
    }

    if (googleMapController == null) {
      _pendingCameraInit = true;
      if (points.isNotEmpty) {
        mylatlng = points.first;
      }
      // Nouveau Set obligatoire : GoogleMap ignore les mutations in-place.
      await setMarkers();
      return;
    }

    await _applyCameraToPoints(points);
    _cameraInitialized = true;
    _pendingCameraInit = false;
  }

  Future<void> _setUserLocationMarker(LatLng userLatLng) async {
    _userLatLng = userLatLng;
    _prepareUserLocationMarker(userLatLng);
    // Réinjecte tous les markers (évite d'écraser les véhicules).
    await setMarkers();
  }

  @override
  void dispose() {
    super.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
  }

  void _onScroll() {
    setState(() {
      _currentPage =
          _scrollController.position.pixels / MediaQuery.of(context).size.width;
      mapReload(_currentPage.round());
    });
  }

  double _clampedMapZoom(double zoom) =>
      zoom > _kVehicleMapMaxZoom ? _kVehicleMapMaxZoom : zoom;

  Future<void> _animateMapCamera(CameraUpdate update) async {
    final controller = googleMapController;
    if (controller == null) return;
    await controller.animateCamera(update);
    await _enforceMaxZoom();
  }

  Future<void> _enforceMaxZoom() async {
    final controller = googleMapController;
    if (controller == null) return;
    try {
      final zoom = await controller.getZoomLevel();
      if (zoom > _kVehicleMapMaxZoom) {
        await controller.moveCamera(
          CameraUpdate.zoomTo(_kVehicleMapMaxZoom),
        );
      }
    } catch (_) {}
  }

  void _openVehiclePreviewSheet(dynamic vehicle) {
    ItemInfo? itemInfoData;
    try {
      final jsonString = vehicle.itemInfo;
      if (jsonString != null) {
        itemInfoData = ItemInfo.fromJson(json.decode(jsonString));
      }
    } catch (_) {}

    final approxLabel =
        MapPrivacyHelper.approximateAddressLabel(vehicle).tr;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notifires.getboxcolor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: SafeArea(
            top: false,
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
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: myNetworkImageWithShimmer('${vehicle.image}'),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${vehicle.name}',
                  style: heading3Grey1(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: getColorBasedOnActiveModuleid(),
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        approxLabel,
                        style: regular(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "$currency ${vehicle.price}${" /day".tr}",
                  style: heading2Grey1(context).copyWith(
                    color: getColorBasedOnActiveModuleid(),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: getColorBasedOnActiveModuleid(),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VehicleDetailSScreen(
                            id: vehicle.id,
                            itemInfo: itemInfoData,
                            rating: vehicle.itemRating,
                            title: vehicle.name,
                            address: approxLabel,
                            latitute: vehicle.latitude,
                            longtitute: vehicle.longitude,
                            frontImage: vehicle.image,
                            itemType: vehicle.itemType,
                            price: vehicle.price,
                            isWishList: vehicle.isInWishlist ?? false,
                            handleback: true,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'View details'.tr,
                      style: heading3(context).copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void mapReload(int index) {
    if (index < 0 || index >= items.length) return;
    mylatlng = _displayPositionForItem(items[index]);
    setState(() {
      _animateMapCamera(CameraUpdate.newLatLng(mylatlng));
    });
  }

  Future<void> searchMethodOnMapMoved(String latitude, String longitude) async {
    if (!_userMovingMap) return;
    searchControllerHome.setCity = "";
    searchControllerHome.setCountry = "";
    searchControllerHome.setState = "";
    searchControllerHome.placeRadius = 0.0;
    searchControllerHome.centralLat = 0.0;
    searchControllerHome.centralLng = 0.0;
    searchControllerHome.sendvalueInApiforrecentValue.value = false;
    itemModel = null;
    if (_lastApiCallLocation != null) {
      final distance = _calculateDistance(
        double.parse(latitude),
        double.parse(longitude),
        _lastApiCallLocation!.latitude,
        _lastApiCallLocation!.longitude,
      );
      if (distance < 0.1) return;
    }
    _lastApiCallLocation =
        LatLng(double.parse(latitude), double.parse(longitude));
    setState(() {
      isLoadingMap = true;
    });
    try {
      var result = await searchControllerHome.searchItems(
        '',
        searchControllerHome.selectedtypesvalues.toString(),
        "",
        "${activeModuleId.value == 1 ? searchControllerHome.selectedBeds : '0'}",
        "${activeModuleId.value == 1 ? searchControllerHome.selectedBathroom : '0'}",
        searchControllerHome.featuresvalues.toString(),
        "1000",
        generalScopeController.startDateCustomDate.value.toString(),
        generalScopeController.endDateCustomDate.value.toString(),
        activeModuleId.value == 1 ? "0" : "0",
        latitude.toString(),
        longitude.toString(),
        context,
        "${activeModuleId.value == 2 ? searchControllerHome.maketypeFunction() : activeModuleId.value == 5 ? searchControllerHome.bookablemetadata() : ''}",
      );
      itemModel = ItemModel.fromJson(result);
      var newItems = itemModel!.data!.items ?? [];
      if (newItems.isNotEmpty) {
        items = List.from(newItems);
        _obfuscatedPositions.clear();
        final withCoords = items.where((e) => _parseItemLatLng(e) != null);
        final anchor =
            withCoords.isNotEmpty ? withCoords.first : items.first;
        mylatlng = _displayPositionForItem(anchor);
        _lastLocationWithResults = mylatlng;
        await setMarkers();
        visibleList = true;
        searchControllerHome.searchFilterList
          ..clear()
          ..addAll(newItems);
        searchControllerHome.offset = itemModel!.data!.offset!;
      } else if (_lastLocationWithResults != null) {
        await _animateMapCamera(
          CameraUpdate.newLatLng(_lastLocationWithResults!),
        );
      }
      if (mounted) {
        setState(() {
          isLoadingMap = false;
        });
      }
    } catch (error) {
      setState(() {
        isLoadingMap = false;
      });
      if (_lastLocationWithResults != null) {
        _animateMapCamera(
          CameraUpdate.newLatLng(_lastLocationWithResults!),
        );
      }
    }
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double p = 0.017453292519943295;
    final double cLat1 = math.cos(lat1 * p);
    final double cLat2 = math.cos(lat2 * p);
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        cLat1 * cLat2 * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  Marker? currentLocationMarker;
  BitmapDescriptor? _vehicleMarkerIcon;

  Future<BitmapDescriptor> _loadVehicleMarkerIcon() async {
    if (_vehicleMarkerIcon != null) return _vehicleMarkerIcon!;
    try {
      final bytes = await mapViewController.getBytesFromCanvasImage(96, 96);
      _vehicleMarkerIcon = BitmapDescriptor.bytes(
        bytes,
        width: 48,
        height: 48,
        imagePixelRatio: 2,
      );
    } catch (e) {
      debugPrint('Vehicle marker icon fallback: $e');
      _vehicleMarkerIcon =
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
    return _vehicleMarkerIcon!;
  }

  /// Injecte tous les véhicules (+ pin utilisateur) dans un **nouveau** Set.
  /// GoogleMap ne détecte pas les mutations in-place de [markers].
  Future<void> setMarkers() async {
    final Set<Marker> newMarkers = {};
    final Set<Circle> newCircles = {};
    final List<dynamic> localList = List.from(items);
    final zoneColor = getColorBasedOnActiveModuleid();
    final vehicleIcon = await _loadVehicleMarkerIcon();

    for (var i = 0; i < localList.length; i++) {
      final location = localList[i];
      try {
        if (_parseItemLatLng(location) == null) {
          debugPrint(
            'Skip marker: missing coords for item ${location.id}',
          );
          continue;
        }

        // Position floutée (400–1200 m) — jamais les coords exactes API.
        final displayPosition = _displayPositionForItem(location);
        final markerId =
            'vehicle_${location.id?.toString() ?? 'idx'}_$i';

        newCircles.add(
          Circle(
            circleId: CircleId('zone_$markerId'),
            center: displayPosition,
            radius: MapPrivacyHelper.approximateZoneRadiusMeters,
            fillColor: zoneColor.withOpacity(0.12),
            strokeColor: zoneColor.withOpacity(0.35),
            strokeWidth: 1,
          ),
        );

        final priceLabel =
            '$currency ${location.price}${" /day".tr}'.trim();
        final captured = location;
        final capturedIndex = i;

        newMarkers.add(
          Marker(
            markerId: MarkerId(markerId),
            position: displayPosition,
            icon: vehicleIcon,
            consumeTapEvents: true,
            infoWindow: InfoWindow(
              title: '${captured.name ?? ''}',
              snippet: priceLabel,
              onTap: () => _openVehiclePreviewSheet(captured),
            ),
            onTap: () {
              final index = items.indexWhere(
                (element) =>
                    element.id?.toString() == captured.id?.toString(),
              );
              final resolvedIndex = index != -1 ? index : capturedIndex;
              if (resolvedIndex >= 0 && resolvedIndex < items.length) {
                setState(() {
                  visibleList = true;
                  currentIndex = resolvedIndex;
                });
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToIndex(resolvedIndex);
                });
              }
              _openVehiclePreviewSheet(captured);
            },
          ),
        );
      } catch (e, stack) {
        debugPrint("Error while setting marker: $e\n$stack");
      }
    }

    if (_userLatLng != null) {
      _prepareUserLocationMarker(_userLatLng!);
    }
    if (currentLocationMarker != null) {
      newMarkers.add(currentLocationMarker!);
      newCircles.add(
        Circle(
          circleId: const CircleId('current_location_circle'),
          center: currentLocationMarker!.position,
          radius: 50,
          fillColor: Colors.blue.withOpacity(0.25),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      );
    }

    debugPrint(
      'Map markers: ${newMarkers.length} '
      '(vehicles: ${newMarkers.where((m) => m.markerId.value.startsWith('vehicle_')).length} '
      '/ items: ${localList.length})',
    );

    if (!mounted) return;
    setState(() {
      markers = newMarkers;
      circles = newCircles;
    });
  }

  Set<Circle> circles = {};

  Future<void> _moveToCurrentLocation() async {
    showLoading();
    try {
      await _centerMapOnUserAndVehicles(requestPermission: true);
    } finally {
      closeLoading();
    }
  }

  Future<void> searchMethod() async {
    itemModel = null;
    showLoading();
    try {
      final price = searchControllerHome.resolveSearchPriceParam();
      var result = await searchControllerHome.searchItems(
        '',
        searchControllerHome.selectedtypesvalues.toString(),
        price,
        "${activeModuleId.value == 1 ? searchControllerHome.selectedBeds : '0'}",
        "${activeModuleId.value == 1 ? searchControllerHome.selectedBathroom : '0'}",
        searchControllerHome.featuresvalues.toString(),
        "1000",
        generalScopeController.startDateCustomDate.value.toString(),
        generalScopeController.endDateCustomDate.value.toString(),
        activeModuleId.value == 1 ? "0" : "0",
        "$slatsearch",
        "$sLongSearch",
        context,
        "${activeModuleId.value == 2 ? searchControllerHome.maketypeFunction() : activeModuleId.value == 5 ? searchControllerHome.bookablemetadata() : ''}",
      );

      itemModel = ItemModel.fromJson(result);
      var newItems = itemModel!.data!.items ?? [];
      closeLoading();
      if (newItems.isNotEmpty) {
        searchControllerHome.searchFilterList.clear();
        searchControllerHome.searchFilterList.addAll(newItems);
        searchControllerHome.offset = itemModel!.data!.offset!;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ViewOnMapScreen(title: widget.title, list: newItems),
          ),
        );
      } else {
        if (_lastLocationWithResults != null) {
          _animateMapCamera(
            CameraUpdate.newLatLngZoom(
              _lastLocationWithResults!,
              _clampedMapZoom(_kVehicleMapInitialZoom),
            ),
          );
        }
        showErrorToastMessage("Data not found!");
      }
    } catch (error) {
      closeLoading();
      if (_lastLocationWithResults != null) {
        _animateMapCamera(
          CameraUpdate.newLatLngZoom(
            _lastLocationWithResults!,
            _clampedMapZoom(_kVehicleMapInitialZoom),
          ),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) async {
    googleMapController = controller;
    bool isdark = GetStorage().read("getDarkValue") ?? false;
    if (isdark) {
      String style = await DefaultAssetBundle.of(context)
          .loadString('assets/json/map_dark.json');
      googleMapController?.setMapStyle(style);
    }

    // Réapplique les markers dès que le contrôleur est prêt.
    if (markers.isNotEmpty || items.isNotEmpty) {
      await setMarkers();
    }

    if (_pendingCameraInit || !_cameraInitialized) {
      final points = <LatLng>[];
      if (_userLatLng != null) {
        points.add(_userLatLng!);
      }
      for (final item in items) {
        if (_parseItemLatLng(item) != null) {
          points.add(_displayPositionForItem(item));
        }
      }
      // moveCamera sous le loader : pas d'animation visible au dévoilement.
      await _applyCameraToPoints(points, instant: true);
      _cameraInitialized = true;
      _pendingCameraInit = false;
    }

    _finishMapInitialization();
  }

  void _zoomIn() {
    _animateMapCamera(CameraUpdate.zoomIn());
  }

  void _zoomOut() {
    _animateMapCamera(CameraUpdate.zoomOut());
  }

  void _scrollToIndex(int index) {
    // ensure list is valid
    if (items.isEmpty) return;

    // ensure index is safe
    if (index < 0 || index >= items.length) return;

    // ensure controller is attached
    if (carouselController.ready &&
        carouselController is CarouselSliderControllerImpl) {
      try {
        carouselController.animateToPage(index);
      } catch (e) {
        debugPrint("Scroll failed: $e");
      }
    } else {
      debugPrint("Carousel controller not ready yet, skipping scroll");
    }
  }

  bool isLoadingMap = false;
  @override
  Widget build(BuildContext context) {
    final brandColor = getColorBasedOnActiveModuleid();
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          if (_mapReadyToBuild)
            GoogleMap(
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              minMaxZoomPreference: _kVehicleMapZoomPreference,
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: mylatlng,
                zoom: _kVehicleMapInitialZoom,
              ),
              markers: markers,
              circles: circles,
              onCameraMove: (CameraPosition position) {
                if (_isClampingZoom) return;
                _userMovingMap = true;
                // Empêche le pinch-zoom au-delà du plafond (adresse exacte).
                if (position.zoom > _kVehicleMapMaxZoom) {
                  _currentCameraPosition = CameraPosition(
                    target: position.target,
                    zoom: _kVehicleMapMaxZoom,
                    tilt: position.tilt,
                    bearing: position.bearing,
                  );
                  _isClampingZoom = true;
                  googleMapController
                      ?.moveCamera(
                    CameraUpdate.newCameraPosition(_currentCameraPosition!),
                  )
                      .whenComplete(() {
                    _isClampingZoom = false;
                  });
                } else {
                  _currentCameraPosition = position;
                }
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(seconds: 1), () {
                  _userMovingMap = false;
                });
              },
              onCameraIdle: () {
                _enforceMaxZoom();
                if (_debounce?.isActive ?? false) _debounce?.cancel();
                _debounce = Timer(const Duration(seconds: 1), () {
                  if (_currentCameraPosition != null && _userMovingMap) {
                    searchMethodOnMapMoved(
                        _currentCameraPosition!.target.latitude.toString(),
                        _currentCameraPosition!.target.longitude.toString());
                    _userMovingMap = false;
                  }
                });
              },
            ),
          if (!_isMapInitializing)
          Positioned(
              left: 20,
              right: 20,
              top: 70,
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white),
                child: Row(
                  children: [
                    Expanded(
                        child: InkWell(
                      onTap: () {
                        searchControllerHome.hitApiOnMap = true;
                        openSearchWizard(context);
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: grey4)),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 5,
                            ),
                            SizedBox(
                              height: 35,
                              child: Icon(
                                Icons.location_on_outlined,
                                color: grey2,
                              ),
                            ),
                            const SizedBox(
                              width: 6,
                            ),
                            Obx(
                              () => searchControllerHome
                                          .setBoolForCurrentLocation.value ==
                                      true
                                  ? Expanded(
                                      flex: 19,
                                      child: Text(
                                        searchControllerHome
                                            .aroundCurrentLocation,
                                        style: regular3(context).copyWith(
                                            color: grey4,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis),
                                        maxLines: 1,
                                      ),
                                    )
                                  : Expanded(
                                      flex: 19,
                                      child: Text(
                                        generalScopeController
                                                    .homeSearchLocation.value !=
                                                ""
                                            ? generalScopeController
                                                .homeSearchLocation.value
                                            : generalScopeController
                                                    .textEditingControllerCity
                                                    .text
                                                    .isEmpty
                                                ? "Where do you go?".tr
                                                : generalScopeController
                                                    .textEditingControllerCity
                                                    .text,
                                        style: regular3(context).copyWith(
                                            color: grey4,
                                            fontSize: 15,
                                            overflow: TextOverflow.ellipsis),
                                        maxLines: 1,
                                      ),
                                    ),
                            ),
                            InkWell(
                              onTap: () {
                                try {
                                  if (searchControllerHome.hitApiOnMap ==
                                      true) {
                                    Get.to(
                                        () => const HomeMain(initialIndex: 0));
                                    generalController.currentIndex.value = 0;
                                  } else {
                                    Navigator.pop(context);
                                  }
                                } catch (e) {}
                                setState(() {});
                              },
                              child: Icon(
                                Icons.close,
                                color: grey3,
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            )
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              )),
          if (!_isMapInitializing && isLoadingMap)
            Positioned(
                  top: 120,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 30,
                        width: 50,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: whiteColor),
                        child: Image.asset(
                          "assets/images/loader.gif",
                          color: grey2,
                          scale: 2,
                        )),
                  )),
          if (!_isMapInitializing)
          Positioned(
            bottom: 50,
            right: 10,
            child: Column(
              children: [
                // dont remove this code
                FloatingActionButton(
                  onPressed: _moveToCurrentLocation,
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.location_on, color: Colors.black),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomIn,
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.zoom_in, color: Colors.black),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  onPressed: _zoomOut,
                  mini: true,
                  backgroundColor: Colors.white,
                  child: const Icon(Icons.zoom_out, color: Colors.black),
                ),
              ],
            ),
          ),
          if (!_isMapInitializing)
          Visibility(
            visible: visibleList && items.isNotEmpty,
            child: Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                        onTap: () {
                          setState(() {
                            visibleList = false;
                          });
                        },
                        child: const Icon(
                          Icons.cancel_outlined,
                          size: 30,
                        )),
                  ),
                  CarouselSlider.builder(
                    carouselController: carouselController,
                    itemCount: items.length,
                    itemBuilder: (context, index, realIndex) {
                      ItemInfo? itemInfoData;
                      String? jsonString = items[index].itemInfo;
                      if (jsonString != null) {
                        itemInfoData =
                            ItemInfo.fromJson(json.decode(jsonString));
                      } else {}
                      return Padding(
                        padding: const EdgeInsets.all(10),
                        child: InkWell(
                          onTap: () {
                            final approx = MapPrivacyHelper
                                .approximateAddressLabel(items[index])
                                .tr;
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VehicleDetailSScreen(
                                          id: items.elementAt(index).id,
                                          itemInfo: itemInfoData,
                                          rating: items[index].itemRating,
                                          title: items[index].name,
                                          address: approx,
                                          latitute: items[index].latitude,
                                          longtitute: items[index].longitude,
                                          frontImage: items[index].image,
                                          itemType: items[index].itemType,
                                          price: items[index].price,
                                          isWishList:
                                              items[index].isInWishlist ??
                                                  false,
                                          handleback: true,
                                        )));
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: notifires.getboxcolor,
                                borderRadius: BorderRadius.circular(12)),
                            child: Row(
                              children: [
                                SizedBox(
                                  height: 100,
                                  width: 170,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: myNetworkImageWithShimmer(
                                        items[index].image),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        items[index].name.toString(),
                                        style: heading3Grey1(context),
                                        maxLines: 1,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color:
                                                getColorBasedOnActiveModuleid(),
                                            size: 18,
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          Expanded(
                                              child: Text(
                                            MapPrivacyHelper
                                                    .approximateAddressLabel(
                                                        items[index])
                                                .tr,
                                            style: regular(context).copyWith(
                                                overflow:
                                                    TextOverflow.ellipsis),
                                            maxLines: 1,
                                          )),
                                        ],
                                      ),
                                      const Spacer(),
                                      Expanded(
                                        child: Text(
                                          "$currency ${items[index].price}${" /day".tr}",
                                          style: heading2Grey1(context).copyWith(
                                              color:
                                                  getColorBasedOnActiveModuleid(),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    options: CarouselOptions(
                      initialPage: currentIndex,
                      height: 160,
                      viewportFraction: 1,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        // _userMovingMap = true;
                        currentIndex = index;
                        setState(() {
                          mapReload(index);
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isMapInitializing)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 42,
                        height: 42,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(brandColor),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          "Retrieving your location...".tr,
                          textAlign: TextAlign.center,
                          style: regular3(context).copyWith(
                            color: grey2,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
