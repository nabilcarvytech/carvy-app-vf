import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/view/host/common_widget_host.dart';

import '../../../customwidget/data_not_found.dart';
import '../../../helper/http_service.dart';
import '../../../model/booking_model.dart';

class CancelOrders extends StatefulWidget {
  final bool fromPropBooking;
  const CancelOrders({super.key, required this.fromPropBooking});

  @override
  State<CancelOrders> createState() => _CancelOrdersState();
}

class _CancelOrdersState extends State<CancelOrders> {
  RefreshController refreshController = RefreshController();
  BookingModel? bookingModel;
  List<Bookings> listCancelledbookingList = [];
  num offset = 0;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    Map<String, String> postData = {"type": "Cancelled", "offset": '$offset'};
    var result = await httpPost(Config.vendorbookingRecord, postData);

    if (result != null) {
      bookingModel = BookingModel.fromJson(result);
      if (bookingModel!.data != null) {
        listCancelledbookingList.addAll(bookingModel!.data!.bookings!);
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
    listCancelledbookingList = [];
    setState(() {});
    offset = 0;
    getData();
  }

  void onItemCancelled(int index) {
    // Remove the cancelled booking from the list
    setState(() {
      listCancelledbookingList.removeAt(index);
    });
  }

  @override
  void dispose() {
    refreshController.dispose(); // Dispose the RefreshController
    super.dispose();
  }

  stateSetter(fn) => setState(() {});

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
              : listCancelledbookingList.isEmpty
                  ? Center(
                      child: buildNoDataWidget(
                        context,
                        "No Cancelled Order Available".tr,
                      ),
                    )
                  : myBookingHostListWidget(
                      listCancelledbookingList,
                      "Cancelled",
                      stateSetter,
                      widget.fromPropBooking,
                      "Cancelled",
                      onItemCancelled,
                    ),
        ));
  }
}
