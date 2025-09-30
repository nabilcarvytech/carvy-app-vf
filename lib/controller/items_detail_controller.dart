import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/work_space.dart';
import '../api/config.dart';
import '../helper/http_service.dart';
import '../model/item_details_model.dart';

class ItemDetailsController extends GetxController implements GetxService {
  BookingController bookingController = Get.find();
  bool houseRuleLoading = false;
  bool cancellationLoading = false;
  bool isDescriptionExpanded = false;
  late GoogleMapController mapController;
  ItemDetailsModel? vehicleDetailModel;
  bool vehicleCarRules = false;
  bool vehiclecancellationLoading = false;
  bool vehicleisDescriptionExpanded = false;
  var isLoadingVehicle = true.obs;
  var isLoadingVehicleNotFound = true.obs;
  List vehicleimageList = [];
  Future getdataVehicle(id) async {
    itemInfoDetails.clear();
    vehicleimageList.clear();
    isLoadingVehicle.value = true;
    isLoadingVehicleNotFound.value = false;
    update();
    var response = await httpPost(Config.getItemDetails, {"item_id": "$id"});
    if (response != null && response['status'] == 200) {
      vehicleDetailModel = ItemDetailsModel.fromJson(response);
      vehicleimageList.addAll(
          vehicleDetailModel!.data!.itemDetails!.galleryImageUrls ?? []);
      if (vehicleDetailModel!.data!.itemDetails!.frontImageUrl != null) {
        vehicleimageList.insert(
            0, vehicleDetailModel!.data!.itemDetails!.frontImageUrl!);
      } else {
        vehicleimageList.insert(0, "");
      }
      isLoadingVehicle.value = false;

      update();

      String? itemInfo = vehicleDetailModel?.data?.itemDetails?.itemInfo;
      if (itemInfo != null) {
        itemInfoDetails = json.decode(itemInfo);
      }
    } else {
      isLoadingVehicleNotFound.value = true;
      isLoadingVehicle.value = false;
      update();
    }
  }

  late GoogleMapController vehicleMapController;
  void vehicleOnMapCreated(GoogleMapController controller) {
    vehicleMapController = controller;
  }

  void vehicleZoomIn() {
    vehicleMapController.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  void vehicleZoomOut() {
    vehicleMapController.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  bool showMore = true;
  void vehicleDispose() {
    isLoadingVehicle.value = true;
  }

  bool isDescriptionExpandedVehicle = false;
}
