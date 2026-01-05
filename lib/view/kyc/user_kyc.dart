import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carvy/controller/kyc_controller.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/work_space.dart';

class UserKyc extends StatefulWidget {
  const UserKyc({super.key});

  @override
  State<UserKyc> createState() => _UserKycState();
}

class _UserKycState extends State<UserKyc> {
  ProfileController profileController = Get.find();
  KycController kycController = Get.find();

  @override
  void initState() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      kycController.getUserKycData();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Obx(() {
              if (kycController.isdataLoading.value) {
                return SizedBox.shrink();
              }

              // Mapper les statuts selon le contrat API (kyc_status)
              String displayText = "";
              Color displayColor = Colors.grey;

              if (kycController.activeStatus.value == "approved") {
                displayText = "Vérifié";
                displayColor = Colors.green;
              } else if (kycController.activeStatus.value == "pending" ||
                  kycController.activeStatus.value == "review") {
                displayText = "Vérification en cours";
                displayColor = Colors.orange;
              } else if (kycController.activeStatus.value == "rejected") {
                displayText = "Rejeté";
                displayColor = Colors.red;
              } else {
                final statusInfo = kycController.getReviewStatus();
                final statusText = statusInfo["text"] as String;
                final statusColor = statusInfo["color"] as Color?;
                if (statusText.isNotEmpty) {
                  displayText = statusText;
                  displayColor = statusColor ?? Colors.grey;
                }
              }

              return displayText.isNotEmpty
                  ? Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: displayColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: displayColor, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: displayColor,
                            ),
                          ),
                          SizedBox(width: 6),
                          Text(
                            displayText,
                            style: TextStyle(
                              color: displayColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.shrink();
            }),
          ),
        ],
        backgroundColor: notifires.getbgcolor,
        title: 'KYC'.tr,
        titleColor: notifires.getwhiteblackcolor,
      ),
      body: Obx(
        () {
          // Afficher le loader si les données sont en cours de chargement
          if (kycController.isdataLoading.value == true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            );
          }

          // Toujours afficher le formulaire d'édition, même si le statut est 'pending'
          // L'utilisateur peut modifier ses documents à tout moment

          // Afficher le formulaire d'édition
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListView(
              children: [
                Row(
                  children: [
                    Text(
                      "First driver license".tr,
                      style: heading2Grey1(context)
                          .copyWith(color: blackColor, fontSize: 15),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "*",
                      style: heading2Grey1(context).copyWith(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                SizedBox(
                  child: Row(
                    children: [
                      Expanded(child: addharFrontImage("Change", context)),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(child: addharBack("", context)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Primary reference mob no".tr,
                  style: heading2Grey1(context)
                      .copyWith(color: blackColor, fontSize: 15),
                ),
                SizedBox(
                  height: 5,
                ),
                AbsorbPointer(
                  absorbing:
                      kycController.activeStatus.value == "yes" ? true : false,
                  child: IntelPhoneFieldRefs(
                    validator: (phoneNumber) {
                      if (phoneNumber == null || phoneNumber.number.isEmpty) {
                        return 'Please enter your phone number';
                      }

                      int expectedLength =
                          phoneLengths[phoneNumber.countryISOCode] ?? 10;
                      if (phoneNumber.number.length != expectedLength) {
                        return 'Phone number must be $expectedLength digits';
                      }
                      return null;
                    },
                    defultcountry: kycController.countryShortNamePrimary,
                    textEditingControllerCommons:
                        kycController.referenceMobileNo1,
                    selectedcountry: kycController.defaultCountryCodePrimary,
                    oncountryChanged: (value) {
                      kycController.referenceMobileNo1.clear();
                      kycController.defaultCountryCodePrimary =
                          "+${value.dialCode}";
                      kycController.countryShortNamePrimary = value.code;
                    },
                    onChanged: (value) {
                      // Limit the input to the expected length
                      int expectedLength = phoneLengths[
                              profileController.defaultCountry.value] ??
                          10;

                      if (value!.number.length > expectedLength) {
                        // Truncate the input to the expected length
                        kycController.referenceMobileNo1.text =
                            value.number.substring(0, expectedLength);
                        kycController.referenceMobileNo1.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset:
                                  kycController.referenceMobileNo1.text.length),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Text("Second driver license".tr,
                    style: heading2Grey1(context)
                        .copyWith(color: blackColor, fontSize: 15)),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Expanded(child: dfFrontImage("", context)),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(child: dlBackImage("", context)),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Text(
                  "Secondary reference mob no (Optional)".tr,
                  style: heading2Grey1(context)
                      .copyWith(color: blackColor, fontSize: 15),
                ),
                SizedBox(
                  height: 5,
                ),
                AbsorbPointer(
                  absorbing:
                      kycController.activeStatus.value == "yes" ? true : false,
                  child: IntelPhoneFieldRefs(
                    validator: (phoneNumber) {
                      if (phoneNumber == null || phoneNumber.number.isEmpty) {
                        return 'Please enter your phone number';
                      }

                      int expectedLength =
                          phoneLengths[phoneNumber.countryISOCode] ?? 10;
                      if (phoneNumber.number.length != expectedLength) {
                        return 'Phone number must be $expectedLength digits';
                      }
                      return null;
                    },
                    defultcountry: kycController.countryShortNameSecondary,
                    textEditingControllerCommons:
                        kycController.referenceMobileNo2,
                    selectedcountry: kycController.defaultCountryCodeSecondary,
                    oncountryChanged: (value) {
                      kycController.referenceMobileNo2.clear();
                      kycController.defaultCountryCodeSecondary =
                          "+${value.dialCode}";
                      kycController.countryShortNameSecondary = value.code;
                    },
                    onChanged: (value) {
                      // Limit the input to the expected length
                      int expectedLength = phoneLengths[
                              profileController.defaultCountry.value] ??
                          10;

                      if (value!.number.length > expectedLength) {
                        // Truncate the input to the expected length
                        kycController.referenceMobileNo2.text =
                            value.number.substring(0, expectedLength);
                        kycController.referenceMobileNo2.selection =
                            TextSelection.fromPosition(
                          TextPosition(
                              offset:
                                  kycController.referenceMobileNo2.text.length),
                        );
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                // Toujours permettre la soumission pour permettre la mise à jour des documents
                // (Update mode - même si le statut est pending/review, on peut écraser les anciens documents)
                Obx(() {
                  // Ne bloquer que si le statut est 'approved' (vérifié et finalisé)
                  final status = kycController.activeStatus.value;
                  final isDisabled = status == "yes" || status == "approved";

                  return Column(
                    children: [
                      // Bouton "Passer pour l'instant" stylisé
                      Center(
                        child: TextButton(
                          onPressed: () {
                            kycController.bypassKyc();
                            Get.back();
                          },
                          child: Text(
                            "Passer pour l'instant".tr,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      // Bouton "Appliquer"
                      isDisabled
                          ? SizedBox()
                          : CustomsButtons(
                              text: "Apply".tr,
                              backgroundColor: getColorBasedOnActiveModuleid(),
                              onPressed: () {
                                kycController.submit(context);
                              }),
                    ],
                  );
                })
              ],
            ),
          );
        },
      ),
    );
  }

  // Widget pour afficher une image en lecture seule (mode pending)
  Widget _buildReadOnlyImagePreview(String imageUrl, BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
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
      child: imageUrl.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return getErrorImage();
                },
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.grey.shade400,
                    size: 35,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Aucune image".tr,
                    style: regular2(context).copyWith(
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget addharFrontImage(String text, BuildContext context) {
    // Permettre l'édition même si le statut est 'pending' (ne bloquer que 'yes' et 'approved')
    final isEditable = kycController.activeStatus.value != "yes" &&
        kycController.activeStatus.value != "approved";

    return IgnorePointer(
      ignoring: !isEditable,
      child: PopupMenuButton<int>(
        enabled: isEditable,
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () async {
              kycController
                  .uplaodImageAddharFront(ImageSource.camera, context)
                  .then((_) {
                setState(() {});
              });
            },
            child: Text(
              "Select with camera".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              kycController
                  .uplaodImageAddharFront(ImageSource.gallery, context)
                  .then((_) {
                setState(() {});
              });
            },
            child: Text(
              "Select with Gallery".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
        ],
        offset: const Offset(1, 50),
        child: Container(
          height: 200,
          width: double.infinity,
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
          child: Obx(() {
            // Afficher un indicateur de chargement si les données sont en cours de chargement
            if (kycController.isdataLoading.value) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // Priorité 1: Image locale sélectionnée
            Widget imageWidget;
            if (kycController.addharFrontImage.value != null) {
              imageWidget = ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(kycController.addharFrontImage.value!.path),
                  fit: BoxFit.cover,
                ),
              );
            }
            // Priorité 2: URL depuis le backend (persistante)
            else if (kycController.frontImageUrl.value.isNotEmpty) {
              imageWidget = ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  kycController.frontImageUrl.value,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return getErrorImage();
                  },
                ),
              );
            }
            // Priorité 3: Icône d'upload
            else {
              imageWidget = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    color: getColorBasedOnActiveModuleid(),
                    size: 35,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Front image",
                    style: regular2(context),
                  ),
                ],
              );
            }

            // Vérifier si l'édition est autorisée (permettre l'édition même si pending)
            final isEditable = kycController.activeStatus.value != "yes" &&
                kycController.activeStatus.value != "approved";

            return Stack(
              children: [
                Center(child: imageWidget),
                // Afficher l'icône d'édition uniquement si l'édition est autorisée
                isEditable
                    ? Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget addharBack(String text, BuildContext context) {
    // Permettre l'édition même si le statut est 'pending' (ne bloquer que 'yes' et 'approved')
    final isEditable = kycController.activeStatus.value != "yes" &&
        kycController.activeStatus.value != "approved";

    return IgnorePointer(
      ignoring: !isEditable,
      child: PopupMenuButton<int>(
        enabled: isEditable,
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () async {
              if (kycController.activeStatus.value == "yes") {
                return;
              }
              kycController
                  .uplaodImageAddharback(ImageSource.camera, context)
                  .then((_) {
                setState(
                    () {}); // This ensures the UI updates after the image is uploaded
              });
            },
            child: Text(
              "Select with camera".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              if (kycController.activeStatus.value == "yes") {
                return;
              }
              kycController
                  .uplaodImageAddharback(ImageSource.gallery, context)
                  .then((_) {
                setState(
                    () {}); // This ensures the UI updates after the image is uploaded
              });
            },
            child: Text(
              "Select with Gallery".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
        ],
        offset: const Offset(1, 50),
        child: Container(
          height: 200,
          width: double.infinity,
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
          child: Obx(() {
            // Afficher un indicateur de chargement si les données sont en cours de chargement
            if (kycController.isdataLoading.value) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            // Priorité 1: Image locale sélectionnée
            Widget imageWidget;
            if (kycController.addharBackImage.value != null) {
              imageWidget = ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(kycController.addharBackImage.value!.path),
                  fit: BoxFit.cover,
                ),
              );
            }
            // Priorité 2: URL depuis le backend (persistante)
            else if (kycController.backImageUrl.value.isNotEmpty) {
              imageWidget = ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  kycController.backImageUrl.value,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return getErrorImage();
                  },
                ),
              );
            }
            // Priorité 3: Icône d'upload
            else {
              imageWidget = Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_upload,
                    color: getColorBasedOnActiveModuleid(),
                    size: 35,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Back image",
                    style: regular2(context),
                  ),
                ],
              );
            }

            // Vérifier si l'édition est autorisée (permettre l'édition même si pending)
            final isEditable = kycController.activeStatus.value != "yes" &&
                kycController.activeStatus.value != "approved";

            return Stack(
              children: [
                Center(child: imageWidget),
                // Afficher l'icône d'édition uniquement si l'édition est autorisée
                isEditable
                    ? Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black54,
                          ),
                          padding: EdgeInsets.all(6),
                          child: Icon(
                            Icons.edit,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget dfFrontImage(String text, BuildContext context) {
    // Désactiver l'édition si le statut est 'pending' ou 'approved'
    final isEditable = kycController.activeStatus.value != "yes" &&
        kycController.activeStatus.value != "approved" &&
        kycController.activeStatus.value != "pending";

    return IgnorePointer(
      ignoring: !isEditable,
      child: PopupMenuButton<int>(
        enabled: isEditable,
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () async {
              if (kycController.activeStatus.value == "yes") {
                return;
              }
              kycController
                  .uploadotherIdentiotyFront(ImageSource.camera, context)
                  .then((_) {
                setState(() {});
              });
            },
            child: Text(
              "Select with Camera".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              if (kycController.activeStatus.value == "yes") {
                return;
              }
              kycController
                  .uploadotherIdentiotyFront(ImageSource.gallery, context)
                  .then((_) {
                setState(() {});
              });
            },
            child: Text(
              "Select with Gallery".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
        ],
        offset: const Offset(1, 50),
        child: Obx(() {
          // Afficher un indicateur de chargement si les données sont en cours de chargement
          if (kycController.isdataLoading.value) {
            return Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: notifires.getboxcolor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Priorité 1: Image locale sélectionnée
          Widget imageWidget;
          if (kycController.otherimageFront.value != null) {
            imageWidget = ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(kycController.otherimageFront.value!.path),
                fit: BoxFit.cover,
              ),
            );
          }
          // Priorité 2: URL depuis le backend (persistante)
          else if (kycController.otherFrontImageUrl.value.isNotEmpty) {
            imageWidget = ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                kycController.otherFrontImageUrl.value,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return getErrorImage();
                },
              ),
            );
          }
          // Priorité 3: Icône d'upload
          else {
            imageWidget = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: getColorBasedOnActiveModuleid(),
                  size: 35,
                ),
                SizedBox(height: 10),
                Text(
                  "Front image",
                  style: regular2(context),
                ),
              ],
            );
          }

          // Vérifier si l'édition est autorisée
          final isEditable = kycController.activeStatus.value != "yes" &&
              kycController.activeStatus.value != "approved" &&
              kycController.activeStatus.value != "pending";

          return Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
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
                child: Center(child: imageWidget),
              ),
              // Afficher l'icône d'édition uniquement si l'édition est autorisée
              isEditable
                  ? Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          );
        }),
      ),
    );
  }

  Widget dlBackImage(String text, BuildContext context) {
    // Désactiver l'édition si le statut est 'pending' ou 'approved'
    final isEditable = kycController.activeStatus.value != "yes" &&
        kycController.activeStatus.value != "approved" &&
        kycController.activeStatus.value != "pending";

    return IgnorePointer(
      ignoring: !isEditable,
      child: PopupMenuButton<int>(
        enabled: isEditable,
        itemBuilder: (context) => [
          PopupMenuItem(
            onTap: () async {
              if (kycController.activeStatus.value == "yes") {
                return;
              }
              kycController
                  .uploadotherIdentiotyBack(ImageSource.camera, context)
                  .then((_) {
                setState(
                    () {}); // Ensures UI updates after the image is uploaded
              });
            },
            child: Text(
              "Select with Camera".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
          PopupMenuItem(
            onTap: () async {
              kycController
                  .uploadotherIdentiotyBack(ImageSource.gallery, context)
                  .then((_) {
                setState(
                    () {}); // Ensures UI updates after the image is uploaded
              });
            },
            child: Text(
              "Select with Gallery".tr,
              style: regular02.copyWith(color: grey1),
            ),
          ),
        ],
        offset: const Offset(1, 50),
        child: Obx(() {
          // Afficher un indicateur de chargement si les données sont en cours de chargement
          if (kycController.isdataLoading.value) {
            return Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: notifires.getboxcolor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Priorité 1: Image locale sélectionnée
          Widget imageWidget;
          if (kycController.otherImageBack.value != null) {
            imageWidget = ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(kycController.otherImageBack.value!.path),
                fit: BoxFit.cover,
              ),
            );
          }
          // Priorité 2: URL depuis le backend (persistante)
          else if (kycController.otherBackImageUrl.value.isNotEmpty) {
            imageWidget = ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                kycController.otherBackImageUrl.value,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return getErrorImage();
                },
              ),
            );
          }
          // Priorité 3: Icône d'upload
          else {
            imageWidget = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload,
                  color: getColorBasedOnActiveModuleid(),
                  size: 35,
                ),
                SizedBox(height: 10),
                Text(
                  "Back image",
                  style: regular2(context),
                ),
              ],
            );
          }

          // Vérifier si l'édition est autorisée
          final isEditable = kycController.activeStatus.value != "yes" &&
              kycController.activeStatus.value != "approved" &&
              kycController.activeStatus.value != "pending";

          return Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
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
                child: Center(child: imageWidget),
              ),
              // Afficher l'icône d'édition uniquement si l'édition est autorisée
              isEditable
                  ? Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black54,
                        ),
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    )
                  : SizedBox.shrink(),
            ],
          );
        }),
      ),
    );
  }
}
