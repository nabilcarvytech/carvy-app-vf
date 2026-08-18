import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/add_address_controller.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/myaccount/addaddress/user_address.dart';
import 'package:carvy/work_space.dart'; //

class PickAddressWitjhMap extends StatefulWidget {
  dynamic isback;
  PickAddressWitjhMap({super.key, this.isback});

  @override
  State<PickAddressWitjhMap> createState() => _PickAddressWitjhMapState();
}

class _PickAddressWitjhMapState extends State<PickAddressWitjhMap> {
  AddAddressController addAddressController = Get.find();
  late GoogleMapController mapController;
  BitmapDescriptor? customMarkerIcon;
  LatLng? _pendingCameraTarget;
  bool _mapControllerReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initializeMapFlow());
    _setCustomMarkerIcon();
  }

  Future<void> _initializeMapFlow() async {
    await addAddressController.getDoorStepAddressp(true);
    await _setCustomMarkerIcon();
    if (!mounted) return;

    final hasSavedCoords = addAddressController.hasValidDoorstepCoordinates;
    final hasSavedAddress = addAddressController.addressText.value
            .trim()
            .isNotEmpty ||
        addAddressController.fullAddressController.text.trim().isNotEmpty;

    if (hasSavedCoords && hasSavedAddress) {
      final lat = double.parse(addAddressController.doorSteplatitude.value);
      final lng = double.parse(addAddressController.doorSteplongitude.value);
      final target = LatLng(lat, lng);
      _updateMarkerPosition(target);
      _pendingCameraTarget = target;
      _applyPendingCamera();
      return;
    }

    if (hasSavedCoords && !hasSavedAddress) {
      final lat = double.parse(addAddressController.doorSteplatitude.value);
      final lng = double.parse(addAddressController.doorSteplongitude.value);
      await addAddressController.resolveAddressFromLatLng(lat, lng);
      if (!mounted) return;
      if (addAddressController.fullAddressController.text.trim().isNotEmpty) {
        final target = LatLng(lat, lng);
        _updateMarkerPosition(target);
        _pendingCameraTarget = target;
        _applyPendingCamera();
        setState(() {});
        return;
      }
    }

    await _moveToCurrentLocation();
    if (!mounted) return;
    if (!addAddressController.hasValidDoorstepCoordinates) {
      final fallback = LatLng(
        AddAddressController.fallbackMapLat,
        AddAddressController.fallbackMapLng,
      );
      _updateMarkerPosition(fallback);
      _pendingCameraTarget = fallback;
      _applyPendingCamera();
    }
    if (mounted) setState(() {});
  }

  void _applyPendingCamera() {
    final t = _pendingCameraTarget;
    if (t == null || !_mapControllerReady) return;
    mapController.animateCamera(CameraUpdate.newLatLng(t));
    _pendingCameraTarget = null;
  }

  Future<void> _setCustomMarkerIcon() async {
    try {
      customMarkerIcon = BitmapDescriptor.defaultMarker;
      setState(() {});
    } catch (e) {
      customMarkerIcon = BitmapDescriptor.defaultMarker;
      setState(() {});
    }
  }

  Timer? _debounceTimer;
  LatLng? _lastCameraTarget;

  void _onMapTapped(LatLng position) async {
    if (customMarkerIcon == null) {
      await _setCustomMarkerIcon();
    }
    addAddressController.doorSteplatitude.value = position.latitude.toString();
    addAddressController.doorSteplongitude.value =
        position.longitude.toString();
    _updateMarkerPosition(position);
    await updateMapLocation(position);
  }

  void updatePosition(CameraPosition position) {
    _lastCameraTarget = position.target;
  }

  void _onCameraIdle() {
    final target = _lastCameraTarget;
    if (target == null) return;
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }
    // Debounce 500ms pour éviter les appels API à chaque micro-ajustement.
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      addAddressController.doorSteplatitude.value = target.latitude.toString();
      addAddressController.doorSteplongitude.value = target.longitude.toString();
      _updateMarkerPosition(target);
      updateMapLocation(target);
    });
  }

  void _updateMarkerPosition(LatLng position) {
    Marker? existingMarker = addAddressController.markers.firstWhereOrNull(
      (marker) => marker.markerId.value == 'marker_2',
    );

    if (existingMarker == null) {
      addAddressController.markers.add(
        Marker(
          markerId: const MarkerId('marker_2'),
          position: position,
          draggable: true,
          icon: customMarkerIcon ?? BitmapDescriptor.defaultMarker,
          onDragEnd: (LatLng newPosition) {
            addAddressController.doorSteplatitude.value =
                newPosition.latitude.toString();
            addAddressController.doorSteplongitude.value =
                newPosition.longitude.toString();
            updateMapLocation(newPosition);
          },
        ),
      );
    } else {
      setState(() {
        addAddressController.markers.remove(existingMarker);
        addAddressController.markers.add(
          existingMarker.copyWith(positionParam: position),
        );
      });
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> updateMapLocation(LatLng newPosition) async {
    addAddressController.selectedLat = newPosition.latitude.toString();
    addAddressController.selectedLong = newPosition.longitude.toString();
    await addAddressController.resolveAddressFromLatLng(
      newPosition.latitude,
      newPosition.longitude,
    );
    if (mounted) setState(() {});
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _mapControllerReady = true;
    _applyPendingCamera();
  }

  void _zoomIn() {
    mapController.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  void _zoomOut() {
    mapController.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  /// GPS → reverse geocoding → centrage carte + marqueur.
  Future<void> _moveToCurrentLocation() async {
    final coords = await addAddressController.fetchCurrentLocation(context);
    if (!mounted || coords == null) return;

    final target = LatLng(coords.lat, coords.lng);
    _updateMarkerPosition(target);
    if (_mapControllerReady) {
      await mapController.animateCamera(
        CameraUpdate.newLatLngZoom(target, 16),
      );
    } else {
      _pendingCameraTarget = target;
    }
    setState(() {});
  }

  Future<void> _popToPreviousScreen() async {
    if (addAddressController.canConfirmDoorstepAddress) {
      await addAddressController.recordCurrentAddressInHistory();
    }
    if (!mounted) return;
    if (Navigator.of(context).canPop()) {
      Get.back();
      return;
    }
    // Carte ouverte comme route racine (ex. après Get.offAll)
    generalController.currentIndex.value = 4;
    Get.offAll(() => const HomeMain(initialIndex: 4));
  }

  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
        backgroundColor: notifires.getbgcolor,
        title: 'Map'.tr,
        titleColor: notifires.getwhiteblackcolor,
        onBackButtonPressed: _popToPreviousScreen,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          color: notifires.getbgcolor,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              height: 140,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Obx(() {
                            if (addAddressController.isAddressLoading.value) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      "Retrieving your location...".tr,
                                      maxLines: 3,
                                      style: boldstyle(context).copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }
                            final addr = addAddressController
                                    .addressText.value.isNotEmpty
                                ? addAddressController.addressText.value
                                : addAddressController
                                    .fullAddressController.text;
                            if (addr.isEmpty) {
                              return Text(
                                "Select a location on the map or use the search field."
                                    .tr,
                                maxLines: 3,
                                style: boldstyle(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                ),
                              );
                            }
                            return Text(
                              addr,
                              maxLines: 2,
                              style: boldstyle(context)
                                  .copyWith(fontWeight: FontWeight.bold),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 50,
                      width: Get.width,
                      child: Obx(() {
                        final ok =
                            addAddressController.canConfirmDoorstepAddress;
                        return ElevatedButton(
                          onPressed: ok
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (builder) =>
                                          const UserAddress(),
                                    ),
                                  );
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.only(
                                left: 5, right: 5, top: 10, bottom: 10),
                            backgroundColor: getColorBasedOnActiveModuleid(),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            disabledBackgroundColor: Colors.grey.shade400,
                          ),
                          child: Text(
                            "Pick Address".tr,
                            style: heading2(context).copyWith(
                              color: ok ? whiteColor : Colors.white70,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(
              () => Stack(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12)),
                            child: GoogleMap(
                                circles: addAddressController
                                        .hasValidDoorstepCoordinates
                                    ? {
                                        Circle(
                                          circleId:
                                              const CircleId("radius_circle"),
                                          center: LatLng(
                                            double.parse(addAddressController
                                                .doorSteplatitude.value),
                                            double.parse(addAddressController
                                                .doorSteplongitude.value),
                                          ),
                                          radius: 500,
                                          fillColor:
                                              Colors.blue.withOpacity(0.2),
                                          strokeColor: Colors.blue,
                                          strokeWidth: 2,
                                        ),
                                      }
                                    : {},
                                scrollGesturesEnabled: true,
                                rotateGesturesEnabled: true,
                                zoomGesturesEnabled: true,
                                compassEnabled: true,
                                myLocationEnabled: false,
                                myLocationButtonEnabled: false,
                                zoomControlsEnabled: false,
                                onMapCreated: _onMapCreated,
                                markers: addAddressController.markers,
                                onTap: _onMapTapped,
                                onCameraMove: updatePosition,
                                onCameraIdle: _onCameraIdle,
                                initialCameraPosition: CameraPosition(
                                    target:
                                        addAddressController.doorstepMapCenter,
                                    zoom: 14))),
                        Positioned(
                          top: 150,
                          right: 16,
                          child: Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () {
                                _zoomOut();
                              },
                              child: Container(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "-",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 110,
                          right: 16,
                          child: Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: () {
                                _zoomIn();
                              },
                              child: Container(
                                padding: const EdgeInsets.only(
                                    left: 6, right: 6, top: 1, bottom: 1),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.add),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                            left: 0,
                            right: 0,
                            child: Container(
                              color: whiteColor,
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Container(
                                  height: 60,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 1,
                                          color:
                                              getColorBasedOnActiveModuleid()),
                                      borderRadius: BorderRadius.circular(2)),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: SizedBox(
                                          child:
                                              GooglePlaceAutoCompleteTextField(
                                            textStyle: regular2(context)
                                                .copyWith(color: blackColor),
                                            containerHorizontalPadding: 5,
                                            containerVerticalPadding: 9,
                                            focusNode: _focusNode,
                                            boxDecoration: BoxDecoration(
                                              color: whiteColor,
                                            ),
                                            textEditingController:
                                                addAddressController
                                                    .fullAddressController,
                                            googleAPIKey: Config.googleKey,
                                            countries: null,
                                            inputDecoration: InputDecoration(
                                              prefixIcon: Icon(
                                                Icons.location_on,
                                                color:
                                                    getColorBasedOnActiveModuleid(),
                                              ),
                                              filled: true,
                                              fillColor: whiteColor,
                                              hintText: 'Street Address'.tr,
                                              border: InputBorder.none,
                                            ),
                                            isLatLngRequired: true,
                                            getPlaceDetailWithLatLng:
                                                (Prediction prediction) async {
                                              if (prediction.lat == null ||
                                                  prediction.lng == null) {
                                                return;
                                              }
                                              final lat =
                                                  double.parse(prediction.lat!);
                                              final lng =
                                                  double.parse(prediction.lng!);
                                              _focusNode.unfocus();
                                              if (customMarkerIcon == null) {
                                                await _setCustomMarkerIcon();
                                              }
                                              if (_mapControllerReady) {
                                                mapController.animateCamera(
                                                  CameraUpdate.newLatLng(
                                                    LatLng(lat, lng),
                                                  ),
                                                );
                                              } else {
                                                _pendingCameraTarget =
                                                    LatLng(lat, lng);
                                              }
                                              addAddressController
                                                      .doorSteplatitude
                                                      .value =
                                                  prediction.lat!;
                                              addAddressController
                                                      .doorSteplongitude
                                                      .value =
                                                  prediction.lng!;
                                              _updateMarkerPosition(
                                                  LatLng(lat, lng));
                                              await addAddressController
                                                  .resolveAddressFromLatLng(
                                                      lat, lng);
                                              if (mounted) setState(() {});
                                            },
                                            itemClick: (Prediction prediction) {
                                              addAddressController
                                                      .fullAddressController
                                                      .text =
                                                  prediction.description!;
                                              addAddressController
                                                      .fullAddressController
                                                      .selection =
                                                  TextSelection.fromPosition(
                                                      TextPosition(
                                                          offset: prediction
                                                              .description!
                                                              .length));
                                              _focusNode.unfocus();
                                            },
                                            seperatedBuilder: Divider(
                                              color: blackColor,
                                              thickness: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                          height: 65,
                                          decoration:
                                              BoxDecoration(color: whiteColor),
                                          padding: const EdgeInsets.all(10),
                                          child: Icon(
                                            Icons.search,
                                            color:
                                                getColorBasedOnActiveModuleid(),
                                            size: 35,
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            )),
                        Positioned(
                            top: 200,
                            right: 16,
                            child: Material(
                                elevation: 2,
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                    onTap: _moveToCurrentLocation,
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Tooltip(
                                          message: 'Current location'.tr,
                                          child: const Icon(
                                            Icons.my_location,
                                          ),
                                        ),
                                    ),
                                ),
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
