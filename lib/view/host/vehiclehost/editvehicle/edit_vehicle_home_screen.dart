import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:carvy/controller/add_items_host_controller.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/view/host/common_widget_host.dart';
import 'package:carvy/view/host/calender/edit_calander_third_step_common.dart';
import 'package:carvy/view/host/upload_image_screen.dart';
import 'package:carvy/view/host/vehiclehost/editvehicle/edit_vehicle_first_section_screen.dart';
import 'package:carvy/work_space.dart';

class EditVehicleHomeScreen extends StatefulWidget {
  final ScreenMode? mode;
  final String? vehicleId;

  const EditVehicleHomeScreen({super.key, this.mode, this.vehicleId});

  @override
  State<EditVehicleHomeScreen> createState() => _EditVehicleHomeScreenState();
}

class _EditVehicleHomeScreenState extends State<EditVehicleHomeScreen> {
  AddItemsHostController addItemsHostController = Get.find();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.mode == ScreenMode.edit) {
        // populateFields a déjà été appelé avant la navigation depuis host_search_screen.dart
        // On s'assure juste que les données sont chargées si nécessaire
        // NE PAS appeler fetchItemData() car elle appelle cleanTextController() et écrase les données
        if (addItemsHostController.vehicleListItemType.isEmpty) {
          addItemsHostController.getDataItemType();
        }
        if (addItemsHostController.selectedVehicleType != null && 
            addItemsHostController.selectedVehicleType!.isNotEmpty) {
          // En mode édition, on réutilise exactement la même API que l'ajout
          // pour charger toutes les marques et modèles
          addItemsHostController.getVehicleDataMakeModel();
        }
        // Forcer une mise à jour pour rafraîchir l'UI
        addItemsHostController.update();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (v) {
        checkUpdateStep1 = false;
        checkUpdateStep2 = false;
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const BottomHost(initialIndex: 0)),
        );
      },
      child: Scaffold(
        backgroundColor: notifires.getbgcolor,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            backgroundColor: notifires.getbgcolor,
            surfaceTintColor: notifires.getbgcolor,
            automaticallyImplyLeading: false,
            title: Text('Become a Host'.tr, style: heading1Grey1(context)),
            centerTitle: true,
            actions: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                child: InkWell(
                    onTap: () {
                      checkUpdateStep1 = false;
                      checkUpdateStep2 = false;
                      Get.to(const BottomHost(initialIndex: 0));
                    },
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: notifires.getboxcolor),
                        child: Icon(
                          Icons.close,
                          size: 25,
                          color: notifires.getwhiteblackcolor,
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              LabelNames(labelname: 'Step #1'.tr),
              const SizedBox(height: 10),
              AbsorbPointer(
                absorbing: checkUpdateStep1,
                child: EditContainer(
                  icon: Icon(
                    Icons.local_florist,
                    color: notifires.getwhiteblackcolor,
                  ),
                  title: "Describe your vehicle".tr,
                  bgcolor: checkUpdateStep1
                      ? notifires.getInVisibleBoxColor
                      : notifires.getboxcolor,
                  subtitle: "Vehicle details, vehicle fetaures and \nmore..".tr,
                  onTap: () {
                    Get.to(() => const EditVehicleFirstSectionScreen());
                  },
                ),
              ),
              const SizedBox(height: 20),
              LabelNames(labelname: 'Step #2'.tr),
              const SizedBox(height: 10),
              AbsorbPointer(
                absorbing: checkUpdateStep2,
                child: EditContainer(
                  icon: Icon(
                    Icons.inbox,
                    color: notifires.getwhiteblackcolor,
                  ),
                  title: "Set the scene".tr,
                  bgcolor: checkUpdateStep2
                      ? notifires.getInVisibleBoxColor
                      : notifires.getboxcolor,
                  subtitle: "Upload photos from gallery or camera".tr,
                  onTap: () {
                    Get.to(() => const UploadImageScreen(
                          mode: ScreenMode.edit,
                        ));
                  },
                ),
              ),
              const SizedBox(height: 20),
              LabelNames(labelname: 'Step #3'.tr),
              const SizedBox(height: 10),
              EditContainer(
                icon: Icon(
                  Icons.thumb_up_off_alt,
                  color: notifires.getwhiteblackcolor,
                ),
                title: "Prepare Your vehicle for Guests".tr,
                bgcolor: notifires.getboxcolor,
                subtitle:
                    "Effortless Booking Management with Dynamic Calendar and Enhanced Availability"
                        .tr,
                onTap: () {
                  Get.to(() => const EditCalenderOnThirdStepCommon());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
