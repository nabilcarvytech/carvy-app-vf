import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/model/items_model.dart';
import '../api/config.dart';
import '../helper/http_service.dart';
import '../model/get_user_profile.dart';
import '../model/get_vendor_items_reviews.dart';

class PublicProfileController extends GetxController implements GetxService {
  GetUserProfile? getUserProfile;
  GetVendorItemsReviews? getVendorItemsReviews;
  GetVendorItemsReviews? getVendorItemsReviewsScreen;
  ItemModel? getUserItems;
  var isLoading = true.obs;
  Future<void> getDataPublicProfile(userid) async {
    try {
      isLoading.value = true;
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response = await httpGet(Config.getUserProfile, {"userid": userid});

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static user profile data
      var response = {
        "status": 200,
        "message": "User profile retrieved successfully",
        "error": "",
        "data": {
          "name": "John Doe",
          "profile_image": "https://example.com/profile.jpg",
          "profile_background": "https://example.com/background.jpg",
          "intro_text": "Experienced host with 5 years of hosting",
          "total_reviews_on_items": 25,
          "average_rating_on_items": 4.5,
          "years_of_hosting": "5",
          "languages": "English, French",
          "livecity": "Los Angeles",
          "age": "35",
          "join_in": "2020-01-01",
          "verified_identity": "1",
          "verified_email": "1",
          "verified_phone": "1"
        }
      };
      // ========== END MOCK DATA ==========
      getUserProfile = GetUserProfile.fromJson(response);

      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response2 =
      //     await httpGet(Config.getVendorItemReviews, {"userid": userid});

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static vendor item reviews data
      var response2 = {
        "status": 200,
        "message": "Vendor item reviews retrieved successfully",
        "error": "",
        "data": {
          "reviews": [
            {
              "item_id": "101",
              "item_name": "Toyota Camry 2023",
              "guest_response": {
                "guest_name": "Alice Johnson",
                "guest_rating": "5",
                "guest_message": "Excellent vehicle!",
                "guest_profile": "https://example.com/guest1.jpg",
                "guest_id": "10"
              },
              "host_response": {
                "host_name": "John Doe",
                "host_rating": "5",
                "host_message": "Great guest!",
                "host_profile": "https://example.com/host.jpg",
                "host_id": userid
              },
              "created_at": "2025-01-10T10:00:00.000Z"
            }
          ],
          "offset": 0
        }
      };
      // ========== END MOCK DATA ==========
      getVendorItemsReviews = GetVendorItemsReviews.fromJson(response2);

      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response3 = await httpGet(Config.getUseritems, {"userid": userid});

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static user items data
      var response3 = {
        "status": 200,
        "message": "User items retrieved successfully",
        "error": "",
        "data": {
          "items": [
            {
              "id": 101,
              "name": "Toyota Camry 2023",
              "item_rating": "4.5",
              "mobile": "+1234567890",
              "status": "1",
              "person_allowed": "5",
              "price": "50.00",
              "address": "123 Main Street, Los Angeles",
              "state_region": "California",
              "zip_postal_code": "90001",
              "city": "Los Angeles",
              "latitude": "34.0522",
              "longitude": "-118.2437",
              "item_type_id": "1",
              "image": "https://example.com/camry-front.jpg",
              "item_info":
                  "{\"host_id\":\"$userid\",\"service_type\":\"booking\",\"make_type\":\"Toyota\",\"model\":\"Camry\",\"year\":\"2023\",\"transmission\":\"Automatic\",\"seat_capicity\":\"5\",\"host_first_name\":\"John\",\"review_data\":[],\"features_data\":[],\"gallery_image_urls\":[]}",
              "is_in_wishlist": false,
              "item_type": "Sedan",
              "distance": "0"
            }
          ],
          "offset": 0
        }
      };
      // ========== END MOCK DATA ==========
      getUserItems = ItemModel.fromJson(response3);
    } catch (e) {
      //
    } finally {
      isLoading.value = false;
      update();
    }
  }

  RefreshController refreshController = RefreshController();
  List<Reviews> list = [];
  num offset = 0;
  var isLoadingReviewScreen = false.obs;
  Future getDataPublicProfileReview(userid) async {
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // httpGet(Config.getVendorItemReviews,
    //     {"userid": userid, "offset": "$offset"}).then((response) {

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Static vendor item reviews data with pagination
    var response = {
      "status": 200,
      "message": "Vendor item reviews retrieved successfully",
      "error": "",
      "data": {
        "reviews": [
          {
            "item_id": "101",
            "item_name": "Toyota Camry 2023",
            "guest_response": {
              "guest_name": "Alice Johnson",
              "guest_rating": "5",
              "guest_message": "Excellent vehicle! Very clean and comfortable.",
              "guest_profile": "https://example.com/guest1.jpg",
              "guest_id": "10"
            },
            "host_response": {
              "host_name": "John Doe",
              "host_rating": "5",
              "host_message": "Great guest! Highly recommend.",
              "host_profile": "https://example.com/host.jpg",
              "host_id": userid
            },
            "created_at": "2025-01-10T10:00:00.000Z"
          }
        ],
        "offset": offset + 1
      }
    };
    // ========== END MOCK DATA ==========
    if (response != null) {
      getVendorItemsReviewsScreen = GetVendorItemsReviews.fromJson(response);
      list.addAll(getVendorItemsReviewsScreen!.data!.reviews!);
      offset = getVendorItemsReviewsScreen!.data!.offset!;
    }
    refreshController.loadComplete();
    refreshController.refreshCompleted();
    update();
  }

  @override
  void onClose() {
    PublicProfileController();
    super.onClose();
  }
}
