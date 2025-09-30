import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/payout_model.dart';
import 'package:carvy/model/payout_transaction.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/wallet/payment_method_screen.dart';
import 'package:carvy/work_space.dart';

class PayoutScreen extends StatefulWidget {
  final String walletBalance;
  const PayoutScreen({super.key, required this.walletBalance});

  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  GlobalKey<FormState> globalKey = GlobalKey();
  num offset = 0;
  RefreshController refreshController = RefreshController();
  PayoutTransaction? payoutTransaction;
  TextEditingController textEditingController = TextEditingController();
  List<PayoutTransactions> list = [];
  @override
  void initState() {
    super.initState();

    addbankAccountController.fetchPaymentMethod();

    addbankAccountController.fetchPaymentType().then((_) {
      final payoutTypes =
          addbankAccountController.getPaymentTypeModel?.data?.payoutMethods;

      if (payoutTypes != null && payoutTypes.isNotEmpty) {
        final firstMethod = payoutTypes.first;
        setState(() {
          addbankAccountController.id = firstMethod.id ?? '';
          addbankAccountController.type = firstMethod.payoutMethod ?? '';
          addbankAccountController.textEditingControllerAccName.text =
              firstMethod.details?.accountName ?? '';
          addbankAccountController.textEditingControllerAcc.text =
              firstMethod.details?.accountNumber ?? '';
          addbankAccountController.textEditingControllerBankName.text =
              firstMethod.details?.bankName ?? '';
          addbankAccountController.textEditingControllerBranchName.text =
              firstMethod.details?.branchName ?? '';
          addbankAccountController.textEditingControllerIBAN.text =
              firstMethod.details?.iban ?? '';
          addbankAccountController.textEditingControllerSwift.text =
              firstMethod.details?.swiftCode ?? '';
          addbankAccountController.email.text =
              firstMethod.details?.email ?? '';
          addbankAccountController.note.text = firstMethod.details?.note ?? '';
        });
      }
    });
    getData();
  }

  getData() async {
    var ress =
        await httpPost(Config.getPayoutTransactions, {"offset": "$offset"});
    if (ress != null) {
      payoutTransaction = PayoutTransaction.fromJson(ress);
      list.addAll(payoutTransaction!.data!.payoutTransactions!);
      offset = payoutTransaction!.data!.offset!;
    }
    setState(() {});
    refreshController.loadComplete();
    refreshController.refreshCompleted();
  }

  onLoading() {
    getData();
  }

  onRefresh() {
    payoutTransaction = null;
    list = [];
    setState(() {});
    offset = 0;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: notifires.getbgcolor,
      appBar: AppBar(
        backgroundColor: notifires.getbgcolor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back,
            color: notifires.getwhiteblackcolor,
          ),
        ),
        title: Text(
          "PayOut".tr,
          style: TextStyle(
            fontSize: 17,
            // fontFamily: FontStyles.gilroyBold,
            color: notifires.getwhiteblackcolor,
          ),
        ),
      ),
      body: SmartRefresher(
        controller: refreshController,
        onRefresh: onRefresh,
        onLoading: onLoading,
        enablePullUp: offset == -1 ? false : true,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: notifires.getBoxColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet,
                              color: themeColor, size: 40),
                          const SizedBox(width: 16),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "TotalEarning".tr,
                                  style: regular2(context)
                                      .copyWith(color: themeColor),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "$currency ${widget.walletBalance}",
                                  style: headingh5.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: themeColor),
                                ),
                              ]),
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              if (widget.walletBalance.toString() == "0.00") {
                                showErrorToastMessage(
                                    "Insufficient balance".tr);
                                return;
                              }
                              payoutBottomSheet();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: themeColor,
                                  borderRadius: BorderRadius.circular(12)),
                              child: Text(
                                "Payout".tr,
                                style: regular2(context).copyWith(
                                    // fontWeight: FontWeight.bold,
                                    color: whiteColor),

                                // ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        "History".tr,
                        style: TextStyle(
                          fontSize: 17,
                          color: notifires.getwhiteblackcolor,
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    payoutTransaction == null
                        ? const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : list.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Center(
                                    child: buildNoDataWidget(
                                        context, "No data found".tr)),
                              )
                            : ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: list.length,
                                itemBuilder: (itemBuilder, index) {
                                  final payout = list[index];
                                  return Container(
                                    margin: const EdgeInsets.only(
                                        top: 8, left: 16, right: 16),
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: notifires.getblackwhitecolor,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: greyColor),
                                      boxShadow: const [
                                        BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4)
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text("ID: ${payout.id ?? "-"}",
                                                style: heading3Grey1(context)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                "Method: ${payout.paymentMethod ?? "-"}",
                                                style: regular(context)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                                "Created: ${payout.createdAt ?? "-"}",
                                                style: regular(context)
                                                    .copyWith(color: grey4)),
                                            Text(
                                                "Updated: ${payout.updatedAt ?? "-"}",
                                                style: regular(context)
                                                    .copyWith(color: grey4)),
                                          ],
                                        ),
                                        const Divider(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              payout.payoutStatus ?? "-",
                                              style: TextStyle(
                                                color: payout.payoutStatus ==
                                                        "Pending"
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              "${payout.currency ?? ""} ${payout.amount ?? ""}",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: payout.payoutStatus ==
                                                        "Pending"
                                                    ? Colors.red
                                                    : Colors.green,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (payout.payoutStatus == "Success" &&
                                            payout.image != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 12.0),
                                            child: Stack(
                                              alignment: Alignment.topLeft,
                                              children: [
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                  child: SizedBox(
                                                    width: double.infinity,
                                                    child:
                                                        myNetworkImageWithShimmer(
                                                            payout.image!),
                                                  ),
                                                ),
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(6.0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black54,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10.0),
                                                      bottomRight:
                                                          Radius.circular(10.0),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    "Proof of Payout",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void payoutBottomSheet() {
    final payoutTypes =
        addbankAccountController.getPaymentTypeModel?.data?.payoutMethods ?? [];

    final activePayoutTypes =
        payoutTypes.where((method) => method.details?.isActive == 1).toList();
    int? selectedMethodId =
        activePayoutTypes.isNotEmpty ? activePayoutTypes.first.id : null;
    showModalBottomSheet<void>(
      backgroundColor: notifires.getbgcolor,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 16),

                    Text(
                      "Choose Payment Method".tr,
                      style: heading2(context),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Max payout Limit $currency ${widget.walletBalance}",
                      style: regular2(context),
                    ),
                    const SizedBox(height: 20),

                    if (activePayoutTypes.isNotEmpty) ...[
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: activePayoutTypes.length,
                          itemBuilder: (context, index) {
                            final method = activePayoutTypes[index];
                            // Ensure method.id is not null for comparison
                            if (method.id == null) {
                              return const SizedBox.shrink();
                            }
                            final isSelected = selectedMethodId == method.id;
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedMethodId = method.id;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: notifires.getBoxColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? themeColor
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Method: ${method.payoutMethod ?? 'Unknown'}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isSelected
                                                ? themeColor
                                                : notifires.getwhiteblackcolor,
                                          ),
                                        ),
                                        const Spacer(),
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (method.payoutMethod?.toLowerCase() ==
                                        "bank account") ...[
                                      if (method.details?.accountName != null)
                                        Text(
                                            "Account Name: ${method.details!.accountName}"),
                                      if (method.details?.accountNumber != null)
                                        Text(
                                            "Account Number: ${method.details!.accountNumber}"),
                                      if (method.details?.bankName != null)
                                        Text(
                                            "Bank: ${method.details!.bankName}"),
                                      if (method.details?.branchName != null)
                                        Text(
                                            "Branch: ${method.details!.branchName}"),
                                      if (method.details?.iban != null)
                                        Text("IBAN: ${method.details!.iban}"),
                                      if (method.details?.swiftCode != null)
                                        Text(
                                            "Swift: ${method.details!.swiftCode}"),
                                    ] else ...[
                                      if (method.details?.email != null)
                                        Text("Email: ${method.details!.email}"),
                                      if (method.details?.note != null)
                                        Text("Note: ${method.details!.note}"),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                    ] else ...[
                      Text("No active payout account added yet.".tr),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => const PaymentMethod(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Add Account".tr,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Show TextFormField only if there are active methods
                    if (activePayoutTypes.isNotEmpty)
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 1.1,
                        child: Form(
                          key: globalKey,
                          child: TextFormField(
                            controller: textEditingController,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: notifires.getgreycolor),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: notifires.getgreycolor),
                              ),
                              hintText: "Amount".tr,
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "EnterAmount".tr;
                              }
                              final parsedValue =
                                  double.tryParse(value.replaceAll(",", ""));
                              if (parsedValue == null)
                                return "InvalidNumber".tr;
                              if (parsedValue >
                                  double.parse(widget.walletBalance
                                      .replaceAll(",", ""))) {
                                return "MaxAmountExceeded".tr;
                              }
                              if (parsedValue < 10) {
                                return "MinimumAmountIs".tr;
                              }
                              return null;
                            },
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d*\.?\d{0,2}$')),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: themeColor.withOpacity(.2),
                                ),
                                child: Center(
                                  child: Text(
                                    "Cancel".tr,
                                    style: TextStyle(
                                      color: themeColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (activePayoutTypes.isNotEmpty) ...[
                            const SizedBox(width: 24),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  if (!globalKey.currentState!.validate())
                                    return;
                                  if (selectedMethodId == null) {
                                    showErrorToastMessage(
                                        "Please select a payment method.".tr);
                                    return;
                                  }

                                  showLoading();
                                  var response = await httpPost(
                                    Config.insertPayout,
                                    {
                                      "amount": textEditingController.text,
                                      "currency": currency,
                                      "active_payout_method_id":
                                          selectedMethodId,
                                    },
                                  );
                                  textEditingController.clear();
                                  closeLoading();

                                  if (response != null) {
                                    PayoutModel model =
                                        PayoutModel.fromJson(response);
                                    if (model.status == 200) {
                                      showToastMessage(model.message);
                                      Get.back();
                                      payoutTransaction = null;
                                      offset = 0;
                                      list = [];
                                      setState(() {});
                                      getData();
                                    } else {
                                      showErrorToastMessage(model.error);
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: themeColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "Proceed".tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
