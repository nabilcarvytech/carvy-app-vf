import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/vehicle_home_model.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/payments/wallet_screen.dart';
import 'package:carvy/work_space.dart';
import '../../customwidget/miscellaneous_project_elements.dart';
import '../bottombar/home_main.dart';
import 'booking_success_page.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';

class PaymentScreen extends StatefulWidget {
  final String? url;
  final String? bookingId;
  final dynamic? price;
  final bool? fromBooking;
  final dynamic bookingForSomeOne;
  final dynamic noteForOwner;
  final dynamic numberofguest;
  final dynamic idFeatured;
  final int? totalNight;
  final ItemInfo? itemDetails;
  final String? frontImage;
  final String? address;
  final String? rating;
  final String? itemType;
  final String? title;

  final String? isAddDoorStepPrice;
  const PaymentScreen({
    super.key,
    this.url,
    this.bookingId,
    this.price,
    this.fromBooking,
    this.bookingForSomeOne,
    this.noteForOwner,
    this.numberofguest,
    this.idFeatured,
    this.totalNight,
    this.itemDetails,
    this.address,
    this.rating,
    this.itemType,
    this.title,
    this.isAddDoorStepPrice,
    this.frontImage,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late InAppWebViewController webViewController;
  bool _isLoading = true;
  Timer? _timer;
  int _secondsRemaining = 600;
  bool _isTimerActive = true;
  bool _isNavigating = false;
  bool _showExitConfirm = false;
  BookingController bookingController = Get.find();
  @override
  void initState() {
    super.initState();
    _startTimer();

    // Listen for keyboard visibility changes
    KeyboardVisibilityController().onChange.listen((bool visible) {
      if (!visible) {
        webViewController.evaluateJavascript(source: """
          const inputs = document.querySelectorAll('input, textarea');
          const formData = {};
          inputs.forEach(input => {
            if (input.name) formData[input.name] = input.value;
          });
          window.formData = formData;
        """);
      } else {
        webViewController.evaluateJavascript(source: """
          if (window.formData) {
            const inputs = document.querySelectorAll('input, textarea');
            inputs.forEach(input => {
              if (input.name && window.formData[input.name]) {
                input.value = window.formData[input.name];
              }
            });
          }
        """);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> getData() async {
    if (_isNavigating) return;
    try {
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response = await httpPost(Config.bookingpaymentsuccess, {
      //   "booking_id": widget.bookingId,
      // });

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static success response for payment success
      var response = {
        "status": 200,
        "message": "Payment verified successfully",
        "error": "",
        "data": {
          "booking_id": widget.bookingId,
          "payment_status": "success",
          "bookingpayment": "success"
        }
      };
      // ========== END MOCK DATA ==========

      if (response != null) {
        setState(() {});
      }
    } catch (e) {
      print("Error fetching payment status: $e");
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isTimerActive) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          timer.cancel();
          getData();
          _showTimeoutBottomSheet();
        }
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _isTimerActive = false;
      _timer?.cancel();
    });
  }

  void _showTimeoutBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: notifires.getbgcolor,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 3), () {
          getData();
          handleBoackfromPayment = true;
          bookingController.commonNavigateToBookingSummary(
              context,
              widget.idFeatured,
              widget.itemDetails,
              widget.address,
              widget.frontImage,
              widget.title,
              widget.rating,
              widget.itemType,
              widget.price,
              bookingController.addDoorStepPrice
                  ? widget.itemDetails?.doorStepPrice
                  : "0");
        });
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.timer_off,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 16),
              Text('Payment Time Expired', style: regular3(context)),
              const SizedBox(height: 12),
              Text(
                'The payment session has timed out. Redirecting to booking summary...',
                style: regular3(context),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              LinearProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
                backgroundColor: Colors.grey[200],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _onWillPop() async {
    // Prevent back navigation if we're already processing a navigation
    if (_isNavigating) return false;

    // Show confirmation dialog
    if (!_showExitConfirm) {
      setState(() {
        _showExitConfirm = true;
      });

      final result = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: notifires.getboxcolor,
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  commonlyUserlogoAlert(),
                  const SizedBox(height: 5),
                  Text('Are you sure want to go back'.tr,
                      textAlign: TextAlign.center, style: regular2(context))
                ],
              ),
            ),
            actions: <Widget>[
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Container(
                            margin: const EdgeInsets.only(left: 8, right: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text(
                              "Cancel".tr,
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ))),
                      )),
                      Expanded(
                          child: InkWell(
                        onTap: () {
                          getData();
                          handleBoackfromPayment = true;
                          bookingController.commonNavigateToBookingSummary(
                              context,
                              widget.idFeatured,
                              widget.itemDetails,
                              widget.address,
                              widget.frontImage,
                              widget.title,
                              widget.rating,
                              widget.itemType,
                              widget.price,
                              bookingController.addDoorStepPrice
                                  ? widget.itemDetails?.doorStepPrice
                                  : "0");
                        },
                        child: Container(
                            margin: const EdgeInsets.only(left: 8, right: 8),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                border: Border.all(color: themeColor),
                                color: themeColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                                child: Text(
                              "Yes".tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ))),
                      )),
                    ],
                  ),
                  const SizedBox(height: 8)
                ],
              )
            ],
          );
        },
      );

      setState(() {
        _showExitConfirm = false;
      });

      if (result == true) {
        _stopTimer();
        handleBoackfromPayment = true;
        getData();
        Navigator.of(context).pop();
        return true;
      }
      return false;
    }
    return false;
  }

  void handleBack() {
    _onWillPop();
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _handleNavigation(String url) {
    debugPrint("Navigated to: $url");
    if (_isNavigating) return;

    // ========== MOCK HANDLING - TEMPORARY CODE FOR OFFLINE MODE ==========
    // TODO: REMOVE THIS MOCK HANDLING AFTER NODE.JS BACKEND IMPLEMENTATION
    // This code detects mock payment URLs (containing "cs_test_mock") and treats them as success
    // In production with Node.js backend, Stripe will redirect to a real payment_success URL
    // and this mock detection will not be needed.
    if (url.contains("cs_test_mock")) {
      debugPrint(
          "⚠️ MOCK MODE: Detected mock payment URL, simulating payment success");
      _stopTimer();
      _isNavigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingSuccessPage(
              bookingId: widget.bookingId!,
              initialStatus: "Paid",
            ),
          ),
        )
            .then((_) {
          generalController.currentIndex.value = 2;
          generalController.tabController.index = 2;
          Get.offAll(() => const HomeMain(initialIndex: 2));
        });
        _isNavigating = false;
      });
      return; // Exit early, don't process other conditions
    }
    // ========== END MOCK HANDLING ==========

    if (url.contains("wallet_recharge_success") ||
        url.contains("wallet_recharge_fail")) {
      _stopTimer();
      _isNavigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (url.contains("wallet_recharge_success")) {
          Get.offAll(() => const WalletScreen());
        } else {
          showErrorToastMessage("Your recharge failed".tr);
          Get.offAll(() => const WalletScreen());
        }
        _isNavigating = false;
      });
    } else if (url.contains("payment_fail")) {
      _stopTimer();
      _isNavigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showErrorToastMessage("Your booking failed".tr);
        Navigator.of(context).pop();
        _isNavigating = false;
      });
    } else if (url.contains("payment_success")) {
      _stopTimer();
      _isNavigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushReplacement(
          MaterialPageRoute(
            builder: (context) => BookingSuccessPage(
              bookingId: widget.bookingId!,
              initialStatus: "Paid",
            ),
          ),
        )
            .then((_) {
          generalController.currentIndex.value = 2;
          generalController.tabController.index = 2;
          Get.offAll(() => const HomeMain(initialIndex: 2));
        });
      });
    } else if (url.contains("/invalid-order")) {
      _stopTimer();
      _isNavigating = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pop();
        _isNavigating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _onWillPop();
      },
      child: Scaffold(
        backgroundColor: notifires.getbgcolor,
        resizeToAvoidBottomInset: true,
        appBar: CustomAppBars(
          backgroundColor: notifires.getbgcolor,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: notifires.getwhiteblackcolor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatTime(_secondsRemaining),
                    style: TextStyle(
                      color: notifires.getwhiteblackcolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          title:
              "Payment ${widget.fromBooking == true ? "$currency ${widget.price}" : ""}",
          onBackButtonPressed: handleBack,
          titleColor: notifires.getwhiteblackcolor,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: widget.url != null
                    ? URLRequest(url: WebUri(widget.url!))
                    : null,
                initialSettings: InAppWebViewSettings(
                  transparentBackground: true,
                  javaScriptEnabled: true,
                  useShouldOverrideUrlLoading: true,
                  allowsInlineMediaPlayback: true,
                  mediaPlaybackRequiresUserGesture: false,
                  useHybridComposition: false,
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  controller.evaluateJavascript(source: """
                    document.addEventListener('focusout', function(e) {
                      if (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA') {
                        setTimeout(function() {
                          e.target.focus();
                        }, 0);
                      }
                    });
                  """);
                },
                onLoadStart: (controller, url) {
                  setState(() {
                    _isLoading = true;
                  });
                },
                onLoadStop: (controller, url) {
                  setState(() {
                    _isLoading = false;
                  });
                  _handleNavigation(url?.toString() ?? "");
                  controller.evaluateJavascript(source: """
                    document.querySelectorAll('input, textarea').forEach(input => {
                      input.addEventListener('blur', function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                      });
                    });
                  """);
                },
                shouldOverrideUrlLoading: (controller, navigationAction) async {
                  final url = navigationAction.request.url?.toString() ?? "";
                  _handleNavigation(url);
                  return NavigationActionPolicy.ALLOW;
                },
                onReceivedError: (controller, request, error) {
                  debugPrint("WebView Error: ${error.description}");
                },
              ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
