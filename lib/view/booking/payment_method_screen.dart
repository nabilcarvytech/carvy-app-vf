import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/model/booking_payment_method_model.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';
import 'package:carvy/api/config.dart';

class PaymentMethodScreen extends StatefulWidget {
  final String vehicleId;
  
  const PaymentMethodScreen({
    super.key,
    required this.vehicleId,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  BookingController bookingController = Get.find();

  @override
  void initState() {
    super.initState();
    // Charger les méthodes de paiement au démarrage
    bookingController.fetchPaymentMethods();
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
  double calculateFinalAmount(PaymentMethod method) {
    if (bookingController.getItemPrices?.data?.grossPrice == null) {
      return 0.0;
    }

    try {
      double basePrice = double.parse(
          bookingController.getItemPrices!.data!.grossPrice.toString());
      double feePercentage = method.feePercentage ?? 0.0;
      double feeAmount = basePrice * (feePercentage / 100);
      return basePrice + feeAmount;
    } catch (e) {
      debugPrint('❌ [calculateFinalAmount] Erreur: $e');
      return 0.0;
    }
  }

  // Formater le montant avec la devise
  String formatAmount(double amount) {
    final formatter = NumberFormat.currency(
      symbol: bookingController.currency.isNotEmpty
          ? bookingController.currency
          : '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifires.getbgcolor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 80,
        leading: GestureDetector(
          onTap: () => Get.back(),
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
          'Sélectionner une méthode de paiement'.tr,
          style: heading2Grey1(context),
        ),
      ),
      body: GetBuilder<BookingController>(
        builder: (controller) {
          // Vérification de l'UI - print au début du build
          print('🖥️ UI BUILD: controller.paymentMethodsList.length = ${controller.paymentMethodsList.length}');
          debugPrint('🖥️ UI BUILD: controller.paymentMethodsList.length = ${controller.paymentMethodsList.length}');
          
          // Utiliser Obx pour isLoadingPaymentMethods (observable)
          return Obx(() {
            if (controller.isLoadingPaymentMethods.value) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Diagnostic de visibilité - utiliser paymentMethodsList
            final paymentMethodsCount = controller.paymentMethodsList.length;
            // Validation UI : tester aussi avec le modèle directement
            final paymentMethodsCountFromModel = controller.paymentMethodModel?.data?.paymentMethods?.length ?? 0;
            debugPrint('🔍 COMPARAISON: paymentMethodsList.length = $paymentMethodsCount, paymentMethodModel.length = $paymentMethodsCountFromModel');
            print('🔍 COMPARAISON: paymentMethodsList.length = $paymentMethodsCount, paymentMethodModel.length = $paymentMethodsCountFromModel');
            
            // Si paymentMethodsList est vide mais le modèle contient des données, utiliser le modèle
            final finalPaymentMethods = paymentMethodsCount > 0 
                ? controller.paymentMethodsList 
                : (controller.paymentMethodModel?.data?.paymentMethods ?? []);
            final finalCount = paymentMethodsCount > 0 ? paymentMethodsCount : paymentMethodsCountFromModel;
            
            if (finalPaymentMethods.isEmpty) {
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
                      'Aucune méthode de paiement disponible'.tr,
                      style: heading2Grey1(context),
                    ),
                    const SizedBox(height: 8),
                    // Diagnostic de visibilité
                    Text(
                      'Nombre d\'éléments trouvés (List): $paymentMethodsCount',
                      style: regular3(context).copyWith(
                        color: notifires.getgreycolor,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      'Nombre d\'éléments trouvés (Model): $paymentMethodsCountFromModel',
                      style: regular3(context).copyWith(
                        color: notifires.getgreycolor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }

            // Utiliser controller.paymentMethodsList (liste synchronisée) ou le modèle en fallback
            debugPrint('📋 Nombre d\'éléments dans paymentMethodsList : ${controller.paymentMethodsList.length}');
            print('📋 Nombre d\'éléments dans paymentMethodsList : ${controller.paymentMethodsList.length}');
            debugPrint('📋 Nombre d\'éléments dans paymentMethodModel : ${controller.paymentMethodModel?.data?.paymentMethods?.length ?? 0}');
            print('📋 Nombre d\'éléments dans paymentMethodModel : ${controller.paymentMethodModel?.data?.paymentMethods?.length ?? 0}');

            // Forçage de reconstruction avec GetBuilder supplémentaire
            return GetBuilder<BookingController>(
              builder: (ctrl) {
                // Utiliser paymentMethodsList en priorité, sinon paymentMethodModel
                final methodsToDisplay = ctrl.paymentMethodsList.isNotEmpty 
                    ? ctrl.paymentMethodsList 
                    : (ctrl.paymentMethodModel?.data?.paymentMethods ?? []);
                
                // Vérification que le ListView.builder utilise bien la bonne source
                print('📋 ListView.builder: methodsToDisplay.length = ${methodsToDisplay.length}');
                debugPrint('📋 ListView.builder: methodsToDisplay.length = ${methodsToDisplay.length}');
                
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: methodsToDisplay.length,
                  itemBuilder: (context, index) {
                    final method = methodsToDisplay[index];
                
                    // Log pour diagnostic
                    print('Affichage de la méthode: ${method.name}');
                    debugPrint('📋 Affichage de la méthode: ${method.name} (index: $index)');
                
                final isSelected =
                    bookingController.selectedPaymentMethod?.id == method.id;
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
                      setState(() {
                        bookingController.selectedPaymentMethod = method;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // Logo à gauche
                          if (method.logoUrl != null &&
                              method.logoUrl!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                cleanImageUrl(method.logoUrl),
                                width: 60,
                                height: 60,
                                fit: BoxFit.contain,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    color: notifires.getboxcolor,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) {
                                  debugPrint('❌ Erreur chargement logo: $error');
                                  debugPrint('❌ URL tentée: ${cleanImageUrl(method.logoUrl)}');
                                  return Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: notifires.getboxcolor,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.payment,
                                      color: notifires.getgreycolor,
                                      size: 30,
                                    ),
                                  );
                                },
                              ),
                            )
                          else
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: notifires.getboxcolor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.payment,
                                color: notifires.getgreycolor,
                              ),
                            ),
                          const SizedBox(width: 16),
                          // Nom et description au centre
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  method.name ?? 'Méthode de paiement'.tr,
                                  style: heading2(context).copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (method.instructions != null &&
                                    method.instructions!.isNotEmpty)
                                  const SizedBox(height: 4),
                                if (method.instructions != null &&
                                    method.instructions!.isNotEmpty)
                                  Text(
                                    method.instructions!,
                                    style: regular3(context).copyWith(
                                      color: notifires.getgreycolor,
                                      fontSize: 12,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Montant final à droite
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatAmount(finalAmount),
                                style: heading2(context).copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: getColorBasedOnActiveModuleid(),
                                ),
                              ),
                              if (method.feePercentage != null &&
                                  method.feePercentage! > 0)
                                Text(
                                  '+${method.feePercentage}% frais'.tr,
                                  style: regular3(context).copyWith(
                                    color: notifires.getgreycolor,
                                    fontSize: 10,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          // Indicateur de sélection
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? getColorBasedOnActiveModuleid()
                                : notifires.getgreycolor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Encadré d'information pour Digital Wallet
                if (isSelected &&
                    isDigitalWallet &&
                    method.instructions != null &&
                    method.instructions!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: getColorBasedOnActiveModuleid().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: getColorBasedOnActiveModuleid().withOpacity(0.3),
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
                else if (index < methodsToDisplay.length - 1)
                  const SizedBox(height: 16),
              ],
            );
                  },
                );
              },
            );
          });
        },
      ),
      bottomNavigationBar: Obx(() {
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
                        // Appeler processBooking avec la méthode sélectionnée
                        bookingController.processBooking(
                          vehicleId: widget.vehicleId,
                          widgetVehicleId: widget.vehicleId,
                        );
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
                        'Confirmer le paiement'.tr,
                        style: heading2(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
