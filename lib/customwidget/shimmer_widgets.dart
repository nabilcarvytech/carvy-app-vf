import 'package:flutter/material.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerWidget {}

Color baseColor = notifires.getBaseColor;

Widget sliderShimmer() {
  return SizedBox(
    height: 180,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
      ),
      child: Shimmer.fromColors(
        baseColor: notifires.getBaseColor,
        highlightColor: notifires.getHighlightColor,
        child: Container(
          decoration: BoxDecoration(
            color: notifires.getWhitetodarkgeryColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    ),
  );
}

Widget shimmerContainer() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: Container(
      decoration: BoxDecoration(
        color: notifires.getWhitetodarkgeryColor,
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}

Widget locationShimmer() {
  return SizedBox(
    child: Shimmer.fromColors(
      baseColor: notifires.getBaseColor,
      highlightColor: notifires.getHighlightColor,
      child: Container(
        decoration: BoxDecoration(
          color: notifires.getWhitetodarkgeryColor,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
  );
}

Widget horizontialShimmerContainer() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 160,
          decoration: BoxDecoration(
            color: notifires.getWhitetodarkgeryColor,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        Container(
          height: 18,
          width: 90,
          decoration: BoxDecoration(
            color: notifires.getWhitetodarkgeryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 12,
          // width: 140,
          decoration: BoxDecoration(
            color: notifires.getWhitetodarkgeryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 12,
          // width: 140,
          decoration: BoxDecoration(
            color: notifires.getWhitetodarkgeryColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    ),
  );
}

Widget horiZontialShimmerWidget() {
  return SizedBox(
    height: 250,
    child: ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeLarge, top: 5, bottom: 5),
          child: SizedBox(
              height: 250, width: 190, child: horizontialShimmerContainer()),
        );
      },
      itemCount: 4,
      scrollDirection: Axis.horizontal,
    ),
  );
}

Widget horiZontialShimmerWidgetVehicle() {
  return SizedBox(
    height: 270,
    child: ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeLarge, top: 5, bottom: 5),
          child: SizedBox(
              height: 270,
              width: 230,
              child: Shimmer.fromColors(
                baseColor: notifires.getBaseColor,
                highlightColor: notifires.getHighlightColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 170,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 22,
                      width: 170,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 15,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 13,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ],
                ),
              )),
        );
      },
      itemCount: 4,
      scrollDirection: Axis.horizontal,
    ),
  );
}

Widget verticleShimmerWidgetVehicle() {
  return SizedBox(
    child: ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeLarge,
              top: 10,
              bottom: 5,
              right: Dimensions.paddingSizeLarge),
          child: SizedBox(
              child: Shimmer.fromColors(
            baseColor: notifires.getBaseColor,
            highlightColor: notifires.getHighlightColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 190,
                  decoration: BoxDecoration(
                    color: notifires.getWhitetodarkgeryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  height: 22,
                  width: 170,
                  decoration: BoxDecoration(
                    color: notifires.getWhitetodarkgeryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Container(
                  height: 20,
                  decoration: BoxDecoration(
                    color: notifires.getWhitetodarkgeryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  height: 15,
                  decoration: BoxDecoration(
                    color: notifires.getWhitetodarkgeryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: notifires.getWhitetodarkgeryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          )),
        );
      },
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      scrollDirection: Axis.vertical,
    ),
  );
}

Widget rectangleLocation() {
  return SizedBox(
    height: 125,
    child: ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
          child: SizedBox(height: 125, width: 146, child: locationShimmer()),
        );
      },
      itemCount: 6,
      scrollDirection: Axis.horizontal,
    ),
  );
}

Widget loactionScreenShimmer() {
  return Padding(
    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
    child: GridView.builder(
        itemCount: 18,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 125,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10),
        itemBuilder: (context, index) {
          return locationShimmer();
        }),
  );
}

Widget topCategoriesScreenShimmer() {
  return Padding(
    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
    child: GridView.builder(
        itemCount: 18,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 170,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10),
        itemBuilder: (context, index) {
          return locationShimmer();
        }),
  );
}

Widget circleLocation() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: SizedBox(
      height: 90,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
            child: Column(
              children: [
                Container(
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: notifires.getWhitetodarkgeryColor,
                    borderRadius: BorderRadius.circular(55),
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: 6,
        scrollDirection: Axis.horizontal,
      ),
    ),
  );
}

Widget boxLocation() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: SizedBox(
        height: 40,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: Dimensions.paddingSizeLarge),
              child: Column(
                children: [
                  Container(
                    height: 40,
                    width: index == 0
                        ? 40
                        : index == 1
                            ? 70
                            : 110,
                    decoration: BoxDecoration(
                      color: notifires.getWhitetodarkgeryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            );
          },
          itemCount: 6,
          scrollDirection: Axis.horizontal,
        ),
      ),
    ),
  );
}

Widget topCateforyBoatShimmer() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: SizedBox(
      height: 80,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              children: [
                Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                    color: notifires.getWhitetodarkgeryColor,
                    borderRadius: BorderRadius.circular(55),
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: 6,
        scrollDirection: Axis.horizontal,
      ),
    ),
  );
}

Widget chatMassageShimmer() {
  return SizedBox(
    width: double.maxFinite,
    height: double.maxFinite,
    child: Column(
      children: [
        ListTile(
          title: SizedBox(
            height: 20,
            width: 200,
            child: shimmerContainer(),
          ),
          subtitle: SizedBox(
            height: 15,
            width: 300,
            child: shimmerContainer(),
          ),
          leading: SizedBox(
            height: 50,
            width: 50,
            child: shimmerContainer(),
          ),
        ),
        Divider(
          color: notifires.getGrey5Whitecolor,
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 30,
                width: 270,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 30,
                width: 220,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 30,
                width: 230,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 50,
                width: 50,
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(25)),
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 30,
                width: 320,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 30,
                width: 260,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              SizedBox(
                height: 50,
                width: 50,
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 30,
                width: 270,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 30,
                width: 220,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 30,
                width: 230,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 15, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                height: 30,
                width: 370,
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                )),
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            height: 60,
            width: double.maxFinite,
            child: shimmerContainer(),
          ),
        ),
      ],
    ),
  );
}

Widget topCateforyBookableShimmer() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: SizedBox(
      height: 50,
      child: ListView.builder(
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              children: [
                Container(
                  height: 50,
                  width: 120,
                  decoration: BoxDecoration(
                    color: notifires.getWhitetodarkgeryColor,
                    borderRadius: BorderRadius.circular(55),
                  ),
                ),
              ],
            ),
          );
        },
        itemCount: 6,
        scrollDirection: Axis.horizontal,
      ),
    ),
  );
}

Widget verticleShimmerWidgetParking() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: SizedBox(
      child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 1,
            crossAxisSpacing: 5,
            mainAxisExtent: 125,
            mainAxisSpacing: 3,
          ),
          shrinkWrap: true,
          itemCount: 8,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 15, right: 15, top: 5),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.only(top: 5),
                    leading: Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                          color: notifires.getdarkwhitecolor,
                          borderRadius: BorderRadius.circular(30)),
                    ),
                    title: Container(
                      height: 17,
                      width: 140,
                      decoration: BoxDecoration(
                          color: notifires.getdarkwhitecolor,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    subtitle: Container(
                      height: 13,
                      width: 130,
                      decoration: BoxDecoration(
                          color: notifires.getdarkwhitecolor,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 18,
                          // width: 90,
                          decoration: BoxDecoration(
                            color: notifires.getWhitetodarkgeryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Container(
                          height: 18,
                          // width: 90,
                          decoration: BoxDecoration(
                            color: notifires.getWhitetodarkgeryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Container(
                          height: 18,
                          // width: 90,
                          decoration: BoxDecoration(
                            color: notifires.getWhitetodarkgeryColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            );
          }),
    ),
  );
}

Widget horiZontialShimmerWidgetParking() {
  return SizedBox(
    height: 50,
    child: ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeLarge, top: 5, bottom: 5, right: 5),
          child: SizedBox(
              height: 50,
              width: index == 0 ? 60 : 120,
              child: shimmerContainer()),
        );
      },
      itemCount: 6,
      scrollDirection: Axis.horizontal,
    ),
  );
}

Widget horiZontialShimmerWidgetBookable() {
  return SizedBox(
    height: 270,
    child: ListView.builder(
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(
              left: Dimensions.paddingSizeLarge, top: 5, bottom: 5),
          child: SizedBox(
              height: 270,
              width: 150,
              child: Shimmer.fromColors(
                baseColor: notifires.getBaseColor,
                highlightColor: notifires.getHighlightColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 150,
                      width: 140,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 18,
                      width: 90,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 12,
                      width: 140,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 12,
                      width: 140,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              )),
        );
      },
      itemCount: 4,
      scrollDirection: Axis.horizontal,
    ),
  );
}

Widget recentSearchShimmerWidgetBookable() {
  return SizedBox(
    child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisExtent: 50,
          mainAxisSpacing: 10,
        ),
        shrinkWrap: true,
        itemCount: 6,
        physics: const NeverScrollableScrollPhysics(),
        // itemCount:  _showMore ? parkingList.length : 5,
        // itemCount: 5,
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: grey5,
              ),
              width: double.maxFinite,
              child: shimmerContainer(),
            ),
          );
        }),
  );
}

Widget verticleShimmerWidgetBookable() {
  return SizedBox(
    child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          crossAxisSpacing: 0,
          mainAxisSpacing: 10,
          mainAxisExtent: 250,
        ),
        shrinkWrap: true,
        itemCount: 8,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeLarge,
                  top: 5,
                  bottom: 5,
                  right: Dimensions.paddingSizeLarge),
              child: SizedBox(
                  child: Shimmer.fromColors(
                baseColor: notifires.getBaseColor,
                highlightColor: notifires.getHighlightColor,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 18,
                      width: 90,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              )),
            ),
          );
        }),
  );
}

Widget topCateforySpaceShimmer() {
  return Padding(
    padding:
        const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
    child: SizedBox(
      height: 220,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            mainAxisExtent: 120,
            // childAspectRatio: .6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 10),
        itemBuilder: (context, index) {
          return shimmerContainer();
        },
        itemCount: 8,
      ),
    ),
  );
}

//for Details............
Widget propertyDetailsShimmer() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: ListView(
      children: [
        Container(
          height: 265,
          decoration: BoxDecoration(
              color: notifires.getdarkwhitecolor,
              borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24))),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              itemBuilder: (contaxt, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 10),
                  child: Container(
                    height: 55,
                    width: 85,
                    decoration: BoxDecoration(
                        color: notifires.getdarkwhitecolor,
                        borderRadius: BorderRadius.circular(10)),
                    child: shimmerContainer(),
                  ),
                );
              },
              itemCount: 5,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 20,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 20,
                width: 60,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(10)),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 15,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 13,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 120,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 25,
                width: 120,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 25,
                width: 120,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              // SizedBox(width: 10,)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 25,
                width: 120,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: 25,
                width: 120,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              // SizedBox(width: 10,)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 13,
            // width: 160,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 12,
            width: 120,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Container(
          height: 276,
          decoration: BoxDecoration(
            color: notifires.getdarkwhitecolor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  color: notifires.getdarkwhitecolor,
                  borderRadius: BorderRadius.circular(30)),
            ),
            title: Row(
              children: [
                Container(
                  height: 17,
                  width: 170,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ],
            ),
            subtitle: Container(
              height: 13,
              width: 130,
              decoration: BoxDecoration(
                  color: notifires.getdarkwhitecolor,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    ),
  );
}

Widget spaceDetailsShimmer() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: ListView(
      children: [
        Container(
          height: 265,
          decoration: BoxDecoration(
              color: notifires.getdarkwhitecolor,
              borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24))),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              itemBuilder: (contaxt, index) {
                return Padding(
                  padding:
                      const EdgeInsets.only(right: 10, bottom: 10, left: 2),
                  child: Container(
                    height: 55,
                    width: 85,
                    decoration: BoxDecoration(
                        color: notifires.getdarkwhitecolor,
                        borderRadius: BorderRadius.circular(10)),
                    child: shimmerContainer(),
                  ),
                );
              },
              itemCount: 4,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Container(
                height: 20,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 20,
                width: 60,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 260,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 20,
                width: 220,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 20,
                width: 180,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              // SizedBox(width: 10,)
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 15,
            width: 200,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 13,
            width: 250,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 13,
            width: 240,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 13,
            // width: 160,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 12,
            width: 120,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Container(
          height: 276,
          decoration: BoxDecoration(
            color: notifires.getdarkwhitecolor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  color: notifires.getdarkwhitecolor,
                  borderRadius: BorderRadius.circular(30)),
            ),
            title: Row(
              children: [
                Container(
                  height: 17,
                  width: 170,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ],
            ),
            subtitle: Container(
              height: 13,
              width: 130,
              decoration: BoxDecoration(
                  color: notifires.getdarkwhitecolor,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    ),
  );
}

Widget parkingDetailsShimmer() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: ListView(
      children: [
        Container(
            height: 265,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(24),
                    bottomLeft: Radius.circular(24)))),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
          child: Row(
            children: [
              Container(
                height: 20,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 20,
                width: 60,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(10)),
              ),
              const Spacer(),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(20)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(
            left: 8,
            top: 8,
            bottom: 8,
          ),
          child: Row(
            children: [
              Container(
                height: 15,
                width: 350,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(10)),
              ),
            ],
          ),
        ),
        activeModuleId.value == 4
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                            color: notifires.getdarkwhitecolor,
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                            color: notifires.getdarkwhitecolor,
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Container(
                        height: 35,
                        decoration: BoxDecoration(
                            color: notifires.getdarkwhitecolor,
                            borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                    // SizedBox(width: 10,)
                  ],
                ),
              )
            : const SizedBox(),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  color: notifires.getdarkwhitecolor,
                  borderRadius: BorderRadius.circular(30)),
            ),
            title: Row(
              children: [
                Container(
                  height: 17,
                  width: 170,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ],
            ),
            subtitle: Container(
              height: 13,
              width: 130,
              decoration: BoxDecoration(
                  color: notifires.getdarkwhitecolor,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 13,
            // width: 160,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 12,
            width: 120,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Container(
          height: 276,
          decoration: BoxDecoration(
            color: notifires.getdarkwhitecolor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    ),
  );
}

Widget vehicleDetailsShimmer() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: ListView(
      children: [
        Container(
          height: 265,
          decoration: BoxDecoration(
              color: notifires.getdarkwhitecolor,
              borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24))),
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              itemBuilder: (contaxt, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10, bottom: 10),
                  child: Container(
                    height: 55,
                    width: 85,
                    decoration: BoxDecoration(
                        color: notifires.getdarkwhitecolor,
                        borderRadius: BorderRadius.circular(10)),
                    child: shimmerContainer(),
                  ),
                );
              },
              itemCount: 5,
              scrollDirection: Axis.horizontal,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: Container(
            height: 25,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(5)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 8),
          child: Container(
            height: 18,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(5)),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              // SizedBox(width: 10,)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              // SizedBox(width: 10,)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              // SizedBox(width: 10,)
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 13,
            // width: 160,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            height: 12,
            width: 120,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 30,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(6)),
              ),
              const SizedBox(
                width: 15,
              ),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 12,
                width: 120,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Container(
          height: 276,
          decoration: BoxDecoration(
            color: notifires.getdarkwhitecolor,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 25,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 8),
          child: Container(
            height: 120,
            decoration: BoxDecoration(
                color: notifires.getdarkwhitecolor,
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                height: 16,
                width: 160,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const Spacer(),
              Container(
                height: 13,
                width: 130,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(12)),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListTile(
            leading: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                  color: notifires.getdarkwhitecolor,
                  borderRadius: BorderRadius.circular(30)),
            ),
            title: Row(
              children: [
                Container(
                  height: 17,
                  width: 170,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ],
            ),
            subtitle: Container(
              height: 13,
              width: 130,
              decoration: BoxDecoration(
                  color: notifires.getdarkwhitecolor,
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        )
      ],
    ),
  );
}

Widget subCategoriesScreenShimmer() {
  return Row(
    children: [
      Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: grey6,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            )),
        width: 90,
        child: ListView.builder(
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 5, top: 10),
              child: Column(
                children: [
                  Shimmer.fromColors(
                    baseColor: notifires.getBaseColor,
                    highlightColor: notifires.getHighlightColor,
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        color: notifires.getWhitetodarkgeryColor,
                        borderRadius: BorderRadius.circular(35),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                ],
              ),
            );
          },
          scrollDirection: Axis.vertical,
          itemCount: 10,
        ),
      ),
      const SizedBox(
        width: 10,
      ),
      Expanded(
          child: SingleChildScrollView(
        child: Column(
          children: [
            horiZontialShimmerWidgetParking(),
            const SizedBox(
              height: 10,
            ),
            verticleShimmerWidgetBookable()
          ],
        ),
      ))
    ],
  );
}

Widget publicProfileScreenShimmer() {
  return Shimmer.fromColors(
    baseColor: notifires.getBaseColor,
    highlightColor: notifires.getHighlightColor,
    child: ListView(
      children: [
        Stack(
          children: [
            Container(
              alignment: Alignment.topCenter,
              height: 240,
              child: Container(
                height: 176,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(24),
                        bottomLeft: Radius.circular(12))),
              ),
            ),
            Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: Shimmer.fromColors(
                    baseColor: notifires.getBaseColor,
                    highlightColor: notifires.getHighlightColor,
                    child: Container(
                      height: 130,
                      width: 130,
                      decoration: BoxDecoration(
                          color: notifires.getdarkwhitecolor,
                          borderRadius: BorderRadius.circular(65)),
                    ),
                  ),
                ))
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 15,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: notifires.getBaseColor,
                  highlightColor: notifires.getHighlightColor,
                  child: Container(
                    height: 15,
                    width: 130,
                    decoration: BoxDecoration(
                        color: notifires.getdarkwhitecolor,
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Shimmer.fromColors(
                  baseColor: notifires.getBaseColor,
                  highlightColor: notifires.getHighlightColor,
                  child: Container(
                    height: 13,
                    width: 120,
                    decoration: BoxDecoration(
                        color: notifires.getdarkwhitecolor,
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            )
          ],
        ),
        const SizedBox(
          height: 50,
        ),
        Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Shimmer.fromColors(
                baseColor: notifires.getBaseColor,
                highlightColor: notifires.getHighlightColor,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                              color: notifires.getdarkwhitecolor,
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                              color: notifires.getdarkwhitecolor,
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Container(
                          height: 45,
                          decoration: BoxDecoration(
                              color: notifires.getdarkwhitecolor,
                              borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                      // SizedBox(width: 10,)
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                height: 45,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 45,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                height: 45,
                decoration: BoxDecoration(
                    color: notifires.getdarkwhitecolor,
                    borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(
                height: 15,
              ),
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 170,
                    decoration: BoxDecoration(
                        color: notifires.getdarkwhitecolor,
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  height: 110,
                  decoration: BoxDecoration(
                      color: notifires.getdarkwhitecolor,
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        )
      ],
    ),
  );
}

Widget filterScreenShimmer() {
  return Stack(
    children: [
      Positioned(
        left: 20,
        right: 20,
        bottom: 20,
        child: SizedBox(
          height: 50,
          child: shimmerContainer(),
        ),
      ),
      Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: Dimensions.paddingSizeLarge,
                  top: Dimensions.paddingSizeLarge,
                  bottom: 70,
                  right: Dimensions.paddingSizeLarge),
              child: ListView(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    height: 60,
                    child: shimmerContainer(),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  activeModuleId.value == 1
                      ? Row(
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: shimmerContainer(),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: shimmerContainer(),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: shimmerContainer(),
                              ),
                            ),
                            const Spacer(),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: shimmerContainer(),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: shimmerContainer(),
                              ),
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: SizedBox(
                                height: 50,
                                child: shimmerContainer(),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: shimmerContainer(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: shimmerContainer(),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 20,
                        width: 140,
                        child: shimmerContainer(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: shimmerContainer(),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 20,
                        width: 140,
                        child: shimmerContainer(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: shimmerContainer(),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 20,
                        width: 140,
                        child: shimmerContainer(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: shimmerContainer(),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 20,
                        width: 140,
                        child: shimmerContainer(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: 50,
                        width: 140,
                        child: shimmerContainer(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: shimmerContainer(),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 20,
                        width: 140,
                        child: shimmerContainer(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: shimmerContainer(),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 20,
                        width: 140,
                        child: shimmerContainer(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: shimmerContainer(),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 20,
                        width: 140,
                        child: shimmerContainer(),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SizedBox(
                        height: 40,
                        width: 40,
                        child: shimmerContainer(),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      SizedBox(
                        height: 20,
                        width: 140,
                        child: shimmerContainer(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget myBookingScreenShimmer() {
  return ListView.builder(
    itemBuilder: (context, index) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 380,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: double.maxFinite,
                    height: 160,
                    child: shimmerContainer()),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(width: 270, height: 20, child: shimmerContainer()),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(width: 250, height: 20, child: shimmerContainer()),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(width: 250, height: 20, child: shimmerContainer()),
                const SizedBox(
                  height: 10,
                ),
                SizedBox(width: 240, height: 20, child: shimmerContainer()),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    SizedBox(width: 235, height: 20, child: shimmerContainer()),
                    const Spacer(),
                    SizedBox(width: 70, height: 20, child: shimmerContainer()),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(height: 40, child: shimmerContainer()),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Spacer(),
                    Expanded(
                      child: SizedBox(height: 40, child: shimmerContainer()),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: SizedBox(height: 40, child: shimmerContainer()),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
    scrollDirection: Axis.vertical,
    itemCount: 4,
  );
}

Widget chatInboxScreenShimmer() {
  return ListView.builder(
    itemBuilder: (context, index) {
      return ListTile(
        title: SizedBox(height: 13, child: shimmerContainer()),
        subtitle: SizedBox(height: 13, width: 170, child: shimmerContainer()),
        leading: SizedBox(height: 60, width: 60, child: shimmerContainer()),
      );
    },
    itemCount: 10,
    scrollDirection: Axis.vertical,
  );
}

Widget homeHostScreenShimmer() {
  return SingleChildScrollView(
    child: Column(
      children: [
        const SizedBox(
          height: 20,
        ),
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Row(
            children: [
              Expanded(
                  child: SizedBox(
                height: 100,
                child: shimmerContainer(),
              )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: SizedBox(
                height: 100,
                child: shimmerContainer(),
              )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: SizedBox(
                height: 100,
                child: shimmerContainer(),
              )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Row(
            children: [
              Expanded(
                  child: SizedBox(
                height: 100,
                child: shimmerContainer(),
              )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: SizedBox(
                height: 100,
                child: shimmerContainer(),
              )),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                  child: SizedBox(
                height: 100,
                child: shimmerContainer(),
              )),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 30,
                width: 150,
                child: shimmerContainer(),
              ),
              SizedBox(
                height: 30,
                width: 50,
                child: shimmerContainer(),
              ),
            ],
          ),
        ),
        verticleShimmerWidgetBookable()
      ],
    ),
  );
}

Widget calanderScreenShimmer() {
  return Padding(
    padding: const EdgeInsets.all(10),
    child: ListView(
      children: [
        const SizedBox(
          height: 30,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 1,
                child: SizedBox(
                  height: 100,
                  child: shimmerContainer(),
                )),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  SizedBox(
                    height: 20,
                    child: shimmerContainer(),
                  ),
                  const SizedBox(
                    height: 14,
                  ),
                  SizedBox(
                    height: 14,
                    width: 150,
                    child: shimmerContainer(),
                  ),
                ],
              ),
            )
          ],
        ),
        const SizedBox(
          height: 30,
        ),
        SizedBox(
          height: 20,
          child: shimmerContainer(),
        ),
        const SizedBox(
          height: 8,
        ),
        Row(
          children: [
            SizedBox(
              height: 20,
              width: 200,
              child: shimmerContainer(),
            ),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: 24,
          child: shimmerContainer(),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          children: [
            SizedBox(
              height: 17,
              width: 120,
              child: shimmerContainer(),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: 50,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemBuilder: (context, index) {
              return index == 0 ? const SizedBox() : shimmerContainer();
            },
            itemCount: 31,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ),
        const SizedBox(
          height: 40,
        ),
        Row(
          children: [
            SizedBox(
              height: 17,
              width: 120,
              child: shimmerContainer(),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        SizedBox(
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisExtent: 50,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10),
            itemBuilder: (context, index) {
              return index == 0 ? const SizedBox() : shimmerContainer();
            },
            itemCount: 31,
            physics: const NeverScrollableScrollPhysics(),
          ),
        )
      ],
    ),
  );
}
