import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:carvy/controller/home_controller.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/myaccount/setting_screen.dart';
import 'package:carvy/work_space.dart';

class ChangeCurrency extends StatefulWidget {
  const ChangeCurrency({super.key});

  @override
  State<ChangeCurrency> createState() => _ChangeCurrencyState();
}

class _ChangeCurrencyState extends State<ChangeCurrency> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredCurrencyList = [];
  HomeController homeController = Get.find();
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      homeController.getCurrency().then((_) {
        setState(() {
          _filteredCurrencyList = homeController.currencyModel?.data ?? [];
        });
      });
    });
  }

  void _filterCurrencies(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCurrencyList = homeController.currencyModel?.data ?? [];
      } else {
        _filteredCurrencyList = homeController.currencyModel?.data
                ?.where((currency) => currency.currencyName!
                    .toLowerCase()
                    .contains(query.toLowerCase()))
                .toList() ??
            [];
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
        title: "Currency",
        titleColor: notifires.getGrey1Whitecolor,
        backgroundColor: notifires.getbgcolor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: notifires.getBoxColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextFormField(
                controller: _searchController,
                style: regular2(context),
                onChanged: (query) {
                  _filterCurrencies(query);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search for currency".tr,
                  hintStyle: regular2(context),
                  prefixIcon: const Icon(CupertinoIcons.search),
                ),
              ),
            ),
          ),
          Obx(() => Expanded(
                child: homeController.currencyLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ListView.builder(
                        itemCount: _filteredCurrencyList.length,
                        itemBuilder: (context, index) {
                          var currencyInternal = _filteredCurrencyList[index];
                          bool isSelected =
                              currencyInternal.currencyCode == currency;
                          return Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: ListTile(
                              tileColor: isSelected
                                  ? Colors.blue.shade100
                                  : null, // Highlight selected item
                              onTap: () {
                                try {
                                  currency = currencyInternal.currencyCode;
                                  GetStorage()
                                      .write("selectedCurrencyCode", currency);
                                  GetStorage()
                                      .write("setSelectedCurrency", true);
                                  showLoading();
                                  // Clear cached data
                                  GetStorage().remove("generalSettings");
                                  GetStorage().remove("locationDataVehicle");
                                  GetStorage().remove("mustViewsVehiclesData");
                                  GetStorage().remove("NearYouVehicle");
                                  GetStorage().remove("vehicleTypeHome");
                                  GetStorage().remove("make");
                                  generalController
                                      .fetchGeneralSettings()
                                      .then((_) {
                                    closeLoading();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const SettingScreen()),
                                    );
                                  }).catchError((error) {
                                    closeLoading();
                                  });
                                } catch (e) {
                                  // print('Error: $e');
                                }
                              },
                              leading: Text(
                                "${currencyInternal.currencySymbol}",
                                style: heading3(context),
                              ),
                              trailing: isSelected
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              title: Text(
                                "${currencyInternal.currencyName}",
                                style: heading3(context),
                              ),
                            ),
                          );
                        },
                      ),
              )),
        ],
      ),
    );
  }
}
