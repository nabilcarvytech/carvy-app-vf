import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:provider/provider.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/auth_controller.dart';
import 'package:carvy/controller/profile_controller.dart';
import 'package:carvy/customwidget/custom_drop_down.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/form_validation.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/myaccount/static_page_screen.dart';
import 'package:carvy/work_space.dart';
import 'package:image_picker/image_picker.dart';

class RequestTobecomeHopst extends StatefulWidget {
  const RequestTobecomeHopst({super.key});

  @override
  State<RequestTobecomeHopst> createState() => _RequestTobecomeHopstState();
}

class _RequestTobecomeHopstState extends State<RequestTobecomeHopst> {
  ProfileController profileController = Get.find();
  bool isChecked = false;
  final AuthController authController = Get.find();
  final _formKey = GlobalKey<FormState>();
  FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    authController.becomeLeadFirstName.clear();
    authController.becomeLeadLastname.clear();
    authController.becomeLeadEmail.clear();
    authController.becomeLeadPhoneNumber.clear();
    authController.becomeLeadFulladdress.clear();
    authController.companyName.clear();
    authController.selectIdentityType = '';
    authController.selectedImag.value = '';
    if (loginModel!.data!.firstName != null) {
      authController.becomeLeadFirstName.text = loginModel!.data!.firstName!;
    }
    if (loginModel!.data!.lastName != null) {
      authController.becomeLeadLastname.text = loginModel!.data!.lastName!;
    }
    if (loginModel!.data!.email != null) {
      authController.becomeLeadEmail.text = loginModel!.data!.email!;
    }

    if (loginModel!.data!.phone != null) {
      authController.becomeLeadPhoneNumber.text = loginModel!.data!.phone!;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    notifires = Provider.of<ColorNotifires>(context, listen: true);
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      body: Stack(
        children: [
      
          SingleChildScrollView(
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: Dimensions.containerWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeLarge,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          commonlyUserlogo(),
                          const SizedBox(
                            height: 10,
                          ),
                          Text("Request to become Lead".tr,
                              style: heading1(context)),
                          Text("Fill the form".tr,
                              style: regular2(context).copyWith(
                                  color: notifires.getGrey3Whitecolor)),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFieldRefs(
                            inputAlignment: TextAlign.start,
                            txt: "First Name".tr,
                            icons: Icon(
                              Icons.person_2_outlined,
                              color: acentColor,
                            ),
                            textEditingControllerCommon:
                                authController.becomeLeadFirstName,
                            inputType: TextInputType.name,
                            validator: (value) {
                              if (isValidName(value!)) {
                                return null;
                              } else {
                                return 'Name is invalid'.tr;
                              }
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFieldRefs(
                            inputAlignment: TextAlign.start,
                            txt: "Last Name".tr,
                            icons: Icon(
                              Icons.person_2_outlined,
                              color: acentColor,
                            ),
                            textEditingControllerCommon:
                                authController.becomeLeadLastname,
                            inputType: TextInputType.name,
                            validator: (value) {
                              if (isValidName(value!)) {
                                return null;
                              } else {
                                return 'Name is invalid'.tr;
                              }
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFieldRefs(
                            inputAlignment: TextAlign.start,
                            txt: "Company name (optional)".tr,
                            icons: Icon(
                              Icons.comment_bank,
                              color: acentColor,
                            ),
                            textEditingControllerCommon:
                                authController.companyName,
                            inputType: TextInputType.name,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFieldRefs(
                            inputAlignment: TextAlign.start,
                            txt: "Email Address".tr,
                            icons: Icon(
                              Icons.mail,
                              color: acentColor,
                            ),
                            textEditingControllerCommon:
                                authController.becomeLeadEmail,
                            inputType: TextInputType.emailAddress,
                            validator: (value) {
                              return validateEmail(value!);
                            },
                          ),
                          const SizedBox(height: 20),
                          IntelPhoneFieldRefs(
                            defultcountry:
                                profileController.defaultCountry.value,
                            selectedcountry:
                                profileController.selectedCountry.value,
                            textEditingControllerCommons:
                                authController.becomeLeadPhoneNumber,
                            oncountryChanged: (number) {
                              authController.becomeLeadPhoneNumber.clear();
                              profileController.selectedCountry.value =
                                  number.dialCode;
                              profileController.defaultCountry.value =
                                  number.code;
                              setState(() {});
                            },
                            onChanged: (value) {
                              int expectedLength = phoneLengths[
                                      profileController.defaultCountry.value] ??
                                  10;
                              if (value!.number.length > expectedLength) {
                                authController.becomeLeadPhoneNumber.text =
                                    value.number.substring(0, expectedLength);
                                authController.becomeLeadPhoneNumber.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: authController
                                          .becomeLeadPhoneNumber.text.length),
                                );
                              }
                              return null;
                            },
                            validator: (phoneNumber) {
                              if (phoneNumber == null ||
                                  phoneNumber.number.isEmpty) {
                                return 'Please enter your phone number';
                              }

                              int expectedLength =
                                  phoneLengths[phoneNumber.countryISOCode] ??
                                      10;

                              if (phoneNumber.number.length != expectedLength) {
                                return 'Phone number must be $expectedLength digits';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          CustomDropdown(
                            options: const ["Citizenship", "Residence"],
                            onSelected: (value) {
                              authController.selectresedinceType =
                                  value.toString();
                            },
                            checkmarkColor: acentColor,
                          ),
                          const SizedBox(height: 20),
                          FormField(
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (value) {
                                final addressController =
                                    authController.becomeLeadFulladdress;
                                if (addressController.text.isEmpty) {
                                  return 'Please enter the address'.tr;
                                }
                                return null;
                              },
                              builder: (state) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 63,
                                      child: GooglePlaceAutoCompleteTextField(
                                        focusNode: _focusNode,
                                        textStyle: regular3(context),
                                        boxDecoration: BoxDecoration(
                                            color: notifires.getBoxColor,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        textEditingController: authController
                                            .becomeLeadFulladdress,
                                        googleAPIKey: Config.googleKey,
                                        countries: null,
                                        inputDecoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.location_on,
                                              color: acentColor,
                                            ),
                                            hintText: "Enter Address".tr,
                                            contentPadding: const EdgeInsets
                                                .symmetric(
                                                vertical: 14,
                                                horizontal:
                                                    15), // Adjust contentPadding
                                            hintStyle: regular3(context),
                                            border: InputBorder.none),
                                        isLatLngRequired: true,
                                        getPlaceDetailWithLatLng:
                                            (Prediction prediction) {
                                          setState(() {
                                            authController
                                                    .selectlettobecomeHost =
                                                prediction.lat.toString();
                                            authController
                                                    .selectlongTibecomeHost =
                                                prediction.lng.toString();
                                          });
                                          _focusNode.unfocus();

                                          state.didChange(authController
                                              .becomeLeadFulladdress);
                                        },
                                        itemClick: (Prediction prediction) {
                                          authController.becomeLeadFulladdress
                                              .text = prediction.description!;
                                          authController.becomeLeadFulladdress
                                                  .selection =
                                              TextSelection.fromPosition(
                                                  TextPosition(
                                                      offset: prediction
                                                          .description!
                                                          .length));

                                          _focusNode.unfocus();
                                        },
                                        itemBuilder: (context, index,
                                            Prediction prediction) {
                                          return Container(
                                            decoration: BoxDecoration(
                                              color: notifires.getboxcolor,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0, vertical: 2),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.location_on,
                                                      color: notifires
                                                          .getgreycolor,
                                                    ),
                                                    const SizedBox(width: 7),
                                                    Expanded(
                                                      child: Text(
                                                        prediction
                                                                .description ??
                                                            "",
                                                        style:
                                                            regular3(context),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 2,
                                                ),
                                                Divider(
                                                  color: notifires.getgreycolor,
                                                  thickness: 1,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        seperatedBuilder: const SizedBox(),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                          const SizedBox(height: 20),
                          CustomDropdown(
                            options: const ["Passport", "Driver License"],
                            onSelected: (value) {
                              authController.selectIdentityType =
                                  value.toString();
                            },
                            checkmarkColor: acentColor,
                            identityTyoe: true,
                          ),
                          const SizedBox(height: 20),
                          Container(
                            height: 60,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              color: notifires.getBoxColor,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(Icons.photo, color: acentColor),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (webPlateForm) {
                                        selectImageForweb();
                                      } else {
                                        try {
                                          var image = await ImagePicker()
                                              .pickImage(
                                                  source: ImageSource.gallery);
                                          if (image == null) {
                                            return;
                                          }
                                          await authController
                                              .compressAndUploadImage(
                                                  image.path, "Gallery");
                                        } on PlatformException {
                                          if (Platform.isIOS) {
                                            showOpenAppSettingsDialog(context,
                                                "Gallery permission denied. Please go to settings and allow the Gallery.");
                                          }
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Select Photo".tr,
                                      style: regular3(context),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                Icon(Icons.camera, color: acentColor),
                                const SizedBox(
                                  width: 10,
                                ),
                                webPlateForm
                                    ? const SizedBox()
                                    : Expanded(
                                        child: GestureDetector(
                                          onTap: () async {
                                            try {
                                              var image = await ImagePicker()
                                                  .pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              if (image == null) {
                                                return;
                                              }
                                              await authController
                                                  .compressAndUploadImage(
                                                      image.path, "Camera");
                                            } on PlatformException {
                                              if (Platform.isIOS) {
                                                showOpenAppSettingsDialog(
                                                    context,
                                                    "Camera permission denied. Please go to settings and allow the Camera.");
                                              }
                                            }
                                          },
                                          child: Text(
                                            "Capture Photo".tr,
                                            style: regular3(context),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => authController.selectedImag.value == ""
                                ? const SizedBox()
                                : SizedBox(
                                    height: 200,
                                    child: ClipRRect(
                                      child: webPlateForm
                                          ? Image.network(
                                              authController
                                                  .identityimageforWeb!.path,
                                              fit: BoxFit.fitHeight,
                                            )
                                          : Image.file(
                                              File(authController
                                                  .selectedImag.value),
                                              fit: BoxFit.fitHeight,
                                            ),
                                    ),
                                  ),
                          ),
                          authController.identityimageforWeb == null
                              ? const SizedBox()
                              : SizedBox(
                                  height: 200,
                                  child: ClipRRect(
                                    child: webPlateForm
                                        ? Image.network(
                                            authController
                                                .identityimageforWeb!.path,
                                            fit: BoxFit.fitHeight,
                                          )
                                        : Image.file(
                                            File(authController
                                                .selectedImag.value),
                                            fit: BoxFit.fitHeight,
                                          ),
                                  ),
                                ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  constraints: const BoxConstraints.expand(
                                      width: 33, height: 40),
                                  color: Colors.transparent,
                                  padding: const EdgeInsets.only(right: 5),
                                  child: Transform.translate(
                                    offset: const Offset(-5, 6),
                                    child: Transform.scale(
                                      scale: 1.3,
                                      child: Checkbox(
                                        activeColor: acentColor,
                                        focusColor: acentColor,
                                        value: isChecked,
                                        onChanged: (bool? newValue) {
                                          setState(() {
                                            isChecked = newValue!;
                                          });
                                        },
                                        checkColor: whiteColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              Dimensions.radiusSmall),
                                        ),
                                        side: BorderSide(
                                            color: notifires.getGrey3Whitecolor,
                                            width: 2.0),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    showModalBottomSheet(
                                      useRootNavigator: true,
                                      backgroundColor: notifires.getbgcolor,
                                      isScrollControlled: true,
                                      useSafeArea: true,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return StaticPage(
                                          data:
                                              "Terms of Service for Vehicle Owner"
                                                  .tr,
                                        );
                                      },
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                        8.0), // Optional padding
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        maxWidth: MediaQuery.of(context)
                                                .size
                                                .width /
                                            1.6, // Adjust max width as needed
                                      ),
                                      child: Text.rich(
                                        TextSpan(
                                          text:
                                              "By submitting the form, you agree \n"
                                                  .tr,
                                          style: regular3(context)
                                              .copyWith(fontSize: 14),
                                          children: [
                                            TextSpan(
                                              text: 'Terms and Condition'.tr,
                                              style: regular(context).copyWith(
                                                color: acentColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        overflow: TextOverflow
                                            .ellipsis, // Handles overflow
                                        maxLines: 2, // Adjust as needed
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 35),
                          CustomsButtons(
                              onPressed: () {
                                if (authController.becomeLeadFirstName.text ==
                                    "") {
                                  showErrorToastMessage(
                                      "Please Enter First Name".tr);
                                  return;
                                }
                                if (authController.becomeLeadLastname.text ==
                                    "") {
                                  showErrorToastMessage(
                                      "Please Enter Last Name".tr);
                                  return;
                                }
                                if (authController.becomeLeadEmail.text == "") {
                                  showErrorToastMessage(
                                      "Please Enter the Email".tr);
                                  return;
                                }
                                if (authController.becomeLeadPhoneNumber.text ==
                                    "") {
                                  showErrorToastMessage(
                                      "Please Enter the Pho".tr);
                                  return;
                                }
                                if (authController.selectresedinceType == "") {
                                  showErrorToastMessage(
                                      "Please select Nationality/Residency".tr);
                                  return;
                                }
                                if (authController.becomeLeadFulladdress.text ==
                                    "") {
                                  showErrorToastMessage(
                                      "Please Enter the full address".tr);
                                  return;
                                }
                                if (authController.selectIdentityType == "") {
                                  showErrorToastMessage(
                                      "Please select Identity Type".tr);
                                  return;
                                }
                                if (webPlateForm) {
                                  if (authController.identityimageforWeb ==
                                      null) {
                                    showErrorToastMessage(
                                        "Please Add the Images");
                                    return;
                                  }
                                } else {
                                  if (authController.selectedImag.value == "") {
                                    showErrorToastMessage(
                                        "Please Add the Images");
                                    return;
                                  }
                                }

                                if (isChecked == false) {
                                  showErrorToastMessage(
                                      "Please accept Terms and Condition ");
                                  return;
                                }
                                authController.sendrequesttobecomeHost(
                                  context,
                                  profileController.selectedCountry.value,
                                  _formKey,
                                  isChecked,
                                );
                              },
                              text: 'Send Request'.tr,
                              backgroundColor: acentColor),
                          const SizedBox(
                            height: 30,
                          ),
                          const SizedBox(height: 80)
                        ]),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void selectImageForweb() async {
    authController.identityimageforWeb = null;
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
        setState(() {
          authController.identityimageforWeb = xfile;
          authController.selectedImagyoBecomeAhostbase64 =
              "data:image/$format;base64,$base64Image";
        });
        closeLoading();
      }
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
}
