import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/safe_rebuild.dart';
import 'package:carvy/utils/theme_style.dart';
import '../../../controller/publix_profile_controller.dart';

class PublicProfileReviewScreen extends StatefulWidget {
  final String? userId;
  final String? name;

  const PublicProfileReviewScreen({super.key, this.userId, this.name});

  @override
  State<PublicProfileReviewScreen> createState() =>
      _PublicProfileReviewScreenState();
}

class _PublicProfileReviewScreenState extends State<PublicProfileReviewScreen> {
  PublicProfileController publicProfileController = Get.find();
  Future<void> fetchData() async {
    publicProfileController.isLoadingReviewScreen.value = true;
    try {
      await publicProfileController.getDataPublicProfileReview(widget.userId);
    } catch (error) {
      //
    } finally {
      publicProfileController.isLoadingReviewScreen.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    runAfterFirstFrame(fetchData);
  }

  void onRefresh() async {
    publicProfileController.isLoadingReviewScreen.value = true; // Start loading
    try {
      publicProfileController.list.clear();
      publicProfileController.offset = 0;

      await publicProfileController.getDataPublicProfileReview(widget.userId);
    } catch (error) {
      //
    } finally {
      publicProfileController.isLoadingReviewScreen.value = false;
    }
  }

  Future<void> onLoading() async {
    try {
      setState(() {});
      await publicProfileController.getDataPublicProfileReview(widget.userId);
      setState(() {});
    } finally {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifires.getbgcolor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 80,
        title: Text(
          "${widget.name}' ${"Review".tr}",
          style: heading2Grey1(context),
        ),
        leading: backButton(),
      ),
      body: GetBuilder<PublicProfileController>(
        builder: (controller) {
          if (controller.isLoadingReviewScreen.isTrue) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return SmartRefresher(
                enablePullDown: true,
                header: const WaterDropHeader(),
                controller: publicProfileController.refreshController,
                onRefresh: onRefresh,
                onLoading: onLoading,
                enablePullUp:
                    publicProfileController.offset == -1 ? false : true,
                child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: publicProfileController.list.length,
                    itemBuilder: (itemBuilder, index) {
                      return Container(
                        margin: const EdgeInsets.only(
                            top: 8, bottom: 8, left: 16, right: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: notifires.getBoxColor,
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {},
                              child: Row(
                                children: [
                                  Container(
                                      height: 48,
                                      width: 48,
                                      decoration: BoxDecoration(
                                          color: whiteColor,
                                          borderRadius:
                                              BorderRadius.circular(30)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(3),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(40),
                                          child: publicProfileController
                                                      .list[index]
                                                      .guestResponse!
                                                      .guestProfile ==
                                                  null
                                              ? Image.network(
                                                  "https://cdn-icons-png.flaticon.com/512/3135/3135715.png")
                                              : Image.network(
                                                  publicProfileController
                                                      .getVendorItemsReviews!
                                                      .data!
                                                      .reviews![index]
                                                      .guestResponse!
                                                      .guestProfile!,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Image.network(
                                                      "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
                                                      fit: BoxFit.cover,
                                                    );
                                                  },
                                                ),
                                        ),
                                      )),
                                  const SizedBox(
                                    width: 16,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  "${publicProfileController.list[index].guestResponse!.guestName}",
                                                  style: heading3Grey1(context),
                                                ),
                                                RatingBar.builder(
                                                  initialRating: double.parse(
                                                      "${publicProfileController.list[index].guestResponse!.guestRating}"),
                                                  itemSize: 20,
                                                  ignoreGestures: true,
                                                  direction: Axis.horizontal,
                                                  itemCount: 5,
                                                  itemPadding: const EdgeInsets
                                                      .symmetric(horizontal: 0),
                                                  itemBuilder: (context, _) =>
                                                      Icon(
                                                    Icons.star,
                                                    color: appyellow,
                                                  ),
                                                  onRatingUpdate:
                                                      (double value) {},
                                                ),
                                              ],
                                            ),
                                            const Spacer(),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "Reviewed in",
                                                  style: regular(context).copyWith(
                                                      color: notifires
                                                          .getGrey3Whitecolor),
                                                ),
                                                Text(
                                                    "${publicProfileController.list[index].createdAt}",
                                                    style: regular(context)
                                                        .copyWith(
                                                            color: notifires
                                                                .getGrey3Whitecolor))
                                              ],
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              publicProfileController
                                  .list[index].guestResponse!.guestMessage!,
                              style: regular2(context).copyWith(),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 5,
                            ),
                            publicProfileController.list[index].hostResponse ==
                                        null ||
                                    publicProfileController.list[index]
                                            .hostResponse!.hostMessage ==
                                        null
                                ? const SizedBox()
                                : Padding(
                                    padding: const EdgeInsets.only(left: 80),
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                          top: 8, bottom: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                SizedBox(
                                                    height: 30,
                                                    width: 30,
                                                    child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(40),
                                                        child: publicProfileController
                                                                    .list[index]
                                                                    .hostResponse!
                                                                    .hostProfile ==
                                                                null
                                                            ? Image.network(
                                                                "https://cdn-icons-png.flaticon.com/512/3135/3135715.png")
                                                            : Image.network(
                                                                publicProfileController
                                                                    .list[index]
                                                                    .hostResponse!
                                                                    .hostProfile!,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ))),
                                                const SizedBox(
                                                  width: 16,
                                                ),
                                                Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${publicProfileController.list[index].hostResponse!.hostName}",
                                                      style: const TextStyle(),
                                                    ),
                                                    RatingBar.builder(
                                                      initialRating: double.parse(
                                                          "${publicProfileController.list[index].hostResponse!.hostRating}"),
                                                      itemSize: 20,
                                                      ignoreGestures: true,
                                                      direction:
                                                          Axis.horizontal,
                                                      itemCount: 5,
                                                      itemPadding:
                                                          const EdgeInsets
                                                              .symmetric(
                                                              horizontal: 0),
                                                      itemBuilder:
                                                          (context, _) => Icon(
                                                        Icons.star,
                                                        color: themeColor,
                                                      ),
                                                      onRatingUpdate:
                                                          (double value) {},
                                                    ),
                                                    const SizedBox(
                                                      height: 8,
                                                    ),
                                                    publicProfileController
                                                                .list[index]
                                                                .hostResponse!
                                                                .hostMessage ==
                                                            null
                                                        ? const SizedBox()
                                                        : Text(
                                                            "${publicProfileController.list[index].hostResponse!.hostMessage!.length > 100 ? publicProfileController.list[index].hostResponse!.hostMessage!.substring(0, 100) : publicProfileController.list[index].hostResponse!.hostMessage}",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.grey,
                                                              // fontFamily: FontStyles.gilroyMedium
                                                            ),
                                                          ),
                                                    Text(
                                                      "${publicProfileController.list[index].createdAt}",
                                                      style: const TextStyle(
                                                          color: Colors.grey,
                                                          // fontFamily:
                                                          // FontStyles.gilroyMedium,
                                                          fontSize: 10),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                          ],
                        ),
                      );
                    }));
          }
        },
      ),
    );
  }
}
