import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/general_data_model.dart';
import 'package:flutter/material.dart';
import '../customwidget/custom_active_module_id_widget.dart';
import '../work_space.dart';

GeneralDataModel? generalDataModel;

class GeneralController extends GetxController implements GetxService {
  late TabController tabController;
  RxInt currentIndex = 0.obs;
  late TabController tabControllerHost;
  RxInt currentIndexHost = 0.obs;
  RxBool hasGeneralData = false.obs;
  RxBool hasGeneralDataforBanner = false.obs;
  RxBool failed = false.obs;
  RxBool msgUpdater = false.obs;
  GeneralDataModel? generalDataModel;
  RxInt myBookingTabIndex = 0.obs;

  Future<void> fetchGeneralSettings([bool? runOnHomePage]) async {
    var datastorelocally = GetStorage().read("generalSettings");
    failed.value = false;
    if (runOnHomePage == false) {
      hasGeneralData.value = true;
    }
    hasGeneralDataforBanner.value = true;

    if (datastorelocally == null) {
      try {
        var response = await httpGet(Config.getgeneralSettings, {});
        if (response != null && response['status'] == 200) {
          GetStorage().write("generalSettings", response);
          generalDataModel = GeneralDataModel.fromJson(response);
          setDedultData();
          if (runOnHomePage == false) {
            hasGeneralData.value = false;
          }
          hasGeneralDataforBanner.value = false;
          update();
        } else {
          _handleFailure(runOnHomePage);
        }
      } catch (e) {
        _handleFailure(runOnHomePage);
      }
    } else {
      generalDataModel = GeneralDataModel.fromJson(datastorelocally);

      setDedultData();

      hasGeneralData.value = false;
      hasGeneralDataforBanner.value = false;
    }
  }

  void _handleFailure(bool? runOnHomePage) {
    update();
    failed.value = true;
    if (runOnHomePage == false) {
      hasGeneralData.value = false;
    }
    hasGeneralDataforBanner.value = false;
  }

  void setDedultData() {
    paymentStatus = generalDataModel?.data?.metaData?.onlinePayment.toString();
    maxPriceRange = generalDataModel?.data?.metaData?.generalMaximumPrice;
    minPricerange = generalDataModel?.data?.metaData?.generalMinimumPrice;
    if (generalDataModel?.data?.metaData?.defultCountryShortNsme != null) {
      profileController.defaultCountry.value =
          generalDataModel!.data!.metaData!.defultCountryShortNsme!;
      profileController.defaultCountryReset.value =
          generalDataModel!.data!.metaData!.defultCountryShortNsme!;
    } else {
      profileController.defaultCountry.value = 'MA';
      profileController.defaultCountryReset.value = 'MA';
    }
    if (generalDataModel?.data?.metaData?.defultPhoneCountry != null) {
      profileController.selectedCountry.value =
          generalDataModel!.data!.metaData!.defultPhoneCountry!;
      profileController.selectedCountryReset.value =
          generalDataModel!.data!.metaData!.defultPhoneCountry!;
    } else {
      profileController.selectedCountry.value = '+212';
      profileController.selectedCountryReset.value = '+212';
    }
    if (isHostMode.value == true) {
      currency = generalDataModel?.data?.metaData?.generalDefaultCurrency ?? "";
    } else {
      currency = GetStorage().read("setSelectedCurrency") == true
          ? GetStorage().read("selectedCurrencyCode") ?? ""
          : generalDataModel?.data?.metaData?.generalDefaultCurrency ?? "";
    }
    showhideItemType = generalDataModel?.data?.metaData?.itemType ?? "";
    showHidePopularRegion =
        generalDataModel?.data?.metaData?.popularRegion ?? "";
    showHideNrarYou = generalDataModel?.data?.metaData?.nearYou ?? "";
    showHideMake = generalDataModel?.data?.metaData?.make ?? "";
    showHideMustView = generalDataModel?.data?.metaData?.mostView ?? "";
    showHideBecomeHost = generalDataModel?.data?.metaData?.becomelead ?? "";
    showhidedistance = generalDataModel?.data?.metaData?.showDistance ?? "";
    digitalsingnature =
        generalDataModel?.data?.metaData?.digitalSingnature ?? "";
    internalVehicleImage =
        generalDataModel?.data?.metaData?.bookingInternalImage ?? "";
    kycenable = generalDataModel?.data?.metaData?.kyc ?? "";
    update();
  }
}
