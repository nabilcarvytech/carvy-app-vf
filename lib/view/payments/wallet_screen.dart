import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/customwidget/data_not_found.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/get_user_wallet_transactions.dart';
import 'package:carvy/model/wallet_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/safe_rebuild.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/payments/wallet_recharge_screen.dart';
import 'package:carvy/work_space.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  RefreshController refreshController = RefreshController();

  List<WalletTransactionsDetails> list = [];
  GetUserWalletTransactions? walletTransactions;
  WalletModel? walletModel;
  num offset = 0;

  RxString balanceAmount = ''.obs;

  getData() async {
    list.clear();
    walletTransactions = null;
    walletModel = null;

    try {
      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // var response = await httpPost(Config.getUserWallet, {});
      //
      // if (response != null) {
      //   walletModel = WalletModel.fromJson(response);
      //   balanceAmount.value = walletModel!.data!.walletBalance!;
      // }

      // MOCK: Simulate network delay for wallet balance
      await Future.delayed(const Duration(milliseconds: 500));

      // MOCK: Static wallet balance
      Map<String, dynamic> mockWalletResponse = {
        "status": 200,
        "message": "Wallet data retrieved successfully",
        "error": "",
        "data": {
          "wallet_balance": "150.00"
        }
      };

      walletModel = WalletModel.fromJson(mockWalletResponse);
      balanceAmount.value = walletModel!.data!.walletBalance ?? "0.00";

      // ========== MOCK DATA - OLD TRANSACTIONS CALL COMMENTED ==========
      // var transactionsResponse = await httpGet(
      //     Config.getUserWalletTransactions, {"offset": "$offset"});
      //
      // if (transactionsResponse != null) {
      //   walletTransactions =
      //       GetUserWalletTransactions.fromJson(transactionsResponse);
      //   list.addAll(walletTransactions!.data!.walletTransactionsDetails!);
      //   offset = walletTransactions!.data!.offset!;
      // }

      // MOCK: Simulate network delay for transactions
      await Future.delayed(const Duration(milliseconds: 500));

      // MOCK: Static wallet transactions list (minimal pour UI)
      Map<String, dynamic> mockTransactionsResponse = {
        "status": 200,
        "message": "Wallet transactions retrieved successfully",
        "error": "",
        "data": {
          "walletTransactionsDetails": [
            {
              "id": 1,
              "type": "credit",
              "amount": "50.00",
              "description": "Booking refund",
              "created_at": "2024-12-15 10:00:00"
            },
            {
              "id": 2,
              "type": "debit",
              "amount": "20.00",
              "description": "Booking payment",
              "created_at": "2024-12-10 15:30:00"
            }
          ],
          "offset": 2,
          "limit": 10
        }
      };

      walletTransactions =
          GetUserWalletTransactions.fromJson(mockTransactionsResponse);
      list.addAll(walletTransactions!.data!.walletTransactionsDetails!);
      offset = walletTransactions!.data!.offset ?? 2;

      setState(() {});
    } catch (e) {
      print(e);
    } finally {
      refreshController.loadComplete();
      refreshController.refreshCompleted();
    }
  }

  @override
  void initState() {
    super.initState();
    runAfterFirstFrame(getData);
  }

  onLoading() {
    setState(() {});
    getData();
  }

  onRefresh() {
    walletTransactions = null;
    list.clear();
    setState(() {});
    offset = 0;
    getData();
  }

  Future<void> navigateScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const WalletRechargeScreen()),
    );
    onRefresh();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        width: Dimensions.containerWidth,
        child: Scaffold(
          backgroundColor: notifires.getbgcolor,
          appBar: CustomAppBars(
            onBackButtonPressed: () {
              generalController.currentIndex.value = 4;

              Get.offAll(() => const HomeMain(initialIndex: 4));
            },
            title: 'Wallet'.tr,
            backgroundColor: notifires.getbgcolor,
            iconColor: notifires.getwhiteblackcolor,
            titleColor: notifires.getwhiteblackcolor,
            actions: [
              InkWell(
                  onTap: () {
                    navigateScreen();
                  },
                  child: Text(
                    "Recharge".tr,
                    style: heading3(context)
                        .copyWith(color: getColorBasedOnActiveModuleid()),
                  )),
              const SizedBox(
                width: 20,
              )
            ],
          ),
          body: walletModel == null
              ? Center(child: CircularProgressIndicator())
              : SmartRefresher(
                  onRefresh: onRefresh,
                  controller: refreshController,
                  child: SingleChildScrollView(
                      child: Stack(children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 232,
                              width: Get.size.width,
                              alignment: Alignment.topLeft,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/walletIMage.png"),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 30),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 0, left: 15),
                                    child: Text(
                                      "Wallet".tr,
                                      textAlign: TextAlign.start,
                                      style: heading2(context).copyWith(
                                          color: notifires.getblackwhitecolor),
                                    ),
                                  ),
                                  const SizedBox(height: 40),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10, left: 15),
                                  ),
                                  Obx(() => Padding(
                                        padding: const EdgeInsets.only(
                                            top: 0, left: 15),
                                        child: Text(
                                            balanceAmount.value == ''
                                                ? "....."
                                                : "$currency ${balanceAmount.value}",
                                            style: heading1(context).copyWith(
                                                fontSize: 30,
                                                color: notifires
                                                    .getblackwhitecolor)),
                                      )),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 0, left: 15),
                                    child: Text("Your Current Balance".tr,
                                        style: heading2(context).copyWith(
                                            color:
                                                notifires.getblackwhitecolor)),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            Text("History".tr, style: heading3Grey1(context)),
                            const SizedBox(
                              height: 8,
                            ),
                            list.isEmpty
                                ? SizedBox()
                                : ListView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: list.length,
                                    itemBuilder: (itemBuilder, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 5),
                                        child: Container(
                                            alignment: Alignment.center,
                                            height: 84,
                                            decoration: BoxDecoration(
                                              color: notifires.getBoxColor,
                                              borderRadius:
                                                  BorderRadius.circular(13),
                                            ),
                                            width: Get.size.height,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 20,
                                                      vertical: 8),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(
                                                    height: 8,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.wallet,
                                                        size: 20,
                                                        color:
                                                            getColorBasedOnActiveModuleid(),
                                                      ),
                                                      const SizedBox(
                                                        width: 10,
                                                      ),
                                                      Text(
                                                          list[index]
                                                              .description!,
                                                          style:
                                                              regular2(context)
                                                                  .copyWith()),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text(list[index].type!,
                                                          style: regular2(context).copyWith(
                                                              color: list[index]
                                                                          .type ==
                                                                      "debit"
                                                                  ? Colors.red
                                                                  : Colors
                                                                      .green)),
                                                      const SizedBox(
                                                        width: 30,
                                                      ),
                                                      Text(
                                                          list[index]
                                                              .createdAt!,
                                                          style: regular(
                                                                  context)
                                                              .copyWith(
                                                                  color: notifires
                                                                      .getGrey3Whitecolor)),
                                                      const Spacer(),
                                                      Text(
                                                          "${list[index].currency} ${list[index].amount}",
                                                          style:
                                                              boldstyle(context)
                                                                  .copyWith(
                                                            fontSize: 16,
                                                            color: list[index]
                                                                        .type ==
                                                                    "debit"
                                                                ? Colors.red
                                                                : Colors.green,
                                                          )),
                                                      const SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            )),
                                      );
                                    }),
                          ]),
                    )
                  ])),
                ),
        ),
      ),
    );
  }
}
