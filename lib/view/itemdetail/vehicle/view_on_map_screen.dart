import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/controller/view_map_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/model/items_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/itemdetail/vehicle/vehicle_detail_screen.dart';
import 'package:carvy/work_space.dart';
import '../../../customwidget/custom_active_module_id_widget.dart';
import '../../../customwidget/project_color.dart';
import '../../../model/vehicle_home_model.dart';
import '../../../utils/theme_style.dart';
import '../../host/common_widget_host.dart';
import '../../search/vehicle/vehicle_filter.dart';
import 'package:geolocator/geolocator.dart';
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
  GoogleMapController? googleMapController;
  MapViewController mapViewController = Get.put(MapViewController());
  late final PageController pageController;
  SearchControllerHome searchControllerHome = Get.find();
  LatLng mylatlng = const LatLng(37.4219983, -122.084);
  Set<Marker> markers = {};
  ItemModel? itemModel;
  bool visibleList = false;
  LatLng? _lastApiCallLocation;
  LatLng? _lastLocationWithResults;
  List<dynamic> items = [];
  bool _userMovingMap = false;
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
    items = List.from(widget.list ?? []);
    if (items.isNotEmpty) {
      mylatlng = LatLng(double.parse(items[0].latitude.toString()),
          double.parse(items[0].longitude.toString()));
      _lastApiCallLocation = mylatlng;
      _lastLocationWithResults = mylatlng;
      visibleList = true;
      setMarkers();
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      searchControllerHome.desildetoSendparametersBasedOnPage.value = true;
      searchControllerHome.searchFilterList.clear();
    });
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

  void mapReload(int index) {
    mylatlng = LatLng(double.parse(items[index].latitude.toString()),
        double.parse(items[index].longitude.toString()));
    setState(() {
      googleMapController!.animateCamera(CameraUpdate.newLatLng(mylatlng));
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
      setState(() {
        if (newItems.isNotEmpty) {
          items.clear();
          items.addAll(newItems);
          mylatlng = _lastApiCallLocation!;
          _lastLocationWithResults = mylatlng;
          markers.clear();
          setMarkers();
          visibleList = true;
          searchControllerHome.searchFilterList.clear();
          searchControllerHome.searchFilterList.addAll(newItems);
          searchControllerHome.offset = itemModel!.data!.offset!;
        } else {
          if (_lastLocationWithResults != null) {
            googleMapController?.animateCamera(
                CameraUpdate.newLatLng(_lastLocationWithResults!));
          }
        }
        isLoadingMap = false;
      });
    } catch (error) {
      setState(() {
        isLoadingMap = false;
      });
      if (_lastLocationWithResults != null) {
        googleMapController
            ?.animateCamera(CameraUpdate.newLatLng(_lastLocationWithResults!));
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
  void setMarkers() async {
    Set<Marker> newMarkers = {};
    List<dynamic> localList = List.from(items);

    for (var location in localList) {
      try {
        final latitude = double.tryParse(location.latitude.toString());
        final longitude = double.tryParse(location.longitude.toString());

        if (latitude == null || longitude == null) {
          continue;
        }

        final priceText = location.price.toString().tr;
        final markerIcon =
            await mapViewController.getBytesFromCanvas(priceText, 150, 25);

        newMarkers.add(
          Marker(
            markerId: MarkerId(location.id.toString()),
            position: LatLng(latitude, longitude),
            icon: BitmapDescriptor.bytes(markerIcon),
            onTap: () {
              final index =
                  items.indexWhere((element) => element.id == location.id);

              if (index != -1) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToIndex(index);
                });
              }
            },
          ),
        );
      } catch (e, stack) {
        debugPrint("Error while setting marker: $e\n$stack");
      }
    }

    if (currentLocationMarker != null) {
      newMarkers.add(currentLocationMarker!);
    }

    setState(() {
      markers = newMarkers;
    });
  }

  Set<Circle> circles = {};

  void _moveToCurrentLocation() async {
    showLoading();
    await _requestPermission();
    Position position = await _getCurrentLocation();
    closeLoading();
    final currentLocationMarkerIcon = await mapViewController
        .getBytesFromCanvasImage(50, 50); // Adjust as needed
    Marker newCurrentLocationMarker = Marker(
      markerId: const MarkerId("current_location"),
      position: LatLng(position.latitude, position.longitude),
      icon: BitmapDescriptor.bytes(currentLocationMarkerIcon),
    );

    setState(() {
      currentLocationMarker = newCurrentLocationMarker;
      markers.add(currentLocationMarker!);
      circles.add(
        Circle(
          circleId: const CircleId("current_location_circle"),
          center: LatLng(position.latitude, position.longitude),
          radius: 50,
          fillColor: Colors.blue.withOpacity(0.5),
          strokeColor: Colors.blue,
          strokeWidth: 2,
        ),
      );
    });

    googleMapController?.animateCamera(CameraUpdate.newLatLng(
      LatLng(position.latitude, position.longitude),
    ));
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
          googleMapController?.animateCamera(
              CameraUpdate.newLatLngZoom(_lastLocationWithResults!, 13));
        }
        showErrorToastMessage("Data not found!");
      }
    } catch (error) {
      closeLoading();
      if (_lastLocationWithResults != null) {
        googleMapController?.animateCamera(
            CameraUpdate.newLatLngZoom(_lastLocationWithResults!, 13));
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
  }

  void _zoomIn() {
    googleMapController?.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  void _zoomOut() {
    googleMapController?.animateCamera(
      CameraUpdate.zoomOut(),
    );
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

  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        closeLoading();
        showOpenAppSettingsDialog(context,
            "Please enable location services to show the nearest vehicles around you.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      closeLoading();
      showOpenAppSettingsDialog(context,
          "Please enable location services to show the nearest vehicles around you.");
      return;
    }
  }

  Future<Position> _getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high)
          .timeout(const Duration(seconds: 15));
    } on TimeoutException {
      showErrorToastMessage(
          "Failed to get current location within the timeout. Please search manually.");
      rethrow;
    }
  }

  bool isLoadingMap = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: mylatlng,
              zoom: 13,
            ),
            markers: markers,
            onCameraMove: (CameraPosition position) {
              _userMovingMap = true;
              _currentCameraPosition = position;
              if (_debounce?.isActive ?? false) _debounce?.cancel();
              _debounce = Timer(const Duration(seconds: 1), () {
                _userMovingMap = false;
              });
            },
            onCameraIdle: () {
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
          Positioned(
              left: 20,
              top: 130,
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      searchControllerHome.prepareFilterSheetOpen();
                      showPopUpScreen(
                          context,
                          VehicleFilter(
                              forsearch: true,
                              onMapRefresh: () {
                                searchMethod();
                              }));
                    },
                    child: PhysicalModel(
                      color: Colors.transparent,
                      shadowColor: notifires.getGrey4Whitecolor,
                      elevation: 2.0, // Adjust the elevation value as needed
                      borderRadius: BorderRadius.circular(12.0),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        width: 120,
                        height: 37,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/f.png',
                              color: grey2,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Text(
                              "Filter".tr,
                              style: regular2(context).copyWith(color: grey2),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            const Icon(
                              CupertinoIcons.arrow_up_down,
                              size: 17,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          isLoadingMap == false
              ? const SizedBox()
              : Positioned(
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
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VehicleDetailSScreen(
                                          id: items.elementAt(index).id,
                                          itemInfo: itemInfoData,
                                          rating: items[index].itemRating,
                                          title: items[index].name,
                                          address: items[index].address,
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
                                            items[index].address.toString(),
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
        ],
      ),
    );
  }
}
