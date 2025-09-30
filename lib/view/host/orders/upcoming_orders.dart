import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart' show Config;
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/model/booking_model.dart';
import 'package:carvy/view/host/common_widget_host.dart';

import '../../../customwidget/data_not_found.dart';
import '../../../customwidget/project_color.dart';
import '../../../helper/http_service.dart';

class UpcomingOrders extends StatefulWidget {
  final bool fromPropBooking;

  const UpcomingOrders({
    super.key,
    required this.fromPropBooking,
  });

  @override
  State<UpcomingOrders> createState() => _UpcomingOrdersState();
}

class _UpcomingOrdersState extends State<UpcomingOrders> {
  RefreshController refreshController = RefreshController();
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      Map<String, String> postData = {"type": "upcoming", "offset": '$offset'};
      var result = await httpPost(Config.vendorbookingRecord, postData);

      if (result != null) {
        bookingModel = BookingModel.fromJson(result);

        if (bookingModel != null &&
            bookingModel!.data != null &&
            bookingModel!.data!.bookings != null) {
          list.addAll(bookingModel!.data!.bookings!);
          offset = bookingModel!.data!.offset!;
        }

        if (mounted) {
          setState(() {});
        }
        refreshController.loadComplete();
        refreshController.refreshCompleted();
      } else {
        // Handle the case where result is null
        // This could be due to network error or other issues

        // You can add additional error handling here if needed
      }
    } catch (error) {
      // Handle other potential errors here
    }
  }

  onLoading() {
    getData();
  }

  onRefresh() {
    bookingModel = null;
    list = [];
    setState(() {});
    offset = 0;
    getData();
  }

  BookingModel? bookingModel;
  List<Bookings> list = [];
  num offset = 0;
  stateSetter(fn) => setState(() {});

  void onItemCancelled(int index) {
    setState(() {
      list.removeAt(index);
    });
  }

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
              : list.isEmpty
                  ? Center(
                      child: buildNoDataWidget(
                        context,
                        "No Upcoming Order Available".tr,
                      ),
                    )
                  : myBookingHostListWidget(
                      list,
                      "Reject",
                      stateSetter,
                      widget.fromPropBooking,
                      "UpComing",
                      onItemCancelled,
                    ),
        ));
  }
}
