import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/model/add_rules_model.dart';
import 'package:carvy/model/cancellation_policies_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/work_space.dart';

class VehcileRulesScreen extends StatefulWidget {
  final VoidCallback? onNextButtonPressed;
  final VoidCallback? onBackButtonPressed;
  final ScreenMode mode;
  const VehcileRulesScreen(
      {super.key,
      this.onNextButtonPressed,
      required this.mode,
      this.onBackButtonPressed});
  @override
  State<VehcileRulesScreen> createState() => _VehcileRulesScreenState();
}

class _VehcileRulesScreenState extends State<VehcileRulesScreen> {
  AddItemsHostController addItemsHostController = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(130),
            child: widget.mode == ScreenMode.add
                ? AppText(txt: "Policies & Rules".tr)
                : const SizedBox()),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Cancellation policies".tr + " :".tr,
                      style: heading2(context),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: addItemsHostController
                          .listCancellationPoliciesVehcile.length,
                      itemBuilder: (context, index) {
                        CancellationPolicies currentRule =
                            addItemsHostController
                                .listCancellationPoliciesVehcile[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(
                            color: notifires.getboxcolor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    currentRule.name.toString(),
                                    style: regular3(context).copyWith(
                                      color: notifires.getGrey2Whitecolor,
                                      fontSize:
                                          14, // Smaller font size for compactness
                                    ),
                                    overflow: TextOverflow
                                        .ellipsis, // Prevent text overflow
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    showBottomSheetDescription(
                                        context, currentRule);
                                  },
                                  child: Text(
                                    "View".tr,
                                    style: regular2(context).copyWith(
                                      fontSize:
                                          12, // Smaller font for "View" link
                                      decoration: TextDecoration.underline,
                                      decorationColor:
                                          getColorBasedOnActiveModuleid(),
                                      color: getColorBasedOnActiveModuleid(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 4),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Adding Rules".tr + " :".tr,
                      style: heading2(context),
                    ),
                    const SizedBox(height: 15),

                    ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: addItemsHostController.listAddRules.length,
                      itemBuilder: (itemBuilder, index) {
                        AddRules currentRule =
                            addItemsHostController.listAddRules[index];
                        return Material(
                          type: MaterialType.transparency,
                          elevation: 4,
                          borderRadius: BorderRadius.circular(10),
                          shadowColor: themeColor,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 10.0, bottom: 10, left: 8, right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (addItemsHostController.selectedRulesList
                                      .contains(currentRule.id)) {
                                    addItemsHostController.selectedRulesList
                                        .remove(currentRule.id);
                                  } else {
                                    addItemsHostController.selectedRulesList
                                        .add(currentRule.id);
                                  }
                                });
                              },
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CheckBoxHost(currentRule: currentRule),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Transform.translate(
                                            offset: const Offset(0, -5),
                                            child: Text(
                                              '${currentRule.name}',
                                              softWrap: true,
                                              textAlign: TextAlign.start,

                                              // "hello",
                                              style: regular3(context).copyWith(
                                                  color: notifires
                                                      .getGrey2Whitecolor),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(
                          height: 5,
                        );
                      },
                    ),
                    // ),
                  ],
                ),
              ),
              // ),
            ],
          ),
        ),
        bottomNavigationBar: BottomHosts(
          onTap: () {
            if (widget.mode == ScreenMode.edit) {
              addItemsHostController.updateMethod();
            } else {
              addItemsHostController.addItems();
            }
          },
          txt: widget.mode == ScreenMode.add ? 'Submit'.tr : "Update".tr,
          backButtontxt: "Back".tr,
          backOnPressed: () {
            if (widget.mode == ScreenMode.edit) {
              widget.onBackButtonPressed!();
            } else {
              Get.back();
            }
          },
        ));
  }
}
