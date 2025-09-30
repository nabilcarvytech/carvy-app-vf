import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/add_bank_account_controller.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/get_payment_details_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/wallet/add_payment_detials.dart';
import 'package:carvy/view/host/wallet/bank_account_host.dart';

class PaymentMethod extends StatefulWidget {
  const PaymentMethod({super.key});

  @override
  State<PaymentMethod> createState() => _PaymentMethodState();
}

class _PaymentMethodState extends State<PaymentMethod> {
  AddBankAccount addbankAccountController = Get.find();
  Map<String, dynamic>? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    addbankAccountController.clearAccountPreviousData();
    addbankAccountController.getPaymentTypeModel = null;
    addbankAccountController.paymentMethodModel = null;
    addbankAccountController.fetchPaymentMethod().then((_) {
      addbankAccountController.fetchPaymentType().then((_) {
        final payoutMethods =
            addbankAccountController.getPaymentTypeModel?.data?.payoutMethods;
        final payoutTypes =
            addbankAccountController.paymentMethodModel?.data?.payoutTypes;

        if (payoutMethods != null && payoutMethods.isNotEmpty) {
          PayoutMethod? activeMethod = payoutMethods.firstWhere(
            (method) => method.details?.isActive == 1,
            orElse: () => PayoutMethod(id: 0, payoutMethod: 'None'),
          );
          if (activeMethod.id != 0) {
            setState(() {
              _selectedPaymentMethod = {
                'id': activeMethod.id,
                'name': activeMethod.payoutMethod,
              };
              addbankAccountController.id = activeMethod.id?.toString() ?? '';
              addbankAccountController.type = activeMethod.payoutMethod ?? '';
              addbankAccountController.textEditingControllerAccName.text =
                  activeMethod.details?.accountName ?? '';
              addbankAccountController.textEditingControllerAcc.text =
                  activeMethod.details?.accountNumber ?? '';
              addbankAccountController.textEditingControllerBankName.text =
                  activeMethod.details?.bankName ?? '';
              addbankAccountController.textEditingControllerBranchName.text =
                  activeMethod.details?.branchName ?? '';
              addbankAccountController.textEditingControllerIBAN.text =
                  activeMethod.details?.iban ?? '';
              addbankAccountController.textEditingControllerSwift.text =
                  activeMethod.details?.swiftCode ?? '';
              addbankAccountController.email.text =
                  activeMethod.details?.email ?? '';
              addbankAccountController.note.text =
                  activeMethod.details?.note ?? '';
            });
          }
        } else if (payoutTypes != null && payoutTypes.isNotEmpty) {
          final firstMethod = payoutTypes.first;
          setState(() {
            _selectedPaymentMethod = {
              'id': firstMethod.id,
              'name': firstMethod.name,
            };
            addbankAccountController.id = firstMethod.id?.toString() ?? '';
            addbankAccountController.type = firstMethod.name ?? '';
          });
        } else {
          setState(() {
            _selectedPaymentMethod = null;
            addbankAccountController.id = '';
            addbankAccountController.type = '';
          });
        }
      });
    });
  }

  void _onPaymentMethodSelected(Map<String, dynamic>? value) {
    setState(() {
      _selectedPaymentMethod = value;
    });

    if (value == null) {
      addbankAccountController.id = '';
      addbankAccountController.type = '';
      return;
    }

    final payoutMethods =
        addbankAccountController.getPaymentTypeModel?.data?.payoutMethods;
    final selectedId = value['id'];
    addbankAccountController.id = selectedId?.toString() ?? '';
    addbankAccountController.type = value['name'] ?? '';

    if (payoutMethods != null && payoutMethods.isNotEmpty) {
      final userMethod = payoutMethods.firstWhere(
        (method) => method.id == selectedId,
        orElse: () => PayoutMethod(id: 0, payoutMethod: 'None'),
      );

      if (userMethod.id != 0) {
        addbankAccountController.textEditingControllerAccName.text =
            userMethod.details?.accountName ?? '';
        addbankAccountController.textEditingControllerAcc.text =
            userMethod.details?.accountNumber ?? '';
        addbankAccountController.textEditingControllerBankName.text =
            userMethod.details?.bankName ?? '';
        addbankAccountController.textEditingControllerBranchName.text =
            userMethod.details?.branchName ?? '';
        addbankAccountController.textEditingControllerIBAN.text =
            userMethod.details?.iban ?? '';
        addbankAccountController.textEditingControllerSwift.text =
            userMethod.details?.swiftCode ?? '';
        addbankAccountController.email.text = userMethod.details?.email ?? '';
        addbankAccountController.note.text = userMethod.details?.note ?? '';
      }
    }
  }

  Future<void> _updatePaymentMethodStatus(
    BuildContext context,
    int methodId,
    int isActive,
    PayoutMethod userMethod,
    AddBankAccount controller,
  ) async {
    try {
      final existingPayoutMethods =
          controller.getPaymentTypeModel?.data?.payoutMethods ?? [];

      List<Map<String, dynamic>> payoutMethodsList =
          existingPayoutMethods.map((method) {
        final int parsedMethodId = method.id ?? 0;
        final int methodIsActive = parsedMethodId == methodId
            ? isActive
            : (method.details?.isActive ?? 0);
        return {
          "payout_method_id": parsedMethodId,
          "is_active": methodIsActive,
          if (method.payoutMethod?.toLowerCase() == "bank account") ...{
            "account_name": method.details?.accountName,
            "bank_name": method.details?.bankName,
            "branch_name": method.details?.branchName,
            "account_number": method.details?.accountNumber,
            "iban": method.details?.iban,
            "swift_code": method.details?.swiftCode,
          } else ...{
            "email": method.details?.email,
            "note": method.details?.note,
          }
        };
      }).toList();

      var map = {
        "payout_methods": payoutMethodsList,
        "active_payout_method_id": methodId,
      };

      showLoading();
      var response = await httpPost(Config.addPaymentMethod, map);
      closeLoading();

      if (response is String) {
        try {
          response = jsonDecode(response);
          debugPrint("Decoded API Response: $response");
        } catch (e) {
          showErrorToastMessage("Invalid API response format: $response");
          debugPrint("JSON Decode Error: $e");
          return;
        }
      }

      if (response is Map<String, dynamic> && response["status"] != null) {
        if (response["status"] == 200) {
          if (response["data"] is Map<String, dynamic> &&
              (response["data"]["payout_methods"] == null ||
                  response["data"]["payout_methods"] is List)) {
            addbankAccountController.getPaymentTypeModel =
                GetPaymentTypeModel.fromJson(response);
            showToastMessage("Payment method status updated successfully");
            setState(() {});
          } else {
            showErrorToastMessage(
                "Unexpected payout_methods format in response");
            debugPrint("Invalid payout_methods: ${response["data"]}");
          }
        } else {
          showErrorToastMessage(
              "${response["error"] ?? "Failed to update payment method status"}");
        }
      } else {
        showErrorToastMessage("Unexpected API response format: $response");
        debugPrint("Invalid response structure: $response");
      }
    } catch (e) {
      closeLoading();
      showErrorToastMessage("An error occurred: $e");
      debugPrint("Exception: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
        title: 'Payment Options'.tr,
        backgroundColor: notifires.getbgcolor,
        iconColor: notifires.getwhiteblackcolor,
        titleColor: notifires.getwhiteblackcolor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select a Payment Method'.tr, style: heading2(context)),
            const SizedBox(height: 8),
            Text(
              'Choose one option to add your payment method'.tr,
              style: regular2(context),
            ),
            const SizedBox(height: 20),
            Obx(
              () => addbankAccountController.isLoadingPayment.value
                  ? const Center(child: SizedBox())
                  : addbankAccountController
                              .paymentMethodModel?.data?.payoutTypes?.isEmpty ??
                          true
                      ? Center(
                          child: buildNoDataWidget(
                            context,
                            "Data not found".tr,
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: addbankAccountController
                                    .paymentMethodModel
                                    ?.data
                                    ?.payoutTypes
                                    ?.length ??
                                0,
                            itemBuilder: (context, index) {
                              final method = addbankAccountController
                                  .paymentMethodModel
                                  ?.data
                                  ?.payoutTypes?[index];
                              if (method == null ||
                                  method.id == null ||
                                  method.name == null) {
                                return const SizedBox.shrink();
                              }

                              final payoutMethods = addbankAccountController
                                  .getPaymentTypeModel?.data?.payoutMethods;
                              final userMethod = payoutMethods != null &&
                                      payoutMethods.isNotEmpty
                                  ? payoutMethods.firstWhere(
                                      (m) => m.id == method.id,
                                      orElse: () => PayoutMethod(
                                          id: 0, payoutMethod: 'None'),
                                    )
                                  : null;

                              String statusText = '';
                              Color? statusColor;
                              bool isActive = false;
                              if (userMethod != null && userMethod.id != 0) {
                                isActive = userMethod.details?.isActive == 1;
                                statusText =
                                    isActive ? ' (Active)' : ' (Inactive)';
                                statusColor =
                                    isActive ? Colors.green : Colors.red;
                              } else {
                                statusText = ' (Not Configured)';
                                statusColor = Colors.grey;

                                if (_selectedPaymentMethod == null) {
                                  WidgetsBinding.instance
                                      .addPostFrameCallback((_) {
                                    _onPaymentMethodSelected({
                                      'id': method.id,
                                      'name': method.name,
                                    });
                                  });
                                }
                              }

                              final isSelected =
                                  _selectedPaymentMethod?['id'] == method.id;

                              return InkWell(
                                onTap: () {
                                  _onPaymentMethodSelected({
                                    'id': method.id,
                                    'name': method.name,
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isSelected
                                            ? getColorBasedOnActiveModuleid()
                                            : notifires.getGrey4Whitecolor,
                                      ),
                                    ),
                                    height: 60,
                                    child: Row(
                                      children: [
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Text(
                                                (method.name ?? 'Unknown')
                                                    .capitalizeFirst!,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: isSelected
                                                      ? FontWeight.w600
                                                      : FontWeight.w500,
                                                  color: isSelected
                                                      ? themeColor
                                                      : notifires
                                                          .getGrey2Whitecolor,
                                                ),
                                              ),
                                              const Spacer(),
                                              Text(
                                                statusText,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: statusColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        if (userMethod != null &&
                                            userMethod.id != 0)
                                          Transform.scale(
                                            scale: 0.7,
                                            child: Switch(
                                              value: isActive,
                                              onChanged: (bool newValue) async {
                                                await _updatePaymentMethodStatus(
                                                  context,
                                                  method.id ?? 0,
                                                  newValue ? 1 : 0,
                                                  userMethod,
                                                  addbankAccountController,
                                                );
                                              },
                                              activeColor: Colors.green,
                                              inactiveThumbColor: Colors.red,
                                            ),
                                          ),
                                        IconButton(
                                          onPressed: () {
                                            if (_selectedPaymentMethod ==
                                                    null ||
                                                _selectedPaymentMethod!['id'] !=
                                                    method.id) {
                                              _onPaymentMethodSelected({
                                                'id': method.id,
                                                'name': method.name,
                                              });
                                            }

                                            final selectedId =
                                                _selectedPaymentMethod!['id'];
                                            final selectedName =
                                                _selectedPaymentMethod!['name'];

                                            if (statusText ==
                                                ' (Not Configured)') {
                                              addbankAccountController
                                                  .clearAccountPreviousData();
                                            }

                                            if (selectedName
                                                    .toString()
                                                    .toLowerCase() ==
                                                "bank account") {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (builder) =>
                                                      const AddBankAccountScreen(),
                                                ),
                                              );
                                            } else {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (builder) =>
                                                      AddPaymentDetials(
                                                    addedit: userMethod == null
                                                        ? "Add"
                                                        : "Edit",
                                                    id: selectedId,
                                                    type: selectedName,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: Icon(
                                            userMethod == null
                                                ? Icons.add
                                                : Icons.edit,
                                            size: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
