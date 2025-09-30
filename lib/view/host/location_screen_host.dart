import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/model/location_host_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/work_space.dart';

class LocationScreenHost extends StatefulWidget {
  final VoidCallback? onNextButtonPressed;
  final VoidCallback? onBackButtonPressed;
  final ScreenMode mode;

  const LocationScreenHost(
      {super.key,
      this.onNextButtonPressed,
      required this.mode,
      this.onBackButtonPressed});

  @override
  State<LocationScreenHost> createState() => _LocationScreenHostState();
}

class _LocationScreenHostState extends State<LocationScreenHost> {
  Timer? _debounceTimer;
  bool isselected = true;
  bool isnotselected = false;
  AddItemsHostController addItemsHostController = Get.find();
  final _formKey = GlobalKey<FormState>();

  void _onMapTapped(LatLng position) async {
    addItemsHostController.updateMapLocation(position, widget.mode);
    await addItemsHostController.mapController!.animateCamera(
      CameraUpdate.newLatLng(position),
    );
    String mainAddress = await addItemsHostController.getMainAddress(
        position.latitude, position.longitude);

    if (widget.mode == ScreenMode.edit) {
      addItemsHostController.textEditingControllerEditAddress.text =
          mainAddress;
    } else {
      addItemsHostController.textEditingControllerAddress.text = mainAddress;
    }
  }

  bool _isKeyboardOpened = false;
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    if (widget.mode == ScreenMode.add &&
        latitudeGlobal.isNotEmpty &&
        longitudeGlobal.isNotEmpty) {
      final latLng = LatLng(
        double.tryParse(latitudeGlobal) ?? 0.0,
        double.tryParse(longitudeGlobal) ?? 0.0,
      );
      _updateLocationFromGlobal(latLng);
    }
    _initializeMapWithRegion();
  }

  void _initializeMapWithRegion() {
    if (addItemsHostController.selectedCityName!.isNotEmpty) {
      final region = addItemsHostController.listLocation.firstWhere(
        (region) => region.name == addItemsHostController.selectedCityName,
        orElse: () => LocationsHost(
          id: 0,
          cityName: 'Default City',
          countryCode: 'US',
          latitude: '37.7749',
          longitude: '-122.4194',
        ),
      );
      final latLng = LatLng(
        double.tryParse(region.latitude ?? '0.0') ?? 0.0,
        double.tryParse(region.longitude?.toString() ?? '0.0') ?? 0.0,
      );
      if (latLng.latitude != 0.0 || latLng.longitude != 0.0) {
        _updateLocationFromRegion(latLng, region);
      }
    }
  }

  void _updateLocationFromGlobal(LatLng position) async {
    addItemsHostController.selectedLat.value = position.latitude.toString();
    addItemsHostController.selectedLong.value = position.longitude.toString();

    String mainAddress = await addItemsHostController.getMainAddress(
      position.latitude,
      position.longitude,
    );

    if (widget.mode == ScreenMode.edit) {
      addItemsHostController.textEditingControllerEditAddress.text =
          mainAddress;
    } else {
      addItemsHostController.textEditingControllerAddress.text = mainAddress;
    }

    await addItemsHostController.getPlaceDetailFromLatLng(
      position.latitude,
      position.longitude,
      widget.mode,
    );

    await addItemsHostController.mapController!.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  void _updateLocationFromRegion(LatLng position, LocationsHost region) async {
    addItemsHostController.selectedLat.value = position.latitude.toString();
    addItemsHostController.selectedLong.value = position.longitude.toString();

    addItemsHostController.textEditingControllerEditCountry.clear();
    addItemsHostController.textEditingControllerCountry.clear();
    addItemsHostController.textEditingControllerEditState.clear();
    addItemsHostController.textEditingControllerState.clear();
    addItemsHostController.textEditingControllerEditCity.clear();
    addItemsHostController.textEditingControllerCity.clear();
    addItemsHostController.textEditingControllerEditZip.clear();
    addItemsHostController.textEditingControllerZip.clear();

    String mainAddress = await addItemsHostController.getMainAddress(
      position.latitude,
      position.longitude,
    );

    if (widget.mode == ScreenMode.edit) {
      addItemsHostController.textEditingControllerEditAddress.text =
          mainAddress;
    } else {
      addItemsHostController.textEditingControllerAddress.text = mainAddress;
    }

    await addItemsHostController.getPlaceDetailFromLatLng(
      position.latitude,
      position.longitude,
      widget.mode,
    );

    await addItemsHostController.mapController!.animateCamera(
      CameraUpdate.newLatLng(position),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(130),
        child: widget.mode == ScreenMode.add
            ? AppText(txt: "Where's your place located?".tr)
            : const SizedBox(),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification notification) {
          if (notification is ScrollStartNotification ||
              notification is ScrollUpdateNotification) {
            return true;
          }
          return false;
        },
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 15),
                    LabelNames(labelname: 'Region'.tr),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 58,
                      child: CustomDropdownHostLocation(
                        mode: widget.mode,
                        heading: "Choose Region type".tr,
                        selectedEditInitialValue:
                            addItemsHostController.selectedCityName,
                        options: addItemsHostController.listLocation,
                        onSelected: (List<dynamic> list) {
                          addItemsHostController.selectedCityName =
                              list[0].toString(); // City name
                          addItemsHostController.selectedCityShortName =
                              list[1].toString(); // countryCode
                          String latitude = list[2].toString(); // latitude
                          String longitude = list[3].toString(); // longitude
                          addItemsHostController.selectLocation = true;
                          addItemsHostController.forLocation = false;

                          setState(() {
                            addItemsHostController.selectedLat.value = latitude;
                            addItemsHostController.selectedLong.value =
                                longitude;

                            _updateLocationFromRegion(
                              LatLng(
                                double.tryParse(latitude) ?? 0.0,
                                double.tryParse(longitude) ?? 0.0,
                              ),
                              addItemsHostController.listLocation.firstWhere(
                                (region) =>
                                    region.name ==
                                    addItemsHostController.selectedCityName,
                                orElse: () => LocationsHost(
                                  id: 0,
                                  cityName: 'Default City',
                                  countryCode: 'US',
                                  latitude: '37.7749',
                                  longitude: '-122.4194',
                                ),
                              ),
                            );
                          });
                        },
                        checkmarkColor: getColorBasedOnActiveModuleid(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    LabelNames(labelname: 'Full Address'.tr),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 65,
                      child: FormField(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          final addressController =
                              widget.mode == ScreenMode.edit
                                  ? addItemsHostController
                                      .textEditingControllerEditAddress
                                  : addItemsHostController
                                      .textEditingControllerAddress;
                          if (addressController.text.isEmpty) {
                            return 'Please enter the address'.tr;
                          }
                          return null;
                        },
                        builder: (state) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (addItemsHostController.forLocation ==
                                      true) {
                                    showErrorToastMessage(
                                        "Select Region first".tr);
                                    return;
                                  }
                                },
                                child: SizedBox(
                                  height: 63,
                                  child: AbsorbPointer(
                                    absorbing: widget.mode == ScreenMode.edit
                                        ? false
                                        : addItemsHostController.forLocation,
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: GooglePlaceAutoCompleteTextField(
                                        focusNode: _focusNode,
                                        textStyle: regular2(context),
                                        boxDecoration: BoxDecoration(
                                          color: notifires.getBoxColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        textEditingController: widget.mode ==
                                                ScreenMode.edit
                                            ? addItemsHostController
                                                .textEditingControllerEditAddress
                                            : addItemsHostController
                                                .textEditingControllerAddress,
                                        googleAPIKey: Config.googleKey,
                                        countries: [
                                          addItemsHostController
                                              .selectedCityShortName
                                              .toString()
                                        ],
                                        inputDecoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.location_on,
                                            color: notifires.getwhiteblackcolor,
                                          ),
                                          hintText: "Enter Address".tr,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            vertical: 14,
                                            horizontal: 15,
                                          ),
                                          hintStyle: regular2(context),
                                          border: InputBorder.none,
                                        ),
                                        isLatLngRequired: true,
                                        getPlaceDetailWithLatLng:
                                            (Prediction prediction) {
                                          addItemsHostController
                                              .textEditingControllerEditCountry
                                              .clear();
                                          addItemsHostController
                                              .textEditingControllerCountry
                                              .clear();
                                          addItemsHostController
                                              .textEditingControllerEditState
                                              .clear();
                                          addItemsHostController
                                              .textEditingControllerState
                                              .clear();
                                          addItemsHostController
                                              .textEditingControllerEditCity
                                              .clear();
                                          addItemsHostController
                                              .textEditingControllerCity
                                              .clear();
                                          addItemsHostController
                                              .textEditingControllerEditZip
                                              .clear();
                                          addItemsHostController
                                              .textEditingControllerZip
                                              .clear();
                                          setState(() {
                                            addItemsHostController
                                                    .selectedLat.value =
                                                prediction.lat.toString();
                                            addItemsHostController
                                                    .selectedLong.value =
                                                prediction.lng.toString();
                                          });
                                          _focusNode.unfocus();
                                          final addressController = widget
                                                      .mode ==
                                                  ScreenMode.edit
                                              ? addItemsHostController
                                                  .textEditingControllerEditAddress
                                              : addItemsHostController
                                                  .textEditingControllerAddress;
                                          state.didChange(addressController);
                                          addItemsHostController
                                              .getPlaceDetailFromId(
                                                  prediction.placeId,
                                                  widget.mode);
                                          addItemsHostController
                                              .updateMapLocationForSeachWithAutoSuggestation();
                                        },
                                        itemClick: (Prediction prediction) {
                                          if (widget.mode == ScreenMode.edit) {
                                            addItemsHostController
                                                .textEditingControllerEditAddress
                                                .text = prediction.description!;
                                            addItemsHostController
                                                    .textEditingControllerEditAddress
                                                    .selection =
                                                TextSelection.fromPosition(
                                                    TextPosition(
                                                        offset: prediction
                                                            .description!
                                                            .length));
                                          } else {
                                            addItemsHostController
                                                .textEditingControllerAddress
                                                .text = prediction.description!;
                                            addItemsHostController
                                                    .textEditingControllerAddress
                                                    .selection =
                                                TextSelection.fromPosition(
                                                    TextPosition(
                                                        offset: prediction
                                                            .description!
                                                            .length));
                                            addItemsHostController
                                                .getPlaceDetailFromId(
                                                    prediction.placeId,
                                                    widget.mode);
                                            _focusNode.unfocus();
                                          }
                                        },
                                        itemBuilder: (context, index,
                                            Prediction prediction) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: notifires.getboxcolor,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 2),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      color: notifires
                                                          .getgreycolor,
                                                    ),
                                                    const SizedBox(width: 7),
                                                    Expanded(
                                                      child: Text(
                                                        prediction
                                                                .description ??
                                                            "",
                                                        style:
                                                            regular2(context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 2),
                                                Divider(
                                                  color: notifires.getgreycolor,
                                                  thickness: 1,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        seperatedBuilder: const SizedBox(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    LabelNames(
                        labelname: "Tap on map to change the location".tr),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 600,
                      child: AbsorbPointer(
                        absorbing: false,
                        child: Stack(
                          children: [
                            GoogleMap(
                              myLocationEnabled: true,
                              myLocationButtonEnabled: true,
                              mapType: MapType.normal,
                              scrollGesturesEnabled: true,
                              rotateGesturesEnabled: true,
                              zoomControlsEnabled: false,
                              zoomGesturesEnabled: true,
                              compassEnabled: true,
                              mapToolbarEnabled: true,
                              gestureRecognizers: {
                                Factory<OneSequenceGestureRecognizer>(
                                  () => EagerGestureRecognizer(),
                                ),
                              },
                              onMapCreated: (controller) =>
                                  addItemsHostController
                                      .onMapCreated(controller),
                              initialCameraPosition: CameraPosition(
                                target: addItemsHostController.parseLatLng(
                                      addItemsHostController.selectedLat.value,
                                      addItemsHostController.selectedLong.value,
                                    ) ??
                                    const LatLng(0, 0),
                                zoom: 18.0,
                              ),
                              minMaxZoomPreference:
                                  const MinMaxZoomPreference(2.0, 21.0),
                              onCameraMove: (CameraPosition position) {
                                addItemsHostController.selectedLat.value =
                                    position.target.latitude.toString();
                                addItemsHostController.selectedLong.value =
                                    position.target.longitude.toString();

                                if (_debounceTimer?.isActive ?? false) {
                                  _debounceTimer!.cancel();
                                }
                                _debounceTimer =
                                    Timer(const Duration(milliseconds: 500),
                                        () async {
                                  String mainAddress =
                                      await addItemsHostController
                                          .getMainAddress(
                                    position.target.latitude,
                                    position.target.longitude,
                                  );
                                  setState(() {
                                    if (widget.mode == ScreenMode.edit) {
                                      addItemsHostController
                                          .textEditingControllerEditAddress
                                          .text = mainAddress;
                                    } else {
                                      addItemsHostController
                                          .textEditingControllerAddress
                                          .text = mainAddress;
                                    }
                                  });
                                });
                              },
                              onTap: _onMapTapped,
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Column(
                                children: [
                                  Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      onTap: addItemsHostController.zoomIn,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.add, size: 24),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(8),
                                    child: InkWell(
                                      onTap: addItemsHostController.zoomOut,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child:
                                            const Icon(Icons.remove, size: 24),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              bottom: 0,
                              left: 0,
                              child: Transform.translate(
                                offset: const Offset(0, -15),
                                child: Center(
                                  child: Image.asset(
                                    "assets/images/dropmarker.png",
                                    height: 34,
                                    width: 34,
                                    alignment: Alignment.bottomCenter,
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
              ),
            ),
          ]),
        ),
      ),
      bottomNavigationBar: BottomHosts(
        onTap: () {
          FocusScope.of(context).unfocus();
          addItemsHostController.validateLocation(
            context: context,
            formKey: _formKey,
            mode: widget.mode,
            isAddItem: true,
            onNextButtonPressed: widget.onNextButtonPressed,
          );
        },
        txt: truncatetext("Next".tr, 9),
        backButtontxt: "Back".tr,
        backOnPressed: () {
          if (widget.mode == ScreenMode.edit) {
            widget.onBackButtonPressed!();
          } else {
            Get.back();
          }
        },
      ),
    );
  }
}
