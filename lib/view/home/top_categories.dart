import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/search/after_search.dart';
import 'package:carvy/work_space.dart';
import '../../customwidget/data_not_found.dart';
import '../bottombar/home_main.dart';

class TopCategories extends StatefulWidget {
  final String? userId;
  final String? title;
  final bool? toshowbrands;
  final List? list;
  const TopCategories(
      {super.key, this.title, this.userId, this.toshowbrands, this.list});

  @override
  State<TopCategories> createState() => _TopCategoriesState();
}

class _TopCategoriesState extends State<TopCategories> {
  SearchControllerHome filterController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
            backgroundColor: notifires.getbgcolor,
            appBar: CustomAppBars(
              onBackButtonPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) => const HomeMain(
                              initialIndex: 0,
                            )));
              },
              title: widget.title.toString() == "Make"
                  ? "Make"
                  : activeModuleId.value == 4
                      ? "Parking Location".tr
                      : widget.toshowbrands == true
                          ? "Popular brands".tr
                          : "Top Categories".tr,
              backgroundColor: notifires.getbgcolor,
              iconColor: notifires.getwhiteblackcolor,
              titleColor: notifires.getwhiteblackcolor,
            ),
            body: widget.list!.isEmpty
                ? Center(
                    child: buildNoDataWidget(context, "No Data founds".tr),
                  )
                : Padding(
                    padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                    child: uiBasedOnActiveModuleId(),
                  )),
      ),
    );
  }

  Widget uiBasedOnActiveModuleId() {
    return GridView.builder(
      itemCount: widget.list!.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisExtent: 160,
          mainAxisSpacing: 2,
          crossAxisSpacing: 2),
      itemBuilder: (context, index) {
        return Card(
          color: notifires.getboxcolor,
          child: InkWell(
            onTap: () {
              filterController.setDefaultDates(
                startDateCustomDate: generalScopeController.startDateCustomDate,
                endDateCustomDate: generalScopeController.endDateCustomDate,
                startDate: filterController.startDate,
                endDates: filterController.endDates,
              );
              filterController.maketypesValus.clear();
              filterController.maketypesValus.add(widget.list![index].id);

              Future.microtask(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AfterSearch(
                      mode: "make",
                    ),
                  ),
                );
              });
            },
            onHover: (value) {},
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      width: 110,
                      height: 90,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: notifires.getBoxColor),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: myNetworkImageFitWidth(
                            widget.list![index].imageUrl ??
                                "default_image_url"),
                      )),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  (widget.list![index].makeName?.length ?? 0) > 10
                      ? '${widget.list![index].makeName!.substring(0, 9)}..' // Truncate the name if it's longer than 10 characters
                      : (widget.list![index].makeName ??
                          ""), // If name is null, display an empty string
                  textAlign: TextAlign.center,
                  style: heading3Grey1(context),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
