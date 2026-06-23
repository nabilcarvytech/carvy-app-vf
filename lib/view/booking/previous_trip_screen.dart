import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/customwidget/shimmer_widgets.dart';
import '../../controller/booking_record_controller.dart';
import '../../customwidget/data_not_found.dart';
import '../../customwidget/project_color.dart';
import '../../utils/common_widget.dart';
import '../../utils/safe_rebuild.dart';

class PreviousTrip extends StatefulWidget {
  final bool fromPropBooking;
  const PreviousTrip({super.key, required this.fromPropBooking});

  @override
  State<PreviousTrip> createState() => _PreviousTripState();
}

class _PreviousTripState extends State<PreviousTrip> {
  final BookingRecordController bookingRecordController = Get.find();
  RefreshController refreshController = RefreshController();

  void onItemCancelled(int index) {
    bookingRecordController.removeBooking(index);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    runAfterFirstFrame(() => getData());
  }

  getData() async {
    // Lors du premier chargement, passer explicitement offset: 0 pour réinitialiser la liste
    await bookingRecordController.getBookingRecord(
      type: "previous",
      offset: 0, // Toujours commencer à 0 pour éviter les doublons
    );
    
    if (mounted) {
      setState(() {});
    }
    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

  onLoading() async {
    // Pour la pagination, utiliser l'offset actuel du controller
    await bookingRecordController.getBookingRecord(
      type: "previous",
      offset: bookingRecordController.offset, // Utiliser l'offset pour la pagination
    );
    refreshController.loadComplete();
  }

  onRefresh() {
    bookingRecordController.resetList();
    getData();
  }

  stateSetter(fn) => setState(() {});

  @override
  void dispose() {
    refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        body: Obx(() => SmartRefresher(
          controller: refreshController,
          onRefresh: onRefresh,
          onLoading: onLoading,
          enablePullUp: bookingRecordController.offset == -1 ? false : true,
          child: bookingRecordController.isLoading.value
              ? myBookingScreenShimmer()
              : bookingRecordController.bookingsList.isEmpty
                  ? Center(
                      child: buildNoDataWidget(
                        context,
                        "No Previous Booking Available".tr,
                      ),
                    )
                  : myBookingListWidget(
                      bookingRecordController.bookingsList,
                      "Add Review",
                      stateSetter,
                      widget.fromPropBooking,
                      "Previous",
                      onItemCancelled,
                    ),
        )));
  }
}
