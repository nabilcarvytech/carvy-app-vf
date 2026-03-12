import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart' show httpPost;
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/work_space.dart';

class VehiclePhotoesBooking extends StatefulWidget {
  final String id;

  VehiclePhotoesBooking({super.key, required this.id});

  @override
  State<VehiclePhotoesBooking> createState() => _VehiclePhotoesBookingState();
}

class _VehiclePhotoesBookingState extends State<VehiclePhotoesBooking> {
  List<File> _vehicleImages = [];

  List<String> imageListbase64 = [];

  final ImagePicker _picker = ImagePicker();

  final int fileSizeThreshold = 500 * 1024; // 500KB
  final int goodQuality = 90;
  final int badQuality = 70;
  final int maxWidth = 800;
  final int maxHeight = 800;
  final int maxImages = 5;

  Future<void> _showImageSourceDialog({
    required bool isMultiple,
    required Function(List<File>) onImagesSelected,
  }) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      backgroundColor: notifires.getbgcolor,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt,
                  color: getColorBasedOnActiveModuleid()),
              title: Text('Camera'.tr,
                  style: TextStyle(color: notifires.getwhiteblackcolor)),
              onTap: () async {
                Navigator.pop(context);
                await _selectImages(ImageSource.camera, onImagesSelected);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library,
                  color: getColorBasedOnActiveModuleid()),
              title: Text('Gallery'.tr,
                  style: TextStyle(color: notifires.getwhiteblackcolor)),
              onTap: () async {
                Navigator.pop(context);
                await _selectImages(ImageSource.gallery, onImagesSelected);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectImages(
      ImageSource source, Function(List<File>) onImagesSelected) async {
    String sourceName = source == ImageSource.camera ? 'Camera' : 'Gallery';
    try {
      showLoading();
      List<File> selectedImages = [];
      List<XFile> xFiles = [];

      if (source == ImageSource.gallery) {
        xFiles = await _picker.pickMultiImage();
      } else {
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) xFiles = [image];
      }

      if (xFiles.isEmpty) {
        closeLoading();
        return;
      }

      for (final XFile xFile in xFiles) {
        final imageFile = File(xFile.path);
        final imageSize = await imageFile.length();
        final quality =
            imageSize > fileSizeThreshold ? badQuality : goodQuality;

        final compressedImage = await FlutterImageCompress.compressWithFile(
          xFile.path,
          quality: quality,
          minWidth: maxWidth,
          minHeight: maxHeight,
        );

        if (compressedImage != null) {
          final base64Image = base64Encode(compressedImage);
          String format = '';
          if (compressedImage.length > 8) {
            if (compressedImage[0] == 0xFF && compressedImage[1] == 0xD8) {
              format = 'jpeg';
            } else if (compressedImage[0] == 0x89 &&
                compressedImage[1] == 0x50) {
              format = 'png';
            }
          }
          imageListbase64.add("data:image/$format;base64,$base64Image");
          selectedImages.add(imageFile);
        }
      }
      closeLoading();

      if (selectedImages.isNotEmpty) {
        onImagesSelected(selectedImages);
      }
    } on PlatformException {
      closeLoading();
      if (Platform.isIOS) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Permission Denied'.tr),
            content: Text(
                '$sourceName permission denied. Please go to settings and allow the $sourceName.'
                    .tr),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'.tr),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> updateUploadImage() async {
    showLoading();
    try {
      final List<String> imageListbase64 = this.imageListbase64;
      final String galleryImage =
          imageListbase64.isEmpty ? "" : imageListbase64.join("##");
      Map<String, dynamic> map = {
        "booking_id": "${widget.id}",
        "per_booking_images": galleryImage,
      };

      print('🚀 [API_SEND] Envoi de l\'image en Base64 pour le booking: ${widget.id}');
      print('📊 [API_SEND] Nombre d\'images: ${imageListbase64.length}');
      print('📊 [API_SEND] Taille des données: ${galleryImage.length} caractères');

      dynamic response;
      try {
        response = await httpPost(Config.addInteriorImage, map);
        print('📡 [RETOUR_API] Réponse reçue du serveur');
        print('📝 [RETOUR_API] Type de réponse: ${response.runtimeType}');
        print('📝 [RETOUR_API] Contenu complet: $response');
      } catch (e) {
        print('🚨 [ERREUR_RESEAU] Impossible de joindre le serveur: $e');
        closeLoading();
        showErrorToastMessage('Erreur réseau: Impossible de contacter le serveur');
        return;
      }

      closeLoading();
      if (response != null && response.containsKey('success')) {
        final successValue = response['success'].toString();
        print('✅ [RETOUR_API] Code succès: $successValue');
        if (successValue == '200') {
          print('🎉 [RETOUR_API] Upload réussi - ouverture OTP automatique');
          BookingController bookingController = Get.find();
          showToastMessage(response['message']?.toString() ??
              'Images uploaded successfully');
          bookingController.currentBookingIdForOtp.value = widget.id;
          bookingController.openOtpAfterImageSubmit.value = true;
          generalController.currentIndex.value = 0;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Get.back(result: true);
          });
        } else {
          print('❌ [RETOUR_API] Échec upload - Code: $successValue');
          showErrorToastMessage(
              response['error']?.toString() ?? 'Failed to upload images');
        }
      } else {
        print('❌ [RETOUR_API] Réponse invalide - Clés disponibles: ${response?.keys?.join(", ")}');
        showErrorToastMessage('Invalid response from server');
      }
    } catch (e) {
      print('💥 [ERREUR_GENERALE] Erreur inattendue dans updateUploadImage: $e');
      closeLoading();
      showErrorToastMessage('Failed to upload images: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = getColorBasedOnActiveModuleid();
    return Scaffold(
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CustomsButtons(
            text: "Submit".tr,
            backgroundColor: getColorBasedOnActiveModuleid(),
            onPressed: () {
              if (imageListbase64.length < 2) {
                showErrorToastMessage("Please add at least 2 images".tr);
                return;
              }

              if (imageListbase64.length > maxImages) {
                showErrorToastMessage("Maximum $maxImages images allowed".tr);
                return;
              }

              updateUploadImage();
            }),
      ),
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
        onBackButtonPressed: () => Navigator.pop(context),
        title: 'Add Photos'.tr,
        backgroundColor: notifires.getbgcolor,
        iconColor: notifires.getwhiteblackcolor,
        titleColor: notifires.getwhiteblackcolor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            _buildSectionHeader('Car Interior & Exterior'.tr, primaryColor),
            const SizedBox(height: 16),
            // Grid for vehicle images with integrated add tiles
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1,
              ),
              itemCount: maxImages,
              itemBuilder: (context, index) {
                if (index < _vehicleImages.length) {
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, opacity, child) {
                      return Opacity(
                        opacity: opacity,
                        child: child,
                      );
                    },
                    child: _buildVehicleImageCard(
                      imageFile: _vehicleImages[index],
                      onRemove: () {
                        setState(() {
                          _vehicleImages.removeAt(index);
                          imageListbase64.removeAt(index);
                        });
                      },
                      primaryColor: primaryColor,
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: () {
                      if (_vehicleImages.length >= maxImages) return;
                      _showImageSourceDialog(
                        isMultiple: true,
                        onImagesSelected: (List<File> files) {
                          final remaining = maxImages - _vehicleImages.length;
                          if (files.length > remaining) {
                            showToastMessage(
                                "Only added $remaining images to reach the maximum of $maxImages"
                                    .tr);
                            files = files.sublist(0, remaining);
                          }
                          setState(() {
                            _vehicleImages.addAll(files);
                          });
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: notifires.getbgcolor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: notifires.getwhiteblackcolor.withOpacity(0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: primaryColor.withOpacity(0.6),
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for section headers
  Widget _buildSectionHeader(String title, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LabelNames(
          labelname: title,
        ),
        Container(
          width: 60,
          height: 3,
          margin: const EdgeInsets.only(top: 4),
          color: accentColor,
        ),
      ],
    );
  }

  Widget _buildVehicleImageCard({
    required File? imageFile,
    required VoidCallback onRemove,
    required Color primaryColor,
  }) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: notifires.getbgcolor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notifires.getwhiteblackcolor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageFile != null
                ? Image.file(
                    imageFile,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : Center(
                    child: Icon(
                      Icons.directions_car,
                      size: 40,
                      color: primaryColor.withOpacity(0.6),
                    ),
                  ),
          ),
        ),
        if (imageFile != null)
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.9),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
