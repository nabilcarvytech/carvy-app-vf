import 'dart:convert';
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
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var result = await httpPost(Config.upcommingRecord, postData);

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Static booking data for upcoming trips
    String bookingType = postData['type'] ?? 'upcoming';
    num currentOffset = int.tryParse(postData['offset'] ?? '0') ?? 0;

    var result = {
      "status": 200,
      "message": "Bookings retrieved successfully",
      "error": "",
      "data": {
        "Bookings": [
          {
            "id": DateTime.now().millisecondsSinceEpoch,
            "itemid": "101",
            "userid": "1",
            "host_id": "1001",
            "check_in": "2025-12-16",
            "check_out": "2025-12-18",
            "status": "Pending",
            "total_day": "2",
            "per_day": "50.00",
            "book_for": "",
            "base_price": "100.00",
            "cleaning_charge": "5.00",
            "guest_charge": "0.00",
            "service_charge": "10.00",
            "security_money": "100.00",
            "iva_tax": "12.50",
            "total_guest": "1",
            "doorstep_price": "0",
            "total": "127.50",
            "admin_commission": "10.00",
            "vendor_commision": "90.00",
            "currency_code": "MAD",
            "cancellation_reasion": "",
            "cancelled_charge": "",
            "transaction": "",
            "payment_method": "stripe",
            "payment_status": "Paid",
            "image": "https://example.com/camry.jpg",
            "item_title": "Toyota Camry 2023",
            "item_data": jsonEncode([
              {
                "item_id": 101,
                "title": "Toyota Camry 2023",
                "price": "50.00",
                "description": "Clean and comfortable sedan",
                "address": "123 Main Street, Los Angeles, CA 90001",
                "state_region": "California",
                "zip_postal_code": "90001",
                "latitude": "34.0522",
                "longitude": "-118.2437",
                "item_rating": "4.5",
                "mobile": "+1234567890",
                "status": "1",
                "person_allowed": "5",
                "item_type": "Sedan",
                "city": "Los Angeles",
                "item_info": jsonEncode({
                  "host_id": "1001",
                  "make_type": "Toyota",
                  "model": "Camry",
                  "year": "2023",
                  "service_type": "booking"
                })
              }
            ]),
            "wall_amt": "0.00",
            "note": "",
            "rating": "4.5",
            "cancelled_by": "",
            "created_at": DateTime.now().subtract(const Duration(days: 1)).toString().split('.')[0],
            "updated_at": DateTime.now().toString().split('.')[0],
            "review_status": "0",
            "review_rating": "",
            "review": "",
            "host_name": "John Doe",
            "host_number": "+1234567890",
            "host_email": "john.doe@example.com",
            "host_phone_country": "+1",
            "user_name": "User Test",
            "user_number": "+212694492918",
            "user_phone_country": "+212",
            "user_email": "user@example.com",
            "module": "2",
            "token": "",
            "start_time": "00:00",
            "end_time": "11:30",
            "booking_meta": "",
            "is_item_delivered": 0,
            "is_item_received": 0,
            "is_item_returned": 0,
            "is_item_delivered_button": "",
            "is_item_returned_button": "",
            "is_received_button": "",
            "pick_otp": "",
            "drop_otp": "",
            "doorStep_address": "",
            "booking_vehicle_images": null,
            "signature_image": null
          }
        ],
        "offset": currentOffset + 10,
        "limit": 10
      }
    };
    // ========== END MOCK DATA ==========

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
