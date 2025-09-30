import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/booking_model.dart';
import 'package:carvy/view/host/common_widget_host.dart';

class LiveOrderds extends StatefulWidget {
  final bool fromPropBooking;

  const LiveOrderds({
    super.key,
    required this.fromPropBooking,
  });

  @override
  State<LiveOrderds> createState() => _LiveOrderdsState();
}

class _LiveOrderdsState extends State<LiveOrderds> {
  RefreshController refreshController = RefreshController();
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    try {
      Map<String, String> postData = {"type": "ongoing", "offset": '$offset'};
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
                        "No OnGoing Order Available".tr,
                      ),
                    )
                  : myBookingHostListWidget(
                      list,
                      "Cancel",
                      stateSetter,
                      widget.fromPropBooking,
                      "Ongoing",
                      onItemCancelled,
                    ),
        ));
  }
}
