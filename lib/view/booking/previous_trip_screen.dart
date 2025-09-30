import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import '../../api/config.dart';
import '../../customwidget/data_not_found.dart';
import '../../customwidget/project_color.dart';
import '../../helper/http_service.dart';
import '../../model/booking_model.dart';
import '../../utils/common_widget.dart';

class PreviousTrip extends StatefulWidget {
  final bool fromPropBooking;
  const PreviousTrip({super.key, required this.fromPropBooking});

  @override
  State<PreviousTrip> createState() => _PreviousTripState();
}

class _PreviousTripState extends State<PreviousTrip> {
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
    var result = await httpPost(Config.upcommingRecord, postData);

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
                        "No Previous Booking Available".tr,
                      ),
                    )
                  : myBookingListWidget(
                      listpreview,
                      "Add Review",
                      stateSetter,
                      widget.fromPropBooking,
                      "Previous",
                      onItemCancelled,
                    ),
        ));
  }
}
