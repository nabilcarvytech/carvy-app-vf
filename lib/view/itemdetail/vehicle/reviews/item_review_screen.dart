import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import '../../../../api/config.dart';
import '../../../../helper/http_service.dart';
import '../../../../model/item_reviews_model.dart';
import '../../../../utils/common_widget.dart';

class YourReview extends StatefulWidget {
  final String? id;
  final String? userId;
  const YourReview({super.key, this.id, this.userId});
  @override
  State<YourReview> createState() => _YourReviewState();
}

class _YourReviewState extends State<YourReview> {
  ItemReviewsModel? itemReviewsModel;
  List<Reviews> list = [];
  num offset = 0;
  RefreshController refreshController = RefreshController();
  @override
  void initState() {
    super.initState();

    getData();
  }

  getData() async {
    // ========== MOCK DATA - OLD API CALL COMMENTED ==========
    // var response = await httpPost(
    //     Config.getItemReviews, {"item_id": widget.id, "offset": '$offset'});

    // MOCK: Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK: Static item reviews data
    var response = {
      "status": 200,
      "message": "Item reviews retrieved successfully",
      "error": "",
      "data": {
        "reviews": [
          {
            "id": 1,
            "booking_id": "101",
            "item_id": widget.id ?? "101",
            "item_name": "Toyota Camry 2023",
            "guest_id": "1",
            "guest_name": "John Doe",
            "guest_image": "https://example.com/profile1.jpg",
            "rating": "5",
            "message":
                "Excellent vehicle! Very clean and comfortable. Highly recommend!",
            "created_at": "2025-01-10T10:00:00.000Z",
            "updated_at": "2025-01-10T10:00:00.000Z"
          },
          {
            "id": 2,
            "booking_id": "102",
            "item_id": widget.id ?? "101",
            "item_name": "Toyota Camry 2023",
            "guest_id": "2",
            "guest_name": "Jane Smith",
            "guest_image": "https://example.com/profile2.jpg",
            "rating": "4",
            "message":
                "Great experience overall. The car was in perfect condition.",
            "created_at": "2025-01-08T14:30:00.000Z",
            "updated_at": "2025-01-08T14:30:00.000Z"
          },
          {
            "id": 3,
            "booking_id": "103",
            "item_id": widget.id ?? "101",
            "item_name": "Toyota Camry 2023",
            "guest_id": "3",
            "guest_name": "Mike Johnson",
            "guest_image": "https://example.com/profile3.jpg",
            "rating": "5",
            "message":
                "Perfect for a weekend trip. Smooth ride and great fuel economy.",
            "created_at": "2025-01-05T09:15:00.000Z",
            "updated_at": "2025-01-05T09:15:00.000Z"
          }
        ],
        "offset": offset + 3
      }
    };
    // ========== END MOCK DATA ==========
    if (response != null) {
      itemReviewsModel = ItemReviewsModel.fromJson(response);
      list.addAll(itemReviewsModel!.data!.reviews!);
      offset = itemReviewsModel!.data!.offset!;
      setState(() {});
    }
    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

  onLoading() {
    getData();
  }

  onRefresh() {
    itemReviewsModel = null;
    list = [];
    setState(() {});
    offset = 0;
    getData();
  }

  bool isReviewExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Dimensions.containerWidth,
          child: Scaffold(
              backgroundColor: notifires.getbgcolor,
              appBar: CustomAppBars(
                  title: "Review".tr,
                  backgroundColor: notifires.getbgcolor,
                  iconColor: notifires.getwhiteblackcolor,
                  titleColor: notifires.getwhiteblackcolor),
              body: SmartRefresher(
                  controller: refreshController,
                  onRefresh: onRefresh,
                  onLoading: onLoading,
                  enablePullUp: offset == -1 ? false : true,
                  child: itemReviewsModel == null
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(10),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      color: notifires.getgreycolor
                                          .withOpacity(.2),
                                    ),
                                    borderRadius: BorderRadius.circular(10)),
                                color: notifires.getboxcolor,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            child: list[index].guestImage ==
                                                    null
                                                ? const Icon(
                                                    Icons
                                                        .account_circle_rounded,
                                                    size: 40,
                                                  )
                                                : SizedBox(
                                                    height: 50,
                                                    width: 50,
                                                    child: myNetworkImage(
                                                        list[index].guestImage),
                                                  ),
                                          ),
                                          const SizedBox(
                                            width: 15,
                                          ),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  text: list[index].guestName!,
                                                  style: heading3Grey1(context)
                                                      .copyWith(
                                                    color: notifires
                                                        .getwhiteblackcolor,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 2,
                                              ),
                                              Row(
                                                children: [
                                                  RatingBar.builder(
                                                    unratedColor:
                                                        notifires.getgreycolor,
                                                    initialRating:
                                                        list[index].vehicleRating,
                                                    itemSize: 20,
                                                    ignoreGestures: true,
                                                    direction: Axis.horizontal,
                                                    itemCount: 5,
                                                    itemPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 2.0),
                                                    itemBuilder: (context, _) =>
                                                        Icon(
                                                      Icons.star,
                                                      color:
                                                          getColorBasedOnActiveModuleid(),
                                                    ),
                                                    onRatingUpdate: (rating) {},
                                                  ),
                                                  const SizedBox(
                                                    width: 3,
                                                  ),
                                                  Text(
                                                    "(${list[index].vehicleRating.toStringAsFixed(1)})",
                                                    style: headingh6.copyWith(
                                                        color: notifires
                                                            .getwhiteblackcolor),
                                                  )
                                                ],
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 15),
                                        child: Text(
                                          list[index].message ?? "No Review",
                                          style: regular2(context).copyWith(
                                              color:
                                                  notifires.getwhiteblackcolor,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${list[index].updatedAt}",
                                            style: headingh6.copyWith(
                                              fontSize: 12,
                                              color: notifires.getgreycolor,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ))),
        ));
  }
}
