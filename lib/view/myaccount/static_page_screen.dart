import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/static_controller.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:flutter_html/flutter_html.dart' as flutter_html;

class StaticPage extends StatefulWidget {
  final String data;
  const StaticPage({super.key, required this.data});
  @override
  State<StaticPage> createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage> {
  StaticController staticController = Get.find();
  @override
  void initState() {
    super.initState();
    staticController.string.value = "";
    staticController.fetchData(widget.data);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => staticController.string.value.isEmpty
        ? Scaffold(
            backgroundColor: notifires.getblackwhitecolor,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            backgroundColor: notifires.getblackwhitecolor,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: notifires.getblackwhitecolor,
              elevation: 0,
              leading: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Icon(
                  Icons.arrow_back,
                  color: notifires.getwhiteblackcolor,
                ),
              ),
              title: Text(
                widget.data.tr,
                style:
                    appBarHeading.copyWith(color: notifires.getwhiteblackcolor),
              ),
            ),
            body: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: flutter_html.Html(
                    data: staticController.string.value, // Render HTML content
                    style: {
                      "body": flutter_html.Style(
                        color: notifires.getwhiteblackcolor,
                        fontSize: flutter_html.FontSize(16.0),
                      ),
                    },
                  ),
                ),
              ],
            ),
          ));
  }
}
