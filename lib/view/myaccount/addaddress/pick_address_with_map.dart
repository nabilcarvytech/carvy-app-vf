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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      addAddressController.getDoorStepAddressp(true);
      final initialPosition = LatLng(
        double.parse(addAddressController.doorSteplatitude.value),
        double.parse(addAddressController.doorSteplongitude.value),
      );
      _onMapTapped(initialPosition);
    });
    _setCustomMarkerIcon();
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

  void _onMapTapped(LatLng position) async {
    if (customMarkerIcon == null) {
      await _setCustomMarkerIcon();
    }
    _updateMarkerPosition(position);
    updateMapLocation(position);
    addAddressController.doorSteplatitude.value = position.latitude.toString();
    addAddressController.doorSteplongitude.value =
        position.longitude.toString();
  }

  void updatePosition(CameraPosition position) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      final newLatLng =
          LatLng(position.target.latitude, position.target.longitude);
      _updateMarkerPosition(newLatLng);
      updateMapLocation(newLatLng);
      addAddressController.doorSteplatitude.value =
          position.target.latitude.toString();
      addAddressController.doorSteplongitude.value =
          position.target.longitude.toString();
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
    await addAddressController.getPlaceDetailFromLatLng(
        newPosition.latitude, newPosition.longitude);
    String mainAddress = await addAddressController.getMainAddress(
        newPosition.latitude, newPosition.longitude);
    int maxLength = 75;
    String shortAddress = shortenAddress(mainAddress, maxLength);
    addAddressController.fullAddressController.text = shortAddress;
    setState(() {});
  }

  String shortenAddress(String address, int maxLength) {
    return address.length <= maxLength
        ? address
        : '${address.substring(0, maxLength)}...';
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
        onBackButtonPressed: () {
          if (widget.isback == "back") {
            Get.back();
          } else {
            generalController.currentIndex.value = 0;
            Get.to(const HomeMain(initialIndex: 0));
          }
        },
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
                          child: Text(
                            maxLines: 2,
                            addAddressController.fullAddressController.text,
                            style: boldstyle(context)
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
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
                      child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => const UserAddress()));
                          },
                          style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.only(
                                  left: 5, right: 5, top: 10, bottom: 10),
                              backgroundColor: getColorBasedOnActiveModuleid(),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                          child: Text(
                            "Pick Address".tr,
                            style:
                                heading2(context).copyWith(color: whiteColor),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )),
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
              () => addAddressController.doorSteplatitude.value == "" &&
                      addAddressController.doorSteplongitude.value == ""
                  ? const SizedBox()
                  : Stack(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12)),
                            child: GoogleMap(
                                circles: {
                                  Circle(
                                    circleId: const CircleId("radius_circle"),
                                    center: LatLng(
                                        double.parse(addAddressController
                                            .doorSteplatitude.value),
                                        double.parse(addAddressController
                                            .doorSteplongitude.value)),
                                    radius: 500, // Set the radius in meters
                                    fillColor: Colors.blue.withOpacity(0.2),
                                    strokeColor: Colors.blue,
                                    strokeWidth: 2,
                                  ),
                                },
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
                                initialCameraPosition: CameraPosition(
                                    target: LatLng(
                                        double.parse(addAddressController
                                            .doorSteplatitude.value),
                                        double.parse(addAddressController
                                            .doorSteplongitude.value)),
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
                                                (Prediction prediction) {
                                              addAddressController
                                                  .clearAddressFields();

                                              setState(() {
                                                mapController.animateCamera(
                                                  CameraUpdate.newLatLng(LatLng(
                                                      double.parse(
                                                          prediction.lat!),
                                                      double.parse(
                                                          prediction.lng!))),
                                                );
                                              });
                                              _focusNode.unfocus();

                                              addAddressController
                                                  .getPlaceDetailFromId(
                                                prediction.placeId,
                                              );
                                              // addAddressController
                                              //     .updateMapLocationForSeachWithAutoSuggestation();
                                              setState(() {});
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
                                    onTap: () {
                                      addAddressController
                                          .getUserLocationForBetterSearch(
                                              context)
                                          .then((v) {
                                        setState(() {});

                                        mapController.animateCamera(
                                          CameraUpdate.newLatLng(
                                            LatLng(
                                              double.parse(addAddressController
                                                  .doorSteplatitude.value),
                                              double.parse(addAddressController
                                                  .doorSteplongitude.value),
                                            ),
                                          ),
                                        );
                                      }).catchError((e) {
                                        print("Error: $e");
                                      });
                                    },
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 4),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child:
                                            const Icon(Icons.location_on))))),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
