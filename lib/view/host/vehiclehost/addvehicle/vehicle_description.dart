import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/vehiclehost/addvehicle/vehicle_price_screen.dart';

import 'package:carvy/work_space.dart';

class VehcileDescriptionScreen extends StatefulWidget {
  final VoidCallback? onNextButtonPressed;
  final ScreenMode? mode;
  final VoidCallback? onBackButtonPressed;

  const VehcileDescriptionScreen(
      {super.key,
      this.onNextButtonPressed,
      this.mode,
      this.onBackButtonPressed});
  @override
  State<VehcileDescriptionScreen> createState() =>
      _VehcileDescriptionScreenState();
}

class _VehcileDescriptionScreenState extends State<VehcileDescriptionScreen> {
  AddItemsHostController addItemsHostController = Get.find();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(125),
            child: widget.mode == ScreenMode.add
                ? AppText(txt: "Add Vehicle Detail".tr)
                : const SizedBox()),
        body: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 15),
            // lineContainer(),
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelNames(labelname: 'Vehicle Name'.tr),
                    const SizedBox(height: 10),
                    TextFieldRefs(
                      textInputAction: TextInputAction.done,
                      maxlength: 100,
                      txt: 'Enter Title'.tr,
                      textEditingControllerCommon: widget.mode ==
                              ScreenMode.edit
                          ? addItemsHostController
                              .textEditingControllerEditTitle
                          : addItemsHostController.textEditingControllerTitle,
                      inputType: TextInputType.name,
                      inputAlignment: TextAlign.left,
                    ),
                    LabelNames(labelname: 'Vehicle Description'.tr),
                    const SizedBox(height: 10),
                    TextFieldRefs(
                        textInputAction: TextInputAction.done,
                        txt: 'Enter Description'.tr,
                        textEditingControllerCommon: widget.mode ==
                                ScreenMode.edit
                            ? addItemsHostController
                                .textEditingControllerEditDesc
                            : addItemsHostController.textEditingControllerDesc,
                        inputType: TextInputType.multiline,
                        minlines: 12,
                        maxlength: 500,
                        maxlines: null,
                        inputAlignment: TextAlign.left),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ]),
        ),
        bottomNavigationBar: BottomHosts(
          onTap: () {
            addItemsHostController.validateAndNavigate(
              context: context,
              formKey: _formKey,
              mode: widget.mode,
              onNextButtonPressed: widget.onNextButtonPressed,
              titleController: widget.mode == ScreenMode.edit
                  ? addItemsHostController.textEditingControllerEditTitle
                  : addItemsHostController.textEditingControllerTitle,
              descriptionController: widget.mode == ScreenMode.edit
                  ? addItemsHostController.textEditingControllerEditDesc
                  : addItemsHostController.textEditingControllerDesc,
              navigateToScreen: const VehiclePriceScreen(mode: ScreenMode.add),
            );
          },
          txt: truncatetext("Next".tr, 9),
          backButtontxt: "Back".tr,
          // backOnPressed: (() {
          //   Get.back();
          // }),
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
