import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/model/review_model.dart';
import 'package:carvy/view/myaccount/publicProfile/public_profile_review_screen.dart';
import 'package:carvy/view/review/review_display_widgets.dart';
import 'package:carvy/work_space.dart';
import '../../../controller/publix_profile_controller.dart';
import '../../../../customwidget/see_image_full_screen.dart';
import '../../../../utils/common_widget.dart';
import '../../../customwidget/shimmer_widgets.dart';
import '../../home/recommendation_screen.dart';

class PublicProfile extends StatefulWidget {
  final String? userid;
  final String? userName;
  final String? photo;
  final String? profileImage;
  const PublicProfile({
    super.key,
    this.userid,
    this.userName,
    this.photo,
    this.profileImage,
  });

  @override
  State<PublicProfile> createState() => _PublicProfileState();
}

class _PublicProfileState extends State<PublicProfile> {
  final PublicProfileController publicProfileController = Get.find();
  int pageValue = 0;

  @override
  void initState() {
    super.initState();
    // Charger les données du profil au démarrage
    if (widget.userid != null && widget.userid!.isNotEmpty) {
      publicProfileController.getDataPublicProfile(widget.userid);
    }
  }

  stateSetter(fn) => setState(() {});

  void _navigateToVendorListings() {
    final name = publicProfileController.getUserProfile?.data?.name ??
        widget.userName ??
        '';
    Get.to(
      () => RecommendationScreen(
        comefromprofilepage: true,
        agencyName: name,
        locationId: "-1",
        userId: widget.userid,
        itemList: publicProfileController.getUserItems?.data?.items,
      ),
      transition: Transition.fadeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          body: GetBuilder<PublicProfileController>(
            builder: (controller) {
              if (controller.isLoading.isTrue) {
                return publicProfileScreenShimmer();
              } else {
                // Vérifier si les données sont disponibles, sinon afficher un message d'erreur
                if (controller.getUserProfile == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: notifires.getGrey3Whitecolor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Erreur de chargement".tr,
                            style: heading2(context),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Impossible de charger le profil. Veuillez réessayer.".tr,
                            style: regular2(context).copyWith(
                              color: notifires.getGrey3Whitecolor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              // Réessayer le chargement
                              controller.getDataPublicProfile(widget.userid);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: getColorBasedOnActiveModuleid(),
                            ),
                            child: Text("Réessayer".tr),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return publicProfile(context, controller);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget publicProfile(
      BuildContext context, PublicProfileController controller) {
    String userName = publicProfileController.getUserProfile?.data?.name ??
        'Name Not Available'.tr;
    String? profileImageUrl = widget.profileImage;

    String defaultImageAsset =
        "https://static.vecteezy.com/system/resources/thumbnails/009/734/564/small/default-avatar-profile-icon-of-social-media-user-vector.jpg";
    return Align(
        alignment: Alignment.center,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          body: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                                      bottomRight: Radius.circular(24))),
                              child: ClipRRect(
                                  borderRadius: const BorderRadius.only(
                                      bottomLeft: Radius.circular(24),
                                      bottomRight: Radius.circular(24)),
                                  child: myNetworkImageFillBox(widget.photo)),
                            ),
                          ),
                          Positioned(
                              left: 0,
                              right: 0,
                              top: 145,
                              child: GestureDetector(
                                onTap: () {
                                  if (profileImageUrl != null) {
                                    Get.to(() => SeeImageFullScreen(
                                        image: profileImageUrl));
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 65,
                                  child: ClipRRect(
                                      borderRadius: BorderRadius.circular(74),
                                      child: myNetworkImageFillBox(
                                          profileImageUrl ??
                                              defaultImageAsset)),
                                ),
                              ))
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: heading2Grey1(context),
                                  textAlign: TextAlign.center,
                                ),
                                publicProfileController
                                            .getUserProfile?.data?.liveCity
                                            .toString() ==
                                        ""
                                    ? const SizedBox()
                                    : Text(
                                        ("Live in".tr +
                                                (publicProfileController
                                                        .getUserProfile
                                                        ?.data
                                                        ?.liveCity ??
                                                    ''))
                                            .tr,
                                        style: regular(context).copyWith(
                                            color:
                                                notifires.getGrey3Whitecolor),
                                      ),
                                Text(
                                  ("${"language".tr} ${publicProfileController.getUserProfile?.data?.languages ?? ''}")
                                      .tr,
                                  style: regular(context).copyWith(
                                      color: notifires.getGrey3Whitecolor),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Compteur : Avis (non cliquable — chiffre en gris)
                            Obx(() => Column(
                              children: [
                                Text(
                                  publicProfileController.totalReviews.value.toString(),
                                  style: boldstyle(context).copyWith(
                                      color: notifires.getGrey1Whitecolor,
                                      fontSize: 17),
                                ),
                                Text(
                                  'reviews_count'.tr,
                                  style: regular2(context).copyWith(
                                      color: notifires.getGrey3Whitecolor),
                                ),
                              ],
                            )),
                            // Compteur : nombre de véhicules (tap → RecommendationScreen)
                            InkWell(
                              onTap: _navigateToVendorListings,
                              borderRadius: BorderRadius.circular(8),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Column(
                                  children: [
                                    Text(
                                      publicProfileController
                                              .getUserItems
                                              ?.data
                                              ?.items
                                              ?.length
                                              .toString() ??
                                          '0',
                                      style: boldstyle(context).copyWith(
                                          color:
                                              getColorBasedOnActiveModuleid(),
                                          fontSize: 17,
                                        ),
                                    ),
                                    Text(
                                      'vehicles_count'.tr,
                                      style: regular2(context).copyWith(
                                          color:
                                              notifires.getGrey3Whitecolor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Compteur : Évaluation globale (non cliquable — gris)
                            Obx(() => Column(
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      publicProfileController.globalAverage.value.toStringAsFixed(1),
                                      style: boldstyle(context).copyWith(
                                          color: notifires.getGrey1Whitecolor,
                                          fontSize: 17),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.star,
                                      size: 16,
                                      color: notifires.getGrey3Whitecolor,
                                    ),
                                  ],
                                ),
                                Text(
                                  'rating_label'.tr,
                                  style: regular2(context).copyWith(
                                      color: notifires.getGrey3Whitecolor),
                                ),
                              ],
                            )),
                          ],
                        ),
                      ),
                      publicProfileController.isLoading.value
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 20),
                              child: Text(
                                textAlign: TextAlign.center,
                                "${publicProfileController.getUserProfile?.data?.introText}",
                                style: regular2(context).copyWith(),
                              ),
                            ),
                      const SizedBox(
                        height: 8,
                      ),
                      publicProfileController.getUserProfile?.data?.joinIn
                                  .toString() ==
                              ""
                          ? const SizedBox()
                          : Text(
                              "${'joined_since'.tr} ${publicProfileController.getUserProfile?.data?.joinIn ?? ""}",
                              style: regular2(context).copyWith(
                                  color: getColorBasedOnActiveModuleid()),
                            ),
                      const SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Container(
                          height: 53,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              color: notifires.getBoxColor,
                              borderRadius: BorderRadius.circular(13)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.email_outlined,
                                size: 30,
                                color: getColorBasedOnActiveModuleid(),
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Text(
                                'email_label'.tr,
                                style: appRegularText.copyWith(
                                    color: notifires.getwhiteblackcolor),
                              ),
                              const Spacer(),
                              Text(
                                publicProfileController.getUserProfile?.data
                                            ?.verifiedEmail ==
                                        "0"
                                    ? "Email not verified".tr
                                    : 'email_verified'.tr,
                                style: appRegularText.copyWith(
                                  color: publicProfileController
                                              .getUserProfile
                                              ?.data
                                              ?.verifiedEmail ==
                                          "0"
                                      ? notifires.getGrey3Whitecolor
                                      : Colors.green,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Container(
                          height: 53,
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          decoration: BoxDecoration(
                              color: notifires.getBoxColor,
                              borderRadius: BorderRadius.circular(13)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.phone,
                                size: 30,
                                color: getColorBasedOnActiveModuleid(),
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              Text(
                                'phone_label'.tr,
                                style: appRegularText.copyWith(
                                    color: notifires.getwhiteblackcolor),
                              ),
                              const Spacer(),
                              Text(
                                publicProfileController.getUserProfile?.data
                                            ?.verifiedPhone ==
                                        "0"
                                    ? "Phone not verified".tr
                                    : 'phone_verified'.tr,
                                style: appRegularText.copyWith(
                                  color: publicProfileController
                                              .getUserProfile
                                              ?.data
                                              ?.verifiedPhone ==
                                          "0"
                                      ? notifires.getGrey3Whitecolor
                                      : Colors.green,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // ========== SECTION : Détails des évaluations ==========
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
                            Obx(() {
                              if (publicProfileController.isLoadingReviews.value) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              
                              if (publicProfileController.criteriaAverages.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "Aucune évaluation disponible".tr,
                                    style: regular2(context).copyWith(
                                      color: notifires.getGrey3Whitecolor,
                                    ),
                                  ),
                                );
                              }
                              
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: publicProfileController.criteriaAverages.length,
                                itemBuilder: (context, index) {
                                  final key = publicProfileController.criteriaAverages.keys.elementAt(index);
                                  final rating = publicProfileController.criteriaAverages[key] ?? 0.0;
                                  
                                  // Traduire la clé pour l'affichage
                                  String displayName = key;
                                  if (key == 'communication_rating') {
                                    displayName = "Communication".tr;
                                  } else if (key == 'vehicle_condition_rating') {
                                    displayName = "État du véhicule".tr;
                                  } else {
                                    // Capitaliser la première lettre et remplacer les underscores
                                    displayName = key
                                        .replaceAll('_', ' ')
                                        .split(' ')
                                        .map((word) => word.isEmpty 
                                            ? '' 
                                            : word[0].toUpperCase() + word.substring(1))
                                        .join(' ');
                                  }
                                  
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              displayName,
                                              style: regular2(context).copyWith(
                                                color: notifires.getwhiteblackcolor,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  rating.toStringAsFixed(1),
                                                  style: boldstyle(context).copyWith(
                                                    color: getColorBasedOnActiveModuleid(),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                                Icon(
                                                  Icons.star,
                                                  size: 16,
                                                  color: getColorBasedOnActiveModuleid(),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        LinearProgressIndicator(
                                          value: rating / 5.0,
                                          backgroundColor: notifires.getBoxColor,
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            getColorBasedOnActiveModuleid(),
                                          ),
                                          minHeight: 8,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      // ========== SECTION : Commentaires ==========
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'comments_label'.tr,
                              style: heading2Grey1(context).copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Obx(() {
                              if (publicProfileController.isLoadingReviews.value) {
                                return const SizedBox();
                              }
                              
                              if (publicProfileController.reviewsList.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(20.0),
                                  child: Text(
                                    "Aucun commentaire disponible".tr,
                                    style: regular2(context).copyWith(
                                      color: notifires.getGrey3Whitecolor,
                                    ),
                                  ),
                                );
                              }
                              
                              final allReviews =
                                  publicProfileController.reviewsList;
                              final previewReviews = allReviews.length > 2
                                  ? allReviews.take(2).toList()
                                  : allReviews;
                              final agencyName = publicProfileController
                                  .getUserProfile?.data?.name;

                              return Column(
                                children: [
                                  ...previewReviews.map((raw) {
                                    final review =
                                        ReviewRatings.asMap(raw);
                                    return buildAgencyReviewListTile(
                                      context,
                                      review,
                                    );
                                  }),
                                  buildViewAllReviewsButton(
                                    totalCount: allReviews.length,
                                    onTap: () => showAllAgencyReviewsBottomSheet(
                                      context,
                                      reviews: List<Map<String, dynamic>>.from(
                                          allReviews),
                                      agencyName: agencyName,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      // ========== SECTION : Ancienne section Reviews (pour compatibilité) ==========
                      publicProfileController.getVendorItemsReviews?.data ==
                              null
                          ? const SizedBox()
                          : publicProfileController
                                  .getVendorItemsReviews!.data!.reviews!.isEmpty
                              ? const SizedBox()
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Reviews".tr,
                                        style:
                                            heading2Grey1(context).copyWith(),
                                      ),
                                      const Spacer(),
                                      InkWell(
                                        onTap: () {
                                          if (webPlateForm) {
                                            Get.toNamed(
                                                WebRoutes
                                                    .publicProfileReviewScreen,
                                                arguments: {
                                                  "userId":
                                                      widget.userid.toString(),
                                                  "name":
                                                      publicProfileController
                                                          .getUserProfile!
                                                          .data!
                                                          .name!,
                                                });
                                          } else {
                                            Get.to(() =>
                                                PublicProfileReviewScreen(
                                                  userId:
                                                      widget.userid.toString(),
                                                  name: publicProfileController
                                                      .getUserProfile!
                                                      .data!
                                                      .name!,
                                                ));
                                          }
                                        },
                                        child: Text(
                                          "View All Review".tr,
                                          style: regular2(context).copyWith(
                                              color:
                                                  getColorBasedOnActiveModuleid()),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                      const SizedBox(
                        height: 5,
                      ),
                      publicProfileController.getVendorItemsReviews?.data ==
                              null
                          ? const SizedBox()
                          : publicProfileController
                                  .getVendorItemsReviews!.data!.reviews!.isEmpty
                              ? const SizedBox()
                              : SizedBox(
                                  height: 180,
                                  child: PageView.builder(
                                      onPageChanged: (value) {
                                        pageValue = value;
                                        setState(() {});
                                      },
                                      itemCount: publicProfileController
                                          .getVendorItemsReviews!
                                          .data!
                                          .reviews!
                                          .length,
                                      pageSnapping: true,
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (itemBuilder, index) {
                                        final review = publicProfileController
                                            .getVendorItemsReviews
                                            ?.data
                                            ?.reviews?[index];
                                        final message =
                                            review?.guestResponse?.guestMessage;

                                        final truncatedMessage =
                                            message != null &&
                                                    message.length > 100
                                                ? message.substring(0, 100)
                                                : message ?? "";

                                        final result = truncatedMessage;
                                        return Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                color: notifires.getBoxColor,
                                                borderRadius:
                                                    BorderRadius.circular(13)),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                          color: whiteColor,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      30)),
                                                      height: 48,
                                                      width: 48,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(3),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(40),
                                                          child: publicProfileController
                                                                      .getVendorItemsReviews!
                                                                      .data!
                                                                      .reviews![
                                                                          index]
                                                                      .guestResponse!
                                                                      .guestProfile ==
                                                                  null
                                                              ? Image.network(
                                                                  "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                                                                  fit: BoxFit
                                                                      .cover,
                                                                )
                                                              : Image.network(
                                                                  publicProfileController
                                                                      .getVendorItemsReviews!
                                                                      .data!
                                                                      .reviews![
                                                                          index]
                                                                      .guestResponse!
                                                                      .guestProfile!,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  errorBuilder:
                                                                      (context,
                                                                          error,
                                                                          stackTrace) {
                                                                    return Image
                                                                        .network(
                                                                      "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    );
                                                                  },
                                                                ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 16,
                                                    ),
                                                    Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "${publicProfileController.getVendorItemsReviews!.data!.reviews![index].guestResponse!.guestName}",
                                                          style: heading3Grey1(
                                                                  context)
                                                              .copyWith(),
                                                        ),
                                                        RatingBar.builder(
                                                          initialRating:
                                                              double.parse(
                                                                  "${publicProfileController.getVendorItemsReviews!.data!.reviews![index].guestResponse!.guestRating}"),
                                                          itemSize: 20,
                                                          ignoreGestures: true,
                                                          direction:
                                                              Axis.horizontal,
                                                          itemCount: 5,
                                                          itemPadding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      0),
                                                          itemBuilder:
                                                              (context, _) =>
                                                                  Icon(
                                                            Icons.star,
                                                            color: appyellow,
                                                          ),
                                                          onRatingUpdate:
                                                              (double value) {},
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                      ],
                                                    ),
                                                    const Spacer(),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          "Reviewed in",
                                                          style: regular(
                                                                  context)
                                                              .copyWith(
                                                                  color: notifires
                                                                      .getGrey3Whitecolor),
                                                        ),
                                                        Text(
                                                            "${publicProfileController.getVendorItemsReviews!.data!.reviews![index].createdAt}",
                                                            style: regular(
                                                                    context)
                                                                .copyWith(
                                                                    color: notifires
                                                                        .getGrey3Whitecolor))
                                                      ],
                                                    )
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 5,
                                                      vertical: 5),
                                                  child: Text(result,
                                                      style: regular2(context)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }),
                                ),
                      publicProfileController.getVendorItemsReviews!.data ==
                              null
                          ? const SizedBox()
                          : publicProfileController
                                  .getVendorItemsReviews!.data!.reviews!.isEmpty
                              ? const SizedBox()
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Wrap(
                                      children: [
                                        for (var x in publicProfileController
                                            .getVendorItemsReviews!
                                            .data!
                                            .reviews!)
                                          Container(
                                            height: 8,
                                            width: 8,
                                            margin:
                                                const EdgeInsets.only(left: 8),
                                            decoration: BoxDecoration(
                                                color: publicProfileController
                                                                .getVendorItemsReviews!
                                                                .data!
                                                                .reviews![
                                                            pageValue] ==
                                                        x
                                                    ? getColorBasedOnActiveModuleid()
                                                    : Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(20)),
                                          )
                                      ],
                                    ),
                                  ],
                                ),
                      const SizedBox(
                        height: 10,
                      ),
                      const SizedBox(
                        height: 50,
                      ),
                    ]),
              ),
              Positioned(
                  left: 0,
                  top: 25,
                  child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 15, top: 8, bottom: 8, right: 20),
                        child: PhysicalModel(
                          color: Colors.transparent,
                          shadowColor: notifires.getGrey4Whitecolor,
                          elevation:
                              5.0, // Adjust the elevation value as needed
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            alignment: Alignment.center,
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                                color: notifires.getboxcolor,
                                borderRadius: BorderRadius.circular(8)),
                            child: Icon(Icons.arrow_back,
                                color: getColorBasedOnActiveModuleid()),
                          ),
                        ),
                      )))
            ],
          ),
        ));
  }
}
