import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

Color themeColor = const Color(0xFF27489E);
Color whiteColor = const Color(0xffFFFFFF);
Color blackColor = const Color(0xFF212121);
Color bgColor = grey6;
Color darkBlue = const Color(0xff3D5BF6);
Color yellowColor = const Color(0xffFFBB0D);
Color redColor = const Color(0xffFF4747);
Color lightsGrey = const Color(0xffDDDDDD);
Color darkmode = const Color(0xff111315);
Color boxcolor = const Color(0xff202427);
Color greycolor = const Color(0xff9e9e9e);
Color greyColors = const Color(0xffA7AEC1);
Color perpulshadow = const Color(0xffede3ed);
Color buttonColor = const Color(0xff6F42E5);
Color blueColor = const Color(0xff2196f3);
Color greenColor = const Color(0xff00ff00);
Color gradientColor = const Color(0xff00D261);
Color brownColor = const Color(0xff481f01);
Color orangeColor = const Color(0xffff9933);
Color lightyello = const Color(0xfff4c430);
Color redgradient = const Color(0xffFF6B6B);
Color greentext = const Color(0xff20BC3B);
Color bordercolor = const Color(0xffF5F2FB);
Color blackColor2 = const Color.fromARGB(255, 49, 15, 15);
Color greyColor = const Color.fromARGB(255, 198, 202, 215);
Color greyColor2 = const Color(0xffA7AEC1);
Color darkblue2 = const Color(0xff3D5BF6);
Color yelloColor2 = const Color(0xffF78F2C);
Color redColor2 = const Color(0xffFF4747);
Color lightgrey2 = const Color(0xffDDDDDD);
Color lightBlack = const Color(0xff730001);
Color lightBlack2 = const Color(0XFF636777);
Color onoffColor = const Color(0xffE7E7E7);
Color onoffColor2 = const Color(0xffE7E7E7);
Color fevAndSearchColor = const Color(0xFFf7f7f7);
Color lightblue = const Color(0xFFccdbfd);
Color greensColor = yelloColor2;
Color lightGrey = const Color(0xFFbbbbbb);
Color pinnetsColor = const Color.fromARGB(255, 248, 236, 217);
Color darkgrey = const Color(0xFFF6F4F4);
Color darkbox = const Color(0xff2ec4b6);
Color vehicleThemeColor = const Color(0xff78290f);
Color bookableThemeColor = greensColor;
Color boatThemeColor = const Color(0xff48cae4);
Color spaceThemeColor = const Color(0xfff7a072);
Color parkingThemeColor = const Color(0xff9d4edd);
Color doctorThemeColor = const Color(0xff3461ec);
Color lightBackColor = const Color(0xffe2eafc);
Color baseColor = Colors.grey.shade300;
Color highlight = Colors.grey.shade100;
Color grey2 = const Color(0xFF616161);
Color grey1 = const Color(0xFF212121);
Color grey3 = const Color(0xFF9E9E9E);
Color grey4 = const Color(0xFFBDBDBD);
Color grey6 = const Color(0xFFF7F7F7);
Color grey5 = const Color(0xFFEEEEEE);
Color bgBlue = const Color(0xFFF6FAFD);
Color strockcolor = const Color(0xFFEBEDF9);
Color fillColor = const Color(0xFF292B49);
Color vehicalThemColor = const Color(0xFF27489E);
Color boatThemColor = const Color(0xFF41ADE9);
Color parkingThemColor = const Color(0xFF8863D8);
Color bookableThemColor = const Color(0xFFEDB037);
Color spaceThemColor = const Color(0xFF005DB2);
Color bgRed = const Color(0xFFFFF5F5);
Color bgYellow = const Color(0xFFFFFEE0);
Color bgPurple = const Color(0xFFFCF4FF);
Color acentColor = themeColor;
Color appyellow = const Color(0xFFFFD33C);
Color appgreen = const Color(0xFF00CE78);
Color pc1 = const Color(0xFFE94165);
Color greenback = const Color(0xFF85D487);
Color pc2 = const Color(0xFFE94165).withOpacity(.8);
Color sliderbg = const Color(0xFF636402);
Color sliderbg2 = const Color(0xFF3C3C3C);
Color lightYellow = const Color(0xFFFCE5BC);
Color lightBlue = const Color(0xFFCAE3F1);
Color circleBg = const Color(0xFFD9D0B2);

class ColorNotifires with ChangeNotifier {
  bool isDark = GetStorage().read("getDarkValue") ?? false;
  set setIsDark(value) {
    isDark = value;
    notifyListeners();
  }

  get getIsDark => isDark;
  get getbgcolor => isDark ? darkmode : bgColor;
  get getbgnextcolor => isDark
      ? const Color.fromARGB(255, 33, 26, 26)
      : const Color.fromARGB(255, 239, 237, 237);
  get getboxcolor => isDark ? boxcolor : whiteColor;
  get getlightblackcolor => isDark ? boxcolor : lightBlack;
  get getInVisibleBoxColor => isDark ? grey2 : Colors.grey.shade200;
  get getwhiteblackcolor => isDark ? whiteColor : blackColor;
  get getwhitegreycolor => isDark ? whiteColor : greyColor;
  get getgreycolor => isDark ? greyColor : greyColor;
  get getwhitebluecolor => isDark ? whiteColor : darkBlue;
  get getblackgreycolor => isDark ? lightBlack2 : greyColor;
  get getcardcolor => isDark ? darkmode : whiteColor;
  get getgreywhite => isDark ? whiteColor : greyColor;
  get getredcolor => isDark ? redColor : redColor2;
  get getprocolor => isDark ? yellowColor : yelloColor2;
  get getblackwhitecolor => isDark ? blackColor : whiteColor;
  get getlightblack => isDark ? lightBlack2 : lightBlack2;
  get getbuttonscolor => isDark ? lightsGrey : lightgrey2;
  get getbuttoncolor => isDark ? greyColor : onoffColor;
  get getdarkbluecolor => isDark ? darkBlue : darkBlue;
  get getdarkscolor => isDark ? blackColor : bgColor;
  get getdarkwhitecolor => isDark ? whiteColor : whiteColor;
  get getblackblue => isDark ? blueColor : blackColor;

  get getfevAndSearch => isDark ? darkmode : fevAndSearchColor;
  get getlightblackwhite => isDark ? blackColor : fevAndSearchColor;
  get getswitchcolor => isDark ? blueColor : lightsGrey;
  get getthemecolor => isDark ? yelloColor2 : blackColor;
  get getthemewhitecolor => isDark ? whiteColor : themeColor;
  get getWhitepinnetsColor => isDark ? whiteColor : pinnetsColor;
  get getWhitetodarkgeryColor => isDark ? darkmode : darkgrey;
  get getDoctorModuleColor => isDark ? darkmode : doctorThemeColor;
  get getBaseColor => isDark ? Colors.grey.shade700 : Colors.grey.shade300;
  get getHighlightColor => isDark ? Colors.grey.shade600 : Colors.grey.shade100;
  get getAppBarcolor => isDark ? darkmode : lightBackColor.withOpacity(0.7);
  get getGrey1Whitecolor => isDark ? whiteColor : grey1;
  get getGrey2Whitecolor => isDark ? whiteColor : grey2;
  get getGrey3Whitecolor => isDark ? whiteColor : grey3;
  get getGrey4Whitecolor => isDark ? whiteColor : grey4;
  get getGrey5Whitecolor => isDark ? whiteColor : grey5;
  get getGrey6Whitecolor => isDark ? whiteColor : grey6;
  get getBoxColor => isDark ? grey2 : whiteColor;
}

late ColorNotifires notifires;

class CustomThemes {
  static const themeColor = Color(0xffF29931);
}
