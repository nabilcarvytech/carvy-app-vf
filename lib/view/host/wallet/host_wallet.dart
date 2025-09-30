import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';

import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/vendor_wallet.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/wallet/payout_screen.dart';
import '../../../model/get_vendor_wallet_transactions.dart';
import '../../../work_space.dart';
import 'package:get/get.dart';

class HostWallet extends StatefulWidget {
  const HostWallet({super.key});

  @override
  State<HostWallet> createState() => _HostWalletState();
}

class _HostWalletState extends State<HostWallet> {
  VendorWallet? vendorWallet;
  GetVendorWalletTransactions? getVendorWalletTransactions;
  List<WalletTransactionsDetails> list = [];
  RefreshController refreshController = RefreshController();
  num offset = 0;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    httpPost(Config.getVendorWallet, {}).then((response) {
      if (response != null) {
        vendorWallet = VendorWallet.fromJson(response);
        setState(() {});
      }
      refreshController.loadComplete();
      refreshController.refreshCompleted();
    });

    httpPost(Config.getVendorWalletTransactions, {"offset": "$offset"})
        .then((response) {
      if (response != null) {
        getVendorWalletTransactions =
            GetVendorWalletTransactions.fromJson(response);
        list.addAll(
            getVendorWalletTransactions!.data!.walletTransactionsDetails!);
        offset = getVendorWalletTransactions!.data!.offset!;
        setState(() {});
      }
      refreshController.loadComplete();
      refreshController.refreshCompleted();
    });
  }

  onLoading() {
    getData();
  }

  onRefresh() {
    getVendorWalletTransactions = null;
    vendorWallet = null;
    list = [];
    setState(() {});
    offset = 0;
    getData();
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        body: SmartRefresher(
          controller: refreshController,
          onRefresh: onRefresh,
          onLoading: onLoading,
          enablePullUp: offset == -1 ? false : true,
          child: vendorWallet == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
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
                                      "Wallet Balance".tr,
                                      style: regular2(context)
                                          .copyWith(color: themeColor),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "$currency ${vendorWallet?.data?.walletBalance ?? ''}",
                                      style: headingh5.copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: themeColor),
                                    ),
                                  ]),
                              const Spacer(),
                              InkWell(
                                onTap: () {
                                  if (vendorWallet?.data?.walletBalance
                                          .toString() ==
                                      "0.00") {
                                    showErrorToastMessage(
                                        "Insufficient balance".tr);
                                    return;
                                  }
                                  Get.to(() => PayoutScreen(
                                        walletBalance:
                                            vendorWallet!.data!.walletBalance!,
                                      ));
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 6),
                          child: Row(
                            children: [
                              Text("Transactions".tr,
                                  style: heading2Grey1(context)),
                              const SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.history, color: grey3),
                            ],
                          ),
                        ),
                        getVendorWalletTransactions == null
                            ? const Center(
                                child: CircularProgressIndicator(),
                              )
                            : list.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 40.0, bottom: 40),
                                      child: Center(
                                          child: buildNoDataWidget(
                                        context,
                                        "No Transaction Available".tr,
                                      )),
                                    ),
                                  )
                                : ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: list.length,
                                    shrinkWrap: true,
                                    itemBuilder: (itemBuilder, index) {
                                      return _buildTransactionTile(list[index]);
                                    },
                                  )
                      ],
                    ),
                  ),
                ),
        ));
  }

  Widget _buildTransactionTile(
      WalletTransactionsDetails walletTransactionDetail) {
    bool isCredit =
        walletTransactionDetail.type.toString().toLowerCase() == "credit";
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: notifires.getBoxColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor:
                    isCredit ? Colors.green.shade100 : Colors.red.shade100,
                child: Icon(
                  isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isCredit ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(walletTransactionDetail.type?.toString() ?? "",
                          style: heading3Grey1(context)),
                      const SizedBox(height: 0),
                      Text(walletTransactionDetail.description ?? "",
                          style: regular(context)),
                      Text(
                        "${walletTransactionDetail.createdAt}",
                        style: regular(context).copyWith(color: grey4),
                      )
                    ]),
              ),
              Text(
                "$currency ${walletTransactionDetail.amount ?? ""}",
                style: TextStyle(
                  fontSize: 14,
                  color: isCredit ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
