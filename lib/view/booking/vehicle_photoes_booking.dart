import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:async';

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

  // Comptage simple par catégorie (pour la check-list)
  int _frontCount = 0;
  int _rearCount = 0;
  int _damageCount = 0;

  // Catégorie de capture active
  CaptureCategory? _activeCategory;

  final int fileSizeThreshold = 500 * 1024; // 500KB
  final int goodQuality = 90;
  final int badQuality = 70;
  final int maxWidth = 800;
  final int maxHeight = 800;
  final int maxImages = 5;

  void _incrementCategoryCount(int added) {
    if (_activeCategory == null) return;
    switch (_activeCategory!) {
      case CaptureCategory.front:
        _frontCount += added;
        break;
      case CaptureCategory.rear:
        _rearCount += added;
        break;
      case CaptureCategory.damage:
        _damageCount += added;
        break;
    }
  }

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
          bookingController.requestOtpOverlay(widget.id);
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
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) return;
        Get.back();
      },
      child: Scaffold(
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
        onBackButtonPressed: () => Get.back(),
        elevation: 0,
        // Nouveau titre demandé
        title: 'État du véhicule : Photos de sécurité',
        backgroundColor: notifires.getbgcolor,
        iconColor: notifires.getwhiteblackcolor,
        titleColor: notifires.getwhiteblackcolor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bloc d'information (Pourquoi)
            _buildInfoBlock(primaryColor),
            const SizedBox(height: 20),
            _buildSectionHeader('Car Interior & Exterior'.tr, primaryColor),
            const SizedBox(height: 16),

            // Check-list stylisée (Comment)
            Row(
              children: [
                Expanded(
                  child: _ChecklistTile(
                    icon: Icons.directions_car_filled_outlined,
                    label: 'Avant',
                    primaryColor: primaryColor,
                    counter: _frontCount,
                    onTap: () {
                      if (_vehicleImages.length >= maxImages) return;
                      _activeCategory = CaptureCategory.front;
                      _showImageSourceDialog(
                        isMultiple: true,
                        onImagesSelected: (List<File> files) {
                          final remaining = maxImages - _vehicleImages.length;
                          var toAdd = files;
                          if (files.length > remaining) {
                            showToastMessage(
                                "Only added $remaining images to reach the maximum of $maxImages"
                                    .tr);
                            toAdd = files.sublist(0, remaining);
                          }
                          setState(() {
                            _vehicleImages.addAll(toAdd);
                            _incrementCategoryCount(toAdd.length);
                          });
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ChecklistTile(
                    icon: Icons.time_to_leave, // arrière stylisé
                    label: 'Arrière',
                    primaryColor: primaryColor,
                    counter: _rearCount,
                    onTap: () {
                      if (_vehicleImages.length >= maxImages) return;
                      _activeCategory = CaptureCategory.rear;
                      _showImageSourceDialog(
                        isMultiple: true,
                        onImagesSelected: (List<File> files) {
                          final remaining = maxImages - _vehicleImages.length;
                          var toAdd = files;
                          if (files.length > remaining) {
                            showToastMessage(
                                "Only added $remaining images to reach the maximum of $maxImages"
                                    .tr);
                            toAdd = files.sublist(0, remaining);
                          }
                          setState(() {
                            _vehicleImages.addAll(toAdd);
                            _incrementCategoryCount(toAdd.length);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Zone spéciale "Rayures / Dégâts existants"
            _DamageTile(
              primaryColor: primaryColor,
              counter: _damageCount,
              onTap: () {
                if (_vehicleImages.length >= maxImages) return;
                _activeCategory = CaptureCategory.damage;
                _showImageSourceDialog(
                  isMultiple: true,
                  onImagesSelected: (List<File> files) {
                    final remaining = maxImages - _vehicleImages.length;
                    var toAdd = files;
                    if (files.length > remaining) {
                      showToastMessage(
                          "Only added $remaining images to reach the maximum of $maxImages"
                              .tr);
                      toAdd = files.sublist(0, remaining);
                    }
                    setState(() {
                      _vehicleImages.addAll(toAdd);
                      _incrementCategoryCount(toAdd.length);
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Aperçu des images sélectionnées (toujours présent)
            if (_vehicleImages.isNotEmpty) _buildSectionHeader('Aperçu', primaryColor),
            if (_vehicleImages.isNotEmpty) const SizedBox(height: 12),
            if (_vehicleImages.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: _vehicleImages.length,
                itemBuilder: (context, index) {
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
                          // Suppression simple: on réduit aussi un compteur s'il en reste (>0)
                          if (_frontCount > 0) {
                            _frontCount--;
                          } else if (_rearCount > 0) {
                            _rearCount--;
                          } else if (_damageCount > 0) {
                            _damageCount--;
                          }
                          _vehicleImages.removeAt(index);
                          imageListbase64.removeAt(index);
                        });
                      },
                      primaryColor: primaryColor,
                    ),
                  );
                },
              ),
          ],
        ),
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

// Catégories de capture pour la check-list
enum CaptureCategory { front, rear, damage }

// Bloc d'information "Pourquoi ?"
Widget _buildInfoBlock(Color accentColor) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: accentColor.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: accentColor.withOpacity(0.2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Text('🛡️')),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Protégez votre caution. Prenez des photos de la voiture avant de démarrer. Cela prouve l\'état initial en cas de litige.',
            style: TextStyle(
              color: Colors.blueGrey.shade800,
              height: 1.3,
            ),
          ),
        ),
      ],
    ),
  );
}

// Tuile de check-list compacte
class _ChecklistTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final int counter;
  final Color primaryColor;

  const _ChecklistTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.counter,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: notifires.getbgcolor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notifires.getwhiteblackcolor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, size: 36, color: primaryColor),
                if (counter > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$counter',
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(color: notifires.getwhiteblackcolor)),
          ],
        ),
      ),
    );
  }
}

// Tuile spéciale "Dégâts existants" (icône composite + micro-animation)
class _DamageTile extends StatefulWidget {
  final VoidCallback onTap;
  final int counter;
  final Color primaryColor;

  const _DamageTile({
    required this.onTap,
    required this.counter,
    required this.primaryColor,
  });

  @override
  State<_DamageTile> createState() => _DamageTileState();
}

class _DamageTileState extends State<_DamageTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  Timer? _pulseTimer;

  static const Color _carvyBlue = Color(0xFF27489E);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Micro animation toutes les 3 secondes
    _pulseTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted) return;
      try {
        await _controller.forward();
        if (!mounted) return;
        await _controller.reverse();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notifires.getbgcolor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: notifires.getwhiteblackcolor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône composite: voiture de profil + main qui tapote
            SizedBox(
              width: 48,
              height: 36,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.directions_car_outlined,
                      color: _carvyBlue,
                      size: 36,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ScaleTransition(
                      scale: _scale,
                      child: Icon(
                        Icons.touch_app_outlined,
                        color: _carvyBlue,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre en gras demandé
                  Text(
                    'Dégâts préexistants ?',
                    style: TextStyle(
                      color: notifires.getwhiteblackcolor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Message plus direct
                  Text(
                    'Signalez chaque rayure avec votre doigt.',
                    style: TextStyle(
                      color: notifires.getwhiteblackcolor.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.counter > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.primaryColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${widget.counter}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
