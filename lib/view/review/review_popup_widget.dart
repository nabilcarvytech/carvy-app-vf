import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/booking_record_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/booking_model.dart' show Bookings;
import 'package:carvy/utils/theme_style.dart';

/// Bottom sheet d'avis depuis une notification [REVIEW_REQUEST] (legacy).
void showReviewRequestNotificationBottomSheet(
  BuildContext context,
  Map<String, dynamic> data,
) {
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
                  Text(
                    "Comment s'est passée votre location ?".tr,
                    style: heading2(context).copyWith(
                      color: notifires.getwhiteblackcolor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Évaluez votre expérience avec le vendeur.".tr,
                    style: regular2(context).copyWith(
                      color: notifires.getGrey2Whitecolor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildRatingCriterion(
                    context: context,
                    title: "Communication".tr,
                    rating: communicationRating,
                    onRatingUpdate: (rating) {
                      setState(() => communicationRating = rating);
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildRatingCriterion(
                    context: context,
                    title: "État du véhicule".tr,
                    rating: vehicleConditionRating,
                    onRatingUpdate: (rating) {
                      setState(() => vehicleConditionRating = rating);
                    },
                  ),
                  const SizedBox(height: 24),
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
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("Passer".tr),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (communicationRating == 0.0 ||
                                vehicleConditionRating == 0.0) {
                              showErrorToastMessage(
                                  "Veuillez évaluer tous les critères".tr);
                              return;
                            }
                            showLoading();
                            try {
                              final bookingId = Bookings.normalizeEntityId(
                                      data['booking_id']) ??
                                  '';
                              final vendorId = Bookings.normalizeEntityId(
                                      data['vendor_id']) ??
                                  '';
                              Bookings? bookingFromList;
                              if (Get.isRegistered<BookingRecordController>()) {
                                final brc = Get.find<BookingRecordController>();
                                for (final b in brc.bookingsList) {
                                  if (Bookings.normalizeEntityId(b.id) ==
                                      bookingId) {
                                    bookingFromList = b;
                                    break;
                                  }
                                }
                              }
                              final vehicleId =
                                  Bookings.resolveVehicleIdForReviewPayload(
                                data,
                                booking: bookingFromList,
                              );
                              if (vehicleId == null || vehicleId.isEmpty) {
                                closeLoading();
                                showErrorToastMessage(
                                  'Vehicle not found'.tr,
                                );
                                return;
                              }
                              final response = await httpPost(
                                Config.submitReview,
                                {
                                  'booking_id': bookingId,
                                  'vendor_id': vendorId,
                                  'vehicle_id': vehicleId,
                                  'vehicle_rating':
                                      vehicleConditionRating.round(),
                                  'agency_rating':
                                      communicationRating.round(),
                                  'comment': commentController.text.trim(),
                                },
                              );
                              closeLoading();
                              if (response != null &&
                                  response['status'] == 200) {
                                Navigator.pop(context);
                                showToastMessage(response['message'] ??
                                    "Merci pour votre avis !".tr);
                              } else {
                                showErrorToastMessage(
                                  response?['message'] ??
                                      response?['error'] ??
                                      "Une erreur est survenue".tr,
                                );
                              }
                            } catch (_) {
                              closeLoading();
                              showErrorToastMessage("Erreur de connexion".tr);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: vehicalThemColor,
                          ),
                          child: Text("Envoyer".tr),
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

/// Formulaire d'avis client (véhicule + agence) depuis l'historique des réservations.
void showClientBookingReviewBottomSheet(
  BuildContext context,
  Bookings booking, {
  VoidCallback? onReviewSubmitted,
}) {
  final bookingController = Get.find<BookingController>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) {
      return Obx(() {
        final isLoading = bookingController.isSubmittingReview.value;
        return Container(
          decoration: BoxDecoration(
            color: notifires.getbgcolor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: notifires.getGrey2Whitecolor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Rate your experience'.tr,
                  style: heading2(sheetContext).copyWith(
                    color: notifires.getwhiteblackcolor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Vehicle rating label'.tr,
                  style: regular2(sheetContext).copyWith(
                    fontWeight: FontWeight.w600,
                    color: notifires.getwhiteblackcolor,
                  ),
                ),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: bookingController.vehicleRating.value,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 36,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: vehicalThemColor,
                  ),
                  onRatingUpdate: (v) =>
                      bookingController.vehicleRating.value = v,
                ),
                const SizedBox(height: 20),
                Text(
                  'Agency rating label'.tr,
                  style: regular2(sheetContext).copyWith(
                    fontWeight: FontWeight.w600,
                    color: notifires.getwhiteblackcolor,
                  ),
                ),
                const SizedBox(height: 8),
                RatingBar.builder(
                  initialRating: bookingController.agencyRating.value,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: false,
                  itemCount: 5,
                  itemSize: 36,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: vehicalThemColor,
                  ),
                  onRatingUpdate: (v) =>
                      bookingController.agencyRating.value = v,
                ),
                const SizedBox(height: 20),
                Text(
                  "Commentaire (optionnel)".tr,
                  style: regular2(sheetContext).copyWith(
                    fontWeight: FontWeight.w500,
                    color: notifires.getwhiteblackcolor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: bookingController.reviewCommentController,
                  maxLines: 3,
                  style: regular2(sheetContext).copyWith(
                    color: notifires.getwhiteblackcolor,
                  ),
                  decoration: InputDecoration(
                    hintText: "Partagez votre expérience...".tr,
                    filled: true,
                    fillColor: notifires.getboxcolor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final ok = await bookingController
                                .submitClientReview(
                              booking,
                              onReviewSubmitted: onReviewSubmitted,
                            );
                            if (ok && sheetContext.mounted) {
                              Navigator.pop(sheetContext);
                              Get.snackbar(
                                'Success'.tr,
                                'Thank you for your review!'.tr,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.green.shade600,
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                duration: const Duration(seconds: 3),
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.white,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: vehicalThemColor,
                      disabledBackgroundColor:
                          vehicalThemColor.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Submit review button'.tr,
                            style: boldstyle(sheetContext).copyWith(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      });
    },
  );
}

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
          color: vehicalThemColor,
        ),
        onRatingUpdate: onRatingUpdate,
      ),
    ],
  );
}
