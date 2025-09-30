import 'package:get/get.dart';
import 'package:carvy/controller/home_controller.dart';
import '../api/config.dart';
import '../customwidget/miscellaneous_project_elements.dart';
import '../helper/http_service.dart';
import '../model/wish_list_model.dart';
import '../work_space.dart';

class WishListController extends GetxController implements GetxService {
  HomeController homeController = Get.find();
  var addVishList = false.obs;
  addTowishlist(itemId) async {
    if (token.isEmpty) {
      showErrorToastMessage("You are not Login ");
      return;
    }
    var response = await httpPost(Config.addtowishlist, {"item_id": "$itemId"});
    try {
      WishlistModel wishlistModel = WishlistModel.fromJson(response);
      if (wishlistModel.status == 200) {
        addVishList.value = true;
        update();
        return true;
      } else {
        showToastMessage(wishlistModel.error);
        addVishList.value = false;
        update();
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  removeToWishlist(itemId) async {
    if (token.isEmpty) {
      showErrorToastMessage("You are not Login");
      return;
    }
    var response = await httpPost(Config.removeToWishlist, {
      "item_id": "$itemId",
    });
    try {
      WishlistModel wishlistModel = WishlistModel.fromJson(response);
      if (wishlistModel.status == 200) {
        return true;
      } else {
        showToastMessage(wishlistModel.error);
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
