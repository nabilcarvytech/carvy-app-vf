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
        // ========== MOCK DATA - OLD API CALL COMMENTED ==========
        // var response = await httpGet(Config.getgeneralSettings, {});

        // MOCK: Simulate network delay
        await Future.delayed(const Duration(seconds: 1));

        // MOCK: Static general settings data
        var response = {
          "status": 200,
          "message": "General settings retrieved successfully",
          "error": "",
          "data": {
            "metaData": {
              "general_name": "Carvy",
              "general_email": "support@carvy.com",
              "general_head_code": "",
              "general_default_currency": "MAD",
              "general_default_language": "en",
              "general_logo": "https://example.com/logo.png",
              "general_favicon": "https://example.com/favicon.png",
              "personalization_row_per_page": "10",
              "personalization_min_search_price": "0",
              "personalization_max_search_price": "1000",
              "personalization_date_separator": "/",
              "personalization_date_format": "dd/mm/yyyy",
              "personalization_time_zone": "UTC",
              "personalization_money_format": "symbol",
              "general_minimum_price": "10",
              "general_maximum_price": "500",
              "feesetup_guest_service_charge": "5",
              "feesetup_iva_tax": "10",
              "feesetup_accomodation_tax": "0",
              "onlinepayment": "1",
              "general_default_phone_country": "+212",
              "general_default_country_code": "MA",
              "app_item_type": "1",
              "app_popular_region": "1",
              "app_near_you": "1",
              "app_make": "1",
              "app_most_viewed": "1",
              "app_become_lend": "1",
              "app_show_distance": "1",
              "app_user_digital_signature": "1",
              "app_booking_vehicle_images": "1",
              "app_user_kyc": "1"
            }
          }
        };
        // ========== END MOCK DATA ==========
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
