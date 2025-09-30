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
  bool isOfficeSelected = false;
  bool isHomeSelected = false;
  bool isOtherSelected = false;
  AddAddressController addAddressController = Get.find();
  final _formKey = GlobalKey<FormState>();
  LatLng? _parseLatLng(String? latitude, String? longitude) {
    try {
      if (latitude != null && longitude != null) {
        return LatLng(double.parse(latitude), double.parse(longitude));
      }
    } catch (e) {}
    return null;
  }

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
    await addAddressController.getPlaceDetailFromLatLng(
        newPosition.latitude, newPosition.longitude);
    String mainAddress = await addAddressController.getMainAddress(
        newPosition.latitude, newPosition.longitude);
    int maxLength = 75;
    String shortAddress = shortenAddress(mainAddress, maxLength);

    addAddressController.fullAddressController.text = shortAddress;
  }

  String shortenAddress(String address, int maxLength) {
    if (address.length <= maxLength) {
      return address;
    }
    return '${address.substring(0, maxLength)}...';
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _zoomIn() {
    mapController.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  String selectedOption = "";
  void _zoomOut() {
    mapController.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  bool shouldUpdateMapLocation = false;
  @override
  void initState() {
    super.initState();

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (widget.dataClear == true) {
    //     addAddressController.clearAddressFunction();
    //   }
    // });
  }

  final FocusNode _focusNode = FocusNode();
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
          child: CustomsButtons(
              text: "Save Address".tr,
              backgroundColor: getColorBasedOnActiveModuleid(),
              onPressed: () {
                addAddressController.updateAddress(context);
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
                    () => addAddressController.doorSteplatitude.value == "" &&
                            addAddressController.doorSteplongitude.value == ""
                        ? const SizedBox()
                        : Stack(
                            children: [
                              SizedBox(
                                height: 270,
                                child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: GoogleMap(
                                        circles: {
                                          Circle(
                                            circleId:
                                                const CircleId("radius_circle"),
                                            center: LatLng(
                                                double.parse(
                                                    addAddressController
                                                        .doorSteplatitude
                                                        .value),
                                                double.parse(
                                                    addAddressController
                                                        .doorSteplongitude
                                                        .value)),
                                            radius:
                                                500, // Set the radius in meters
                                            fillColor:
                                                Colors.blue.withOpacity(0.2),
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
                                        markers: addAddressController.markers,
                                        onMapCreated: _onMapCreated,
                                        initialCameraPosition: CameraPosition(
                                          target: _parseLatLng(
                                                addAddressController
                                                    .doorSteplatitude.value,
                                                addAddressController
                                                    .doorSteplongitude.value,
                                              ) ??
                                              const LatLng(0, 0),
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
                        child: Text(
                          maxLines: 4,
                          addAddressController.fullAddressController.text,
                          style: regular3(context)
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
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
                    'House No. & Floor',
                    style: regular3(context),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldAdvance(
                          hintTxt: "",
                          textEditingControllerCommon:
                              addAddressController.houseFloorNumberController,
                          inputType: TextInputType.streetAddress,
                          inputAlignment: TextAlign.start),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'Building & Block No. (Optional)',
                    style: regular3(context),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldAdvance(
                          hintTxt: "",
                          textEditingControllerCommon: addAddressController
                              .buildingBlockNumberController,
                          inputType: TextInputType.streetAddress,
                          inputAlignment: TextAlign.start),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    'LandMark & Area Name. (Optional)',
                    style: regular3(context),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: TextFieldAdvance(
                          hintTxt: "",
                          textEditingControllerCommon:
                              addAddressController.landmarkController,
                          inputType: TextInputType.streetAddress,
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
