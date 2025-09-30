import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carvy/controller/add_bank_account_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:get/get.dart';

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});

  @override
  State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}

class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  AddBankAccount addbankAccountController = Get.find();
  bool shouldLoad = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
        backgroundColor: notifires.getbgcolor,
        title:
            '${addbankAccountController.textEditingControllerAccName.text.isEmpty ? "Add" : "Edit"} Bank Account'
                .tr,
        titleColor: notifires.getwhiteblackcolor,
        onBackButtonPressed: () {
          Get.back();
        },
      ),
      body: Obx(
        () => addbankAccountController.isloading.value == true
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: addbankAccountController.globalKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFieldRefs(
                          inputAlignment: TextAlign.start,
                          txt: "Account Name".tr,
                          inputType: TextInputType.name,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "Account Name is Empty".tr;
                            }
                            return null;
                          },
                          textEditingControllerCommon: addbankAccountController
                              .textEditingControllerAccName,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFieldRefs(
                          inputAlignment: TextAlign.start,
                          txt: "Account Number".tr,
                          inputType: TextInputType.name,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "Account Number is Empty".tr;
                            }
                            return null;
                          },
                          textEditingControllerCommon:
                              addbankAccountController.textEditingControllerAcc,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFieldRefs(
                          inputAlignment: TextAlign.start,
                          txt: "Bank Name".tr,
                          inputType: TextInputType.name,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "Bank Name is Empty".tr;
                            }
                            return null;
                          },
                          textEditingControllerCommon: addbankAccountController
                              .textEditingControllerBankName,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFieldRefs(
                          inputAlignment: TextAlign.start,
                          txt: "Branch Name".tr,
                          inputType: TextInputType.name,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "Branch Name is Empty".tr;
                            }
                            return null;
                          },
                          textEditingControllerCommon: addbankAccountController
                              .textEditingControllerBranchName,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFieldRefs(
                          inputAlignment: TextAlign.start,
                          txt: "IBAN Name".tr,
                          inputType: TextInputType.name,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "IBAN Name is Empty".tr;
                            }
                            return null;
                          },
                          textEditingControllerCommon: addbankAccountController
                              .textEditingControllerIBAN,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFieldRefs(
                          inputAlignment: TextAlign.start,
                          txt: "SWIFT/BIC Code".tr,
                          inputType: TextInputType.name,
                          validator: (value) {
                            if (value != null && value.isEmpty) {
                              return "SWIFT/BIC Code is Empty".tr;
                            }
                            return null;
                          },
                          textEditingControllerCommon: addbankAccountController
                              .textEditingControllerSwift,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        CustomsButtons(
                            text: "Continue".tr,
                            backgroundColor: themeColor,
                            onPressed: () {
                              addbankAccountController.submitpaymentDetails(
                                  context, addbankAccountController.globalKey);
                            }),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
