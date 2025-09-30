import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/myaccount/publicProfile/public_profile_review_screen.dart';
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
  }

  stateSetter(fn) => setState(() {});

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
                                  widget.userName.toString().tr,
                                  style: heading2Grey1(context),
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
                            Column(
                              children: [
                                Text(
                                  publicProfileController.getUserProfile?.data
                                          ?.totalReviewsOnItems
                                          ?.toString() ??
                                      '',
                                  style: boldstyle(context).copyWith(
                                      color: getColorBasedOnActiveModuleid(),
                                      fontSize: 17),
                                ),
                                Text(
                                  "Reviews".tr,
                                  style: regular2(context).copyWith(
                                      color: notifires.getGrey3Whitecolor),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  publicProfileController
                                          .getUserProfile?.data?.yearsOfHosting
                                          ?.toString() ??
                                      '',
                                  style: boldstyle(context).copyWith(
                                      color: getColorBasedOnActiveModuleid(),
                                      fontSize: 17),
                                ),
                                Text(
                                  "Hosting".tr,
                                  style: regular2(context).copyWith(
                                      color: notifires.getGrey3Whitecolor),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  publicProfileController.getUserProfile?.data
                                          ?.totalReviewsOnItems
                                          ?.toString() ??
                                      '',
                                  style: boldstyle(context).copyWith(
                                      color: getColorBasedOnActiveModuleid(),
                                      fontSize: 17),
                                ),
                                Text(
                                  "Rating".tr,
                                  style: regular2(context).copyWith(
                                      color: notifires.getGrey3Whitecolor),
                                ),
                              ],
                            ),

                            // Add more Columns as needed
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
                              "${"Joined in".tr} ${publicProfileController.getUserProfile?.data?.joinIn ?? ""}",
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
                                "Email".tr,
                                style: appRegularText.copyWith(
                                    color: notifires.getwhiteblackcolor),
                              ),
                              const Spacer(),
                              Text(
                                publicProfileController.getUserProfile?.data
                                            ?.verifiedEmail ==
                                        "0"
                                    ? "Email not verified".tr
                                    : "Verified Email".tr,
                                style: appRegularText.copyWith(
                                  color: Colors.green,
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
                                "Phone".tr,
                                style: appRegularText.copyWith(
                                    color: notifires.getwhiteblackcolor),
                              ),
                              const Spacer(),
                              Text(
                                publicProfileController.getUserProfile?.data
                                            ?.verifiedPhone ==
                                        "0"
                                    ? "Phone not verified".tr
                                    : "Verified Phone".tr,
                                style: appRegularText.copyWith(
                                  color: Colors.green,
                                ),
                              )
                            ],
                          ),
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
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 22,
                          right: 22,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                                child: Text(
                                    "${publicProfileController.getUserProfile!.data?.name ?? ""} ${"Listing".tr.tr}",
                                    style: heading2Grey1(context))),
                            InkWell(
                                onTap: () {
                                  Get.to(
                                      () => RecommendationScreen(
                                            comefromprofilepage: true,
                                            title:
                                                "${publicProfileController.getUserProfile!.data!.name!} ${"Listing".tr}",
                                            locationId: "-1",
                                            userId: widget.userid,
                                            itemList: publicProfileController
                                                .getUserItems?.data?.items,
                                          ),
                                      transition: Transition.fadeIn);
                                },
                                child: Text("View All Listing".tr,
                                    style: regular2(context).copyWith(
                                        color:
                                            getColorBasedOnActiveModuleid()))),
                          ],
                        ),
                      ),
                      publicProfileController
                                  .getUserItems?.data?.items?.isEmpty ??
                              true
                          ? const SizedBox
                              .shrink() // Use SizedBox.shrink to take zero space
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  Container(
                                    child: itemVerticalViewPublic(
                                        publicProfileController
                                            .getUserItems?.data?.items,
                                        true,
                                        false,
                                        stateSetter,
                                        context),
                                  ),
                                ],
                              ),
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
