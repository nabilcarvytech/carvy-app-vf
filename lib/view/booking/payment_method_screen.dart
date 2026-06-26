import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/payment_controller.dart';
import 'package:carvy/model/booking_payment_method_model.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/navigation_guard.dart';
import 'package:carvy/utils/payment_flow_debug.dart';
import 'package:carvy/utils/render_debug.dart';
import 'package:carvy/utils/safe_navigation.dart';
import 'package:carvy/utils/safe_rebuild.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';
import 'package:carvy/api/config.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String vehicleId;
  final bool isExtension;

  const PaymentMethodScreen({
    super.key,
    required this.vehicleId,
    this.isExtension = false,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  BookingController bookingController = Get.find();
  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    bookingController.detachPaymentMethodUi();
    bookingController.prepareForRoutePop();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<PaymentController>()) {
      Get.put(PaymentController());
    }
    bookingController.attachPaymentMethodUi();
    runAfterFirstFrame(() {
      if (_disposed || !mounted) return;
      bookingController.fetchPaymentMethods();
      if (!widget.isExtension &&
          bookingController.extensionPaymentContext != null) {
        bookingController.setExtensionPaymentContext(null);
      }
    });
  }

  // Fonction pour nettoyer les URLs (utilise Config.baseurl au lieu d'URLs en dur)
  String cleanImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    
    // Utiliser l'URL de base depuis Config au lieu d'URLs en dur
    String finalUrl = url;
    
    // Si l'URL commence par /uploads, construire l'URL complète depuis Config
    if (finalUrl.startsWith('/uploads') || finalUrl.startsWith('/api/')) {
      // Extraire le domaine de baseurl (sans /api/v1/)
      final baseDomain = Config.baseurl.replaceAll('/api/v1/', '');
      finalUrl = '$baseDomain$finalUrl';
    }
    
    // S'assurer que l'URL a un protocole
    if (!finalUrl.startsWith('http://') && !finalUrl.startsWith('https://')) {
      finalUrl = 'http://$finalUrl';
    }
    
    return finalUrl;
  }

  // Calculer le montant final avec les frais de gestion
  double _checkoutBaseAmount() {
    if (widget.isExtension) {
      return bookingController.extensionCheckoutBaseAmount();
    }
    if (bookingController.getItemPrices?.data?.grossPrice == null) {
      return 0.0;
    }
    try {
      return double.parse(
          bookingController.getItemPrices!.data!.grossPrice.toString());
    } catch (e) {
      return 0.0;
    }
  }

  double calculateFinalAmount(PaymentMethod method) {
    final basePrice = _checkoutBaseAmount();
    if (basePrice <= 0) return 0.0;
    try {
      double feePercentage = method.feePercentage ?? 0.0;
      double feeAmount = basePrice * (feePercentage / 100);
      return basePrice + feeAmount;
    } catch (e) {
      debugPrint('❌ [calculateFinalAmount] Erreur: $e');
      return 0.0;
    }
  }

  /// Libellé localisé pour les noms renvoyés par l'API (Espèce, PayPal, etc.).
  String _localizedPaymentMethodName(String? rawName) {
    final normalized = (rawName ?? '').trim().toLowerCase();
    if (normalized.isEmpty) {
      return 'payment_method_default'.tr;
    }
    if (normalized.contains('paypal')) {
      return 'paypal_payment'.tr;
    }
    if (normalized.contains('esp') ||
        normalized.contains('cash') ||
        normalized.contains('espèce') ||
        normalized.contains('espece') ||
        normalized.contains('espèces')) {
      return 'cash_payment'.tr;
    }
    if (normalized.contains('stripe') || normalized.contains('card')) {
      return 'card_payment'.tr;
    }
    return rawName!.trim();
  }

  // Formater le montant avec la devise
  String formatAmount(double amount) {
    final currencySymbol = widget.isExtension
        ? (bookingController.extensionPaymentContext?.currency ??
            bookingController.currency)
        : bookingController.currency;
    final formatter = NumberFormat.currency(
      symbol: currencySymbol.isNotEmpty ? currencySymbol : '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  Widget _buildExtensionSummary(BuildContext context) {
    final ctx = bookingController.extensionPaymentContext;
    if (ctx == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notifires.getBoxColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: notifires.getGrey6Whitecolor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Extension of @days days'.trParams({'days': '${ctx.extraDays}'}),
            style: boldstyle(context).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'extension_added_period'.trParams({
              'from': ctx.oldEndLabel,
              'to': ctx.newEndLabel,
            }),
            style: regular2(context),
          ),
          if (ctx.startLabel != null && ctx.startLabel!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'extension_total_rental_period'.trParams({
                'from': ctx.startLabel!,
                'to': ctx.newEndLabel,
              }),
              style: regular3(context).copyWith(
                color: notifires.getGrey2Whitecolor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        safePopRoute(context);
      },
      child: Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifires.getbgcolor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 80,
        leading: GestureDetector(
          onTap: () => safePopRoute(context),
          child: Padding(
            padding:
                const EdgeInsets.only(left: 20, top: 8, bottom: 8, right: 20),
            child: PhysicalModel(
              color: Colors.transparent,
              shadowColor: notifires.getGrey4Whitecolor,
              elevation: 1.0,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                alignment: Alignment.center,
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: notifires.getboxcolor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: getColorBasedOnActiveModuleid(),
                ),
              ),
            ),
          ),
        ),
        title: Text(
          widget.isExtension
              ? 'extension_checkout_title'.tr
              : 'select_payment_method'.tr,
          style: heading2Grey1(context),
        ),
      ),
      body: GetBuilder<BookingController>(
        id: BookingController.paymentMethodBodyId,
        builder: (controller) {
          if (_disposed || !mounted || !context.mounted) {
            return const SizedBox.shrink();
          }
          if (NavigationGuard.isNavigating) {
            return const SizedBox.shrink();
          }
          renderDebugLog('GetBuilder avec ID: payment_method_body');
          if (controller.isLoadingPaymentMethods.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final methodsToDisplay = controller.paymentMethodsList;

          if (methodsToDisplay.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payment_outlined,
                    size: 64,
                    color: notifires.getgreycolor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'no_payment_methods_available'.tr,
                    style: heading2Grey1(context),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount:
                methodsToDisplay.length + (widget.isExtension ? 1 : 0),
            itemBuilder: (context, index) {
              if (widget.isExtension && index == 0) {
                return _buildExtensionSummary(context);
              }
              final methodIndex = widget.isExtension ? index - 1 : index;
              final method = methodsToDisplay[methodIndex];

              final isSelected =
                  controller.selectedPaymentMethod?.id == method.id;
              final finalAmount = calculateFinalAmount(method);
              final isDigitalWallet =
                  method.type?.toLowerCase() == 'digital wallet';

              return Column(
                children: [
                  Card(
                    elevation: isSelected ? 4 : 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? getColorBasedOnActiveModuleid()
                            : Colors.transparent,
                        width: isSelected ? 2 : 0,
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        controller.selectedPaymentMethod = method;
                        controller.notifyPaymentMethodBody();
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (method.logoUrl != null &&
                                method.logoUrl!.isNotEmpty)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  cleanImageUrl(method.logoUrl),
                                  width: 52,
                                  height: 52,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    }
                                    return SizedBox(
                                      width: 52,
                                      height: 52,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return SizedBox(
                                      width: 52,
                                      height: 52,
                                      child: Icon(
                                        Icons.payment,
                                        color: notifires.getgreycolor,
                                        size: 28,
                                      ),
                                    );
                                  },
                                ),
                              )
                            else
                              SizedBox(
                                width: 52,
                                height: 52,
                                child: Icon(
                                  Icons.payment,
                                  color: notifires.getgreycolor,
                                  size: 28,
                                ),
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      _localizedPaymentMethodName(method.name),
                                      style: heading2(context).copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (method.instructions != null &&
                                      method.instructions!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      method.instructions!,
                                      style: regular3(context).copyWith(
                                        color: notifires.getgreycolor,
                                        fontSize: 11,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatAmount(finalAmount),
                                  style: heading2(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: getColorBasedOnActiveModuleid(),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (method.feePercentage != null &&
                                    method.feePercentage! > 0)
                                  Text(
                                    '+${method.feePercentage}% ${'fees_label'.tr}',
                                    style: regular3(context).copyWith(
                                      color: notifires.getgreycolor,
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              size: 22,
                              color: isSelected
                                  ? getColorBasedOnActiveModuleid()
                                  : notifires.getgreycolor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (isSelected &&
                      isDigitalWallet &&
                      method.instructions != null &&
                      method.instructions!.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            getColorBasedOnActiveModuleid().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: getColorBasedOnActiveModuleid()
                              .withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: getColorBasedOnActiveModuleid(),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              method.instructions!,
                              style: regular3(context).copyWith(
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (methodIndex < methodsToDisplay.length - 1)
                    const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: MountedSafeObx(
        builder: () {
        final isLoading = bookingController.isProcessingBooking.value;
        return Container(
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
          child: SafeArea(
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (bookingController.selectedPaymentMethod == null ||
                        isLoading)
                    ? null
                    : () {
                        paymentFlowLog('STEP 0 — Confirm payment button TAP',
                            'extension=${widget.isExtension}, method=${bookingController.selectedPaymentMethod?.name}');
                        if (widget.isExtension) {
                          paymentFlowLog(
                              'STEP 0 — calling processExtensionPayment');
                          bookingController.processExtensionPayment();
                        } else {
                          paymentFlowLog('STEP 0 — calling processBooking',
                              'vehicleId=${widget.vehicleId}');
                          bookingController.processBooking(
                            vehicleId: widget.vehicleId,
                            widgetVehicleId: widget.vehicleId,
                          );
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: getColorBasedOnActiveModuleid(),
                  disabledBackgroundColor: notifires.getgreycolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'confirm_payment'.tr,
                        style: heading2(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
      ),
    ),
    );
  }
}
