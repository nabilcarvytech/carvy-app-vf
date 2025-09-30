import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/booking_model.dart';
import 'package:carvy/utils/common_widget.dart';

class LiveBooking extends StatefulWidget {
  final bool fromPropBooking;

  const LiveBooking({
    super.key,
    required this.fromPropBooking,
  });

  @override
  State<LiveBooking> createState() => _LiveBookingState();
}

class _LiveBookingState extends State<LiveBooking> {
  RefreshController refreshController = RefreshController();
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    Map<String, String> postData = {"type": "ongoing", "offset": '$offset'};
    var result = await httpPost(Config.upcommingRecord, postData);
    if (result != null) {
      bookingModel = BookingModel.fromJson(result);
      if (bookingModel!.data != null) {
        list.addAll(bookingModel!.data!.bookings!);
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
                        "No Ongoing Booking Available".tr,
                      ),
                    )
                  : myBookingListWidget(
                      list,
                      "Cancel",
                      stateSetter,
                      widget.fromPropBooking,
                      "ongoing",
                      onItemCancelled,
                    ),
        ));
  }
}
