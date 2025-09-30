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
      var response = await httpGet(Config.getUserProfile, {"userid": userid});
      getUserProfile = GetUserProfile.fromJson(response);
      var response2 =
          await httpGet(Config.getVendorItemReviews, {"userid": userid});
      getVendorItemsReviews = GetVendorItemsReviews.fromJson(response2);
      var response3 = await httpGet(Config.getUseritems, {"userid": userid});
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
    httpGet(Config.getVendorItemReviews,
        {"userid": userid, "offset": "$offset"}).then((response) {
      if (response != null) {
        getVendorItemsReviewsScreen = GetVendorItemsReviews.fromJson(response);
        list.addAll(getVendorItemsReviewsScreen!.data!.reviews!);
        offset = getVendorItemsReviewsScreen!.data!.offset!;
      }
      refreshController.loadComplete();
      refreshController.refreshCompleted();
      update();
    });
  }

  @override
  void onClose() {
    PublicProfileController();
    super.onClose();
  }
}
