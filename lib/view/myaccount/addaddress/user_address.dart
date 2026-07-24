import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carvy/controller/add_address_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/myaccount/addaddress/pick_address_with_map.dart';

class UserAddress extends StatefulWidget {
  const UserAddress({super.key});

  @override
  State<UserAddress> createState() => _UserAddressState();
}

class _UserAddressState extends State<UserAddress> {
  AddAddressController addAddressController = Get.find();

  late GoogleMapController mapController;
  void _onMapTapped(LatLng position) async {
    setState(() {
      addAddressController.markers.clear();
      addAddressController.markers.add(
        Marker(
          markerId: const MarkerId('marker_2'),
          position: position,
          draggable: true,
          icon: BitmapDescriptor.defaultMarker,
          onDragEnd: (LatLng newPosition) {
            setState(() {});
            updateMapLocation(newPosition);
          },
        ),
      );
    });
    updateMapLocation(position);
    addAddressController.doorSteplatitude.value = position.latitude.toString();
    addAddressController.doorSteplongitude.value =
        position.longitude.toString();
  }

  Timer? _debounceTimer;

  void updatePosition(CameraPosition position) {
    setState(() {
      addAddressController.markers.clear();
      addAddressController.markers
          .removeWhere((marker) => marker.markerId.value == 'marker_2');
      addAddressController.markers.add(
        Marker(
          markerId: const MarkerId('marker_2'),
          position: LatLng(position.target.latitude, position.target.longitude),
          draggable: true,
          icon: BitmapDescriptor.defaultMarker,
          onDragEnd: (LatLng newPosition) {
            setState(() {
              updateMapLocation(
                newPosition,
              );
            });
          },
        ),
      );
    });

    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      updateMapLocation(
        LatLng(position.target.latitude, position.target.longitude),
      );
      addAddressController.doorSteplatitude.value =
          position.target.latitude.toString();
      addAddressController.doorSteplongitude.value =
          position.target.longitude.toString();
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> updateMapLocation(LatLng newPosition) async {
    if (!shouldUpdateMapLocation) return;
    setState(() {});
    addAddressController.selectedLat = newPosition.latitude.toString();
    addAddressController.selectedLong = newPosition.longitude.toString();
    await addAddressController.resolveAddressFromLatLng(
      newPosition.latitude,
      newPosition.longitude,
    );
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

  bool shouldUpdateMapLocation = false;
  @override
  void initState() {
    super.initState();
    addAddressController.ensureSuggestedLabelIfEmpty();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        // backgroundColor: white,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Obx(() {
            final ok = addAddressController.canConfirmDoorstepAddress;
            return Opacity(
              opacity: ok ? 1.0 : 0.55,
              child: CustomsButtons(
                text: "Save Address".tr,
                backgroundColor: getColorBasedOnActiveModuleid(),
                onPressed: ok
                    ? () {
                        addAddressController.updateAddress(context);
                      }
                    : () {},
              ),
            );
          }),
        ),
        appBar: CustomAppBars(
          backgroundColor: notifires.getbgcolor,
          title: 'Add Address Details',
          titleColor: notifires.getwhiteblackcolor,
          onBackButtonPressed: () {
            Get.back();
          },
        ),
        backgroundColor: notifires.getbgcolor,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Obx(
                    () => Stack(
                            children: [
                              SizedBox(
                                height: 270,
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: GoogleMap(
                                        circles: addAddressController
                                                .hasValidDoorstepCoordinates
                                            ? {
                                                Circle(
                                                  circleId: const CircleId(
                                                      "radius_circle"),
                                                  center: LatLng(
                                                    double.parse(
                                                        addAddressController
                                                            .doorSteplatitude
                                                            .value),
                                                    double.parse(
                                                        addAddressController
                                                            .doorSteplongitude
                                                            .value),
                                                  ),
                                                  radius: 500,
                                                  fillColor: Colors.blue
                                                      .withOpacity(0.2),
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
                                        markers: addAddressController.markers,
                                        onMapCreated: _onMapCreated,
                                        initialCameraPosition: CameraPosition(
                                          target: addAddressController
                                              .doorstepMapCenter,
                                          zoom: 14,
                                        ))),
                              ),
                              Positioned(
                                top: 58,
                                right: 16,
                                child: Material(
                                  elevation: 2,
                                  borderRadius: BorderRadius.circular(8),
                                  child: InkWell(
                                    onTap: () {
                                      _zoomOut();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          left: 12, right: 12),
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
                                top: 16,
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
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Obx(() {
                          if (addAddressController.isAddressLoading.value) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Retrieving your location...".tr,
                                    maxLines: 4,
                                    style: regular3(context).copyWith(
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
                              : addAddressController.fullAddressController.text;
                          if (addr.isEmpty) {
                            return Text(
                              "Select a location on the map or use the search field."
                                  .tr,
                              maxLines: 4,
                              style: regular3(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            );
                          }
                          return Text(
                            addr,
                            maxLines: 4,
                            style: regular3(context)
                                .copyWith(fontWeight: FontWeight.bold),
                          );
                        }),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(() => PickAddressWitjhMap());
                        },
                        child: Container(
                          height: 30,
                          width: 80,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: themeColor, width: 2),
                          ),
                          child: Text(
                            'Change',
                            style: regular2(context).copyWith(),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(
                  color: greyColor2,
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Current Address'.tr,
                    style: regular3(context),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldAdvance(
                          hintTxt: 'Full address'.tr,
                          textEditingControllerCommon:
                              addAddressController.fullAddressController,
                          inputType: TextInputType.streetAddress,
                          inputAlignment: TextAlign.start),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Address Label'.tr,
                    style: regular3(context),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldAdvance(
                          hintTxt: 'Home, Office, Airport...'.tr,
                          textEditingControllerCommon:
                              addAddressController.addressLabelController,
                          inputType: TextInputType.text,
                          inputAlignment: TextAlign.start),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
