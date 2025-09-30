import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';

class MyReviewScreen extends StatefulWidget {
  final String? id;
  final String? userId;
  const MyReviewScreen({super.key, this.id, this.userId});

  @override
  State<MyReviewScreen> createState() => _MyReviewScreenState();
}

class _MyReviewScreenState extends State<MyReviewScreen>
    with SingleTickerProviderStateMixin {
  TabController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: notifires.getbgcolor,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back,
            color: notifires.getwhiteblackcolor,
          ),
        ),
        title: Text(
          "Reviews".tr,
          style: appBarHeading.copyWith(color: notifires.getwhiteblackcolor),
        ),
        bottom: TabBar(
          labelColor: themeColor,
          controller: _controller,
          dividerColor: greyColor,
          unselectedLabelColor: notifires.getwhiteblackcolor,
          indicatorColor: themeColor,
          tabs: [
            Tab(
              child: Text(
                'About You'.tr,
                style: headingh5,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Tab(
              child: Text(
                'By You'.tr,
                style: headingh5,
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          Center(
              child: Text(
            'Content of Tab 1'.tr,
            style: TextStyle(color: notifires.getwhiteblackcolor),
          )),
          const NestedTabs(),
        ],
      ),
    );
  }
}

class NestedTabs extends StatefulWidget {
  const NestedTabs({super.key});

  @override
  NestedTabsState createState() => NestedTabsState();
}

class NestedTabsState extends State<NestedTabs> with TickerProviderStateMixin {
  TabController? _nestedController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _nestedController = TabController(length: 2, vsync: this);
    _nestedController!.addListener(() {
      setState(() {
        _selectedIndex = _nestedController!.index;
      });
    });
  }

  @override
  void dispose() {
    _nestedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          TabBar(
            dividerColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            controller: _nestedController,
            tabs: [
              Tab(
                child: Container(
                  alignment: Alignment.center,
                  // padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _selectedIndex == 0
                          ? notifires.getwhiteblackcolor
                          : notifires.getblackwhitecolor),
                  child: Text(
                    'UpComing'.tr,
                    style: headingh5.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _selectedIndex == 0
                            ? notifires.getblackwhitecolor
                            : notifires.getwhiteblackcolor),
                  ),
                ),
              ),
              Tab(
                iconMargin: const EdgeInsets.only(bottom: 10),
                child: Container(
                  alignment: Alignment.center,
                  // padding: EdgeInsets.all(Dimensions.PADDING_SIZE_SMALL),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: _selectedIndex == 1
                          ? notifires.getwhiteblackcolor
                          : notifires.getblackwhitecolor),
                  child: Text(
                    'Past'.tr,
                    style: headingh5.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _selectedIndex == 1
                            ? notifires.getblackwhitecolor
                            : notifires.getwhiteblackcolor),
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _nestedController,
              children: [
                Center(
                    child: Text(
                  'Content of Nested Tab 1'.tr,
                  style: TextStyle(color: notifires.getwhiteblackcolor),
                )),
                Center(
                    child: Text('Content of Nested Tab 2'.tr,
                        style: TextStyle(color: notifires.getwhiteblackcolor))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
