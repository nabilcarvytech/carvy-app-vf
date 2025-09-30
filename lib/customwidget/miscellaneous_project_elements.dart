import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:carvy/api/config.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/controller/search_controller.dart';
import 'package:carvy/controller/wish_list_controller.dart';
import 'dart:io';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:carvy/helper/web_router.dart';
import 'package:carvy/utils/common_widget.dart';
import '../utils/theme_style.dart';
import 'package:carvy/work_space.dart';
import '../controller/booking_controller.dart';

class HeaderTextWidget extends StatelessWidget {
  final String headingText;

  const HeaderTextWidget({required this.headingText, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            headingText.tr,
            style:
                heading2(context).copyWith(color: notifires.getGrey3Whitecolor),
          ),
        ],
      ),
    );
  }
}

class ForwardActionTile extends StatelessWidget {
  final VoidCallback onTap;
  final String bookingText;
  final TextStyle textStyle;
  final IconData leadingIcon;
  final Color iconColor;

  const ForwardActionTile({
    required this.onTap,
    this.bookingText = "",
    required this.textStyle,
    this.leadingIcon = Icons.calendar_month,
    this.iconColor = Colors.black,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final translatedBookingText = bookingText.tr;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Container(
          height: 65,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: notifires.getBoxColor,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Row(
            children: [
              const SizedBox(width: 15),
              Icon(
                leadingIcon,
                color: iconColor,
                size: 24,
              ),
              const SizedBox(width: 15),
              Text(
                translatedBookingText.length > 28
                    ? '${translatedBookingText.substring(0, 25)}...'
                    : translatedBookingText,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: textStyle.copyWith(
                  color: notifires.getGrey2Whitecolor,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: notifires.getGrey4Whitecolor,
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// DeleteConfirmationDialog //

class DeleteConfirmationDialogs extends StatefulWidget {
  final String? desc;
  final String? firstButtontext;
  final String? secondButtontext;

  const DeleteConfirmationDialogs({
    super.key,
    this.desc,
    this.firstButtontext,
    this.secondButtontext,
  });

  @override
  DeleteConfirmationDialogState createState() =>
      DeleteConfirmationDialogState();
}

ProfileController profileController = Get.find();

class DeleteConfirmationDialogState extends State<DeleteConfirmationDialogs> {
  bool isCancelSelected = true;
  bool isDeleteSelected = false;

  Future<void> _handleDelete() async {
    showLoading();
    setState(() {
      isCancelSelected = false;
      isDeleteSelected = true;
    });
    Navigator.pop(context);

    var res = await httpPost(Config.deleteAccount, {});
    if (res != null) {
      if (res['status'] == 200) {
        closeLoading();
        showToastMessage(res['message']);
        logout();
      } else {
        closeLoading();
        showErrorToastMessage(res['error']);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: Get.height * 0.26,
        decoration: BoxDecoration(
          color: notifires.getboxcolor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Icon(Icons.error, size: 70, color: redColor2),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Do you want to Delete your Account?'.tr,
                textAlign: TextAlign.center,
                style: gilroyRegular.copyWith(
                  fontSize: 16,
                  color: notifires.getwhiteblackcolor,
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints.expand(height: 40),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              isCancelSelected = true;
                              isDeleteSelected = false;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: notifires.getBoxColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child:
                              Text('Cancel'.tr, style: heading3Grey1(context)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Flexible(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints.expand(height: 40),
                        child: ElevatedButton(
                          onPressed: _handleDelete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: getColorBasedOnActiveModuleid(),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 1.0,
                                  color: getColorBasedOnActiveModuleid()),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Delete'.tr,
                            style: heading3Grey1(context).copyWith(
                              color: whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//Toast Message //

// showToastMessage(message) {
//   BotToast.showCustomText(
//     toastBuilder: (_) => CustomToastMessages(
//       message: message,
//     ),
//     duration: const Duration(seconds: 3),
//   );
// }

// showErrorToastMessage(message) {
//   BotToast.showCustomText(
//     align: const Alignment(0, 0.8),
//     toastBuilder: (toastBuilder) {
//       return CustomToastMessages(
//         message: message.toString(),
//         error: true,
//       );
//     },
//   );
// }

buildShowDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: Image.asset(
          'assets/images/loader.gif',
          color: acentColor,
        ));
      });
}

// class CustomToastMessages extends StatefulWidget {
//   final String message;
//   final bool? error;

//   const CustomToastMessages({
//     super.key,
//     required this.message,
//     this.error,
//   });

//   @override
//   CustomToastMessagesState createState() => CustomToastMessagesState();
// }

// class CustomToastMessagesState extends State<CustomToastMessages>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _scaleAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     );
//     _scaleAnimation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.elasticOut,
//     );
//     _controller.forward();
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScaleTransition(
//       scale: _scaleAnimation,
//       child: Material(
//         elevation: 10,
//         borderRadius: BorderRadius.circular(15),
//         child: Container(
//           width: MediaQuery.of(context).size.width - 80,
//           decoration: BoxDecoration(
//             color: widget.error == null
//                 ? const Color.fromARGB(255, 0, 153, 5)
//                 : const Color.fromARGB(255, 233, 135, 36),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   widget.error == null
//                       ? SvgPicture.asset(
//                           "assets/images/greenIcon.svg",
//                           height: 29,
//                         )
//                       : SvgPicture.asset("assets/images/wornIcon.svg"),
//                   const SizedBox(width: 15),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width / 2,
//                     child: Text(
//                       widget.message,
//                       overflow: TextOverflow.clip,
//                       style: heading3(context)
//                           .copyWith(color: whiteColor, fontSize: 14),
//                     ),
//                   ),
//                 ],
//               ),
//               Icon(
//                 Icons.close,
//                 color: whiteColor,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

showErrorToastMessage(message) {
  BotToast.showCustomText(
    duration: const Duration(seconds: 3),
    align: Alignment.bottomCenter.add(Alignment(0, -0.12)),
    toastBuilder: (context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: CustomToastMessages(
          message: message.toString(),
          error: true,
        ),
      );
    },
  );
}

showToastMessage(message) {
  BotToast.showCustomText(
    align: Alignment.bottomCenter.add(Alignment(0, -0.12)),
    toastBuilder: (_) => Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: CustomToastMessages(
        message: message,
        error: false,
      ),
    ),
    duration: const Duration(seconds: 3),
  );
}

class CustomToastMessages extends StatefulWidget {
  final String message;
  final bool? error;

  const CustomToastMessages({
    super.key,
    required this.message,
    this.error,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomToastMessagesState createState() => _CustomToastMessagesState();
}

class _CustomToastMessagesState extends State<CustomToastMessages>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isError = widget.error ?? false;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                margin:
                    const EdgeInsets.only(top: 20), // Space for floating text
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: grey4,
                      blurRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      height: 28,
                      width: 28,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 1, color: isError ? redColor : appgreen),
                          borderRadius: BorderRadius.circular(28)),
                      child: Icon(
                        isError ? Icons.close : Icons.check,
                        size: 18,
                        color: isError ? redColor : appgreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5,
                right: -5,
                child: InkWell(
                  onTap: () => BotToast.removeAll(),
                  borderRadius: BorderRadius.circular(28),
                  child: Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Icon(
                      isError ? Icons.refresh : Icons.close,
                      size: 18,
                      color: whiteColor,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 16,
                child: Text(
                  isError ? "Error!" : "Success!",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: themeColor,
                    shadows: [
                      Shadow(
                        color: grey4,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

dynamic closeLoading;

showLoading() {
  closeLoading = BotToast.showLoading();
}

bottomSheet() {
  return SizedBox(
    height: 400,
    child: Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
              color: grey4, borderRadius: BorderRadius.circular(12)),
        ),
        const SizedBox(
          height: 20,
        ),
        Image.asset(
          "assets/images/userNot.png",
          width: 200,
          height: 200,
        ),
        Text(
          'User not exist'.tr,
          style: heading02.copyWith(color: grey1),
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "Do you want to Sign Up".tr,
          style: regular02,
        ),
        const SizedBox(
          height: 35,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                Get.back();
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 32, right: 32, top: 14, bottom: 14),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13), color: grey5),
                child:
                    Text("Cancel".tr, style: heading03.copyWith(color: grey2)),
              ),
            ),
            const SizedBox(
              width: 50,
            ),
            InkWell(
              onTap: () {
                Get.toNamed(WebRoutes.signUpScreen);
              },
              child: Container(
                padding: const EdgeInsets.only(
                    left: 32, right: 32, top: 14, bottom: 14),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13), color: themeColor),
                child: Text("Sign up".tr,
                    style: heading03.copyWith(color: whiteColor)),
              ),
            ),
          ],
        )
      ],
    ),
  );
}

class FullMapScreen extends StatefulWidget {
  // String latitude,longitude;
  final dynamic latitude;
  final dynamic longitude;

  const FullMapScreen({super.key, this.latitude, this.longitude});

  @override
  State<FullMapScreen> createState() => _FullMapScreenState();
}

class _FullMapScreenState extends State<FullMapScreen> {
  late GoogleMapController mapController;
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _zoomIn() {
    mapController.animateCamera(
      CameraUpdate.zoomIn(),
    );
  }

  void _zoomOut() {
    mapController.animateCamera(
      CameraUpdate.zoomOut(),
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leadingWidth: 80,
          leading: backButton(),
          backgroundColor: notifires.getbgcolor,
          elevation: 0,
          title: Text(
            "Map".tr,
            style: heading2Grey1(context),
          ),
        ),
        body: Stack(
          children: [
            SizedBox(
              // height: 300,
              child: GoogleMap(
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  compassEnabled: true,
                  onMapCreated: _onMapCreated,
                  markers: {
                    Marker(
                        markerId: const MarkerId("1"),
                        position: LatLng(double.parse(widget.latitude),
                            double.parse(widget.longitude)))
                  },
                  initialCameraPosition: CameraPosition(
                      target: LatLng(double.parse(widget.latitude),
                          double.parse(widget.longitude)),
                      zoom: 14)),
            ),
            kIsWeb || Platform.isAndroid
                ? const SizedBox()
                : Positioned(
                    top: 58,
                    right: 16,
                    child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                            onTap: () {
                              _zoomOut();
                            },
                            child: Container(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Text(
                                  "-",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                ))))),
            kIsWeb || Platform.isAndroid
                ? const SizedBox()
                : Positioned(
                    top: 16,
                    right: 16,
                    child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                            onTap: () {
                              _zoomIn();
                            },
                            child: Container(
                                padding: const EdgeInsets.only(
                                    left: 6, right: 6, top: 1, bottom: 1),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.add))))),
          ],
        ));
  }
}

class FullScreenMapForHost extends StatefulWidget {
  final dynamic latitude;
  final dynamic longitude;
  final ScreenMode mode;

  const FullScreenMapForHost({
    super.key,
    this.latitude,
    this.longitude,
    required this.mode,
  });

  @override
  State<FullScreenMapForHost> createState() => _FullScreenMapForHostState();
}

class _FullScreenMapForHostState extends State<FullScreenMapForHost> {
  AddItemsHostController addItemsHostController = Get.find();
  late GoogleMapController mapController;

  void _updatePosition(CameraPosition position) {
    setState(() {
      addItemsHostController.markers
          .removeWhere((marker) => marker.markerId.value == 'marker_2');
      addItemsHostController.markers.add(
        Marker(
          markerId: const MarkerId('marker_2'),
          position: LatLng(position.target.latitude, position.target.longitude),
          draggable: true,
          icon: BitmapDescriptor.defaultMarker,
          onDragEnd: (LatLng newPosition) {
            _updateMapLocation(newPosition);
          },
        ),
      );
    });
  }

  Future<void> _updateMapLocation(LatLng newPosition) async {
    addItemsHostController.selectedLat.value = newPosition.latitude.toString();
    addItemsHostController.selectedLong.value =
        newPosition.longitude.toString();
    await addItemsHostController.getPlaceDetailFromLatLng(
      newPosition.latitude,
      newPosition.longitude,
      widget.mode, // Pass the mode (add/edit)
    );
    // setState(() {});
  }

  void _onMapTapped(LatLng position) async {
    setState(() {
      addItemsHostController.markers.clear();
      addItemsHostController.markers.add(
        Marker(
          markerId: const MarkerId('marker_2'),
          position: position,
          draggable: true,
          icon: BitmapDescriptor.defaultMarker,
          onDragEnd: (LatLng newPosition) {
            _updateMapLocation(newPosition);
          },
        ),
      );
    });
    _updateMapLocation(position);
    String mainAddress = await addItemsHostController.getMainAddress(
        position.latitude, position.longitude);

    // Update the text field controller with the main address
    if (widget.mode == ScreenMode.edit) {
      addItemsHostController.textEditingControllerEditAddress.text =
          mainAddress;
    } else {
      addItemsHostController.textEditingControllerAddress.text = mainAddress;
    }
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          leadingWidth: 80,
          leading: GestureDetector(
              onTap: () {
                // Get.back();
                Navigator.pop(context, true);
              },
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 20, top: 8, bottom: 8, right: 20),
                child: PhysicalModel(
                  color: Colors.transparent,
                  shadowColor: notifires.getGrey4Whitecolor,
                  elevation: 5.0, // Adjust the elevation value as needed
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    alignment: Alignment.center,
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                        color: notifires.getboxcolor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.arrow_back,
                        color: getColorBasedOnActiveModuleid()),
                  ),
                ),
              )),
          backgroundColor: notifires.getbgcolor,
          elevation: 0,
          title: Text(
            "Map".tr,
            style: heading2Grey1(context),
          ),
        ),
        body: Stack(
          children: [
            SizedBox(
              // height: 300,
              child: GoogleMap(
                  scrollGesturesEnabled: true,
                  rotateGesturesEnabled: true,
                  zoomControlsEnabled: true,
                  zoomGesturesEnabled: true,
                  compassEnabled: true,
                  onMapCreated: (controller) =>
                      addItemsHostController.onMapCreated(controller),
                  markers: addItemsHostController.markers,
                  onTap: _onMapTapped,
                  onCameraMove: _updatePosition,
                  initialCameraPosition: CameraPosition(
                      target: LatLng(double.parse(widget.latitude),
                          double.parse(widget.longitude)),
                      zoom: 14)),
            ),
            Platform.isAndroid
                ? const SizedBox()
                : Positioned(
                    top: 58,
                    right: 16,
                    child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                            onTap: () {
                              addItemsHostController.zoomOut();
                            },
                            child: Container(
                                padding:
                                    const EdgeInsets.only(left: 12, right: 12),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Text(
                                  "-",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24),
                                ))))),
            Platform.isAndroid
                ? const SizedBox()
                : Positioned(
                    top: 16,
                    right: 16,
                    child: Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                            onTap: () {
                              addItemsHostController.zoomIn();
                            },
                            child: Container(
                                padding: const EdgeInsets.only(
                                    left: 6, right: 6, top: 1, bottom: 1),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: const Icon(Icons.add))))),
          ],
        ));
  }
}

Widget languageWidget(
    {String? name, int? value, void Function(int?)? onChanged, radio}) {
  return Container(
    decoration: BoxDecoration(
      // color: notifire.getblackwhitecolor,
      borderRadius: BorderRadius.circular(5),
    ),
    child: Padding(
      padding: const EdgeInsets.only(left: 15, right: 15),
      child: Row(
        children: [
          Text(
            name ?? "",
            style: normalAirBk.copyWith(
                fontSize: 16, color: notifires.getwhiteblackcolor),
          ),
          const Spacer(),
          radio,
          const SizedBox(
            width: 10,
          ),
        ],
      ),
    ),
  );
}

//to check web view

Widget buildRichText(String htmlString) {
  final List<TextSpan> textSpans = [];
  final RegExp htmlRegex = RegExp(r'<[^>]+>|[^<]+');

  for (RegExpMatch match in htmlRegex.allMatches(htmlString)) {
    final String group = match.group(0) ?? '';
    if (group.startsWith('<')) {
      // Handle tags - in this example, only <b> and <i> tags are supported
      if (group == '<b>') {
        textSpans.add(const TextSpan(
            text: '', style: TextStyle(fontWeight: FontWeight.bold)));
      } else if (group == '<i>') {
        textSpans.add(const TextSpan(
            text: '', style: TextStyle(fontStyle: FontStyle.italic)));
      }
    } else {
      // Handle text content
      textSpans.add(TextSpan(text: group.tr));
    }
  }

  return RichText(
    text: TextSpan(
        children: textSpans,
        style: TextStyle(color: notifires.getwhiteblackcolor)),
  );
}

class PhotoSlider extends StatelessWidget {
  final List<dynamic> imageList;
  final PageController pageController;
  final ValueNotifier<int> currentPageNotifier;

  const PhotoSlider({
    super.key,
    required this.imageList,
    required this.pageController,
    required this.currentPageNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            itemCount: imageList.length,
            itemBuilder: (context, index) {
              return FadeInImage.assetNetwork(
                fadeInCurve: Curves.easeInCirc,
                placeholder: "assets/images/ezgif.com-crop.gif",
                height: 50,
                image: imageList.elementAt(index) ?? "",
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: ValueListenableBuilder<int>(
            valueListenable: currentPageNotifier,
            builder: (context, value, child) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(imageList.length, (index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      width: 8.0,
                      height: 8.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: value == index ? Colors.red : Colors.grey,
                      ),
                    );
                  }),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class TimePickerPopup extends StatefulWidget {
  final String hintText;
  final List<String> timesList;
  final Function(String) onSelected;
  final Color checkmarkColor;
  final String? initialValue; // Added initialValue parameter

  const TimePickerPopup({
    super.key,
    required this.timesList,
    required this.onSelected,
    this.hintText = 'Select Time',
    required this.checkmarkColor,
    this.initialValue, // Optional initial value
  });

  @override
  TimePickerPopupState createState() => TimePickerPopupState();
}

class TimePickerPopupState extends State<TimePickerPopup> {
  BookingController bookingController = Get.find();

  @override
  void initState() {
    super.initState();
    // Set initial value if provided, otherwise use the first item from timesList
    if (widget.initialValue != null &&
        widget.timesList.contains(widget.initialValue)) {
      bookingController.hindTimeStart.value = widget.initialValue!;
    } else if (widget.timesList.isNotEmpty) {
      bookingController.hindTimeStart.value = widget.timesList.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (bookingController.startDate.value.toString() == "") {
          showErrorToastMessage("Select Start date".tr);
          return;
        }
        _openBottomSheet(context);
        setState(() {});
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: notifires.getBoxColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(width: 15),
            Expanded(
              child: Obx(
                () => Text(
                  bookingController.hindTimeStart.value.toString() != ""
                      ? bookingController.hindTimeStart.value.toString()
                      : widget.hintText.tr,
                  overflow: TextOverflow.ellipsis,
                  style: regular2(context).copyWith(
                    color: notifires.getGrey2Whitecolor,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.access_time,
              color: notifires.getGrey4Whitecolor,
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: notifires.getbgcolor,
      shape: const BeveledRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                height: 60,
                decoration: BoxDecoration(
                  color: greyColor2.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color.fromARGB(255, 125, 123, 123),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select time".tr,
                      style: heading2(context).copyWith(),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.close,
                        color: notifires.getwhiteblackcolor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.timesList.length,
                  itemBuilder: (BuildContext context, int index) {
                    bool isSelected = widget.timesList[index] ==
                        bookingController.hindTimeStart.value;
                    return Container(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.transparent, // Highlight the selected item
                      child: ListTile(
                        title: Text(
                          widget.timesList[index],
                          style: heading3Grey1(context),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: widget.checkmarkColor)
                            : null,
                        onTap: () {
                          setState(() {
                            bookingController.hindTimeStart.value =
                                widget.timesList[index];
                          });
                          widget.onSelected(widget.timesList[index]);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class TimePickerEndTime extends StatefulWidget {
  final String hintText;
  final List<String> timesList;
  final Function(String) onSelected;
  final Color checkmarkColor;
  final String? initialValue; // Added initialValue parameter

  const TimePickerEndTime({
    super.key,
    required this.timesList,
    required this.onSelected,
    this.hintText = 'Select Time',
    required this.checkmarkColor,
    this.initialValue, // Optional initial value
  });

  @override
  State<TimePickerEndTime> createState() => _TimePickerEndTimeState();
}

class _TimePickerEndTimeState extends State<TimePickerEndTime> {
  BookingController bookingController = Get.find();

  @override
  void initState() {
    super.initState();
    // Set initial value if provided, otherwise use the first item from timesList
    if (widget.initialValue != null &&
        widget.timesList.contains(widget.initialValue)) {
      bookingController.hindTimeSEnd.value = widget.initialValue!;
    } else if (widget.timesList.isNotEmpty) {
      bookingController.hindTimeSEnd.value = widget.timesList.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (bookingController.selectedStartTime.value.toString() == "") {
          showErrorToastMessage("Select Start time".tr);
          return;
        }
        _openBottomSheet(context);
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: notifires.getBoxColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(width: 15),
            Expanded(
              child: Obx(
                () => Text(
                  bookingController.hindTimeSEnd.value.toString() != ""
                      ? bookingController.hindTimeSEnd.value.toString()
                      : widget.hintText.tr,
                  overflow: TextOverflow.ellipsis,
                  style: regular2(context).copyWith(
                    color: notifires.getGrey2Whitecolor,
                  ),
                ),
              ),
            ),
            Icon(
              Icons.access_time,
              color: notifires.getGrey4Whitecolor,
            ),
            const SizedBox(width: 15),
          ],
        ),
      ),
    );
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: notifires.getbgcolor,
      shape: const BeveledRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                height: 60,
                decoration: BoxDecoration(
                  color: greyColor2.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color.fromARGB(255, 125, 123, 123),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select time".tr,
                      style: heading2(context).copyWith(),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.close,
                        color: notifires.getwhiteblackcolor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.timesList.length,
                  itemBuilder: (BuildContext context, int index) {
                    bool isSelected = widget.timesList[index] ==
                        bookingController.hindTimeSEnd.value;
                    return Container(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.transparent, // Highlight the selected item
                      child: ListTile(
                        title: Text(
                          widget.timesList[index],
                          style: heading3Grey1(context),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: widget.checkmarkColor)
                            : null,
                        onTap: () {
                          setState(() {
                            bookingController.hindTimeSEnd.value =
                                widget.timesList[index];
                          });
                          widget.onSelected(widget.timesList[index]);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class HostStartTimePicker extends StatefulWidget {
  final String hintText;
  final List<String> timesList;
  final Function(String) onSelected;
  final Color checkmarkColor;
  final String? initialValue; // New parameter for initial value

  const HostStartTimePicker({
    super.key,
    required this.timesList,
    required this.onSelected,
    this.hintText = 'Select Time',
    required this.checkmarkColor,
    this.initialValue, // Initialize initial value
  });

  @override
  State<HostStartTimePicker> createState() => _HostStartTimePickerState();
}

class _HostStartTimePickerState extends State<HostStartTimePicker> {
  AddItemsHostController addItemsHostController = Get.find();
  String? selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime =
        widget.initialValue; // Initialize selectedTime with initialValue
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _openBottomSheet(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(left: 15),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: notifires.getBoxColor,
            // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  selectedTime ?? widget.hintText,
                  style: regular2(context),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openBottomSheet(BuildContext context) {
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      shape: const BeveledRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color.fromARGB(255, 125, 123, 123),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select time",
                      style: heading3Grey1(context),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: (() {
                        Navigator.pop(context);
                      }),
                      child: const Icon(Icons.close),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.timesList.length,
                  itemBuilder: (BuildContext context, int index) {
                    bool isSelected = selectedTime == widget.timesList[index];
                    return Container(
                      color:
                          isSelected ? Colors.transparent : Colors.transparent,
                      child: ListTile(
                        title: Text(
                          widget.timesList[index],
                          style: regular2(context),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check, color: widget.checkmarkColor)
                            : null,
                        onTap: () {
                          setState(() {
                            selectedTime = widget.timesList[index];
                          });
                          widget.onSelected(widget.timesList[index]);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class TimepickupSearch extends StatefulWidget {
  final String hintText;
  final String? widgetType;
  final List<String> timesList;
  final Function(String) onSelected;
  final Color checkmarkColor;

  const TimepickupSearch({
    super.key,
    required this.timesList,
    required this.onSelected,
    this.widgetType,
    this.hintText = 'Select Time',
    required this.checkmarkColor,
  });

  @override
  State<TimepickupSearch> createState() => _TimepickupSearchState();
}

class _TimepickupSearchState extends State<TimepickupSearch> {
  SearchControllerHome controllerHome = Get.find();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _openBottomSheet(context);
        setState(() {});
      },
      child: Container(
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: notifires.getBoxColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            const SizedBox(
              width: 15,
            ),
            widget.widgetType == "start"
                ? Expanded(
                    child: Obx(
                      () => Text(
                        controllerHome.startTimeSearch.value.toString() != ""
                            ? controllerHome.startTimeSearch.value.toString()
                            : widget.hintText.tr,
                        overflow: TextOverflow.ellipsis,
                        style: regular2(context).copyWith(
                          color: notifires.getGrey2Whitecolor,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: Obx(
                      () => Text(
                        controllerHome.endTimeSearch.value.toString() != ""
                            ? controllerHome.endTimeSearch.value.toString()
                            : widget.hintText.tr,
                        overflow: TextOverflow.ellipsis,
                        style: regular2(context).copyWith(
                          color: notifires.getGrey2Whitecolor,
                        ),
                      ),
                    ),
                  ),
            Icon(
              Icons.access_time,
              color: notifires.getGrey4Whitecolor,
            ),
            const SizedBox(
              width: 15,
            ),
          ],
        ),
      ),
    );
  }

  void _openBottomSheet(BuildContext context) {
    if (controllerHome.startTimeSearch.value.isEmpty) {
      controllerHome.startTimeSearch.value = "12:00 AM";
    }
    if (controllerHome.endTimeSearch.value.isEmpty) {
      controllerHome.endTimeSearch.value = "11:59 PM";
    }

    // Show the modal bottom sheet
    showModalBottomSheet(
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: notifires.getbgcolor,
      shape: const BeveledRectangleBorder(),
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                height: 60,
                decoration: BoxDecoration(
                  color: greyColor2.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: const Color.fromARGB(255, 125, 123, 123),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Select time".tr,
                      style: heading2(context).copyWith(),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(
                        Icons.close,
                        color: notifires.getwhiteblackcolor,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.timesList.length,
                  itemBuilder: (BuildContext context, int index) {
                    bool? isSelected;
                    if (widget.widgetType == "start") {
                      isSelected = widget.timesList[index] ==
                          controllerHome.startTimeSearch.value;
                    } else {
                      isSelected = widget.timesList[index] ==
                          controllerHome.endTimeSearch.value;
                    }

                    return Container(
                      color: isSelected
                          ? Colors.transparent
                          : Colors.transparent, // Highlight the selected item
                      child: ListTile(
                        title: Text(
                          widget.timesList[index],
                          style: heading3Grey1(context),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check,
                                color: widget
                                    .checkmarkColor) // Use the required checkmark color
                            : null,
                        onTap: () {
                          setState(() {
                            // Update the selected time
                            if (controllerHome.startTimeSearch.value.isEmpty) {
                              controllerHome.startTimeSearch.value =
                                  widget.timesList[index];
                            } else {
                              controllerHome.endTimeSearch.value =
                                  widget.timesList[index];
                            }
                          });
                          widget.onSelected(widget.timesList[index]);
                          Navigator.pop(context);
                        },
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

/////// wishListCommon==============
class WishListCommon extends StatefulWidget {
  final dynamic id;
  const WishListCommon({super.key, this.id});

  @override
  State<WishListCommon> createState() => _WishListCommonState();
}

class _WishListCommonState extends State<WishListCommon> {
  WishListController wishListController = Get.find();

  @override
  void initState() {
    wishListController.addTowishlist(widget.id);
    if (wishListController.addTowishlist(widget.id) == true) {}

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

void showCustomSnackbar({
  required String title,
  required String message,
  required Color color,
  required ContentType contentType,
}) {
  Get.snackbar(
    title,
    message,
    snackStyle: SnackStyle.FLOATING,
    backgroundColor: color,
    margin: const EdgeInsets.all(10),
    borderRadius: 10,
    snackPosition: SnackPosition.TOP,
    barBlur: 0,
    animationDuration: const Duration(milliseconds: 300),
    duration: const Duration(seconds: 3),
    colorText: Colors.white,
  );
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final VoidCallback? onEditingComplete;
  final int? minLines;
  final int? maxLines;
  final int? maxlength;
  final Key? keyValue;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validation; // New validation parameter

  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.done,
    this.onFieldSubmitted,
    this.onEditingComplete,
    this.minLines,
    this.maxLines,
    this.maxlength,
    this.keyValue,
    this.onChanged,
    this.validation, // Initialize validation parameter
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: regular2(context).copyWith(color: notifires.getwhiteblackcolor),
      key: keyValue,
      maxLength: maxlength,
      minLines: minLines,
      maxLines: maxLines,
      controller: controller,
      decoration: InputDecoration(
        fillColor: notifires.getBoxColor,
        filled: true,
        contentPadding: const EdgeInsets.all(10),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: notifires.getBoxColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: notifires.getBoxColor)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide(color: notifires.getBoxColor)),
        hintText: hintText,
        hintStyle: regular2(context).copyWith(),
      ),
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,

      onEditingComplete: onEditingComplete,
      // Add validator callback if provided
      validator: validation,
    );
  }
}

class ShortBy extends StatefulWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onOptionSelected;

  const ShortBy({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  ShortByState createState() => ShortByState();
}

class ShortByState extends State<ShortBy> {
  SearchControllerHome filterController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: notifires.getbgcolor,
      child: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
            child: Text(
              'Sort By',
              style: heading3(context),
            ),
          ),
          ...widget.options.map((option) {
            return Transform.translate(
              offset: const Offset(-11, 0),
              child: SizedBox(
                height: 40,
                child: RadioListTile<String>(
                  title: Text(
                    option,
                    style: regular2(context),
                    overflow: TextOverflow.ellipsis,
                  ),
                  value: option,
                  groupValue: filterController.selectredeShortByvalue.value,
                  onChanged: (String? value) {
                    setState(() {});
                    widget.onOptionSelected(value!);
                    Get.back();
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class TextFieldAdvance extends StatefulWidget {
  final String? txt;
  late final String? hintTxt;
  late final Icon? icons;
  late final Icon? suffixIcons;
  final TextInputType inputType;
  final TextEditingController textEditingControllerCommon;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  String? Function(String?)? validator;
  final int? maxlines;
  final int? minlines;
  final int? maxlength;
  final String? counterText;
  final TextAlign inputAlignment;
  final TextInputAction? textInputAction;
  String? Function(String?)? onChange;
  final VoidCallback? onEditingComplete; // Add this line
  final FocusNode? focusNode;
  bool readOnly;
  String? suffixtext;

  TextFieldAdvance({
    this.txt,
    this.hintTxt,
    this.suffixIcons,
    this.icons,
    required this.textEditingControllerCommon,
    required this.inputType,
    this.validator,
    this.textInputAction,
    this.onTap,
    this.focusNode,
    this.maxlines,
    this.onEditingComplete,
    this.inputFormatters,
    this.maxlength,
    this.onChange,
    this.minlines,
    this.counterText,
    required this.inputAlignment,
    this.readOnly = false,
    this.suffixtext,
  });

  @override
  State<TextFieldAdvance> createState() => _TextFieldAdvanceState();
}

class _TextFieldAdvanceState extends State<TextFieldAdvance> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext buildContext, BoxConstraints boxConstraints) {
      return SizedBox(
        width: double.maxFinite,
        child: TextFormField(
          readOnly: widget.readOnly,

          maxLength: widget.maxlength,
          textInputAction: widget.textInputAction,
          textAlign: widget.inputAlignment,
          maxLines: widget.maxlines,
          minLines: widget.minlines,
          controller: widget.textEditingControllerCommon,
          keyboardType: widget.inputType,
          focusNode: widget.focusNode,
          autofocus: false,
          enabled: true,
          textCapitalization: widget.inputType == TextInputType.emailAddress
              ? TextCapitalization.none
              : TextCapitalization.words,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: widget.validator,
          cursorWidth: 1.0,
          cursorColor: notifires.getwhiteblackcolor,
          style: regular2(context),
          onTap: widget.onTap,
          // Added onTap callback
          decoration: InputDecoration(
            filled: true, // Fill the background
            fillColor: notifires.getbgcolor,
            // labelText: widget.txt.tr,
            suffixText: widget.suffixtext,
            // filled: true,
            counterText: widget.counterText,
            counterStyle:
                regular(context).copyWith(color: notifires.getGrey2Whitecolor),
            suffixIcon: widget.suffixIcons,
            errorStyle: regular(context).copyWith(color: redColor),
            // border: InputBorder.none,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: notifires.getBoxColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: notifires.getBoxColor),
            ),
            hintText: widget.hintTxt?.tr,
            hintStyle: regular(context),
            prefixIcon: widget.icons,

            enabled: true,
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: getColorBasedOnActiveModuleid())),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: getColorBasedOnActiveModuleid())),

            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: getColorBasedOnActiveModuleid())),
          ),

          onChanged: widget.onChange,
        ),
      );
    });
  }
}
