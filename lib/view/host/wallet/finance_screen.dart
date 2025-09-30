import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/view/host/wallet/host_earning.dart';
import 'package:carvy/view/host/wallet/host_wallet.dart';

class FinanceMainScreen extends StatefulWidget {
  final bool isFormHome;
  const FinanceMainScreen({super.key, required this.isFormHome});

  @override
  State<FinanceMainScreen> createState() => _FinanceMainScreenState();
}

class _FinanceMainScreenState extends State<FinanceMainScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: CustomAppBars(
          onBackButtonPressed: () {
            Navigator.of(context).pop();
          },
          title: 'Financial Report'.tr,
          centerTitle: true,
          backgroundColor: notifires.getbgcolor,
          iconColor: notifires.getwhiteblackcolor,
          titleColor: notifires.getwhiteblackcolor,
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildTabItem(0, "Wallet".tr),
                  const SizedBox(width: 10),
                  _buildTabItem(1, "Earning".tr)
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: selectedIndex == 0
                  ? const Center(child: HostWallet())
                  : const Center(child: HostEarning()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(int index, String title) {
    bool isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? themeColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? themeColor : Colors.transparent, width: 1.5),
          boxShadow: isSelected == false
              ? [BoxShadow(color: grey5, blurRadius: 5)]
              : [],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? whiteColor : themeColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
