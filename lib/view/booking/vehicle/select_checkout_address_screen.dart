import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/add_address_controller.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/vehicle_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/city_name_helper.dart';
import 'package:carvy/helper/delivery_fee_helper.dart';
import 'package:carvy/model/address_history_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/myaccount/addaddress/user_address.dart';

class SelectCheckoutAddressScreen extends StatefulWidget {
  const SelectCheckoutAddressScreen({super.key});

  @override
  State<SelectCheckoutAddressScreen> createState() =>
      _SelectCheckoutAddressScreenState();
}

class _SelectCheckoutAddressScreenState
    extends State<SelectCheckoutAddressScreen> {
  late final AddAddressController _addr;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<AddAddressController>()) {
      Get.put(AddAddressController());
    }
    _addr = Get.find<AddAddressController>();
    _addr.fetchAddressHistory();
  }

  String _cityFromSavedAddress(AddressHistoryModel item) {
    final fromField = DeliveryFeeHelper.sanitizeCity(item.city);
    if (fromField.isNotEmpty) return fromField;
    return CityNameHelper.extractKnownCityToken(item.address) ??
        CityNameHelper.extractKnownCityToken(item.label) ??
        '';
  }

  List<dynamic> _locationCatalogue() {
    try {
      return Get.find<VehicleController>().locationsList.toList();
    } catch (_) {
      return const [];
    }
  }

  bool _isAddressServed(AddressHistoryModel item) {
    if (!Get.isRegistered<BookingController>()) return false;
    final booking = Get.find<BookingController>();
    final zones = booking.deliveryZones.toList();
    if (zones.isEmpty) return false;
    final city = _cityFromSavedAddress(item);
    if (city.isEmpty) return false;
    return DeliveryFeeHelper.matchZone(
          zones,
          city,
          catalogue: _locationCatalogue(),
        ) !=
        null;
  }

  Future<void> _selectAddress(AddressHistoryModel item) async {
    if (!_isAddressServed(item)) {
      showErrorToastMessage('address_not_served_for_this_vehicle'.tr);
      return;
    }
    final applied = _addr.applyRecentAddress(item);
    if (applied == null) return;
    if (Get.isRegistered<BookingController>()) {
      Get.find<BookingController>().selectProfileHomeDelivery();
    }
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _openAddAddressForm() async {
    _addr.preventDate.value = true;
    _addr.addressSavePopCount = 1;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const UserAddress(),
      ),
    );
    if (!mounted) return;
    await _addr.fetchAddressHistory();
  }

  bool _isActive(AddressHistoryModel item) {
    final current = _addr.checkoutAddressLine.trim().toLowerCase();
    final candidate = item.address.trim().toLowerCase();
    if (current.isEmpty || candidate.isEmpty) return false;
    return current == candidate ||
        current.contains(candidate) ||
        candidate.contains(current);
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    final accent = getColorBasedOnActiveModuleid();

    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
        backgroundColor: notifires.getbgcolor,
        title: 'select_my_address'.tr,
        titleColor: notifires.getwhiteblackcolor,
        onBackButtonPressed: () => Get.back(),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Material(
              color: accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  _openAddAddressForm();
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: accent.withOpacity(0.16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(Icons.add_location_alt_outlined,
                            color: accent, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'add_new_address'.tr,
                          style: regular2(context).copyWith(
                            fontWeight: FontWeight.w700,
                            color: accent,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: accent.withOpacity(0.8)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              final loading = _addr.isAddressHistoryLoading.value;
              final items = _addr.recentAddresses.toList();

              if (loading && items.isEmpty) {
                return const Center(
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  ),
                );
              }

              if (items.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'No recent addresses yet'.tr,
                      textAlign: TextAlign.center,
                      style: regular2(context).copyWith(
                        color: notifires.getGrey3Whitecolor,
                      ),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return _AddressChoiceTile(
                    item: item,
                    selected: _isActive(item),
                    onTap: () {
                      _selectAddress(item);
                    },
                    shorten: _addr.shortenAddress,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AddressChoiceTile extends StatelessWidget {
  const _AddressChoiceTile({
    required this.item,
    required this.selected,
    required this.onTap,
    required this.shorten,
  });

  final AddressHistoryModel item;
  final bool selected;
  final VoidCallback onTap;
  final String Function(String, int) shorten;

  @override
  Widget build(BuildContext context) {
    final accent = getColorBasedOnActiveModuleid();
    final label = item.label.trim();
    final address = item.address.trim();
    final displayLabel =
        label.isNotEmpty ? label : shorten(address, 28);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Material(
      color: notifires.getBoxColor,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: accent.withOpacity(0.12),
        highlightColor: accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? accent : Colors.grey.withOpacity(0.28),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  selected ? Icons.location_on : Icons.location_on_outlined,
                  size: 22,
                  color: selected ? accent : notifires.getGrey3Whitecolor,
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
                      const SizedBox(height: 4),
                      Text(
                        address,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: regular2(context).copyWith(
                          fontSize: 13,
                          height: 1.35,
                          color: notifires.getGrey3Whitecolor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle, color: accent, size: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
