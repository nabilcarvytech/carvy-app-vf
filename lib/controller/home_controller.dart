import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carvy/model/make_type_model.dart';
import 'package:carvy/model/items_model.dart';
import 'package:carvy/model/item_type_model.dart';
import 'package:carvy/model/home_categories_model.dart';
import '../api/config.dart';
import '../helper/http_service.dart';
import '../model/get_currency_details_model.dart';
import '../model/locations_model.dart';
import '../model/vehicle_home_model.dart';

class HomeController extends GetxController implements GetxService {
  apibasedonModuleid() async {
    onVehicleHomeScreenRefresh();
  }

  int currentIndex = 0;
  RxBool loctionCheck = false.obs;
  RxBool ourRecommendationCheck = false.obs;
  RxBool nearyouirems = false.obs;
  RxBool mustViewCheck = false.obs;
  RxBool newArrivalPropertloadingy = false.obs;
  num offset = 0;
  void disposeFunction() {
    loctionCheck.value = false;
    ourRecommendationCheck.value = false;
    mustViewCheck.value = false;
  }

  ItemModel? nearyouItems;
  ItemModel? newArrivalitemyModel;
  LocationsModel? locationsModel;
  LocationsModel? locationModelVehicle;
  var locationCheckVehicle = false.obs;

  RxBool mustViewCheckVehicle = false.obs;
  ItemModel? vehicleMustViewModel;

  num offsetVehicle = 0;

  void disposeFunctionVehicle() {
    locationCheckVehicle.value = false;
    mustViewCheckVehicle.value = false;
  }

  CarMakes? makeTypeModel;
  var isLoadingVehicle = false.obs;
  Future getMakeApi() async {
    isLoadingVehicle.value = true;
    var ameString = GetStorage().read("make");
    if (ameString == null) {
      httpPost(Config.makeType, {}).then((response) {
        if (response != null) {
          makeTypeModel = CarMakes.fromJson(response);
          GetStorage().write("make", response);
          isLoadingVehicle.value = false;
          update();
        }
      });
    } else {
      makeTypeModel = CarMakes.fromJson(ameString);
      isLoadingVehicle.value = false;
      update();
    }
  }

  onVehicleHomeScreenRefresh() {
    getHomeData();
    update();
  }

  var isLoadingTopCategory = true.obs;

  List parkingCategory = [];

  ItemTypeModel? topcCategoryModel;
  Future<void> topCategoryApi() async {
    isLoadingTopCategory.value = true;
    var storedData = GetStorage().read("topCategoryData");
    if (storedData == null) {
      try {
        var response = await httpPost(Config.itemsType, {});
        if (response != null) {
          topcCategoryModel = ItemTypeModel.fromJson(response);
          GetStorage().write("topCategoryData", response);
          isLoadingTopCategory.value = false;
          update();
        }
      } catch (e) {
        isLoadingTopCategory.value = false;
        update();
      }
    } else {
      topcCategoryModel = ItemTypeModel.fromJson(storedData);
      isLoadingTopCategory.value = false;
      update();
    }
  }

  Future<void> nearestItems() async {
    nearyouirems.value = true;
    dynamic getStoragevaluebasedonModulkeid =
        GetStorage().read("NearYouVehicle");
    if (getStoragevaluebasedonModulkeid == null) {
      try {
        var response = await httpPost(Config.nearbyItems, {});
        if (response != null && response['status'] == 200) {
          nearyouItems = ItemModel.fromJson(response);
          GetStorage().write("NearYouVehicle", response);
        } else {}
      } catch (e) {
        //
      } finally {
        nearyouirems.value = false;
        update();
      }
    } else {
      nearyouItems = ItemModel.fromJson(getStoragevaluebasedonModulkeid);
      nearyouirems.value = false;
      update();
    }
  }

  var locationCommon = false.obs;

  CurrencyModel? currencyModel;
  RxBool currencyLoading = false.obs;
  Future<void> getCurrency() async {
    currencyLoading.value = true;
    try {
      var response = await httpPost(Config.getCurrencyDetails, {});
      if (response != null) {
        currencyModel = CurrencyModel.fromJson(response);
        currencyLoading.value = false;
        update();
      } else {
        currencyLoading.value = false;
        update();
      }
    } catch (e) {
      currencyLoading.value = false;
      update();
    }
  }

  List<ItemTypes> vehicleListItemType = [];
  ItemTypeModel? itemTypeModel;
  var isloadingType = false.obs;
  Future<void> getDataItemType() async {
    isloadingType.value = true;
    var storedData = GetStorage().read("vehicleTypeHome");
    if (storedData == null) {
      var response2 = await httpGet(Config.itemsType, {});
      if (response2 != null) {
        itemTypeModel = ItemTypeModel.fromJson(response2);
        isloadingType.value = false;
        GetStorage().write("vehicleTypeHome", response2);
      }
    } else {
      itemTypeModel = ItemTypeModel.fromJson(storedData);
      isloadingType.value = false;
    }
    update();
  }

  RxBool homeDataLoading = false.obs;
  HomeDataModel? homeDataModel;
  Future<void> getHomeData() async {
    homeDataLoading.value = true;
    var storedData = GetStorage().read("homeData");
    if (storedData == null) {
      try {
        var response = await httpGet(Config.homeDataApi, {});

        if (response != null) {
          homeDataModel = HomeDataModel.fromJson(response);
          homeDataLoading.value = false;
          GetStorage().write("homeData", response);
        } else {
          homeDataLoading.value = false;
          update();
        }
      } catch (e) {
        homeDataLoading.value = false;
        update();
      }
    } else {
      homeDataModel = HomeDataModel.fromJson(storedData);

      homeDataLoading.value = false;
    }
    update();
  }
}
