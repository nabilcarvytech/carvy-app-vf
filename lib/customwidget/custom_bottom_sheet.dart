import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import '../controller/global_scope_controller.dart';
import '../model/cancellation_reason_model.dart';

class CustomBottomSheet extends StatefulWidget {
  final CancellationReasonModel model;
  const CustomBottomSheet({super.key, required this.model});
  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet> {
  bool disableconformButton = false;
  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        bottomNavigationBar: Container(
          alignment: Alignment.center,
          height: 60 + MediaQuery.of(context).padding.bottom,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 42, right: 42, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: notifires.getBoxColor,
                      ),
                      color: notifires.getBoxColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text("Cancel".tr,
                        style: heading3(context).copyWith(
                          color: notifires.getGrey1Whitecolor,
                        )),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (GlobalScopeController.selectedRadio == -1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please select a reason'.tr),
                        ),
                      );
                    } else {       
                      Navigator.pop(
                        context,
                        widget
                            .model
                            .data!
                            .reasons![GlobalScopeController.selectedRadio]
                            .orderCancellationId,
                      );
                      GlobalScopeController.selectedRadio =
                          -1; 
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 42, right: 42, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                        border:
                            Border.all(color: getColorBasedOnActiveModuleid()),
                        borderRadius: BorderRadius.circular(8),
                        color: getColorBasedOnActiveModuleid()),
                    child: Text("Confirm".tr,
                        style: heading3(context).copyWith(
                          color: Colors.white,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Text("Select Cancel Reason".tr,
                style: heading2Grey1(context)
                    .copyWith(color: getColorBasedOnActiveModuleid())),
            const SizedBox(
              height: 10,
            ),
            widget.model.data!.reasons!.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 100),
                      child: Text("Data not Found".tr,
                          style: TextStyle(
                            fontSize: 18,
                            color: notifires.getwhiteblackcolor,                
                          )),
                    ),
                  )
                : Expanded(
                    child: ListView.builder(
                        itemCount: widget.model.data!.reasons!.length,
                        shrinkWrap: true,
                        itemBuilder: (itemBuilder, index) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: notifires.getBoxColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: notifires.getGrey3Whitecolor
                                        .withOpacity(0.2),
                                    spreadRadius: 3,
                                    blurRadius: 5,
                                    offset: const Offset(
                                        0, 0), 
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.only(
                                  top: 8, bottom: 8, left: 5, right: 8),
                              child: Row(
                                children: [
                                  Radio(
                                      value: index,
                                      activeColor:
                                          getColorBasedOnActiveModuleid(),
                                      groupValue:
                                          GlobalScopeController.selectedRadio,
                                      onChanged: (value) {
                                        GlobalScopeController.selectedRadio =
                                            index;
                                        disableconformButton = true;
                                        setState(() {});
                                      }),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${widget.model.data!.reasons![index].reason}',
                                      style: regular2(context),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }),
                  ),
            const SizedBox(
              height: 8,
            ),
            const SizedBox(
              height: 16,
            )
          ],
        ));
  }
}
