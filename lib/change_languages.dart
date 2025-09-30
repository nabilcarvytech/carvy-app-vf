import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/get_data_read.dart';
import 'package:carvy/work_space.dart';

// class ChangeLanguages extends StatefulWidget {
//   const ChangeLanguages({super.key});

//   @override
//   State<ChangeLanguages> createState() => _ChangeLanguagesState();
// }

// class _ChangeLanguagesState extends State<ChangeLanguages> {
//   int selectedRadio = 0;
//   int _value = 1;
//   int currentIndex = 0;

//   @override
//   void initState() {
//     super.initState();
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: notifires.getbgcolor,
//       appBar: CustomAppBars(
//         title: 'Language'.tr,
//         backgroundColor: notifires.getbgcolor,
//         centerTitle: false,
//         iconColor: notifires.getwhiteblackcolor,
//         titleColor: notifires.getwhiteblackcolor,
//       ),
//       body: SingleChildScrollView(
//         // physics: BouncingScrollPhysics(),
//         child: SizedBox(
//           height: Get.size.height,
//           width: Get.size.width,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: ListView.builder(
//                   // add the language in the list
//                   itemCount: locale.length,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemBuilder: (context, index) {
//                     return InkWell(
//                       onTap: () {
//                         setState(() {
//                           _value = index;
//                           save("lanValue", _value);
//                           updateLanguage(locale[index]['locale']);
//                           save("lCode", locale[index]['locale'].toString());
//                         });
//                       },
//                       child: languageWidget(
//                         name: locale[index]['name'],
//                         value: index,
//                         radio: Radio(
//                           value: index,
//                        groupValue: getData.read("lanValue") ?? _value,
//                           hoverColor: blueColor,
//                           onChanged: (value4) {
//                             setState(() {
//                               _value = index;
//                               save("lanValue", _value);

//                               updateLanguage(locale[index]['locale']);
//                               save("lCode", locale[index]['locale'].toString());
//                             });
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class ChangeLanguages extends StatefulWidget {
  const ChangeLanguages({super.key});

  @override
  State<ChangeLanguages> createState() => _ChangeLanguagesState();
}

class _ChangeLanguagesState extends State<ChangeLanguages> {
  int selectedRadio = 0;
  int _value = 0;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
        title: 'Language'.tr,
        backgroundColor: notifires.getbgcolor,
        centerTitle: false,
        iconColor: notifires.getwhiteblackcolor,
        titleColor: notifires.getwhiteblackcolor,
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: Get.size.height,
          width: Get.size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: locale.length,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _value = index;
                          save("lanValue", _value);
                          updateLanguage(locale[index]['locale']);
                          globallanguage = locale[index]['locale']
                              as Locale; // Update global variable
                          save("lCode", globallanguage.toString());
                        });
                      },
                      child: languageWidget(
                        name: locale[index]['name'],
                        value: index,
                        radio: Radio(
                          value: index,
                          groupValue: getData.read("lanValue") ?? _value,
                          hoverColor: blueColor,
                          onChanged: (value4) {
                            setState(() {
                              _value = index;
                              save("lanValue", _value);
                              updateLanguage(locale[index]['locale']);
                              globallanguage =
                                  locale[index]['locale'] as Locale;
                              save("lCode", globallanguage.toString());
                            });
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
