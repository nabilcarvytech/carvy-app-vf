import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/vehiclehost/editvehicle/edit_vehicle_home_screen.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:carvy/work_space.dart';
import 'package:image_picker/image_picker.dart';

class UploadImageScreen extends StatefulWidget {
  final VoidCallback? onNextButtonPressed;
  final VoidCallback? onBackButtonPressed;
  final ScreenMode mode;
  const UploadImageScreen(
      {super.key,
      this.onNextButtonPressed,
      required this.mode,
      this.onBackButtonPressed});
  @override
  State<UploadImageScreen> createState() => _UploadImageScreenState();
}

class _UploadImageScreenState extends State<UploadImageScreen> {
  @override
  void initState() {
    super.initState();
    resetState();
  }

  AddItemsHostController addItemsHostController = Get.find();
  bool _imagesChanged = false;
  stateSetter(fn) => setState(() {});
  void resetState() {
    setState(() {
      addItemsHostController.frontImage = null;
      addItemsHostController.docementsImage = null;
      addItemsHostController.galleryImageList.clear();
    });
  }

  bool checkUpdate = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              decoration: const BoxDecoration(),
              child: AppBar(
                leadingWidth: 80,
                title: Text(
                  "Upload your place photos".tr,
                  style: heading2Grey1(context),
                ),
                leading: GestureDetector(
                    onTap: () {
                      if (widget.mode == ScreenMode.add) {
                        Get.to(const BottomHost(
                          initialIndex: 0,
                        ));
                      } else if (widget.mode == ScreenMode.edit) {
                        Get.to(const EditVehicleHomeScreen());
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 20, top: 8, bottom: 8, right: 20),
                      child: PhysicalModel(
                        color: Colors.transparent,
                        shadowColor: notifires.getGrey4Whitecolor,
                        elevation: 5.0,
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
                surfaceTintColor: notifires.getbgcolor,
              ),
            )),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        LabelNames(labelname: "Front Image".tr),
                        frontImagePopup(
                          "Change".tr,
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    frontImagePopup(
                      "",
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    item == null
                        ? const SizedBox()
                        : item!.gallery!.isEmpty
                            ? const SizedBox()
                            : LabelNames(
                                labelname: "Previous Gallery Images".tr),
                    item == null
                        ? const SizedBox()
                        : item!.gallery!.isEmpty
                            ? const SizedBox()
                            : Container(
                                height: 150,
                                decoration: BoxDecoration(
                                  color: notifires.getblackwhitecolor,
                                  borderRadius: BorderRadius.circular(15),
                                  border: Border.all(color: greyColor),
                                ),
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: item!.gallery!.length,
                                  itemBuilder: (itemBuilder, index) {
                                    return Stack(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 16, bottom: 16, left: 16),
                                          child: InkWell(
                                            onTap: () {},
                                            child: SizedBox(
                                              width: Get.width / 3,
                                              height: 134,
                                              child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      border: Border.all()),
                                                  child: ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: Image.network(
                                                        item!.gallery![index]
                                                            .url!,
                                                        fit: BoxFit.fitWidth,
                                                      ))),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                            right: 0,
                                            top: 10,
                                            child: InkWell(
                                                onTap: () {
                                                  dialogExit(
                                                      BuildContext context) {
                                                    return showDialog<void>(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          backgroundColor:
                                                              notifires
                                                                  .getbgcolor,
                                                          surfaceTintColor:
                                                              notifires
                                                                  .getbgcolor,
                                                          content:
                                                              SingleChildScrollView(
                                                            child: ListBody(
                                                              children: <Widget>[
                                                                Icon(
                                                                  Icons.error,
                                                                  size: 75,
                                                                  color:
                                                                      redColor,
                                                                ),
                                                                const SizedBox(
                                                                    height: 5),
                                                                Text(
                                                                    'Do you want to Delete Image?'
                                                                        .tr,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style: smallHeadigAirBd
                                                                        .copyWith(
                                                                            color:
                                                                                notifires.getwhiteblackcolor)),
                                                              ],
                                                            ),
                                                          ),
                                                          actions: <Widget>[
                                                            Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    Expanded(
                                                                        child: InkWell(
                                                                            onTap: () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                            child: Container(margin: const EdgeInsets.only(left: 8, right: 8), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: getColorBasedOnActiveModuleid(), border: Border.all(color: getColorBasedOnActiveModuleid()), borderRadius: BorderRadius.circular(10)), child: Center(child: Text("Cancel".tr, style: normalAirBk.copyWith(color: Colors.white)))))),
                                                                    Expanded(
                                                                        child: InkWell(
                                                                            onTap: () {
                                                                              Navigator.pop(context);
                                                                              addItemsHostController.listDeleteImages.add(item!.gallery![index].url);
                                                                              item!.gallery!.removeAt(index);
                                                                              setState(() {
                                                                                checkUpdate = true;
                                                                              });
                                                                            },
                                                                            child: Container(margin: const EdgeInsets.only(left: 8, right: 8), padding: const EdgeInsets.all(10), decoration: BoxDecoration(border: Border.all(color: getColorBasedOnActiveModuleid()), color: getColorBasedOnActiveModuleid(), borderRadius: BorderRadius.circular(10)), child: Center(child: Text("Yes".tr, style: normalAirBk.copyWith(color: Colors.white)))))),
                                                                  ],
                                                                ),
                                                                const SizedBox(
                                                                  height: 8,
                                                                )
                                                              ],
                                                            )
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  }

                                                  dialogExit(context);
                                                },
                                                child: Container(
                                                    padding:
                                                        const EdgeInsets.all(3),
                                                    decoration: BoxDecoration(
                                                        color: Colors
                                                            .redAccent.shade200,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20)),
                                                    child: const Icon(
                                                      Icons
                                                          .delete_forever_rounded,
                                                      color: Colors.white,
                                                    ))))
                                      ],
                                    );
                                  },
                                )),
                    item != null &&
                            item!.gallery!.isNotEmpty &&
                            item!.gallery!.length == 3
                        ? const SizedBox()
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              LabelNames(
                                labelname: "Gallery Images (Max 2 MB)".tr,
                              ),
                              galleryImagePopup("Add".tr, context),
                            ],
                          ),
                    const SizedBox(height: 15),
                    item != null &&
                            item!.gallery!.isNotEmpty &&
                            item!.gallery!.length == 3
                        ? const SizedBox()
                        : galleryImagePopup("", context),
                    item != null &&
                            item!.gallery!.isNotEmpty &&
                            item!.gallery!.length == 3
                        ? const SizedBox()
                        : const SizedBox(
                            height: 8,
                          ),
                    Text(
                      "${"Select Upto".tr} ${item != null ? item!.gallery!.length + addItemsHostController.galleryImageList.length : ''}${item != null ? '' : addItemsHostController.galleryImageList.length}/3 ${"images".tr}"
                          .tr
                          .tr,
                      style: regular3(context).copyWith(
                          color: notifires.getGrey2Whitecolor, fontSize: 14),
                    ),

                    // Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //   children: [
                    //     LabelNames(labelname: "Official Vehicle Documents".tr),
                    //   ],
                    // ),
                    const SizedBox(height: 35),
                    Container(
                      margin: const EdgeInsets.symmetric(
                         vertical: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: themeColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: themeColor,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "A member of the Carvy team will contact you as soon as possible to validate your car.",
                              style: regular2(context).copyWith(
                                color: Colors.black87,
                                fontSize: 14,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),
                    // Row(
                    //   children: [
                    //     Expanded(
                    //       child: docFrontImagePopup(
                    //         "Registration Card (Carte Grise)",
                    //       ),
                    //     ),
                    //     const SizedBox(
                    //       width: 20,
                    //     ),
                    //     Expanded(
                    //       child: docFrontImagePopup(
                    //         "Vehicle Authorization Document",
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomHosts(
            onTap: () {
              if (_imagesChanged || checkUpdate) {
                addItemsHostController.updateUploadImage(widget.mode);
              } else {
                showErrorToastMessage("update or add the image first ".tr);
              }
            },
            txt: widget.mode == ScreenMode.edit
                ? truncatetext("Update".tr, 9)
                : truncatetext("Submit".tr, 9),
            backButtontxt: "Back".tr,
            backOnPressed: () {
              if (widget.mode == ScreenMode.add) {
                Get.to(const BottomHost(
                  initialIndex: 0,
                ));
              } else if (widget.mode == ScreenMode.edit) {
                Get.to(const EditVehicleHomeScreen());
              }
            }));
  }

  Widget frontImagePopup(text) {
    return PopupMenuButton<int>(
      itemBuilder: (context) => [
        if (!webPlateForm)
          PopupMenuItem(
            onTap: () async {
              selectImageWithSource(
                ImageSource.camera,
              );
            },
            child: Text(
              "Select with camera".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
        PopupMenuItem(
          onTap: () async {
            if (webPlateForm) {
              selectfrontImageForweb();
            } else {
              selectImageWithSource(
                ImageSource.gallery,
              );
            }
          },
          child: Text(
            "Select with Gallery".tr,
            style: regular02.copyWith(color: grey1),
          ),
        ),
      ],
      offset: const Offset(1, 50),
      child: text == "Change".tr
          ? Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                addItemsHostController.frontImage != null ||
                        (item != null && item!.frontImage != null)
                    ? "Change".tr
                    : "",
                style: normalAirBk.copyWith(
                    fontSize: 16, color: getColorBasedOnActiveModuleid()),
              ),
            )
          : Container(
              height: 200,
              decoration: BoxDecoration(
                color: notifires.getboxcolor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: notifires.getGrey3Whitecolor.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                child: addItemsHostController.frontImage != null ||
                        (item != null && item!.frontImage != null)
                    ? SizedBox(
                        width: Get.width,
                        child: InkWell(
                          onTap: () {},
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if (item != null &&
                                    item!.frontImage != null &&
                                    addItemsHostController.frontImage == null)
                                  const CircularProgressIndicator(),
                                if (item != null &&
                                    item!.frontImage != null &&
                                    addItemsHostController.frontImage == null)
                                  Image.network(
                                    item!.frontImage!.url!,
                                    fit: BoxFit.contain,
                                  ),
                                if (addItemsHostController.frontImage != null)
                                  webPlateForm
                                      ? Image.network(
                                          addItemsHostController
                                              .frontImage!.path,
                                          fit: BoxFit.contain,
                                        )
                                      : Image.file(
                                          File(addItemsHostController
                                              .frontImage!.path),
                                          fit: BoxFit.contain,
                                        ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Icon(
                        Icons.cloud_upload,
                        color: getColorBasedOnActiveModuleid(),
                        size: 45,
                      ),
              ),
            ),
    );
  }

  // Widget docFrontImagePopup(String text) {
  //   return PopupMenuButton<int>(
  //     itemBuilder: (context) => [
  //       if (!webPlateForm)
  //         PopupMenuItem(
  //           onTap: () async {
  //             selectImageWithSourceDoc(ImageSource.camera);
  //           },
  //           child: Text(
  //             "Select with Camera".tr,
  //             style: regular02.copyWith(color: grey1),
  //           ),
  //         ),
  //       PopupMenuItem(
  //         onTap: () async {
  //           if (webPlateForm) {
  //             selectDoecImageForweb();
  //           } else {
  //             selectImageWithSourceDoc(ImageSource.gallery);
  //           }
  //         },
  //         child: Text(
  //           "Select with Gallery".tr,
  //           style: regular02.copyWith(color: grey1),
  //         ),
  //       ),
  //     ],
  //     offset: const Offset(1, 50),
  //     child: Container(
  //       height: 200,
  //       decoration: BoxDecoration(
  //         color: notifires.getboxcolor,
  //         borderRadius: BorderRadius.circular(12),
  //         boxShadow: [
  //           BoxShadow(
  //             color: notifires.getGrey3Whitecolor.withOpacity(0.1),
  //             spreadRadius: 3,
  //             blurRadius: 5,
  //             offset: const Offset(0, 0),
  //           ),
  //         ],
  //       ),
  //       child: Center(
  //         child: addItemsHostController.docementsImage != null ||
  //                 (item != null && item!.frontImageDoc != null)
  //             ? Stack(
  //                 children: [
  //                   ClipRRect(
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: SizedBox(
  //                       width: double.infinity,
  //                       height: 200,
  //                       child: addItemsHostController.docementsImage != null
  //                           ? (webPlateForm
  //                               ? Image.network(
  //                                   addItemsHostController.docementsImage!.path,
  //                                   fit: BoxFit.cover,
  //                                 )
  //                               : Image.file(
  //                                   File(addItemsHostController
  //                                       .docementsImage!.path),
  //                                   fit: BoxFit.cover,
  //                                 ))
  //                           : (item!.frontImageDoc != null
  //                               ? Image.network(
  //                                   item!.frontImageDoc!.url!,
  //                                   fit: BoxFit.cover,
  //                                 )
  //                               : const SizedBox()),
  //                     ),
  //                   ),
  //                   Positioned(
  //                     top: 8,
  //                     right: 8,
  //                     child: Container(
  //                       decoration: BoxDecoration(
  //                         color: themeColor,
  //                         borderRadius: BorderRadius.circular(6),
  //                       ),
  //                       child: Padding(
  //                         padding: const EdgeInsets.symmetric(
  //                             horizontal: 8, vertical: 4),
  //                         child: Text(
  //                           "Change".tr,
  //                           style: normalAirBk.copyWith(
  //                             color: whiteColor,
  //                             fontSize: 10,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               )
  //             : Column(
  //                 mainAxisAlignment: MainAxisAlignment.center,
  //                 children: [
  //                   Icon(
  //                     Icons.cloud_upload,
  //                     color: getColorBasedOnActiveModuleid(),
  //                     size: 45,
  //                   ),
  //                   const SizedBox(height: 15),
  //                   Text(
  //                     text,
  //                     style: const TextStyle(fontSize: 10),
  //                   ),
  //                 ],
  //               ),
  //       ),
  //     ),
  //   );
  // }

  // Widget docFrontImagePopup(
  //   text,
  // ) {
  //   return PopupMenuButton<int>(
  //     itemBuilder: (context) => [
  //       if (!webPlateForm)
  //         PopupMenuItem(
  //           onTap: () async {
  //             selectImageWithSourceDoc(
  //               ImageSource.camera,
  //             );
  //           },
  //           child: Text(
  //             "Select with camera".tr,
  //             style: regular02.copyWith(color: grey1),
  //           ),
  //         ),
  //       PopupMenuItem(
  //         onTap: () async {
  //           if (webPlateForm) {
  //             selectDoecImageForweb();
  //           } else {
  //             selectImageWithSourceDoc(
  //               ImageSource.gallery,
  //             );
  //           }
  //         },
  //         child: Text(
  //           "Select with Gallery".tr,
  //           style: regular02.copyWith(color: grey1),
  //         ),
  //       ),
  //     ],
  //     offset: const Offset(1, 50),
  //     child: text == "Change".tr
  //         ? Padding(
  //             padding: const EdgeInsets.only(bottom: 8.0),
  //             child: Text(
  //               addItemsHostController.docementsImage != null ||
  //                       (item != null && item!.frontImageDoc != null)
  //                   ? "Change".tr
  //                   : "",
  //               style: normalAirBk.copyWith(
  //                   fontSize: 16, color: getColorBasedOnActiveModuleid()),
  //             ),
  //           )
  //         : Container(
  //             height: 200,
  //             decoration: BoxDecoration(
  //               color: notifires.getboxcolor,
  //               borderRadius: BorderRadius.circular(12),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: notifires.getGrey3Whitecolor.withOpacity(0.1),
  //                   spreadRadius: 3,
  //                   blurRadius: 5,
  //                   offset: const Offset(0, 0),
  //                 ),
  //               ],
  //             ),
  //             child: Center(
  //               child: addItemsHostController.docementsImage != null ||
  //                       (item != null && item!.frontImageDoc != null)
  //                   ? SizedBox(
  //                       width: Get.width,
  //                       child: InkWell(
  //                         onTap: () {},
  //                         child: ClipRRect(
  //                           borderRadius: BorderRadius.circular(15),
  //                           child: Stack(
  //                             alignment: Alignment.center,
  //                             children: [
  //                               if (item != null &&
  //                                   item!.frontImageDoc != null &&
  //                                   addItemsHostController.docementsImage ==
  //                                       null)
  //                                 const CircularProgressIndicator(),
  //                               if (item != null &&
  //                                   item!.frontImageDoc != null &&
  //                                   addItemsHostController.docementsImage ==
  //                                       null)
  //                                 Image.network(
  //                                   item!.frontImageDoc!.url!,
  //                                   fit: BoxFit.contain,
  //                                 ),
  //                               if (addItemsHostController.docementsImage !=
  //                                   null)
  //                                 webPlateForm
  //                                     ? Image.network(
  //                                         addItemsHostController
  //                                             .docementsImage!.path,
  //                                         fit: BoxFit.contain,
  //                                       )
  //                                     : Image.file(
  //                                         File(addItemsHostController
  //                                             .docementsImage!.path),
  //                                         fit: BoxFit.contain,
  //                                       ),
  //                             ],
  //                           ),
  //                         ),
  //                       ),
  //                     )
  //                   : Column(
  //                     crossAxisAlignment: CrossAxisAlignment.center,
  //                     mainAxisAlignment: MainAxisAlignment.center,
  //                     children: [
  //                       Icon(
  //                           Icons.cloud_upload,
  //                           color: getColorBasedOnActiveModuleid(),
  //                           size: 45,
  //                         ),
  //                         SizedBox(height: 15,),
  //                         Text(text,style: TextStyle(fontSize: 10),)
  //                     ],
  //                   ),
  //             ),
  //           ),
  //   );
  // }

  Widget galleryImagePopup(text, BuildContext context) {
    return PopupMenuButton<int>(
      itemBuilder: (context) =>
          addItemsHostController.galleryImageList.length > 4
              ? []
              : [
                  if (!webPlateForm)
                    PopupMenuItem(
                      onTap: () async {
                        selectMultipleImageWithSource(
                          ImageSource.camera,
                        );
                      },
                      child: Text(
                        "Select with camera".tr,
                        style: regular02.copyWith(color: grey1),
                      ),
                    ),
                  PopupMenuItem(
                    onTap: () async {
                      if (webPlateForm) {
                        selectMultipleImagesForWeb();
                      } else {
                        selectMultipleImageWithSource(
                          ImageSource.gallery,
                        );
                      }
                    },
                    child: Text(
                      "Select with Gallery".tr,
                      style: regular02.copyWith(color: grey1),
                    ),
                  ),
                ],
      offset: const Offset(1, 50),
      child: text == "Add".tr
          ? Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: addItemsHostController.galleryImageList.length +
                              (item != null ? item!.gallery!.length : 0) ==
                          5
                      ? const SizedBox()
                      : Text(
                          addItemsHostController.galleryImageList.isNotEmpty &&
                                  addItemsHostController
                                          .galleryImageList.length <
                                      3
                              ? "Add".tr
                              : addItemsHostController
                                          .galleryImageList.length ==
                                      3
                                  ? ""
                                  : "",
                          style: smallHeadigAirBd.copyWith(
                              color: getColorBasedOnActiveModuleid(),
                              fontSize: 16),
                        ),
                ),
              ],
            )
          : Container(
              height: 150,
              decoration: BoxDecoration(
                color: notifires.getboxcolor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: notifires.getGrey3Whitecolor.withOpacity(0.1),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Center(
                  child: addItemsHostController.galleryImageList.isNotEmpty
                      ? ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount:
                              addItemsHostController.galleryImageList.length,
                          itemBuilder: (itemBuilder, index) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 16, bottom: 16, left: 16),
                                  child: InkWell(
                                    onTap: () {},
                                    child: SizedBox(
                                      width: Get.width / 3,
                                      height: 134,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all()),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          child: webPlateForm
                                              ? Image.network(
                                                  addItemsHostController
                                                      .galleryImageList[index]
                                                      .path,
                                                  fit: BoxFit.contain,
                                                )
                                              : Image.file(
                                                  File(addItemsHostController
                                                      .galleryImageList[index]
                                                      .path),
                                                  fit: BoxFit.contain,
                                                ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                    right: 0,
                                    top: 10,
                                    child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: InkWell(
                                            onTap: () {
                                              addItemsHostController
                                                  .galleryImageList
                                                  .removeAt(index);
                                              addItemsHostController
                                                  .galleryImageBase64List
                                                  .removeAt(index);
                                              setState(() {});
                                            },
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.all(3),
                                                color:
                                                    Colors.redAccent.shade200,
                                                child: const Icon(
                                                  Icons.delete_forever_rounded,
                                                  color: Colors.white,
                                                )))))
                              ],
                            );
                          },
                        )
                      : Icon(
                          Icons.cloud_upload,
                          color: getColorBasedOnActiveModuleid(),
                          size: 45,
                        )),
            ),
    );
  }

  void selectfrontImageForweb() async {
    showLoading();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      for (var file in result.files) {
        Uint8List fileBytes = file.bytes!;
        String base64Image = base64Encode(fileBytes);
        String format = detectImageFormat(fileBytes);
        XFile xfile = XFile.fromData(fileBytes, name: file.name);
        _imagesChanged = true;
        setState(() {});
        addItemsHostController.frontImage = xfile;
        addItemsHostController.frontImageBase64 =
            "data:image/$format;base64,$base64Image";
      }
      closeLoading();
      setState(() {});
    }
  }

  void selectDoecImageForweb() async {
    showLoading();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      for (var file in result.files) {
        Uint8List fileBytes = file.bytes!;

        String base64Image = base64Encode(fileBytes);
        String format = detectImageFormat(fileBytes);
        XFile xfile = XFile.fromData(fileBytes, name: file.name);
        _imagesChanged = true;
        setState(() {});
        addItemsHostController.docementsImage = xfile;
        addItemsHostController.frontImageBase64fordoec =
            "data:image/$format;base64,$base64Image";
      }
      closeLoading();
      setState(() {});
    }
  }

  void selectMultipleImagesForWeb() async {
    if (addItemsHostController.galleryImageList.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You can only select up to 3 images."),
        ),
      );
      return;
    }
    showLoading();
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
    );

    if (result != null && result.files.isNotEmpty) {
      if (result.files.length + addItemsHostController.galleryImageList.length >
          3) {
        showErrorToastMessage(
            "Limit Exceeded ,You can't add more than 3 images.");

        closeLoading();
        return;
      }

      for (var file in result.files) {
        if (addItemsHostController.galleryImageList.length >= 3) break;
        Uint8List fileBytes = file.bytes!;
        String base64Image = base64Encode(fileBytes);
        String format = detectImageFormat(fileBytes);
        XFile xfile = XFile.fromData(fileBytes, name: file.name);
        addItemsHostController.galleryImageList.add(xfile);
        addItemsHostController.galleryImageBase64List
            .add("data:image/$format;base64,$base64Image");
      }
      closeLoading();
      setState(() {});
    }
  }

  String detectImageFormat(Uint8List bytes) {
    if (bytes.length > 4) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8) {
        return 'jpeg';
      } else if (bytes[0] == 0x89 && bytes[1] == 0x50) {
        return 'png';
      }
    }
    return 'jpeg';
  }

  int fileSizeThreshold = 500 * 1024;
  int goodQuality = 90;
  int badQuality = 70;
  int maxWidth = 800;
  int maxHeight = 800;

  String sourec = "";

  Future<void> selectImageWithSource(ImageSource source) async {
    if (source == ImageSource.camera) {
      sourec = "Camera";
    } else {
      sourec = "Gallery";
    }
    try {
      var image = await ImagePicker().pickImage(source: source);

      if (image == null) {
        return;
      }
      addItemsHostController.frontImage = image;
      _imagesChanged = true;
      setState(() {});
      var imageFile = File(image.path);
      int imageSize = await imageFile.length();
      int quality = imageSize > fileSizeThreshold ? badQuality : goodQuality;
      var compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      var base64Image = base64Encode(compressedImage!);

      String format = '';
      if (compressedImage.length > 8) {
        if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
          format = 'jpeg';
        } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
          format = 'png';
        }
      }
      addItemsHostController.frontImageBase64 =
          "data:image/$format;base64,$base64Image";
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "$sourec permission denied. Please go to settings and allow the $sourec.");
      }
    }
  }

  Future<void> selectImageWithSourceDoc(ImageSource source) async {
    if (source == ImageSource.camera) {
      sourec = "Camera";
    } else {
      sourec = "Gallery";
    }
    try {
      var image = await ImagePicker().pickImage(source: source);

      if (image == null) {
        return;
      }
      addItemsHostController.docementsImage = image;
      _imagesChanged = true;
      setState(() {});
      var imageFile = File(image.path);
      int imageSize = await imageFile.length();
      int quality = imageSize > fileSizeThreshold ? badQuality : goodQuality;
      var compressedImage = await FlutterImageCompress.compressWithFile(
        image.path,
        quality: quality,
        minWidth: maxWidth,
        minHeight: maxHeight,
      );

      var base64Image = base64Encode(compressedImage!);

      String format = '';
      if (compressedImage.length > 8) {
        if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
          format = 'jpeg';
        } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
          format = 'png';
        }
      }
      addItemsHostController.frontImageBase64fordoec =
          "data:image/$format;base64,$base64Image";
    } on PlatformException {
      if (Platform.isIOS) {
        showOpenAppSettingsDialog(context,
            "$sourec permission denied. Please go to settings and allow the $sourec.");
      }
    }
  }

  Future<void> selectMultipleImageWithSource(ImageSource source) async {
    if (source == ImageSource.camera) {
      try {
        var image = await ImagePicker().pickImage(source: source);
        if (image == null) {
          return;
        }
        addItemsHostController.galleryImageList.clear();
        var imageFile = File(image.path);
        int imageSize = await imageFile.length();
        int quality = imageSize > fileSizeThreshold ? badQuality : goodQuality;
        var compressedImage = await FlutterImageCompress.compressWithFile(
          image.path,
          quality: quality,
          minWidth: maxWidth,
          minHeight: maxHeight,
        );
        var base64Image = base64Encode(compressedImage!);

        String format = '';
        if (compressedImage.length > 8) {
          if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
            format = 'jpeg';
          } else if (compressedImage[0] == 0x89 && compressedImage[1] == 0x50) {
            format = 'png';
          }
        }
        addItemsHostController.galleryImageList.add(image);
        addItemsHostController.galleryImageBase64List.clear();
        addItemsHostController.galleryImageBase64List
            .add("data:image/$format;base64,$base64Image");
        _imagesChanged = true;
        setState(() {});
      } on PlatformException {
        if (Platform.isIOS) {
          showOpenAppSettingsDialog(context,
              "Camera permission denied. Please go to settings and allow the Camera.");
        }
      }
    } else {
      try {
        List<XFile> images = await ImagePicker().pickMultiImage();
        if (images.isEmpty) {
          return;
        }
        for (int i = 0; i < images.length; i++) {
          if (i < 5) {
            var imageFile = File(images[i].path);
            int imageSize = await imageFile.length();
            int quality =
                imageSize > fileSizeThreshold ? badQuality : goodQuality;
            var compressedImage = await FlutterImageCompress.compressWithFile(
              images[i].path,
              quality: quality,
              minWidth: maxWidth,
              minHeight: maxHeight,
            );
            var base64Image = base64Encode(compressedImage!);

            String format = '';
            if (compressedImage.length > 8) {
              if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
                format = 'jpeg';
              } else if (compressedImage[0] == 0x89 &&
                  compressedImage[1] == 0x50) {
                format = 'png';
              }
            }
            int totalLength = addItemsHostController.galleryImageList.length;
            if (item != null) {
              totalLength += item!.gallery!.length;
            }
            if (totalLength < 3) {
              addItemsHostController.galleryImageList.add(images[i]);
              addItemsHostController.galleryImageBase64List
                  .add("data:image/$format;base64,$base64Image");
            }
            _imagesChanged = true;
            setState(() {});
          }
        }
      } on PlatformException {
        if (Platform.isIOS) {
          showOpenAppSettingsDialog(context,
              "Photo permission denied. Please go to settings and allow the Photo.");
        }
      }
    }
  }
}
