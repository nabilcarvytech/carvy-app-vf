import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/get_payment_details_model.dart';
import 'package:carvy/model/insert_data_account.dart';
import 'package:carvy/model/payment_method_model.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/work_space.dart';

class AddBankAccount extends GetxController implements GetxService {
  TextEditingController textEditingControllerBankName = TextEditingController();
  TextEditingController textEditingControllerBranchName =
      TextEditingController();
  TextEditingController textEditingControllerAcc = TextEditingController();
  TextEditingController textEditingControllerAccName = TextEditingController();
  TextEditingController textEditingControllerIBAN = TextEditingController();
  TextEditingController textEditingControllerSwift = TextEditingController();
  GlobalKey<FormState> globalKey = GlobalKey();
  TextEditingController email = TextEditingController();
  TextEditingController note = TextEditingController();
  var isloading = false.obs;
  var isLoadingPayment = false.obs;
  InsertDataAccount? insertDataAccount;
  PaymentMethodModel? paymentMethodModel;
  GetPaymentTypeModel? getPaymentTypeModel;

  clearAccountPreviousData() {
    textEditingControllerBankName.clear();
    textEditingControllerBranchName.clear();
    textEditingControllerAcc.clear();
    textEditingControllerSwift.clear();
    textEditingControllerIBAN.clear();
    textEditingControllerAccName.clear();
    email.clear();
    note.clear();
  }

  dynamic id = "";
  dynamic type = "";
  Future fetchPaymentMethod() async {
    isLoadingPayment.value = true;
    paymentMethodModel = null;
    try {
      showLoading();
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var res = await httpGet(Config.getPayoutType, {});

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static payout types data
      var res = {
        "status": 200,
        "message": "Payout types retrieved successfully",
        "error": "",
        "data": {
          "payout_methods": [
            {"id": 1, "name": "Bank Account"},
            {"id": 2, "name": "PayPal"},
            {"id": 3, "name": "Stripe"}
          ]
        }
      };
      // ========== END MOCK DATA ==========
      closeLoading();
      if (res != null && res["status"] == 200) {
        paymentMethodModel = PaymentMethodModel.fromJson(res);
        isLoadingPayment.value = false;
      }
      update();
    } catch (e) {
      closeLoading();
      isLoadingPayment.value = false;
      update();
    }
  }

  Future fetchPaymentType() async {
    isLoadingPayment.value = true;
    getPaymentTypeModel = null;
    await Future.delayed(const Duration(seconds: 1));
    try {
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var res = await httpPost(Config.getPayoutMethod, {});

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static payout methods data
      var res = {
        "status": 200,
        "message": "Payout methods retrieved successfully",
        "error": "",
        "data": {
          "payout_methods": [
            {
              "id": 1,
              "payout_method": "Bank Account",
              "details": {
                "id": 1,
                "is_active": 0,
                "account_name": null,
                "bank_name": null,
                "branch_name": null,
                "account_number": null,
                "iban": null,
                "swift_code": null,
                "email": null,
                "note": null,
                "user_id": null,
                "created_at": null,
                "updated_at": null
              }
            },
            {
              "id": 2,
              "payout_method": "PayPal",
              "details": {
                "id": 2,
                "is_active": 0,
                "account_name": null,
                "bank_name": null,
                "branch_name": null,
                "account_number": null,
                "iban": null,
                "swift_code": null,
                "email": null,
                "note": null,
                "user_id": null,
                "created_at": null,
                "updated_at": null
              }
            }
          ]
        }
      };
      // ========== END MOCK DATA ==========

      if (res != null && res["status"] == 200) {
        getPaymentTypeModel = GetPaymentTypeModel.fromJson(res);
        isLoadingPayment.value = false;
      }
      update();
    } catch (e) {
      isLoadingPayment.value = false;
      update();
    }
  }

  Future<void> submitpaymentDetails(
      BuildContext context, GlobalKey<FormState> formKey) async {
    if (!formKey.currentState!.validate()) {
      return;
    }
    try {
      final int? parsedId = int.tryParse(id.toString());
      if (parsedId == null) {
        showErrorToastMessage("Invalid payment method ID: $id");
        return;
      }

      Map<String, dynamic> payoutMethodDetails = {
        "payout_method_id": parsedId,
        "is_active": 1,
      };

      if (type.toLowerCase() == "bank account") {
        payoutMethodDetails.addAll({
          "account_name": textEditingControllerAccName.text,
          "bank_name": textEditingControllerBankName.text,
          "branch_name": textEditingControllerBranchName.text,
          "account_number": textEditingControllerAcc.text,
          "iban": textEditingControllerIBAN.text,
          "swift_code": textEditingControllerSwift.text,
        });
      } else {
        payoutMethodDetails.addAll({
          "email": email.text,
          "note": note.text,
        });
      }

      final existingPayoutMethods =
          getPaymentTypeModel?.data?.payoutMethods ?? [];

      List<Map<String, dynamic>> payoutMethodsList =
          existingPayoutMethods.map((method) {
        final int? parsedMethodId = int.tryParse(method.id.toString()) ?? 0;

        if (parsedMethodId == parsedId) {
          return payoutMethodDetails;
        }

        return {
          "payout_method_id": parsedMethodId,
          "is_active": method.details?.isActive ?? 0,
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

      if (!existingPayoutMethods
          .any((method) => int.tryParse(method.id.toString()) == parsedId)) {
        payoutMethodsList.add(payoutMethodDetails);
      }

      var map = {
        "payout_methods": payoutMethodsList,
        "active_payout_method_id": parsedId,
      };

      showLoading();
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response = await httpPost(Config.addPaymentMethod, map);

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static success response for adding payment method
      var response = {
        "status": 200,
        "message": "Payment method updated successfully",
        "error": "",
        "data": {
          "payout_methods": [
            {
              "id": parsedId,
              "payout_method": type,
              "details": {
                "id": 1,
                "is_active": 1,
                "account_name": payoutMethodDetails["account_name"],
                "bank_name": payoutMethodDetails["bank_name"],
                "branch_name": payoutMethodDetails["branch_name"],
                "account_number": payoutMethodDetails["account_number"],
                "iban": payoutMethodDetails["iban"],
                "swift_code": payoutMethodDetails["swift_code"],
                "email": payoutMethodDetails["email"],
                "note": payoutMethodDetails["note"],
                "user_id": null,
                "created_at": DateTime.now().toIso8601String(),
                "updated_at": DateTime.now().toIso8601String()
              }
            }
          ]
        }
      };
      // ========== END MOCK DATA ==========
      closeLoading();

      // Note: Mock response is already a Map, so we skip the String check
      if (response is Map<String, dynamic> && response["status"] != null) {
        final status = int.tryParse(response["status"].toString()) ?? -1;
        if (status == 200) {
          final data = response["data"] as Map<String, dynamic>?;
          if (data != null &&
              (data["payout_methods"] == null ||
                  data["payout_methods"] is List)) {
            await addbankAccountController.fetchPaymentType();
            Get.back();
            showToastMessage("Payment method updated successfully");
          } else {
            showErrorToastMessage(
                "Unexpected payout_methods format in response");
            debugPrint("Invalid payout_methods: ${response["data"]}");
          }
        } else {
          showErrorToastMessage(
              "${response["error"] ?? "Failed to update payment method"}");
        }
      } else {
        showErrorToastMessage("Unexpected API response format: $response");
      }
    } catch (e) {
      closeLoading();
      showErrorToastMessage("An error occurred: $e");
    }
  }
}
