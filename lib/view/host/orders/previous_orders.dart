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

  void onItemCancelled(int index) {
    setState(() {
      listpreview.removeAt(index);
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    Map<String, String> postData = {"type": "previous", "offset": '$offset'};
    
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var result = await httpPost(Config.vendorbookingRecord, postData);
    
    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // MOCK: Static vendor booking data using helper
    var result = generateMockVendorBooking(type: "previous", offset: offset);
    // ========== END MOCK DATA ==========

    if (result != null) {
      bookingModel = BookingModel.fromJson(result);
      if (bookingModel!.data != null) {
        listpreview.addAll(bookingModel!.data!.bookings!);
        offset = bookingModel!.data!.offset!;
      }
      if (mounted) {
        setState(() {});
      }
      refreshController.loadComplete();
      refreshController.refreshCompleted();
    }
  }

  onLoading() {
    getData();
  }

  onRefresh() {
    bookingModel = null;
    listpreview = [];
    setState(() {});
    offset = 0;
    getData();
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
          enablePullUp: offset == -1 ? false : true,
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
                      onItemCancelled),
        ));
  }
}
