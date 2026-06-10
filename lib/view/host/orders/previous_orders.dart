import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/orders/_mock_booking_helper.dart';
import '../../../customwidget/data_not_found.dart';
import '../../../customwidget/project_color.dart';
import '../../../helper/http_service.dart';
import '../../../model/booking_model.dart';

class PreviousOrders extends StatefulWidget {
  final bool fromPropBooking;
  const PreviousOrders({super.key, required this.fromPropBooking});

  @override
  State<PreviousOrders> createState() => _PreviousOrdersState();
}

class _PreviousOrdersState extends State<PreviousOrders> {
  BookingModel? bookingModel;
  List<Bookings> listpreview = [];
  num offset = 0;

  RefreshController refreshController = RefreshController();
  
  // ========== VARIABLES DE PAGINATION ==========
  bool isLoading = false;
  bool hasMoreData = true;
  bool isInitialLoad = true;
  // ========== END VARIABLES DE PAGINATION ==========

  void onItemCancelled(int index) {
    setState(() {
      listpreview.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    getData(isLoadMore: false);
  }

  getData({bool isLoadMore = false}) async {
    // ========== VÉRIFICATION PAGINATION ==========
    // Ne pas appeler l'API si déjà en chargement ou s'il n'y a plus de données
    if (isLoading) {
      print('⚠️ [PAGINATION] Appel API ignoré : déjà en chargement');
      return;
    }
    
    // Si c'est un chargement supplémentaire mais qu'il n'y a plus de données
    if (isLoadMore && !hasMoreData) {
      print('⚠️ [PAGINATION] Appel API ignoré : plus de données disponibles');
      refreshController.loadNoData();
      return;
    }
    
    // Si c'est un chargement initial, réinitialiser
    if (!isLoadMore) {
      offset = 0;
      hasMoreData = true;
    }
    // ========== END VÉRIFICATION PAGINATION ==========
    
    try {
      isLoading = true;
      
      Map<String, String> postData = {"type": "previous", "offset": '$offset'};
      
      // ========== APPEL API RÉEL ==========
      print('📦 [ORDERS_DIAG] Appel API vendor-booking-record avec type: previous, offset: $offset, isLoadMore: $isLoadMore');
      var result = await httpPost(Config.vendorbookingRecord, postData);
      print('📦 [ORDERS_DIAG] Données reçues du serveur : ${jsonEncode(result)}');
      // ========== END APPEL API RÉEL ==========
      
      // ========== MOCK DATA - FALLBACK (si API échoue) ==========
      // var result = generateMockVendorBooking(type: "previous", offset: offset);
      // ========== END MOCK DATA ==========

      if (result != null) {
        bookingModel = BookingModel.fromJson(result);
        if (bookingModel!.data != null) {
          List<Bookings>? newBookings = bookingModel!.data!.bookings;
          int bookingsCount = newBookings?.length ?? 0;
          
          // ========== CONDITION D'ARRÊT ==========
          // Si moins de 10 bookings reçus, il n'y a plus de données
          if (bookingsCount < 10) {
            hasMoreData = false;
            print('📦 [PAGINATION] Moins de 10 bookings reçus ($bookingsCount), hasMoreData = false');
          }
          // ========== END CONDITION D'ARRÊT ==========
          
          if (isLoadMore) {
            listpreview.addAll(newBookings!);
          } else {
            listpreview = List<Bookings>.from(newBookings!);
          }
          
          // ========== GESTION DE L'OFFSET ==========
          // Incrémenter l'offset uniquement après une réponse réussie
          if (bookingModel!.data!.offset != null) {
            offset = bookingModel!.data!.offset!;
            print('📦 [PAGINATION] Offset mis à jour : $offset');
          } else {
            // Si offset n'est pas fourni, incrémenter manuellement
            offset = offset + bookingsCount;
            print('📦 [PAGINATION] Offset incrémenté manuellement : $offset');
          }
          // ========== END GESTION DE L'OFFSET ==========
        }
        
        isInitialLoad = false;
        
        if (mounted) {
          setState(() {});
        }
        refreshController.loadComplete();
        refreshController.refreshCompleted();
      } else {
        refreshController.loadFailed();
        refreshController.refreshFailed();
      }
    } catch (error) {
      print('❌ [PAGINATION] Erreur lors du chargement : $error');
      refreshController.loadFailed();
      refreshController.refreshFailed();
    } finally {
      isLoading = false;
    }
  }

  onLoading() {
    // ========== VÉRIFICATION AVANT CHARGEMENT ==========
    if (!hasMoreData) {
      print('⚠️ [PAGINATION] onLoading ignoré : plus de données');
      refreshController.loadNoData();
      return;
    }
    // ========== END VÉRIFICATION ==========
    getData(isLoadMore: true);
  }

  onRefresh() {
    bookingModel = null;
    listpreview = [];
    offset = 0;
    hasMoreData = true;
    isInitialLoad = true;
    isLoading = false;
    setState(() {});
    getData(isLoadMore: false);
  }

  stateSetter(fn) => setState(() {});
  @override
  void dispose() {
    refreshController.dispose(); // Dispose the RefreshController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        body: SmartRefresher(
          controller: refreshController,
          onRefresh: onRefresh,
          onLoading: onLoading,
          enablePullUp: hasMoreData && !isLoading,
          child: bookingModel == null
              ? myBookingScreenShimmer()
              : listpreview.isEmpty
                  ? Center(
                      child: buildNoDataWidget(
                        context,
                        "No Previous Order Available".tr,
                      ),
                    )
                  : myBookingHostListWidget(
                      listpreview,
                      "Add Review",
                      stateSetter,
                      widget.fromPropBooking,
                      "Previous",
                      onItemCancelled,
                      refreshData: onRefresh,
                    ),
        ));
  }
}
