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
import 'package:carvy/model/address_history_model.dart';
import 'package:carvy/view/myaccount/addaddress/pick_address_with_map.dart';

class UserAddress extends StatefulWidget {
  const UserAddress({super.key});

  @override
  State<UserAddress> createState() => _UserAddressState();
}

class _UserAddressState extends State<UserAddress> {
  AddAddressController addAddressController = Get.find();

  late GoogleMapController mapController;
  late FocusNode _addressSearchFocusNode;
  String _addressSearchQuery = '';
  bool _showAddressSuggestions = false;

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
    _addressSearchFocusNode.dispose();
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
    _addressSearchFocusNode = FocusNode();
    _addressSearchFocusNode.addListener(_onAddressSearchFocusChanged);
    addAddressController.ensureSuggestedLabelIfEmpty();
    addAddressController.fetchAddressHistory();
  }

  void _onAddressSearchFocusChanged() {
    setState(() {
      _showAddressSuggestions = _addressSearchFocusNode.hasFocus;
      if (!_addressSearchFocusNode.hasFocus) {
        _addressSearchQuery = '';
      }
    });
  }

  List<AddressHistoryModel> _filteredRecentAddresses() {
    final query = _addressSearchQuery.trim().toLowerCase();
    final recents = addAddressController.recentAddresses;
    if (query.isEmpty) return recents.toList();
    return recents.where((item) {
      final label = item.label.toLowerCase();
      final address = item.address.toLowerCase();
      return label.contains(query) || address.contains(query);
    }).toList();
  }

  Future<void> _applyRecentAddress(AddressHistoryModel item) async {
    FocusScope.of(context).unfocus();
    final target = addAddressController.applyRecentAddress(item);
    if (target == null) return;
    try {
      await mapController.animateCamera(
        CameraUpdate.newLatLngZoom(target, 16),
      );
    } catch (e) {
      debugPrint('animateCamera recent address: $e');
    }
    if (mounted) setState(() {});
  }

  Future<void> _openMapAddressPicker() async {
    FocusScope.of(context).unfocus();
    await Get.to(() => PickAddressWitjhMap());
    if (!mounted) return;
    await addAddressController.recordCurrentAddressInHistory();
    setState(() {});
  }

  Widget _buildMapSearchOption() {
    final accent = getColorBasedOnActiveModuleid();
    return Material(
      color: notifires.getBoxColor,
      child: InkWell(
        onTap: _openMapAddressPicker,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.map_outlined, color: accent, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search new address on map'.tr,
                  style: regular2(context).copyWith(
                    fontWeight: FontWeight.w600,
                    color: accent,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: accent.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAddressTile(AddressHistoryModel item) {
    final label = item.label.trim();
    final address = item.address.trim();
    final displayLabel = label.isNotEmpty
        ? label
        : addAddressController.shortenAddress(address, 28);

    return Material(
      color: notifires.getBoxColor,
      child: InkWell(
        onTap: () => _applyRecentAddress(item),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.location_on_outlined,
                  size: 22,
                  color: notifires.getGrey3Whitecolor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: regular2(context).copyWith(
                        fontWeight: FontWeight.w700,
                        color: notifires.getwhiteblackcolor,
                      ),
                    ),
                    if (address.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: regular2(context).copyWith(
                          fontSize: 13,
                          height: 1.3,
                          color: notifires.getGrey3Whitecolor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAddressSuggestionsPanel() {
    return Obx(() {
      final isLoading = addAddressController.isAddressHistoryLoading.value;
      final filtered = _filteredRecentAddresses();

      return AnimatedSize(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        alignment: Alignment.topCenter,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          decoration: BoxDecoration(
            color: notifires.getBoxColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: greyColor2.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildMapSearchOption(),
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                  child: Text(
                    'No recent addresses yet'.tr,
                    style: regular2(context).copyWith(color: Colors.grey),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 4, 14, 8),
                  child: Text(
                    'Your saved addresses'.tr,
                    style: regular2(context).copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: notifires.getGrey3Whitecolor,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: greyColor2.withOpacity(0.5),
                    indent: 14,
                    endIndent: 14,
                  ),
                  itemBuilder: (context, index) {
                    return _buildRecentAddressTile(filtered[index]);
                  },
                ),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAddressSearchField() {
    final accent = getColorBasedOnActiveModuleid();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Address'.tr,
          style: regular3(context).copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Obx(() {
          final isResolving = addAddressController.isAddressLoading.value;
          return TextField(
            controller: addAddressController.fullAddressController,
            focusNode: _addressSearchFocusNode,
            textInputAction: TextInputAction.search,
            maxLines: 2,
            minLines: 1,
            onChanged: (value) {
              setState(() => _addressSearchQuery = value);
            },
            style: regular2(context).copyWith(
              fontWeight: FontWeight.w500,
              color: notifires.getwhiteblackcolor,
            ),
            decoration: InputDecoration(
              hintText: 'Search or select an address'.tr,
              hintStyle: regular2(context).copyWith(
                color: notifires.getGrey3Whitecolor,
                fontWeight: FontWeight.w400,
              ),
              filled: true,
              fillColor: notifires.getBoxColor,
              prefixIcon: Icon(Icons.search, color: accent),
              suffixIcon: isResolving
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: accent,
                        ),
                      ),
                    )
                  : addAddressController.fullAddressController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.close,
                            size: 20,
                            color: notifires.getGrey3Whitecolor,
                          ),
                          onPressed: () {
                            addAddressController.fullAddressController.clear();
                            addAddressController.addressText.value = '';
                            setState(() => _addressSearchQuery = '');
                          },
                        )
                      : null,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: greyColor2.withOpacity(0.8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: accent, width: 1.5),
              ),
            ),
          );
        }),
        if (_showAddressSuggestions) _buildAddressSuggestionsPanel(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                          height: 220,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                            ),
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
                              markers: addAddressController.markers,
                              onMapCreated: _onMapCreated,
                              initialCameraPosition: CameraPosition(
                                target: addAddressController.doorstepMapCenter,
                                zoom: 14,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 58,
                          right: 16,
                          child: Material(
                            elevation: 2,
                            borderRadius: BorderRadius.circular(8),
                            child: InkWell(
                              onTap: _zoomOut,
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
                              onTap: _zoomIn,
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
                const SizedBox(height: 16),
                _buildAddressSearchField(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    'Address Label'.tr,
                    style: regular3(context).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextFieldAdvance(
                  hintTxt: 'Home, Office, Airport...'.tr,
                  textEditingControllerCommon:
                      addAddressController.addressLabelController,
                  inputType: TextInputType.text,
                  inputAlignment: TextAlign.start,
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
