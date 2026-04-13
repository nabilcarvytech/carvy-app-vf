import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/model/items_model.dart';
import '../api/config.dart';
import '../helper/http_service.dart';
import '../model/get_user_profile.dart';
import '../model/get_vendor_items_reviews.dart';
import '../model/vendor_model.dart';

class PublicProfileController extends GetxController implements GetxService {
  GetUserProfile? getUserProfile;
  GetVendorItemsReviews? getVendorItemsReviews;
  GetVendorItemsReviews? getVendorItemsReviewsScreen;
  ItemModel? getUserItems;
  var isLoading = true.obs;
  
  // ========== Variables d'état pour les avis détaillés (nouvelle API vendor-reviews) ==========
  var totalReviews = 0.obs;
  var globalAverage = 0.0.obs;
  var criteriaAverages = <String, double>{}.obs;
  var reviewsList = <Map<String, dynamic>>[].obs;
  var isLoadingReviews = true.obs;
  // ========== FIN Variables d'état pour les avis détaillés ==========
  Future<void> getDataPublicProfile(userid) async {
    try {
      isLoading.value = true;
      update(); // Force l'affichage du loader
      
      print("🚀 [PROFIL] Récupération des infos pour userid: $userid");
      
      // 1. Appel API Profil
      try {
        var responseProfile = await httpGet(Config.getUserProfile, {"userid": userid});
        if (responseProfile != null) {
          print("✅ [PROFIL] Données brutes reçues: $responseProfile");
          if (responseProfile['status'] == 200) {
            getUserProfile = GetUserProfile.fromJson(responseProfile);
            final vendor = Vendor.fromJson(responseProfile['data']);
            print(
                '📸 [CRITICAL DEBUG] URL Image reçue du Backend : "${vendor.image}"');
            print("✅ [PROFIL] Profil parsé avec succès");
          } else {
            print("❌ [PROFIL] Status != 200: ${responseProfile['status']}, message: ${responseProfile['message']}");
            getUserProfile = null;
          }
        } else {
          print("❌ [PROFIL] La réponse de l'API est nulle");
          getUserProfile = null;
        }
      } catch (e, stackTrace) {
        print("🚨 [CRASH PROFIL] Erreur lors de l'appel API Profil: $e");
        print("🚨 [STACKTRACE PROFIL]: $stackTrace");
        getUserProfile = null;
      }

      // 2. Appel API Avis (ancienne API pour compatibilité)
      try {
        var responseReviews = await httpGet(Config.getVendorItemReviews, {"userid": userid});
        if (responseReviews != null) {
          print("✅ [AVIS] Données brutes reçues: $responseReviews");
          if (responseReviews['status'] == 200) {
            getVendorItemsReviews = GetVendorItemsReviews.fromJson(responseReviews);
            print("✅ [AVIS] Avis parsés avec succès");
          } else {
            print("❌ [AVIS] Status != 200: ${responseReviews['status']}");
            getVendorItemsReviews = null;
          }
        } else {
          print("❌ [AVIS] La réponse de l'API est nulle");
          getVendorItemsReviews = null;
        }
      } catch (e, stackTrace) {
        print("🚨 [CRASH AVIS] Erreur lors de l'appel API Avis: $e");
        print("🚨 [STACKTRACE AVIS]: $stackTrace");
        getVendorItemsReviews = null;
      }
      
      // 2bis. Appel API Avis détaillés (nouvelle API vendor-reviews)
      await fetchVendorReviews(userid);

      // 3. Appel API Véhicules
      try {
        var responseItems = await httpGet(Config.getUseritems, {"userid": userid});
        if (responseItems != null) {
          print("✅ [VÉHICULES] Données brutes reçues: $responseItems");
          if (responseItems['status'] == 200) {
            getUserItems = ItemModel.fromJson(responseItems);
            print("✅ [VÉHICULES] Véhicules parsés avec succès");
          } else {
            print("❌ [VÉHICULES] Status != 200: ${responseItems['status']}");
            getUserItems = null;
          }
        } else {
          print("❌ [VÉHICULES] La réponse de l'API est nulle");
          getUserItems = null;
        }
      } catch (e, stackTrace) {
        print("🚨 [CRASH VÉHICULES] Erreur lors de l'appel API Véhicules: $e");
        print("🚨 [STACKTRACE VÉHICULES]: $stackTrace");
        getUserItems = null;
      }
      
      print("✅ [PROFIL] Chargement terminé - Profil: ${getUserProfile != null}, Avis: ${getVendorItemsReviews != null}, Véhicules: ${getUserItems != null}");
    } catch (e, stackTrace) {
      print("🚨 [CRASH PROFIL] Erreur critique dans getDataPublicProfile: $e");
      print("🚨 [STACKTRACE]: $stackTrace");
      // En cas d'erreur globale, on laisse les modèles à null
      getUserProfile = null;
      getVendorItemsReviews = null;
      getUserItems = null;
    } finally {
      // Quoi qu'il arrive, on arrête le chargement pour débloquer l'UI
      isLoading.value = false;
      update();
      print("🔄 [PROFIL] isLoading mis à false, UI débloquée");
    }
  }

  RefreshController refreshController = RefreshController();
  List<Reviews> list = [];
  num offset = 0;
  var isLoadingReviewScreen = false.obs;
  Future getDataPublicProfileReview(userid) async {
    try {
      isLoadingReviewScreen.value = true;

      final response = await httpGet(Config.getVendorItemReviews,
          {"userid": userid, "offset": "$offset"});

      if (response != null && response['status'] == 200) {
        getVendorItemsReviewsScreen =
            GetVendorItemsReviews.fromJson(response);

        final reviews = getVendorItemsReviewsScreen?.data?.reviews;
        if (reviews != null && reviews.isNotEmpty) {
          list.addAll(reviews);
        }
        final newOffset = getVendorItemsReviewsScreen?.data?.offset;
        if (newOffset != null) {
          offset = newOffset;
        }
      }
    } catch (e) {
      // On ignore l'erreur pour ne pas bloquer le pull-to-refresh.
    } finally {
      refreshController.loadComplete();
      refreshController.refreshCompleted();
      isLoadingReviewScreen.value = false;
      update();
    }
  }

  /// Récupère les avis détaillés du vendeur depuis l'API vendor-reviews
  Future<void> fetchVendorReviews(String vendorId) async {
    try {
      isLoadingReviews.value = true;
      
      print('📊 [VENDOR_REVIEWS] Récupération des avis pour vendor_id: $vendorId');
      print('📊 [VENDOR_REVIEWS] URL: ${Config.baseurl}${Config.vendorReviews}');
      
      // Appel API
      final response = await httpPost(Config.vendorReviews, {"vendor_id": vendorId});
      
      print('📥 [VENDOR_REVIEWS] Réponse reçue du serveur');
      print('📥 [VENDOR_REVIEWS] Type de réponse: ${response.runtimeType}');
      
      if (response != null && response['status'] == 200) {
        final data = response['data'];
        if (data != null) {
          // Remplir les variables d'état
          totalReviews.value = data['total_reviews'] ?? 0;
          globalAverage.value = (data['global_average'] ?? 0.0).toDouble();
          
          // Remplir criteriaAverages
          if (data['criteria_averages'] != null && data['criteria_averages'] is Map) {
            criteriaAverages.clear();
            (data['criteria_averages'] as Map).forEach((key, value) {
              criteriaAverages[key.toString()] = (value ?? 0.0).toDouble();
            });
          }
          
          // Remplir reviewsList
          if (data['reviews'] != null && data['reviews'] is List) {
            reviewsList.value = List<Map<String, dynamic>>.from(data['reviews']);
          } else {
            reviewsList.value = [];
          }
          
          print('✅ [VENDOR_REVIEWS] Données parsées avec succès');
          print('   - total_reviews: ${totalReviews.value}');
          print('   - global_average: ${globalAverage.value}');
          print('   - criteria_averages: ${criteriaAverages.length} critères');
          print('   - reviews: ${reviewsList.length} avis');
        } else {
          print('⚠️ [VENDOR_REVIEWS] Data est null dans la réponse');
          totalReviews.value = 0;
          globalAverage.value = 0.0;
          criteriaAverages.clear();
          reviewsList.value = [];
        }
      } else {
        print('❌ [VENDOR_REVIEWS] Erreur: Status != 200 ou réponse null');
        print('   Status: ${response?['status']}');
        print('   Message: ${response?['message']}');
        print('   Error: ${response?['error']}');
        totalReviews.value = 0;
        globalAverage.value = 0.0;
        criteriaAverages.clear();
        reviewsList.value = [];
      }
    } catch (e, stackTrace) {
      print('❌ [VENDOR_REVIEWS] Exception lors de l\'appel API: $e');
      print('❌ [VENDOR_REVIEWS] StackTrace: $stackTrace');
      totalReviews.value = 0;
      globalAverage.value = 0.0;
      criteriaAverages.clear();
      reviewsList.value = [];
    } finally {
      isLoadingReviews.value = false;
      update();
      print('🔄 [VENDOR_REVIEWS] isLoadingReviews mis à false');
    }
  }

  @override
  void onClose() {
    PublicProfileController();
    super.onClose();
  }
}
