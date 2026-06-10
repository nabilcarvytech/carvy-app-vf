import 'package:flutter/material.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/services/api_service.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/safe_navigation.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/review/review_display_widgets.dart';
import 'package:carvy/work_space.dart';
import 'package:get/get.dart';

/// Profil client consultable par le vendeur (GET client-profile).
class ClientProfileScreen extends StatefulWidget {
  const ClientProfileScreen({super.key, required this.clientId});

  final String clientId;

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? profile;
  List<Map<String, dynamic>> reviews = [];

  static const String _defaultAvatar =
      'https://static.vecteezy.com/system/resources/thumbnails/009/734/564/small/default-avatar-profile-icon-of-social-media-user-vector.jpg';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.getClientProfile(widget.clientId);
      final status = response['status'] ?? response['statusCode'];
      if (status == 403 || status == '403') {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = 'Access denied'.tr;
          });
        }
        return;
      }

      if (response['error'] != null &&
          response['status'] != 200 &&
          response['status'] != '200') {
        if (mounted) {
          setState(() {
            isLoading = false;
            errorMessage = response['message']?.toString() ??
                response['error']?.toString() ??
                'Unable to load profile'.tr;
          });
        }
        return;
      }

      final parsed = ApiService.parseClientProfileData(response);
      if (mounted) {
        setState(() {
          profile = parsed;
          reviews = ApiService.parseClientReviewsList(response);
          isLoading = false;
          if (parsed == null) {
            errorMessage = 'Unable to load profile'.tr;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
          errorMessage = 'Unable to load profile'.tr;
        });
      }
    }
  }

  String _profileImageUrl(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.isEmpty) return '';
    if (v.startsWith('http://') || v.startsWith('https://')) return v;
    return Config.getFullImageUrl(v);
  }

  Widget _statColumn(
    BuildContext context, {
    required String value,
    required String label,
    bool highlight = false,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: boldstyle(context).copyWith(
            color: highlight
                ? getColorBasedOnActiveModuleid()
                : notifires.getGrey1Whitecolor,
            fontSize: 17,
          ),
        ),
        Text(
          label,
          style: regular2(context).copyWith(color: notifires.getGrey3Whitecolor),
        ),
      ],
    );
  }

  Widget _verifiedRow({
    required IconData icon,
    required String leftLabelKey,
    required String verifiedLabelKey,
    required String notVerifiedLabelKey,
    required bool verified,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        height: 53,
        padding: const EdgeInsets.only(left: 10, right: 10),
        decoration: BoxDecoration(
          color: notifires.getBoxColor,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: getColorBasedOnActiveModuleid()),
            const SizedBox(width: 7),
            Text(
              leftLabelKey.tr,
              style: appRegularText.copyWith(color: notifires.getwhiteblackcolor),
            ),
            const Spacer(),
            Text(
              verified ? verifiedLabelKey.tr : notVerifiedLabelKey.tr,
              style: appRegularText.copyWith(
                color: verified ? Colors.green : notifires.getGrey3Whitecolor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: getColorBasedOnActiveModuleid(),
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: regular2(context),
                    ),
                  ),
                )
              : _buildProfileContent(context),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    final data = profile ?? {};
    final name = (data['name'] as String?)?.trim().isNotEmpty == true
        ? data['name'] as String
        : 'Client'.tr;
    final imageUrl = _profileImageUrl(data['profileImage'] as String?);
    final rating = (data['rating'] as num?)?.toDouble() ?? 0.0;
    final totalReviews = (data['totalReviews'] as num?)?.toInt() ?? 0;
    final totalBookings = (data['totalBookings'] as num?)?.toInt() ?? 0;
    final bio = (data['bio'] as String?)?.trim() ?? '';
    final joinIn = (data['joinIn'] as String?)?.trim() ?? '';
    final verifiedEmail = data['verifiedEmail'] as bool?;
    final verifiedPhone = data['verifiedPhone'] as bool?;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  Container(
                    alignment: AlignmentDirectional.topStart,
                    height: 280,
                    width: double.maxFinite,
                    child: Container(
                      width: double.maxFinite,
                      height: 208,
                      decoration: BoxDecoration(
                        color: grey5,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 145,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 65,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(74),
                        child: myNetworkImageFillBox(
                          imageUrl.isNotEmpty ? imageUrl : _defaultAvatar,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                name,
                style: heading2Grey1(context),
                textAlign: TextAlign.center,
              ),
              if (joinIn.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  '${'joined_since'.tr} $joinIn',
                  style: regular2(context).copyWith(
                    color: getColorBasedOnActiveModuleid(),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _statColumn(
                    context,
                    value: totalBookings.toString(),
                    label: 'rentals_count'.tr,
                    highlight: true,
                  ),
                  _statColumn(
                    context,
                    value: rating.toStringAsFixed(1),
                    label: 'rating_label'.tr,
                  ),
                  _statColumn(
                    context,
                    value: totalReviews.toString(),
                    label: 'reviews_count'.tr,
                  ),
                ],
              ),
              if (bio.isNotEmpty) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: regular2(context),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              if (verifiedEmail != null)
                _verifiedRow(
                  icon: Icons.email_outlined,
                  leftLabelKey: 'email_label',
                  verifiedLabelKey: 'email_verified',
                  notVerifiedLabelKey: 'Email not verified',
                  verified: verifiedEmail,
                ),
              if (verifiedPhone != null)
                _verifiedRow(
                  icon: Icons.phone,
                  leftLabelKey: 'phone_label',
                  verifiedLabelKey: 'phone_verified',
                  notVerifiedLabelKey: 'Phone not verified',
                  verified: verifiedPhone,
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'reviews_details'.tr,
                      style: heading2Grey1(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (reviews.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No Review Available'.tr,
                          style: regular2(context).copyWith(
                            color: notifires.getGrey3Whitecolor,
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: reviews.length,
                        itemBuilder: (context, index) {
                          return buildVendorToClientReviewListTile(
                            context,
                            reviews[index],
                          );
                        },
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 60),
            ],
          ),
        ),
        Positioned(
          left: 0,
          top: 25,
          child: GestureDetector(
            onTap: () => safeGetBack(context: context),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 15,
                top: 8,
                bottom: 8,
                right: 20,
              ),
              child: PhysicalModel(
                color: Colors.transparent,
                shadowColor: notifires.getGrey4Whitecolor,
                elevation: 5,
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
        ),
      ],
    );
  }
}
