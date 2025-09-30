import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/work_space.dart';
import '../../api/config.dart';
import '../../helper/http_service.dart';

// class BookingSuccessPage extends StatefulWidget {
//   final String? bookingId;

//   const BookingSuccessPage({super.key, this.bookingId});

//   @override
//   State<BookingSuccessPage> createState() => _BookingSuccessPageState();
// }

// class _BookingSuccessPageState extends State<BookingSuccessPage> {
//   String status = "";
//   int time = 5;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();

//     getData();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }

//   getData() async {
//     var response = await httpPost(Config.bookingpaymentsuccess, {
//       "booking_id": widget.bookingId,
//     });

//     if (response != null) {
//       status = response['data']['bookingpayment'];
//       setState(() {});
//     }

//     _startTimer();
//   }

//   void _startTimer() {
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (timer.tick == 5) {
//         timer.cancel();
//         generalController.currentIndex.value = 2;
//         generalController.tabController.index = 2;
//         Get.offAll(() => const HomeMain(initialIndex: 2));
//       }
//       setState(() {
//         time--;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: true,
//       child: Scaffold(
//         body: status.isEmpty
//             ? const Center(child: CircularProgressIndicator())
//             : Padding(
//                 padding: const EdgeInsets.all(16),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 150),
//                     Lottie.asset(
//                       status == "Paid"
//                           ? 'assets/lottie/success.json'
//                           : 'assets/lottie/failed.json',
//                       fit: BoxFit.fill,
//                       repeat: false,
//                     ),
//                     const SizedBox(height: 50),
//                     InkWell(
//                       onTap: () {},
//                       child: Text(
//                         status == "Paid"
//                             ? "Booking Successful".tr
//                             : "Booking Failed".tr,
//                         style: const TextStyle(
//                             fontWeight: FontWeight.bold, fontSize: 24),
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//                     Text(
//                         "${"You will be redirected automatically in".tr} $time")
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }
class BookingSuccessPage extends StatefulWidget {
  final String? bookingId;
  final String? initialStatus;

  // Singleton guard to prevent multiple instances
  static bool isOpen = false;

  const BookingSuccessPage({super.key, this.bookingId, this.initialStatus});

  @override
  State<BookingSuccessPage> createState() => _BookingSuccessPageState();
}

class _BookingSuccessPageState extends State<BookingSuccessPage> {
  String status = "";
  int time = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Prevent multiple instances
    if (BookingSuccessPage.isOpen) return;
    BookingSuccessPage.isOpen = true;

    status = widget.initialStatus ?? "";
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;

      if (time <= 1) {
        timer.cancel();
        BookingSuccessPage.isOpen = false; // reset singleton
        Navigator.of(context).pop(); // close page
      } else {
        setState(() {
          time--;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    BookingSuccessPage.isOpen = false; // reset singleton on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: status.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 150),
                  Lottie.asset(
                    status == "Paid"
                        ? 'assets/lottie/success.json'
                        : 'assets/lottie/failed.json',
                    fit: BoxFit.fill,
                    repeat: false,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    status == "Paid"
                        ? "Booking Successful".tr
                        : "Booking Failed".tr,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const SizedBox(height: 24),
                  Text("${"You will be redirected automatically in".tr} $time"),
                ],
              ),
            ),
    );
  }
}
