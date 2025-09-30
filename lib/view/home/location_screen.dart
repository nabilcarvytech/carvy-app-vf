import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import '../../../controller/home_controller.dart';
import '../../work_space.dart';

class LocationScreen extends StatefulWidget {
  final List? list;
  const LocationScreen({super.key, this.list});
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  HomeController homeController = Get.find();
  final SearchControllerHome _searchController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          appBar: CustomAppBars(
            title: "Popular Region".tr,
            backgroundColor: notifires.getbgcolor,
            iconColor: notifires.getwhiteblackcolor,
            titleColor: notifires.getwhiteblackcolor,
          ),
          body: connectionLost == true
              ? Center(
                  child: connectionError(context, "Something Went Wrong".tr))
              : widget.list!.isEmpty
                  ? Center(
                      child:
                          buildNoDataWidget(context, "Location not found".tr))
                  : Padding(
                      padding:
                          const EdgeInsets.only(top: 20, left: 18, right: 9),
                      child: GridView.builder(
                        itemCount: widget.list!.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                mainAxisExtent: 125,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 2),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {},
                            child: InkWell(
                              onTap: () {
                                if (widget.list![index].latitude != null &&
                                    widget.list![index].longitude != null) {
                                  slatsearch = widget.list![index].latitude;
                                  sLongSearch = widget.list![index].longitude;
                                  generalScopeController.homeSearchLocation
                                      .value = widget.list![index].cityName!;
                                } else {
                                  slatsearch = "";
                                  sLongSearch = "";
                                }
                                setState(() {});
                                _searchController.setDefaultDates(
                                  startDateCustomDate: generalScopeController
                                      .startDateCustomDate,
                                  endDateCustomDate:
                                      generalScopeController.endDateCustomDate,
                                  startDate: _searchController.startDate,
                                  endDates: _searchController.endDates,
                                );
                                _searchController.submitMethod(context, true);
                              },
                              onHover: (value) {},
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: SizedBox(
                                        width: 120,
                                        height: 125,
                                        child: myNetworkImage(
                                            "${widget.list!.elementAt(index).image}")),
                                  ),
                                  Column(
                                    children: [
                                      const Expanded(child: SizedBox()),
                                      SizedBox(
                                        width: 120,
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                      bottomRight:
                                                          Radius.circular(12),
                                                      bottomLeft:
                                                          Radius.circular(12)),
                                              gradient: LinearGradient(
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                                colors: [
                                                  Colors.transparent,
                                                  Colors.black.withOpacity(0.7),
                                                ],
                                              )),
                                          padding: const EdgeInsets.all(8),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                (widget.list!
                                                                .elementAt(
                                                                    index)
                                                                .cityName
                                                                ?.length ??
                                                            0) >
                                                        10
                                                    ? "${widget.list!.elementAt(index).cityName!.substring(0, 9)}..."
                                                    : widget.list!
                                                            .elementAt(index)
                                                            .cityName ??
                                                        "",
                                                style: boldstyle(context)
                                                    .copyWith(
                                                        color: whiteColor),
                                              ),
                                            ],
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
                      ),
                    ),
        ),
      ),
    );
  }
}
