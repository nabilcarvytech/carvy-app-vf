import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
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
  final bool isExtension;
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
    this.isExtension = false,
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
  bool isPolicyAccepted = false; // État de validation de la politique d'annulation
  BookingController bookingController = Get.find();
  
  /// Normalise cancellationReasonDescription pour gérer tous les formats possibles
  /// Retourne toujours une List<String> pour l'affichage
  List<String> _normalizeCancellationDescription(dynamic description) {
    if (description == null) {
      return [];
    }
    
    // Si c'est déjà une List
    if (description is List) {
      if (description.isEmpty) {
        return [];
      }
      
      return description.map<String>((item) {
        // Si c'est déjà une String, la retourner directement
        if (item is String) {
          return item;
        }
        
        // Si c'est un Map/objet, extraire le texte approprié
        if (item is Map) {
          return item['description']?.toString() ?? 
                 item['text']?.toString() ?? 
                 item['reason']?.toString() ?? 
                 item['content']?.toString() ??
                 item['message']?.toString() ??
                 item.toString();
        }
        
        // Sinon, convertir en String
        return item.toString();
      }).toList();
    }
    
    // Si c'est une String, la mettre dans une List
    if (description is String) {
      return description.isEmpty ? [] : [description];
    }
    
    // Pour tout autre type, convertir en String
    return [description.toString()];
  }
  
  @override
  void initState() {
    super.initState();
    if (widget.isExtension) {
      isPolicyAccepted = true;
    }
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
        if (widget.isExtension) {
          Navigator.of(context).pop('Paid');
        } else {
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
        }
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
        if (widget.isExtension) {
          Navigator.of(context).pop('Paid');
        } else {
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
        }
        _isNavigating = false;
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
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    
    // Log de sécurité pour vérifier les données de politique d'annulation dans l'UI
    print('🛡️ [UI_POLICY_CHECK] Title: ${widget.itemDetails?.cancellationReasonTitle}');
    print('🛡️ [UI_POLICY_CHECK] CancellationReason: ${widget.itemDetails?.cancellationReason}');
    print('🛡️ [UI_POLICY_CHECK] Description: ${widget.itemDetails?.cancellationReasonDescription}');
    debugPrint('🛡️ [UI_POLICY_CHECK] Title: ${widget.itemDetails?.cancellationReasonTitle}');
    debugPrint('🛡️ [UI_POLICY_CHECK] CancellationReason: ${widget.itemDetails?.cancellationReason}');
    debugPrint('🛡️ [UI_POLICY_CHECK] Description count: ${widget.itemDetails?.cancellationReasonDescription?.length}');
    debugPrint('🛡️ [UI_POLICY_CHECK] itemDetails is null: ${widget.itemDetails == null}');
    
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
              // WebView avec blocage des interactions si la politique n'est pas acceptée
              IgnorePointer(
                ignoring: !isPolicyAccepted,
                child: Opacity(
                  opacity: isPolicyAccepted ? 1.0 : 0.5,
                  child: InAppWebView(
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
                  
                  // Sécuriser le bouton de paiement : bloquer la navigation si la politique n'est pas acceptée
                  // Vérifier si l'URL est une URL de soumission de paiement
                  if (!isPolicyAccepted && 
                      (url.contains("payment_success") || 
                       url.contains("payment_fail") || 
                       url.contains("submit") ||
                       url.contains("confirm") ||
                       url.contains("checkout"))) {
                    // Afficher un SnackBar pour informer l'utilisateur
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Veuillez accepter la politique d'annulation avant de continuer.".tr),
                        backgroundColor: Colors.orange,
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: "OK".tr,
                          textColor: Colors.white,
                          onPressed: () {
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          },
                        ),
                      ),
                    );
                    print('🔐 [VALIDATION] Tentative de paiement bloquée - Politique non acceptée');
                    debugPrint('🔐 [VALIDATION] Tentative de paiement bloquée - Politique non acceptée');
                    return NavigationActionPolicy.CANCEL;
                  }
                  
                  _handleNavigation(url);
                  return NavigationActionPolicy.ALLOW;
                },
                onReceivedError: (controller, request, error) {
                  debugPrint("WebView Error: ${error.description}");
                },
                  ),
                ),
              ),
              // Overlay pour bloquer l'interaction avec la WebView si la politique n'est pas acceptée
              if (!isPolicyAccepted)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.1),
                    child: Center(
                      child: Container(
                        margin: const EdgeInsets.all(20),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 48,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "Veuillez accepter la politique d'annulation pour continuer.".tr,
                              textAlign: TextAlign.center,
                              style: regular2(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (_isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
              // Bouton "Politique d'annulation" flottant avec Checkbox
              Positioned(
                bottom: 90, // Positionné au-dessus du bouton "Payer maintenant"
                left: 15,
                right: 15,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        // Ouvrir la modale de détails de la politique
                        String policy = widget.itemDetails?.cancellationReasonTitle ?? 
                                       widget.itemDetails?.cancellationReason ?? 
                                       'Non spécifiée';
                        print('✅ [FIX_CONFIRMED] Policy chargée: $policy');
                        debugPrint('✅ [FIX_CONFIRMED] Policy chargée: $policy');
                        
                        final rawDescription = widget.itemDetails?.cancellationReasonDescription ?? [];
                        final cancellationDescription = _normalizeCancellationDescription(rawDescription);
                        
                        rulesbuttomSheet(
                          context,
                          title: 'cancellation_policy_title'.tr,
                          list: cancellationDescription,
                          isCancellationPolicy: true,
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            // Checkbox bleu moderne
                            Checkbox(
                              value: isPolicyAccepted,
                              onChanged: (bool? value) {
                                setState(() {
                                  isPolicyAccepted = value ?? false;
                                  print('🔐 [VALIDATION] État de acceptation : $isPolicyAccepted');
                                  debugPrint('🔐 [VALIDATION] État de acceptation : $isPolicyAccepted');
                                });
                              },
                              activeColor: const Color(0xFF2B489A), // Le bleu du bouton
                              checkColor: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            // Texte de la politique
                            Expanded(
                              child: Builder(
                                builder: (context) {
                                  String policy = widget.itemDetails?.cancellationReasonTitle ?? 
                                                 widget.itemDetails?.cancellationReason ?? 
                                                 'Non spécifiée';
                                  return Text(
                                    policy,
                                    style: regular3(context).copyWith(
                                      color: getColorBasedOnActiveModuleid(),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Flèche pour ouvrir la modale
                            Icon(
                              Icons.arrow_forward_ios,
                              color: grey3,
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Bouton "Payer maintenant" en bas de l'écran
        bottomNavigationBar: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: notifires.getbgcolor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isPolicyAccepted
                    ? () {
                        // Déclencher le paiement dans la WebView
                        // Essayer de trouver et cliquer sur le bouton de paiement dans la page HTML
                        webViewController.evaluateJavascript(source: """
                          (function() {
                            // Chercher différents types de boutons de paiement
                            const paymentButtons = document.querySelectorAll(
                              'button[type="submit"], ' +
                              'input[type="submit"], ' +
                              'button:contains("Pay"), ' +
                              'button:contains("Payer"), ' +
                              'button:contains("Confirm"), ' +
                              'button:contains("Confirmer"), ' +
                              '.pay-button, ' +
                              '#pay-button, ' +
                              '[class*="pay"], ' +
                              '[id*="pay"]'
                            );
                            
                            // Essayer de trouver un formulaire et le soumettre
                            const forms = document.querySelectorAll('form');
                            if (forms.length > 0) {
                              forms[0].submit();
                              return 'Form submitted';
                            }
                            
                            // Si aucun formulaire, essayer de cliquer sur le premier bouton de soumission trouvé
                            if (paymentButtons.length > 0) {
                              paymentButtons[0].click();
                              return 'Button clicked';
                            }
                            
                            return 'No payment button found';
                          })();
                        """);
                        print('🔐 [VALIDATION] Tentative de paiement déclenchée');
                        debugPrint('🔐 [VALIDATION] Tentative de paiement déclenchée');
                      }
                    : () {
                        // Afficher un SnackBar si l'utilisateur essaie de payer sans accepter
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Veuillez accepter la politique d'annulation avant de continuer.".tr),
                            backgroundColor: Colors.orange,
                            duration: const Duration(seconds: 3),
                            action: SnackBarAction(
                              label: "OK".tr,
                              textColor: Colors.white,
                              onPressed: () {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                        print('🔐 [VALIDATION] Tentative de paiement bloquée - Politique non acceptée');
                        debugPrint('🔐 [VALIDATION] Tentative de paiement bloquée - Politique non acceptée');
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPolicyAccepted
                      ? const Color(0xFF2B489A) // Bleu quand activé
                      : Colors.grey, // Gris quand désactivé
                  disabledBackgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Payer maintenant".tr,
                  style: heading2(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
