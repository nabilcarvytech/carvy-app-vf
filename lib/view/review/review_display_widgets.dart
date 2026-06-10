import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/model/review_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/work_space.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';

/// Liste verticale des avis véhicule (note = [ReviewRatings.vehicleRatingFromJson]).
Widget buildVehicleReviewListTile(
  BuildContext context,
  Map<String, dynamic> review, {
  bool compactMessage = false,
}) {
  final rating = ReviewRatings.vehicleRatingFromJson(review);
  final guestName =
      review['guest_name']?.toString() ?? review['client']?['name']?.toString() ?? 'Guest'.tr;
  final guestImage = review['guest_profile_image'] ??
      review['guest_image'] ??
      review['client']?['profile_picture'];
  final message = review['message']?.toString() ?? review['comment']?.toString() ?? '';
  final date = review['updated_at']?.toString() ??
      review['created_at']?.toString() ??
      '';

  String displayMessage = message;
  if (compactMessage && message.length > 120) {
    displayMessage = '${message.substring(0, 120)}...';
  }

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: SizedBox(
            height: 48,
            width: 48,
            child: guestImage != null && guestImage.toString().isNotEmpty
                ? myNetworkImage(guestImage.toString(), true)
                : Container(
                    color: Colors.grey[200],
                    child: Icon(Icons.person, color: Colors.grey[600]),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(guestName, style: heading3Grey1(context)),
              const SizedBox(height: 4),
              Row(
                children: [
                  _readOnlyStars(rating),
                  const Spacer(),
                  if (date.isNotEmpty)
                    Flexible(
                      child: Text(
                        date,
                        style: regular(context),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
              if (displayMessage.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(displayMessage, style: regular2(context)),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

/// Liste verticale des avis agence (note = [ReviewRatings.agencyRatingFromJson]).
Widget buildAgencyReviewListTile(
  BuildContext context,
  Map<String, dynamic> review,
) {
  final rating = ReviewRatings.agencyRatingFromJson(review);
  final client = review['client'] as Map<String, dynamic>?;
  final clientName = client?['name']?.toString() ?? 'Client'.tr;
  final clientImage = client?['profile_picture'];
  final comment = review['comment']?.toString() ?? review['message']?.toString() ?? '';
  final createdAt = review['created_at']?.toString() ?? '';

  String formattedDate = createdAt;
  try {
    if (createdAt.isNotEmpty) {
      final date = DateTime.parse(createdAt).toLocal();
      formattedDate = '${date.day}/${date.month}/${date.year}';
    }
  } catch (_) {}

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifires.getBoxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: notifires.getGrey3Whitecolor,
                backgroundImage: clientImage != null && clientImage.toString().isNotEmpty
                    ? NetworkImage(clientImage.toString())
                    : null,
                child: clientImage == null || clientImage.toString().isEmpty
                    ? Icon(Icons.person, color: notifires.getwhiteblackcolor, size: 22)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(clientName, style: boldstyle(context)),
                    if (formattedDate.isNotEmpty)
                      Text(
                        formattedDate,
                        style: regular2(context).copyWith(
                          color: notifires.getGrey3Whitecolor,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              _readOnlyStars(rating, itemSize: 18),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(comment, style: regular2(context)),
          ],
        ],
      ),
    ),
  );
}

/// Avis laissé par un vendeur sur un client (profil client).
Widget buildVendorToClientReviewListTile(
  BuildContext context,
  Map<String, dynamic> review,
) {
  final rating = ReviewRatings.parseNumeric(
    review['rating'] ??
        review['vendor_rating'] ??
        review['average_rating'],
  );
  final vendorName = review['vendor_name']?.toString() ??
      review['vendorName']?.toString() ??
      review['host_name']?.toString() ??
      review['hostName']?.toString() ??
      'Vendor'.tr;
  final comment = review['comment']?.toString() ??
      review['message']?.toString() ??
      review['review']?.toString() ??
      '';
  final createdAt = review['created_at']?.toString() ??
      review['updated_at']?.toString() ??
      review['date']?.toString() ??
      '';

  String formattedDate = createdAt;
  try {
    if (createdAt.isNotEmpty) {
      final date = DateTime.parse(createdAt).toLocal();
      formattedDate = '${date.day}/${date.month}/${date.year}';
    }
  } catch (_) {}

  return Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: notifires.getBoxColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: notifires.getGrey3Whitecolor,
                child: Icon(
                  Icons.storefront_outlined,
                  color: notifires.getwhiteblackcolor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vendorName, style: boldstyle(context)),
                    if (formattedDate.isNotEmpty)
                      Text(
                        formattedDate,
                        style: regular2(context).copyWith(
                          color: notifires.getGrey3Whitecolor,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              _readOnlyStars(rating, itemSize: 18),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(comment, style: regular2(context)),
          ],
        ],
      ),
    ),
  );
}

Widget _readOnlyStars(double rating, {double itemSize = 20}) {
  return RatingBar.builder(
    initialRating: rating,
    minRating: 0,
    itemSize: itemSize,
    ignoreGestures: true,
    direction: Axis.horizontal,
    itemCount: 5,
    itemPadding: const EdgeInsets.symmetric(horizontal: 0),
    itemBuilder: (context, _) => Icon(
      Icons.star,
      color: getColorBasedOnActiveModuleid(),
    ),
    onRatingUpdate: (_) {},
  );
}

void _showReviewsBottomSheet({
  required BuildContext sheetContext,
  required String title,
  required Widget child,
}) {
  Get.bottomSheet(
    SafeArea(
      child: Container(
        constraints: BoxConstraints(maxHeight: Get.height * 0.85),
        decoration: BoxDecoration(
          color: notifires.getbgcolor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: notifires.getGrey3Whitecolor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: heading2(sheetContext),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: notifires.getwhiteblackcolor),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Flexible(child: child),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

void showAllVehicleReviewsBottomSheet(
  BuildContext context, {
  required List<dynamic> reviews,
  String? vehicleTitle,
}) {
  final maps = reviews.map(ReviewRatings.asMap).toList();
  _showReviewsBottomSheet(
    sheetContext: context,
    title: '${'Review'.tr}${vehicleTitle != null ? ' — $vehicleTitle' : ''}',
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: maps
          .map((r) => buildVehicleReviewListTile(context, r))
          .toList(),
    ),
  );
}

void showAllAgencyReviewsBottomSheet(
  BuildContext context, {
  required List<Map<String, dynamic>> reviews,
  String? agencyName,
}) {
  _showReviewsBottomSheet(
    sheetContext: context,
    title: '${'Commentaires'.tr}${agencyName != null ? ' — $agencyName' : ''}',
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: reviews
          .map((r) => buildAgencyReviewListTile(context, r))
          .toList(),
    ),
  );
}

/// Bouton discret « Afficher tout » si plus de [previewCount] avis.
Widget buildViewAllReviewsButton({
  required int totalCount,
  int previewCount = 2,
  required VoidCallback onTap,
}) {
  if (totalCount <= previewCount) return const SizedBox.shrink();
  return Align(
    alignment: Alignment.center,
    child: TextButton(
      onPressed: onTap,
      child: Text(
        'view_all'.tr,
        style: TextStyle(
          color: getColorBasedOnActiveModuleid(),
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}
