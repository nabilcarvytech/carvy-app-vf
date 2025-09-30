import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import 'package:carvy/model/booking_model.dart';
import '../../api/config.dart';
import '../../customwidget/data_not_found.dart';
import '../../customwidget/project_color.dart';
import '../../helper/http_service.dart';
import '../../utils/common_widget.dart';

class MyUpCommingTrip extends StatefulWidget {
  final bool fromPropBooking;

  const MyUpCommingTrip({
    super.key,
    required this.fromPropBooking,
  });

  @override
  State<MyUpCommingTrip> createState() => _MyUpCommingTripState();
}

class _MyUpCommingTripState extends State<MyUpCommingTrip> {
  RefreshController refreshController = RefreshController();
  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() async {
    Map<String, String> postData = {"type": "upcoming", "offset": '$offset'};
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
                        "No Upcoming Booking Available".tr,
                      ),
                    )
                  : myBookingListWidget(
                      list,
                      "Cancel",
                      stateSetter,
                      widget.fromPropBooking,
                      "UpComing",
                      onItemCancelled,
                    ),
        ));
  }
}
