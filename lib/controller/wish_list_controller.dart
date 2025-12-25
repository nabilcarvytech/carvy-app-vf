import 'package:get/get.dart';
import 'package:carvy/controller/home_controller.dart';
import 'package:carvy/controller/search_controller.dart';
import '../api/config.dart';
import '../customwidget/miscellaneous_project_elements.dart';
import '../helper/http_service.dart';
import '../model/items_model.dart';
import '../work_space.dart';

/// Contrôleur Wishlist connecté strictement au backend Node.js
/// via les endpoints:
/// - POST add-to-wishlist
/// - POST remove-from-wishlist
/// - GET  get-wishlist
class WishListController extends GetxController implements GetxService {
  HomeController homeController = Get.find();

  /// Utilisé pour refléter rapidement l'état "ajouté aux favoris"
  var addVishList = false.obs;

  /// Chargement de la liste des favoris
  var isLoading = false.obs;

  /// Liste des items favoris (pour l'écran Wishlist)
  RxList<Items> wishlistItems = <Items>[].obs;

  /// Synchronise l'état wishlist dans tous les contrôleurs de l'app
  void _syncWishlistStateAcrossControllers(dynamic itemId, bool isFavorite) {
    print(
        "🔄 [Sync] Syncing wishlist state for item $itemId: isFavorite=$isFavorite");

    // 1. SYNC WITH HOME CONTROLLER
    if (Get.isRegistered<HomeController>()) {
      try {
        final homeCtrl = Get.find<HomeController>();

        // Sync featuredItems
        if (homeCtrl.homeDataModel?.data?.featuredItems != null) {
          final index = homeCtrl.homeDataModel!.data!.featuredItems!.indexWhere(
              (element) => element.id?.toString() == itemId.toString());
          if (index != -1) {
            homeCtrl.homeDataModel!.data!.featuredItems![index].isInWishlist =
                isFavorite;
            print(
                "🔄 [Sync] Updated HomeController featuredItems[$index] (id: $itemId) to isFavorite=$isFavorite");
          }
        }

        // Sync nearbyItems
        if (homeCtrl.homeDataModel?.data?.nearbyItems != null) {
          final index = homeCtrl.homeDataModel!.data!.nearbyItems!.indexWhere(
              (element) => element.id?.toString() == itemId.toString());
          if (index != -1) {
            homeCtrl.homeDataModel!.data!.nearbyItems![index].isInWishlist =
                isFavorite;
            print(
                "🔄 [Sync] Updated HomeController nearbyItems[$index] (id: $itemId) to isFavorite=$isFavorite");
          }
        }

        // Sync mostViewedItems
        if (homeCtrl.homeDataModel?.data?.mostViewedItems != null) {
          final index = homeCtrl.homeDataModel!.data!.mostViewedItems!
              .indexWhere(
                  (element) => element.id?.toString() == itemId.toString());
          if (index != -1) {
            homeCtrl.homeDataModel!.data!.mostViewedItems![index].isInWishlist =
                isFavorite;
            print(
                "🔄 [Sync] Updated HomeController mostViewedItems[$index] (id: $itemId) to isFavorite=$isFavorite");
          }
        }

        // Sync newArrivalItems
        if (homeCtrl.homeDataModel?.data?.newArrivalItems != null) {
          final index = homeCtrl.homeDataModel!.data!.newArrivalItems!
              .indexWhere(
                  (element) => element.id?.toString() == itemId.toString());
          if (index != -1) {
            homeCtrl.homeDataModel!.data!.newArrivalItems![index].isInWishlist =
                isFavorite;
            print(
                "🔄 [Sync] Updated HomeController newArrivalItems[$index] (id: $itemId) to isFavorite=$isFavorite");
          }
        }

        homeCtrl.update(); // Force Home UI to rebuild
      } catch (e) {
        print("⚠️ [Sync] Error syncing HomeController: $e");
      }
    }

    // 2. SYNC WITH SEARCH CONTROLLER (for search results)
    if (Get.isRegistered<SearchControllerHome>()) {
      try {
        final searchCtrl = Get.find<SearchControllerHome>();

        // Sync searchFilterList
        if (searchCtrl.searchFilterList.isNotEmpty) {
          final index = searchCtrl.searchFilterList.indexWhere(
              (element) => element.id?.toString() == itemId.toString());
          if (index != -1) {
            searchCtrl.searchFilterList[index].isInWishlist = isFavorite;
            print(
                "🔄 [Sync] Updated SearchController searchFilterList[$index] (id: $itemId) to isFavorite=$isFavorite");
            searchCtrl.update();
          }
        }
      } catch (e) {
        print("⚠️ [Sync] Error syncing SearchController: $e");
      }
    }
  }

  @override
  void onInit() {
    super.onInit();
    getWishlistData();
  }

  /// Récupère la liste des favoris depuis le backend.
  Future<void> getWishlistData() async {
    if (token.isEmpty) {
      wishlistItems.clear();
      return;
    }

    try {
      isLoading.value = true;
      update();

      print(
          "📤 [Flutter Wishlist] Requesting wishlist data from: ${Config.getWishlist}");
      final response = await httpGet(Config.getWishlist, {});

      // ========== DEBUG: Inspect raw API response ==========
      print("📥 [Flutter Wishlist] ========================================");
      print("📥 [Flutter Wishlist] Server Response: $response");
      print("📥 [Flutter Wishlist] Response type: ${response.runtimeType}");

      if (response != null) {
        print("📥 [Flutter Wishlist] Response status: ${response['status']}");
        print("📥 [Flutter Wishlist] Response message: ${response['message']}");
        print("📥 [Flutter Wishlist] Response error: ${response['error']}");

        if (response['data'] != null) {
          print(
              "📥 [Flutter Wishlist] Response data exists: ${response['data']}");
          print(
              "📥 [Flutter Wishlist] Response data type: ${response['data'].runtimeType}");

          if (response['data'] is Map) {
            final dataMap = response['data'] as Map;
            print("📥 [Flutter Wishlist] Data keys: ${dataMap.keys.toList()}");

            if (dataMap['items'] != null) {
              print(
                  "📥 [Flutter Wishlist] Items field exists: ${dataMap['items']}");
              print(
                  "📥 [Flutter Wishlist] Items type: ${dataMap['items'].runtimeType}");

              if (dataMap['items'] is List) {
                final itemsList = dataMap['items'] as List;
                print("🔢 [Flutter Wishlist] Item count: ${itemsList.length}");
                if (itemsList.isNotEmpty) {
                  print("📥 [Flutter Wishlist] First item: ${itemsList[0]}");
                } else {
                  print("⚠️ [Flutter Wishlist] Items list is EMPTY!");
                }
              } else {
                print(
                    "⚠️ [Flutter Wishlist] Items is NOT a List! Type: ${dataMap['items'].runtimeType}");
              }
            } else {
              print(
                  "⚠️ [Flutter Wishlist] 'items' field is NULL or missing in data!");
            }
          } else if (response['data'] is List) {
            print(
                "🔢 [Flutter Wishlist] Data is directly a List, count: ${(response['data'] as List).length}");
          } else {
            print(
                "⚠️ [Flutter Wishlist] Data is neither Map nor List! Type: ${response['data'].runtimeType}");
          }
        } else {
          print("⚠️ [Flutter Wishlist] Data is NULL!");
        }
      } else {
        print("⚠️ [Flutter Wishlist] Response is NULL!");
      }
      print("📥 [Flutter Wishlist] ========================================");
      // ========== END DEBUG ==========

      if (response != null && response['status'] == 200) {
        final data = response['data'];
        final rawList = (data?['items'] as List<dynamic>?) ?? [];

        print("🔧 [Flutter Wishlist] Parsing ${rawList.length} items...");

        final List<Items> parsed = [];
        for (int i = 0; i < rawList.length; i++) {
          try {
            final item = rawList[i];
            print(
                "🔧 [Flutter Wishlist] Parsing item $i: ${item.toString().substring(0, item.toString().length > 100 ? 100 : item.toString().length)}...");
            parsed.add(Items.fromJson(item));
            print("✅ [Flutter Wishlist] Item $i parsed successfully");
          } catch (e, stackTrace) {
            print("❌ [Flutter Wishlist] Error parsing item $i: $e");
            print("❌ [Flutter Wishlist] Stack trace: $stackTrace");
            print("❌ [Flutter Wishlist] Item data: $rawList[i]");
            // ignore un item mal formé, ne pas casser toute la liste
          }
        }

        print(
            "✅ [Flutter Wishlist] Successfully parsed ${parsed.length} out of ${rawList.length} items");
        wishlistItems.assignAll(parsed);
        print(
            "📋 [Flutter Wishlist] wishlistItems now contains ${wishlistItems.length} items");
      } else {
        final msg = response != null
            ? (response['message']?.toString() ??
                response['error']?.toString() ??
                'Failed to load wishlist')
            : 'Failed to load wishlist';
        showErrorToastMessage(msg);
        wishlistItems.clear();
      }
    } catch (e) {
      showErrorToastMessage('Failed to load wishlist');
      wishlistItems.clear();
    } finally {
      isLoading.value = false;
      update();
    }
  }

  /// Ajoute un véhicule en favoris.
  /// Retourne `true` si `status == 200`, sinon `false`.
  Future<bool> addTowishlist(dynamic itemId) async {
    if (token.isEmpty) {
      showErrorToastMessage("You are not Login");
      return false;
    }

    try {
      final response =
          await httpPost(Config.addtowishlist, {"item_id": "$itemId"});

      if (response != null && response['status'] == 200) {
        addVishList.value = true;
        update();
        final msg = response['message']?.toString() ?? 'Added to favorites';
        showToastMessage(msg);

        // ========== UX SYNC: Update state in all controllers ==========
        _syncWishlistStateAcrossControllers(itemId, true);
        // ========== END UX SYNC ==========

        return true;
      } else {
        final msg = response != null
            ? (response['message']?.toString() ??
                response['error']?.toString() ??
                'Failed to add to favorites')
            : 'Failed to add to favorites';
        showErrorToastMessage(msg);
        addVishList.value = false;
        update();
        return false;
      }
    } catch (e) {
      showErrorToastMessage('Failed to add to favorites');
      addVishList.value = false;
      update();
      return false;
    }
  }

  /// Retire un véhicule des favoris.
  /// Retourne `true` si `status == 200`, sinon `false`.
  Future<bool> removeToWishlist(dynamic itemId) async {
    if (token.isEmpty) {
      showErrorToastMessage("You are not Login");
      return false;
    }

    // ========== UX IMPROVEMENT: Optimistic UI - Remove from local list immediately ==========
    // Remove from local list immediately for better UX (before API call)
    final itemIdString = itemId.toString();
    final initialLength = wishlistItems.length;
    wishlistItems.removeWhere((item) => item.id?.toString() == itemIdString);
    final removed = wishlistItems.length < initialLength;

    if (removed) {
      update(); // Force UI rebuild immediately
      print(
          "⚡ [Optimistic UI] Item removed from local list instantly. Remaining items: ${wishlistItems.length}");

      // ========== UX SYNC: Update state in all controllers immediately ==========
      _syncWishlistStateAcrossControllers(itemId, false);
      // ========== END UX SYNC ==========
    }
    // ========== END UX IMPROVEMENT ==========

    try {
      final response = await httpPost(
        Config.removeToWishlist,
        {"item_id": "$itemId"},
      );

      if (response != null && response['status'] == 200) {
        final msg = response['message']?.toString() ?? 'Removed from favorites';
        showToastMessage(msg);
        print(
            "✅ [Optimistic UI] API confirmed removal - item already removed from UI");

        // ========== UX SYNC: Ensure state is synced (already done optimistically, but confirm) ==========
        _syncWishlistStateAcrossControllers(itemId, false);
        // ========== END UX SYNC ==========

        return true;
      } else {
        // ========== UX IMPROVEMENT: Revert optimistic update if API fails ==========
        // If API call failed, we should refresh the list to restore the item
        // But for now, we'll just show an error and let the next refresh fix it
        final msg = response != null
            ? (response['message']?.toString() ??
                response['error']?.toString() ??
                'Failed to remove from favorites')
            : 'Failed to remove from favorites';
        showErrorToastMessage(msg);
        print(
            "⚠️ [Optimistic UI] API failed - refreshing list to restore state");
        // Refresh the list to restore correct state
        getWishlistData();
        // ========== END UX IMPROVEMENT ==========
        return false;
      }
    } catch (e) {
      showErrorToastMessage('Failed to remove from favorites');
      // ========== UX IMPROVEMENT: Revert optimistic update on exception ==========
      print(
          "⚠️ [Optimistic UI] Exception occurred - refreshing list to restore state");
      getWishlistData();
      // ========== END UX IMPROVEMENT ==========
      return false;
    }
  }
}
