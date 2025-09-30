import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:carvy/customwidget/project_color.dart';

import 'package:flutter/material.dart';

//Dimensions //

class Dimensions {
  static double fontSizeExtraSmall = Get.width >= 1300 ? 14 : 10;
  static double fontSizeSmall = Get.width >= 1300 ? 16 : 12;
  static double fontSizeDefault = Get.width >= 1300 ? 18 : 14;
  static double fontSizeLarge = Get.width >= 1300 ? 20 : 20;
  static double fontSizeExtraLarge = Get.width >= 1300 ? 22 : 18;
  static double fontSizeOverLarge = Get.width >= 1300 ? 30 : 25;

  static double fontSizeLargeNew = Get.width >= 1300 ? 26 : 22;
  static double fontSizeExtraLargeNew = Get.width >= 1300 ? 30 : 25;
  static double fontSizeOverLargeNew = Get.width >= 1300 ? 35 : 30;

  static const double paddingSizeExtraSmall = 5.0;
  static const double paddingSizeSmall = 12.0;
  static const double paddingSizeDefault = 15.0;
  static const double paddingSizeLarge = 15.0;
  static const double paddingSizeExtraLarge = 25.0;

  static const double radiusSmall = 5.0;
  static const double radiusDefault = 10.0;
  static const double radiusLarge = 20.0;
  static const double radiusExtraLarge = 30.0;

  static const double containerWidth = 1200.0;
  static const double containerWidthAppbar = 1235.0;
}

//font styling //

final gilroyBlackItalic = TextStyle(
  fontFamily: 'Gilroy-BlackItalic',
  fontWeight: FontWeight.w900,
  fontSize: Dimensions.fontSizeDefault,
);

final gilroyBold = TextStyle(
  fontFamily: 'AirBold',
  fontWeight: FontWeight.w700,
  fontSize: Dimensions.fontSizeDefault,
);

final gilroyMedium = TextStyle(
  fontFamily: 'AirMedium',
  fontWeight: FontWeight.w500,
  fontSize: Dimensions.fontSizeDefault,
);

final gilroyRegular = TextStyle(
  fontFamily: 'AirMedium',
  fontWeight: FontWeight.w400,
  fontSize: Dimensions.fontSizeDefault,
);

final gilroySemiBold = TextStyle(
  fontFamily: 'AirBold',
  fontWeight: FontWeight.w600,
  fontSize: Dimensions.fontSizeDefault,
);

final gilroyThin = TextStyle(
  fontFamily: 'AirLight',
  fontWeight: FontWeight.w100,
  fontSize: Dimensions.fontSizeDefault,
);

final gilroyUltraLight = TextStyle(
  fontFamily: 'AirBold',
  fontWeight: FontWeight.w200,
  fontSize: Dimensions.fontSizeDefault,
);
final langeHeading = TextStyle(
  fontFamily: 'AirBold',
  fontWeight: FontWeight.w600,
  fontSize: 20,
  color: blackColor,
);
final appBar = TextStyle(
    fontFamily: 'AirBold',
    fontWeight: FontWeight.w600,
    fontSize: 16,
    color: blackColor);

const smallHeading = TextStyle(
  fontFamily: 'AirMedium',
  fontWeight: FontWeight.w500,
  fontSize: 16,
);

const appRegularText = TextStyle(
  fontFamily: 'AirMedium',
  fontWeight: FontWeight.normal,
  fontSize: 14,
);

const appRegularTextBold = TextStyle(
  fontFamily: 'AirMedium',
  fontWeight: FontWeight.bold,
  fontSize: 14,
);
const appSmallText = TextStyle(
  fontFamily: 'AirMedium',
  fontWeight: FontWeight.normal,
  fontSize: 12,
);

const priceColorGrey = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Color.fromARGB(255, 97, 97, 97));
const appGlobalText = TextStyle(
  fontFamily: 'AirMedium',
  fontWeight: FontWeight.normal,
  fontSize: 12,
  color: Color.fromRGBO(119, 118, 118, 1),
  decoration: TextDecoration.none, // Make sure it doesn't have a strikethrough
);

final largeHeading = TextStyle(
  fontFamily: 'AirBold',
  fontWeight: FontWeight.w600,
  fontSize: 20,
  color: blackColor,
);

final largeHeadigAirBd = TextStyle(
  fontFamily: 'AirBold',
  fontWeight: FontWeight.w700,
  fontSize: Dimensions.fontSizeExtraLargeNew,
);
final smallHeadigAirBd = TextStyle(
  fontFamily: 'AirBold',
  fontWeight: FontWeight.w700,
  fontSize: Dimensions.fontSizeLarge,
);

final largeHeadingAirMd = TextStyle(
    fontFamily: 'AirMedium',
    fontSize: Dimensions.fontSizeLargeNew,
    fontWeight: FontWeight.w500);

final smallHeadingAirMd = TextStyle(
    fontFamily: 'AirMedium',
    fontSize: Dimensions.fontSizeLarge,
    fontWeight: FontWeight.w500);

final extraLargeHeadingAirMd = TextStyle(
    fontFamily: 'AirMedium',
    fontSize: Dimensions.fontSizeOverLargeNew,
    fontWeight: FontWeight.w500);

final bottomBarfontAirMd = TextStyle(
    fontFamily: 'AirMedium',
    fontSize: Dimensions.fontSizeDefault,
    fontWeight: FontWeight.w500);

final labelHeadingAirMd = TextStyle(
    fontFamily: 'AirMedium',
    fontSize: Dimensions.fontSizeLarge,
    fontWeight: FontWeight.w500);

final buttonTextAirMd = TextStyle(
    fontFamily: 'AirMedium',
    fontSize: Dimensions.fontSizeExtraLarge,
    fontWeight: FontWeight.w500);

final normalAirBk = TextStyle(
    fontFamily: 'AirBlack',
    fontSize: Dimensions.fontSizeDefault,
    fontWeight: FontWeight.w400);

final smallAirBk = TextStyle(
    fontFamily: 'AirBlack',
    fontSize: Dimensions.fontSizeSmall,
    fontWeight: FontWeight.w400);

final airBlackBold = TextStyle(
  fontFamily: 'AirBlackBold',
  fontSize: Dimensions.fontSizeDefault,
);

final airLight = TextStyle(
  fontFamily: 'AirLight',
  fontSize: Dimensions.fontSizeDefault,
);
const bigHeadingh1 = TextStyle(
    fontFamily: 'AirMedium', fontSize: 30, fontWeight: FontWeight.w500);
const mainHeadingh2 = TextStyle(
    fontFamily: 'AirBlack', fontSize: 27, fontWeight: FontWeight.w500);
const headingh3 = TextStyle(
    fontFamily: 'AirMedium', fontSize: 24, fontWeight: FontWeight.w500);
const headingh4 = TextStyle(
    fontFamily: 'AirMedium', fontSize: 21, fontWeight: FontWeight.w500);
const headingh5 = TextStyle(
    fontFamily: 'AirLight', fontSize: 18, fontWeight: FontWeight.w500);
final headingh6 = TextStyle(
    color: notifires.getwhiteblackcolor,
    fontFamily: 'AirMedium',
    fontSize: 15,
    fontWeight: FontWeight.w500);
const textStyles = TextStyle(
    fontFamily: 'AirLight', fontSize: 14, fontWeight: FontWeight.w500);
const appNormelText = TextStyle(
    fontFamily: 'AirLight', fontSize: 14, fontWeight: FontWeight.w500);

final appBarHeading = TextStyle(
  fontFamily: 'AirBold',
  fontWeight: FontWeight.w700,
  fontSize: Dimensions.fontSizeLarge,
);
const receiptText = TextStyle(
  fontFamily: 'AirLight',
  fontSize: 15,
);
final starColor = themeColor;

//new styles============

var heading01 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: "ManropeBold",
    color: notifires.getGrey2Whitecolor);
var heading02 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: "ManropeBold",
    color: notifires.getGrey2Whitecolor);
var heading03 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    fontFamily: "ManropeBold",
    color: notifires.getGrey2Whitecolor);
var regular02 = TextStyle(
    fontSize: 12,
    fontFamily: "ManropeMedium",
    color: notifires.getGrey2Whitecolor);
var regular01 = TextStyle(
    fontSize: 10,
    fontFamily: "ManropeMedium",
    color: notifires.getGrey2Whitecolor);
var interRegular = TextStyle(
    fontSize: 14,
    fontFamily: "ManropeRegular",
    color: notifires.getGrey3Whitecolor);
var boldTextstyle = TextStyle(
    fontSize: 14,
    fontFamily: "ManropeBold",
    color: notifires.getGrey3Whitecolor);

TextStyle heading1(BuildContext context) {
  final notifires = Provider.of<ColorNotifires>(context);
  return TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: "ManropeBold",
    color: notifires.getGrey2Whitecolor,
  );
}

TextStyle heading2(BuildContext context) {
  final notifires = Provider.of<ColorNotifires>(context);
  return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      fontFamily: "ManropeBold",
      color: notifires.getGrey2Whitecolor);
}

TextStyle heading3(BuildContext context) {
  final notifires = Provider.of<ColorNotifires>(context);
  return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      fontFamily: "ManropeBold",
      color: notifires.getGrey2Whitecolor);
}

TextStyle regular2(BuildContext context) {
  final notifires = Provider.of<ColorNotifires>(context);
  return TextStyle(
      fontSize: 12,
      fontFamily: "ManropeMedium",
      color: notifires.getGrey2Whitecolor);
}

TextStyle regular(BuildContext context) {
  final notifires = Provider.of<ColorNotifires>(context);
  return TextStyle(
      fontSize: 10,
      fontFamily: "ManropeMedium",
      color: notifires.getGrey2Whitecolor);
}

TextStyle regular3(BuildContext context) {
  final notifires = Provider.of<ColorNotifires>(context);
  return TextStyle(
      fontSize: 14,
      fontFamily: "ManropeRegular",
      color: notifires.getGrey3Whitecolor);
}

TextStyle boldstyle(BuildContext context) {
  final notifires = Provider.of<ColorNotifires>(context);
  return TextStyle(
      fontSize: 14,
      fontFamily: "ManropeBold",
      color: notifires.getGrey3Whitecolor);
}

TextStyle heading1Grey1(BuildContext context) {
  final notifires = Provider.of<ColorNotifires>(context);
  return TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    fontFamily: "ManropeBold",
    color: notifires.getGrey1Whitecolor,
  );
}

TextStyle heading2Grey1(BuildContext context) {
  final notifires = Provider.of<ColorNotifires>(context);
  return TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: "ManropeMedium",
    color: notifires.getGrey1Whitecolor,
  );
}

TextStyle heading3Grey1(BuildContext context) {
  final notifires = Provider.of<ColorNotifires>(context);
  return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      fontFamily: "ManropeMedium",
      color: notifires.getGrey1Whitecolor);
}
