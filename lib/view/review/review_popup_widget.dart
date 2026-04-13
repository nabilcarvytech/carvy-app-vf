import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/utils/common_widget.dart';

/// Affiche un BottomSheet pour récolter un avis détaillé après une location
void showReviewBottomSheet(BuildContext context, Map<String, dynamic> data) {
  // Variables pour stocker les notes de chaque critère
  double communicationRating = 0.0;
  double vehicleConditionRating = 0.0;
  final TextEditingController commentController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext bottomSheetContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Container(
            decoration: BoxDecoration(
              color: notifires.getbgcolor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre principal
                  Text(
                    "Comment s'est passée votre location ?".tr,
                    style: heading2(context).copyWith(
                      color: notifires.getwhiteblackcolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  // Sous-titre
                  Text(
                    "Évaluez votre expérience avec le vendeur.".tr,
                    style: regular2(context).copyWith(
                      color: notifires.getGrey2Whitecolor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Critère 1 : Communication
                  _buildRatingCriterion(
                    context: context,
                    title: "Communication".tr,
                    rating: communicationRating,
                    onRatingUpdate: (rating) {
                      setState(() {
                        communicationRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  // Critère 2 : État du véhicule
                  _buildRatingCriterion(
                    context: context,
                    title: "État du véhicule".tr,
                    rating: vehicleConditionRating,
                    onRatingUpdate: (rating) {
                      setState(() {
                        vehicleConditionRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Champ de commentaire optionnel
                  Text(
                    "Commentaire (optionnel)".tr,
                    style: regular2(context).copyWith(
                      color: notifires.getwhiteblackcolor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: notifires.getblackwhitecolor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: notifires.getwhiteblackcolor.withOpacity(0.2),
                      ),
                    ),
                    child: TextField(
                      controller: commentController,
                      maxLines: 3,
                      style: regular2(context).copyWith(
                        color: notifires.getwhiteblackcolor,
                      ),
                      decoration: InputDecoration(
                        hintText: "Partagez votre expérience...".tr,
                        hintStyle: regular2(context).copyWith(
                          color: notifires.getGrey2Whitecolor,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Boutons en bas
                  Row(
                    children: [
                      // Bouton "Passer"
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: notifires.getBoxColor,
                              ),
                            ),
                          ),
                          child: Text(
                            "Passer".tr,
                            style: boldstyle(context).copyWith(
                              color: notifires.getwhiteblackcolor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Bouton "Envoyer"
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Validation : Vérifier que les notes sont renseignées
                            if (communicationRating == 0.0 || vehicleConditionRating == 0.0) {
                              showErrorToastMessage("Veuillez évaluer tous les critères".tr);
                              return;
                            }
                            
                            // Afficher un loader
                            showLoading();
                            
                            try {
                              // Préparer le payload pour l'API
                              Map<String, dynamic> body = {
                                "booking_id": data['booking_id']?.toString() ?? "",
                                "vendor_id": data['vendor_id']?.toString() ?? "",
                                "communication_rating": communicationRating.toInt(),
                                "vehicle_condition_rating": vehicleConditionRating.toInt(),
                                "comment": commentController.text.trim(),
                              };
                              
                              // ========== LOGS AVANT L'APPEL API ==========
                              print('📤 [REVIEW_API] ========================================');
                              print('📤 [REVIEW_API] Envoi de l\'avis vers l\'API');
                              print('📤 [REVIEW_API] URL: ${Config.baseurl}${Config.submitReview}');
                              print('📤 [REVIEW_API] Body JSON:');
                              print('   - booking_id: ${body["booking_id"]}');
                              print('   - vendor_id: ${body["vendor_id"]}');
                              print('   - communication_rating: ${body["communication_rating"]}');
                              print('   - vehicle_condition_rating: ${body["vehicle_condition_rating"]}');
                              print('   - comment: ${body["comment"]}');
                              print('📤 [REVIEW_API] ========================================');
                              
                              // Appel API
                              final response = await httpPost(Config.submitReview, body);
                              
                              // ========== LOGS APRÈS LA RÉPONSE ==========
                              print('📥 [REVIEW_API] ========================================');
                              print('📥 [REVIEW_API] Réponse reçue du serveur');
                              print('📥 [REVIEW_API] Type de réponse: ${response.runtimeType}');
                              
                              if (response != null) {
                                print('📥 [REVIEW_API] Status: ${response['status'] ?? 'N/A'}');
                                print('📥 [REVIEW_API] Message: ${response['message'] ?? 'N/A'}');
                                if (response['error'] != null) {
                                  print('📥 [REVIEW_API] Error: ${response['error']}');
                                }
                                if (response['data'] != null) {
                                  print('📥 [REVIEW_API] Data: ${response['data']}');
                                }
                                print('📥 [REVIEW_API] Réponse complète: $response');
                              } else {
                                print('⚠️ [REVIEW_API] Réponse NULL reçue !');
                              }
                              print('📥 [REVIEW_API] ========================================');
                              
                              // Fermer le loader
                              closeLoading();
                              
                              if (response != null && response['status'] == 200) {
                                // Fermer le BottomSheet
                                Navigator.pop(context);
                                // Afficher un message de succès
                                showToastMessage(response['message'] ?? "Merci pour votre avis !".tr);
                                print('✅ [REVIEW_API] Avis envoyé avec succès');
                                print('✅ [REVIEW_API] Message de succès: ${response['message']}');
                              } else {
                                // Afficher un message d'erreur
                                showErrorToastMessage(response?['message'] ?? response?['error'] ?? "Une erreur est survenue".tr);
                                print('❌ [REVIEW_API] Erreur lors de l\'envoi');
                                print('❌ [REVIEW_API] Status reçu: ${response?['status']}');
                                print('❌ [REVIEW_API] Message d\'erreur: ${response?['message'] ?? response?['error']}');
                              }
                            } catch (e, stackTrace) {
                              // Fermer le loader en cas d'erreur
                              closeLoading();
                              // Afficher un message d'erreur
                              showErrorToastMessage("Erreur de connexion".tr);
                              print('❌ [REVIEW_API] ========================================');
                              print('❌ [REVIEW_API] Exception lors de l\'envoi');
                              print('❌ [REVIEW_API] Type d\'erreur: ${e.runtimeType}');
                              print('❌ [REVIEW_API] Message: $e');
                              print('❌ [REVIEW_API] StackTrace: $stackTrace');
                              print('❌ [REVIEW_API] ========================================');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: getColorBasedOnActiveModuleid(),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "Envoyer".tr,
                            style: boldstyle(context).copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Widget réutilisable pour un critère d'évaluation avec étoiles
Widget _buildRatingCriterion({
  required BuildContext context,
  required String title,
  required double rating,
  required Function(double) onRatingUpdate,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: regular2(context).copyWith(
          color: notifires.getwhiteblackcolor,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8),
      RatingBar.builder(
        initialRating: rating,
        minRating: 1,
        direction: Axis.horizontal,
        allowHalfRating: false,
        itemCount: 5,
        itemSize: 32,
        itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
        itemBuilder: (context, _) => Icon(
          Icons.star,
          color: getColorBasedOnActiveModuleid(),
        ),
        onRatingUpdate: onRatingUpdate,
      ),
    ],
  );
}
