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
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // httpPost(Config.makeType, {}).then((response) {
      //   if (response != null) {
      //     makeTypeModel = CarMakes.fromJson(response);
      //     GetStorage().write("make", response);
      //     isLoadingVehicle.value = false;
      //     update();
      //   }
      // });

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Return static CarMakes data
      final mockResponse = {
        "status": 200,
        "message": "Makes retrieved successfully",
        "error": "",
        "data": {
          "makes": [
            {
              "id": 1,
              "name": "Toyota",
              "description": "Toyota vehicles",
              "status": "1",
              "created_at": "2024-01-01 10:00:00",
              "updated_at": "2024-01-01 10:00:00",
              "deleted_at": "",
              "image": "https://example.com/toyota.png",
              "imageURL": "https://example.com/toyota.png",
              "media": []
            },
            {
              "id": 2,
              "name": "Honda",
              "description": "Honda vehicles",
              "status": "1",
              "created_at": "2024-01-01 10:00:00",
              "updated_at": "2024-01-01 10:00:00",
              "deleted_at": null,
              "image": null,
              "imageURL": "https://example.com/honda.png",
              "media": []
            },
            {
              "id": 3,
              "name": "BMW",
              "description": "BMW vehicles",
              "status": "1",
              "created_at": "2024-01-01 10:00:00",
              "updated_at": "2024-01-01 10:00:00",
              "deleted_at": null,
              "image": null,
              "imageURL": "https://example.com/bmw.png",
              "media": []
            }
          ]
        }
      };

      makeTypeModel = CarMakes.fromJson(mockResponse);
      GetStorage().write("make", mockResponse);
      isLoadingVehicle.value = false;
      update();
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
        // ========== MOCK DATA - OLD API CALL COMMENTED ==========
        // var response = await httpPost(Config.itemsType, {});

        // MOCK: Simulate network delay
        await Future.delayed(const Duration(seconds: 1));

        // MOCK: Return static ItemTypeModel data
        var response = {
          "status": 200,
          "message": "Categories retrieved successfully",
          "error": "",
          "data": {
            "itemTypes": [
              {
                "id": 1,
                "name": "Sedan",
                "description": "Sedan vehicles",
                "status": "1",
                "image": "https://example.com/sedan.png"
              },
              {
                "id": 2,
                "name": "SUV",
                "description": "SUV vehicles",
                "status": "1",
                "image": "https://example.com/suv.png"
              },
              {
                "id": 3,
                "name": "Hatchback",
                "description": "Hatchback vehicles",
                "status": "1",
                "image": "https://example.com/hatchback.png"
              },
              {
                "id": 4,
                "name": "Coupe",
                "description": "Coupe vehicles",
                "status": "1",
                "image": "https://example.com/coupe.png"
              }
            ]
          }
        };

        topcCategoryModel = ItemTypeModel.fromJson(response);
        GetStorage().write("topCategoryData", response);
        isLoadingTopCategory.value = false;
        update();
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
        // ========== MOCK DATA - OLD API CALL COMMENTED ==========
        // var response = await httpPost(Config.nearbyItems, {});

        // MOCK: Simulate network delay
        await Future.delayed(const Duration(seconds: 1));

        // MOCK: Return static ItemModel data for nearby items
        var response = {
          "status": 200,
          "message": "Nearby items retrieved successfully",
          "error": "",
          "data": {
            "items": [
              {
                "id": 101,
                "name": "Toyota Camry 2023",
                "item_rating": "4.5",
                "mobile": "+1234567890",
                "person_allowed": "5",
                "address": "123 Main Street",
                "state_region": "California",
                "city": "Los Angeles",
                "zip_postal_code": "90001",
                "price": "50.00",
                "latitude": "34.0522",
                "longitude": "-118.2437",
                "status": "1",
                "item_type_id": "1",
                "image": "https://example.com/camry.jpg",
                "item_info":
                    "{\"host_id\":\"1001\",\"host_first_name\":\"John\",\"host_last_name\":\"Doe\",\"host_email\":\"john.doe@example.com\",\"host_phone\":\"+1234567890\",\"host_player_id\":\"player_12345\",\"host_profile_image\":\"https://example.com/profile.jpg\",\"make_type\":\"Toyota\",\"model\":\"Camry\",\"year\":\"2023\",\"transmission\":\"automatic\",\"fuel_type\":\"gasoline\",\"odometer\":\"15000\",\"number_of_seats\":\"5\",\"vehicleType\":\"Sedan\",\"license_plate\":\"ABC123\",\"gallery_image_urls\":[\"https://example.com/camry-1.jpg\",\"https://example.com/camry-2.jpg\"],\"review_data\":[],\"features_data\":[{\"id\":1,\"name\":\"GPS Navigation\",\"image_url\":\"https://example.com/gps.png\"},{\"id\":2,\"name\":\"Bluetooth\",\"image_url\":\"https://example.com/bluetooth.png\"}],\"rules\":[],\"is_verified\":\"1\",\"is_featured\":\"1\",\"min_rental_days\":\"1\",\"smoking_status\":\"0\",\"insurance_coverage\":\"Full Coverage\",\"international_travel_status\":\"1\",\"min_age\":\"21\",\"booking_policies_id\":\"1\",\"weekly_discount\":\"10\",\"weekly_discount_type\":\"percentage\",\"monthly_discount\":\"15\",\"monthly_discount_type\":\"percentage\",\"cancellation_reason_title\":\"\",\"cancellation_reason_description\":[],\"doorStep_price\":\"0\",\"service_type\":\"booking\",\"description\":\"\"}",
                "is_in_wishlist": false,
                "item_type": "Sedan",
                "distance": "2.5"
              },
              {
                "id": 102,
                "name": "Honda CR-V 2023",
                "item_rating": "4.7",
                "mobile": "+1234567891",
                "person_allowed": "7",
                "address": "456 Oak Avenue",
                "state_region": "California",
                "city": "San Francisco",
                "zip_postal_code": "94102",
                "price": "65.00",
                "latitude": "37.7749",
                "longitude": "-122.4194",
                "status": "1",
                "item_type_id": "2",
                "image": "https://example.com/crv.jpg",
                "item_info":
                    "{\"host_id\":\"1001\",\"host_first_name\":\"John\",\"host_last_name\":\"Doe\",\"host_email\":\"john.doe@example.com\",\"host_phone\":\"+1234567890\",\"host_player_id\":\"player_12345\",\"host_profile_image\":\"https://example.com/profile.jpg\",\"make_type\":\"Toyota\",\"model\":\"Camry\",\"year\":\"2023\",\"transmission\":\"automatic\",\"fuel_type\":\"gasoline\",\"odometer\":\"15000\",\"number_of_seats\":\"5\",\"vehicleType\":\"Sedan\",\"license_plate\":\"ABC123\",\"gallery_image_urls\":[\"https://example.com/camry-1.jpg\",\"https://example.com/camry-2.jpg\"],\"review_data\":[],\"features_data\":[{\"id\":1,\"name\":\"GPS Navigation\",\"image_url\":\"https://example.com/gps.png\"},{\"id\":2,\"name\":\"Bluetooth\",\"image_url\":\"https://example.com/bluetooth.png\"}],\"rules\":[],\"is_verified\":\"1\",\"is_featured\":\"1\",\"min_rental_days\":\"1\",\"smoking_status\":\"0\",\"insurance_coverage\":\"Full Coverage\",\"international_travel_status\":\"1\",\"min_age\":\"21\",\"booking_policies_id\":\"1\",\"weekly_discount\":\"10\",\"weekly_discount_type\":\"percentage\",\"monthly_discount\":\"15\",\"monthly_discount_type\":\"percentage\",\"cancellation_reason_title\":\"\",\"cancellation_reason_description\":[],\"doorStep_price\":\"0\",\"service_type\":\"booking\",\"description\":\"\"}",
                "is_in_wishlist": false,
                "item_type": "SUV",
                "distance": "5.2"
              }
            ],
            "offset": 0
          }
        };

        if (response['status'] == 200) {
          nearyouItems = ItemModel.fromJson(response);
          GetStorage().write("NearYouVehicle", response);
        }
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
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response = await httpPost(Config.getCurrencyDetails, {});

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Return static CurrencyModel data
      var response = {
        "success": true,
        "data": [
          {
            "id": 1,
            "currency_name": "US Dollar",
            "currency_code": "USD",
            "value_against_default_currency": "1.00",
            "currency_symbol": "\$"
          },
          {
            "id": 2,
            "currency_name": "Euro",
            "currency_code": "EUR",
            "value_against_default_currency": "0.92",
            "currency_symbol": "€"
          },
          {
            "id": 3,
            "currency_name": "British Pound",
            "currency_code": "GBP",
            "value_against_default_currency": "0.79",
            "currency_symbol": "£"
          }
        ]
      };

      currencyModel = CurrencyModel.fromJson(response);
      currencyLoading.value = false;
      update();
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
    try {
      final storedData = GetStorage().read("vehicleTypeHome");
      dynamic response;

      if (storedData != null) {
        // Use cached response if available
        response = storedData;
      } else {
        // Call real backend API: GET /get-all-categories
        response = await httpGet(Config.itemsType, {});
        if (response != null) {
          GetStorage().write("vehicleTypeHome", response);
        }
      }

      if (response != null) {
        itemTypeModel = ItemTypeModel.fromJson(response);

        // Construire la liste utilisée par l'UI avec la catégorie "All"
        vehicleListItemType.clear();
        final types = itemTypeModel?.data?.itemTypes ?? [];
        vehicleListItemType.addAll(types);

        final bool hasAnyType = vehicleListItemType.isNotEmpty;
        if (!hasAnyType) {
          // Si le backend ne renvoie rien, on garde au moins "All"
          vehicleListItemType.add(
            ItemTypes(
              id: '0',
              name: 'All',
              description: 'All vehicle types',
              status: '1',
              image: null,
            ),
          );
        } else {
          final first = vehicleListItemType.first;
          final bool alreadyHasAll =
              (first.name?.toLowerCase() == 'all' || first.id == '0');

          if (!alreadyHasAll) {
            vehicleListItemType.insert(
              0,
              ItemTypes(
                id: '0',
                name: 'All',
                description: 'All vehicle types',
                status: '1',
                image: null,
              ),
            );
          }
        }
      }
    } catch (e) {
      isloadingType.value = false;
      update();
      rethrow;
    }

    isloadingType.value = false;
    update();
  }

  RxBool homeDataLoading = false.obs;
  HomeDataModel? homeDataModel;
  Future<void> getHomeData() async {
    print("🔵 [HOME_DATA] getHomeData() called");
    homeDataLoading.value = true;
    var storedData = GetStorage().read("homeData");
    if (storedData == null) {
      print("🔵 [HOME_DATA] No cached data found, fetching from API...");
      try {
        print(
            "🔵 [HOME_DATA] Calling httpGet with endpoint: ${Config.homeDataApi}");
        print(
            "🔵 [HOME_DATA] Full URL will be: ${Config.baseurl}${Config.homeDataApi}");

        var response = await httpGet(Config.homeDataApi, {});

        print("🔵 [HOME_DATA] Response received from API");
        print("🔵 [HOME_DATA] Response type: ${response.runtimeType}");
        print(
            "🔵 [HOME_DATA] Response keys: ${response is Map ? response.keys.toList() : 'Not a Map'}");

        if (response != null) {
          print("🔵 [HOME_DATA] Response is not null");
          print("🔵 [HOME_DATA] Response status: ${response['status']}");
          print("🔵 [HOME_DATA] Response message: ${response['message']}");

          if (response['data'] != null) {
            print("🔵 [HOME_DATA] Response has 'data' field");
            final data = response['data'];
            print(
                "🔵 [HOME_DATA] Data keys: ${data is Map ? data.keys.toList() : 'Not a Map'}");

            // Log counts of each list
            if (data is Map) {
              print(
                  "🔵 [HOME_DATA] itemTypes count: ${data['itemTypes'] != null && data['itemTypes'] is List ? (data['itemTypes'] as List).length : 'null/not a list'}");
              print(
                  "🔵 [HOME_DATA] nearby_items count: ${data['nearby_items'] != null && data['nearby_items'] is List ? (data['nearby_items'] as List).length : 'null/not a list'}");
              print(
                  "🔵 [HOME_DATA] featured_items count: ${data['featured_items'] != null && data['featured_items'] is List ? (data['featured_items'] as List).length : 'null/not a list'}");
              print(
                  "🔵 [HOME_DATA] most_viewed_items count: ${data['most_viewed_items'] != null && data['most_viewed_items'] is List ? (data['most_viewed_items'] as List).length : 'null/not a list'}");
              print(
                  "🔵 [HOME_DATA] new_arrival_items count: ${data['new_arrival_items'] != null && data['new_arrival_items'] is List ? (data['new_arrival_items'] as List).length : 'null/not a list'}");
              print(
                  "🔵 [HOME_DATA] locations count: ${data['locations'] != null && data['locations'] is List ? (data['locations'] as List).length : 'null/not a list'}");
              print(
                  "🔵 [HOME_DATA] makes count: ${data['makes'] != null && data['makes'] is List ? (data['makes'] as List).length : 'null/not a list'}");
            }
          } else {
            print("⚠️ [HOME_DATA] Response 'data' field is NULL");
          }

          print(
              "🔵 [HOME_DATA] Parsing response with HomeDataModel.fromJson()...");
          homeDataModel = HomeDataModel.fromJson(response);

          if (homeDataModel != null) {
            print("✅ [HOME_DATA] HomeDataModel parsed successfully");
            print(
                "✅ [HOME_DATA] homeDataModel.status: ${homeDataModel!.status}");
            print(
                "✅ [HOME_DATA] homeDataModel.data is null: ${homeDataModel!.data == null}");

            if (homeDataModel!.data != null) {
              print("✅ [HOME_DATA] homeDataModel.data exists");
              print(
                  "✅ [HOME_DATA] itemTypes count: ${homeDataModel!.data!.itemTypes?.length ?? 0}");
              print(
                  "✅ [HOME_DATA] nearbyItems count: ${homeDataModel!.data!.nearbyItems?.length ?? 0}");
              print(
                  "✅ [HOME_DATA] featuredItems count: ${homeDataModel!.data!.featuredItems?.length ?? 0}");
              print(
                  "✅ [HOME_DATA] mostViewedItems count: ${homeDataModel!.data!.mostViewedItems?.length ?? 0}");
              print(
                  "✅ [HOME_DATA] newArrivalItems count: ${homeDataModel!.data!.newArrivalItems?.length ?? 0}");
              print(
                  "✅ [HOME_DATA] locations count: ${homeDataModel!.data!.locations?.length ?? 0}");
              print(
                  "✅ [HOME_DATA] makes count: ${homeDataModel!.data!.makes?.length ?? 0}");
            } else {
              print("⚠️ [HOME_DATA] homeDataModel.data is NULL");
            }
          } else {
            print("❌ [HOME_DATA] HomeDataModel parsing returned NULL");
          }

          print("🔵 [HOME_DATA] Saving response to cache...");
          GetStorage().write("homeData", response);
          print("✅ [HOME_DATA] Response saved to cache");
        } else {
          print(
              "❌ [HOME_DATA] Response is NULL - API call failed or returned null");
        }

        homeDataLoading.value = false;
        print("🔵 [HOME_DATA] homeDataLoading set to false");
      } catch (e, stackTrace) {
        print("❌ [HOME_DATA] ERROR occurred: $e");
        print("❌ [HOME_DATA] Stack trace: $stackTrace");
        homeDataLoading.value = false;
        update();
      }
    } else {
      print("🔵 [HOME_DATA] Using cached data from GetStorage");
      print("🔵 [HOME_DATA] Cached data type: ${storedData.runtimeType}");

      try {
        homeDataModel = HomeDataModel.fromJson(storedData);
        print("✅ [HOME_DATA] Cached data parsed successfully");
      } catch (e) {
        print("❌ [HOME_DATA] Error parsing cached data: $e");
      }

      homeDataLoading.value = false;
    }
    print("🔵 [HOME_DATA] Calling update() and finishing getHomeData()");
    update();
  }
}
