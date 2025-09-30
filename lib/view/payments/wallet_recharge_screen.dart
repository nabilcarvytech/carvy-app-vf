import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../customwidget/form_elements.dart';
import '../../customwidget/miscellaneous_project_elements.dart';
import '../../customwidget/project_bar.dart';
import '../../customwidget/project_color.dart';
import '../../utils/common_widget.dart';
import '../../utils/theme_style.dart';
import '../../work_space.dart';
import '../booking/payment_screen.dart';

class WalletRechargeScreen extends StatefulWidget {
  const WalletRechargeScreen({super.key});

  @override
  State<WalletRechargeScreen> createState() => _WalletRechargeScreenState();
}

class _WalletRechargeScreenState extends State<WalletRechargeScreen> {

  List price = [
    {"price": "100"},
    {"price": "200"},
    {"price": "500"},
    {"price": "1000"},
    {"price": "1500"},
    {"price": "2000"},
  ];
  int selectedPrice=7;
  TextEditingController priceText=TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
        title: "",
        titleColor: notifires.getbgcolor,
        backgroundColor: notifires.getbgcolor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Amount".tr,
                style: heading2Grey1(context),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: priceText,
                cursorColor: getColorBasedOnActiveModuleid(),
                onChanged: (v){
                  setState(() {
                    selectedPrice=-1;
                  });
                },
                decoration: InputDecoration(
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: "Enter amount".tr,
                    hintStyle: heading2(context)
                        .copyWith(color: notifires.getGrey3Whitecolor),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(top: 10, right: 20),
                      child: Text(
                        currency,
                        style: heading2(context)
                            .copyWith(color: notifires.getGrey3Whitecolor),
                      ),
                    )),
                keyboardType: TextInputType.number,
                style: heading1(context)
                    .copyWith(color: getColorBasedOnActiveModuleid()),
                textAlign: TextAlign.start,
              ),
              Divider(
                thickness: 2,
                color: getColorBasedOnActiveModuleid(),
                height: 1,
              ),
              const SizedBox(
                height: 40,
              ),

              SizedBox(
                height: 200,
                child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 25,
                    mainAxisSpacing: 20,
                    mainAxisExtent: 45
                ),
                  itemBuilder: (context,index){

                    return GestureDetector(
                      onTap: (){
                        setState(() {
                          selectedPrice=index;
                          priceText.text=price[index]["price"];
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: grey4.withOpacity(.2),
                                  blurRadius: 3,spreadRadius: 2,
                                  offset: const Offset(0,0)
                              )
                            ],
                            color: selectedPrice==index?getColorBasedOnActiveModuleid():notifires.getBoxColor,
                             borderRadius: BorderRadius.circular(12)
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Text("$currency ${price[index]["price"]}",style: regular2(context).copyWith(color: selectedPrice==index?Colors.white:getColorBasedOnActiveModuleid()),),

                      ),
                    );
                  },itemCount: price.length,),
              ),
              CustomsButtons(text: "Buy now".tr, backgroundColor: getColorBasedOnActiveModuleid(), onPressed: (){
                if (priceText.text.isNotEmpty) {
                      navigateToUrl(
                        endpoint:
                            "/wallet_recharge", // The endpoint for the API
                        queryParams: {
                          "token": token,
                          "amount": priceText.text,
                          "currency": currency,
                        },
                        pageBuilder: (url) =>
                            PaymentScreen(url: url), // Dynamically pass the URL
                      );
                    } else {
                      showErrorToastMessage("Please Enter Amount".tr);
                    }
              })
            ],
          ),
        ),
      ),
    );
  }
}