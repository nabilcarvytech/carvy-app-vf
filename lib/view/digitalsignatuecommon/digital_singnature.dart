import 'dart:convert';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';
import 'package:flutter_html/flutter_html.dart' as flutter_html;
import 'package:carvy/api/config.dart';
import 'package:carvy/controller/booking_controller.dart';
import 'package:carvy/controller/static_controller.dart';
import 'package:carvy/customwidget/custom_active_module_id_widget.dart';
import 'package:carvy/customwidget/form_elements.dart';
import 'package:carvy/customwidget/full_screen_image_view.dart';
import 'package:carvy/customwidget/miscellaneous_project_elements.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import 'package:carvy/helper/http_service.dart';
import 'package:carvy/model/booking_model.dart';
import 'package:carvy/model/digital_singnature_model.dart';
import 'package:carvy/model/item_details_model.dart';
import 'package:carvy/utils/common_widget.dart';
import 'package:carvy/utils/theme_style.dart';
import 'package:carvy/utils/vehicle_common_widgets.dart';
import 'package:carvy/view/bottombar/home_main.dart';
import 'package:carvy/view/host/bottom_bar_host.dart';
import 'package:carvy/work_space.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class DigitalSignature extends StatefulWidget {
  final Bookings? bookings;
  final bool? fromPropBooking;
  final String? doorStepPrice;
  const DigitalSignature({
    super.key,
    this.bookings,
    this.fromPropBooking,
    this.doorStepPrice,
  });

  @override
  State<DigitalSignature> createState() => _DigitalSignatureState();
}

class _DigitalSignatureState extends State<DigitalSignature> {
  BookingController bookingController = Get.find();
  StaticController staticController = Get.find();
  final SignatureController userSignController = SignatureController(
    penStrokeWidth: 5.0,
    penColor: blackColor,
    exportBackgroundColor: whiteColor,
    exportPenColor: blackColor,
  );
  ItemDetails? itemDetails;
  final SignatureController vendorSignController = SignatureController(
    penStrokeWidth: 5.0,
    penColor: blackColor,
    exportBackgroundColor: whiteColor,
    exportPenColor: blackColor,
  );
  final PageController _pageController = PageController();
  int _currentPage = 0;

  bool _userSigned = false;
  bool _vendorSigned = false;
  String? _pdfUrl;
  List<String> imageUrls = [];

  @override
  void dispose() {
    userSignController.dispose();
    vendorSignController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String? _userSignatureUrl;
  String? _vendorSignatureUrl;
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      staticController.string.value = "";
      staticController.fetchData("Booking Agreement");
    });
    if (widget.bookings!.itemData != null) {
      try {
        if (widget.bookings!.itemData!.startsWith("[") &&
            widget.bookings!.itemData!.endsWith("]")) {
          var jsonString = widget.bookings!.itemData!
              .substring(1, widget.bookings!.itemData!.length - 1);
          itemDetails = ItemDetails.fromJson(jsonDecode(jsonString));
        } else {
          itemDetails =
              ItemDetails.fromJson(jsonDecode(widget.bookings!.itemData!));
        }
        setState(() {});
      } catch (e) {
        print("Error parsing itemData: $e");
      }
    }

    bookingController
        .singnatureApi(widget.bookings!.id.toString(), false)
        .then((newResult) {
      if (newResult != null && newResult.success == 200) {
        final signatureData = bookingController.signatureDataResponse?.data;
        if (signatureData != null) {
          _userSigned = signatureData.userSigned == 1;
          _vendorSigned = signatureData.vendorSigned == 1;
          _userSignatureUrl = signatureData.userSignatureUrl?.url ?? '';
          _vendorSignatureUrl = signatureData.vendorSignatureUrl?.url ?? '';
        }
      }

      if (widget.bookings!.iteriorImage != null &&
          widget.bookings!.iteriorImage is List) {
        try {
          final imageList = widget.bookings!.iteriorImage as List;
          imageUrls = imageList
              .map((image) => image['url']?.toString() ?? '')
              .where((url) => url.isNotEmpty)
              .toList();
        } catch (e) {
          print('Error parsing interiorImage: $e');
        }
      }
    });

    bookingController.moduleBasedData(bookings: widget.bookings!);

    print(_userSigned);
  }

  Future<void> _saveSignature({
    required SignatureController controller,
    required String type, // 'user' or 'vendor'
  }) async {
    if (controller.isEmpty) {
      showErrorToastMessage("$type signature is empty!");
      return;
    }

    try {
      showLoading();
      final bytes = await controller.toPngBytes();

      if (bytes == null) {
        showErrorToastMessage("Failed to convert $type signature to image.");
        closeLoading();
        return;
      }

      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final payload = {
        'booking_id': "${widget.bookings?.id}",
        'signature_type': type,
        'signature_image': base64Image,
      };

      // ========== MOCK DATA - OLD API CALL COMMENTED ==========
      // final response = await httpPost(Config.uploadSignature, payload);

      // MOCK: Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // MOCK: Static success response for uploading signature
      final response = {
        "success": 200,
        "message": "Signature uploaded successfully",
        "error": "",
        "data": {
          "booking_id": "${widget.bookings?.id}",
          "signature_type": type,
          "signature_url":
              "https://example.com/signatures/${widget.bookings?.id}_$type.png"
        }
      };
      // ========== END MOCK DATA ==========

      if (response == null || response['success'] != 200) {
        showErrorToastMessage(
            "Failed to upload $type signature: Invalid response.");
        closeLoading();
        return;
      }

      bookingController.signatureDataResponse =
          SignatureDataResponse.fromJson(response);

      final signatureData = bookingController.signatureDataResponse?.data;
      if (signatureData != null) {
        _userSigned = signatureData.userSigned == 1;
        _vendorSigned = signatureData.vendorSigned == 1;
        _userSignatureUrl = signatureData.userSignatureUrl?.url ?? '';
        _vendorSignatureUrl = signatureData.vendorSignatureUrl?.url ?? '';
      } else {
        showErrorToastMessage("Invalid signature data received.");
      }

      // Close loading before navigation
      closeLoading();

      if (isHostMode.value == true) {
        bookingAgrinmentVendor = true;

        bool hasProcessed = false;

        if (!hasProcessed) {
          showLoading(); // Show loading for the delivery status update
          hasProcessed = true;
          try {
            final value = await bookingController.updateItemDeliverStatusHost(
              bookingId: widget.bookings!.id.toString(),
            );

            closeLoading(); // Close loading after delivery status update

            generalController.currentIndexHost.value = 2;

            // Navigate after closing loading
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomHost(initialIndex: 2),
              ),
            );

            if (mounted) {
              setState(() {
                widget.bookings!.isItemDeliveredSetter = value;
                bookingAgrinmentVendor2 = true;
                bookingAgrinmentVendor = false;
              });
            }
          } catch (e) {
            closeLoading(); // Ensure loading is closed on error
            if (mounted) {
              setState(() {
                bookingAgrinmentVendor = false;
              });
              showErrorToastMessage("Error updating delivery status: $e");
              print("Error updating delivery status: $e");
            }
          }
        }
      } else {
        // For user mode - close loading was already done above
        bookingAgrinmentuser = true;
        generalController.currentIndex.value = 2;

        // Navigate after closing loading
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const HomeMain(initialIndex: 2),
          ),
        );
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      closeLoading();
      if (mounted) {
        showErrorToastMessage("Error saving $type signature: $e");
      }
    }
  }

  Future<void> _generatePDF() async {
    if (!_userSigned || !_vendorSigned) {
      showErrorToastMessage("Both signatures are required");
      return;
    }
    showLoading();
    final pdf = pw.Document();

    // Fetch signature images
    final userSignatureResponse = await http.get(Uri.parse(_userSignatureUrl!));
    final vendorSignatureResponse =
        await http.get(Uri.parse(_vendorSignatureUrl!));

    if (userSignatureResponse.statusCode != 200 ||
        vendorSignatureResponse.statusCode != 200) {
      showErrorToastMessage("Failed to load signature images.");
      closeLoading();
      return;
    }

    final userSignature = pw.MemoryImage(userSignatureResponse.bodyBytes);
    final vendorSignature = pw.MemoryImage(vendorSignatureResponse.bodyBytes);

    // Fetch logo
    final logoBytes = await rootBundle.load('assets/images/logo-ub.png');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    // Fetch vehicle interior images
    List<pw.MemoryImage> vehicleImages = [];
    for (String imageUrl in imageUrls) {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        vehicleImages.add(pw.MemoryImage(response.bodyBytes));
      } else {
        showErrorToastMessage("Failed to load vehicle image: $imageUrl");
        closeLoading();
        return;
      }
    }

    // Process terms and conditions
    final termsContent = staticController.string.value;
    final termsText = termsContent
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .toList();

    final termsWidgets = termsText.map((line) {
      final isHeading = line.contains(':') || line.trim().length < 50;
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.Text(
          line.trim(),
          style: isHeading
              ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)
              : pw.TextStyle(fontSize: 11),
        ),
      );
    }).toList();

    final color = PdfColors.blueGrey;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Center(
                child: pw.Container(
                  width: 60,
                  height: 60,
                  decoration: pw.BoxDecoration(
                    shape: pw.BoxShape.circle,
                    color: color,
                  ),
                  child: pw.ClipOval(
                    child: pw.Image(logoImage, fit: pw.BoxFit.cover),
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text("$appName",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)),
              pw.Divider(),
            ],
          ),
          pw.Text("Booking Agreement",
              style:
                  pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 8),
          pw.Text("Receipt #: ${widget.bookings!.id}"),
          pw.Text("Date: ${widget.bookings!.createdAt!.split(" ")[0]}"),
          pw.Text(
              "Booked by: ${loginModel!.data!.firstName!} ${loginModel!.data!.lastName!}"),
          pw.Text("Reservation Code: ${widget.bookings!.token}"),
          if (widget.bookings!.transaction != null)
            pw.Text("Transaction Id: #${widget.bookings!.transaction}"),
          pw.SizedBox(height: 15),
          pw.Text("Booking Details",
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text("Vehicle : ${widget.bookings!.propTitle}"),
          pw.Text("Location: ${bookingController.address}"),
          pw.Text("Additional Details",
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          if (widget.bookings!.module == "1") ...[
            pw.Text("Beds: ${itemDetails!.beds}"),
            pw.Text("Guests: ${widget.bookings!.totalGuest}"),
            pw.Text("Item Type: ${itemDetails!.itemType}"),
          ] else ...[
            pw.Text("Type: ${bookingController.bookingDetailType}"),
            pw.Text("Make: ${bookingController.bookingDetailMake}"),
            pw.Text("Vehicle Type: ${bookingController.vehicleType}"),
            pw.Text("Vehicle Model: ${bookingController.vehicleModel}"),
            pw.Text("Vehicle Year: ${bookingController.vehicleYear}"),
            pw.Text("Vehicle Make: ${bookingController.vehicleMake}"),
            pw.Text("Transmission: ${bookingController.vehicleTransmission}"),
            pw.Text("Odometer: ${bookingController.vehicleOdometer}"),
          ],
          pw.SizedBox(height: 10),
          pw.Text("Owner Details",
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text("Name: ${widget.bookings!.hostName}"),
          pw.Text("Phone: ${widget.bookings!.hostNumber}"),
          pw.Text("Email: ${widget.bookings!.hostEmail}"),
          pw.SizedBox(height: 10),
          pw.Text("Renter Details",
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Text("Name: ${widget.bookings!.userName}"),
          pw.Text("Phone: ${widget.bookings!.userNumber}"),
          pw.Text("Email: ${widget.bookings!.userEmail}"),
          pw.SizedBox(height: 10),
          pw.Text("Trip Details",
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text("Check-In: ${widget.bookings!.checkIn}"),
              pw.Text("Check-Out: ${widget.bookings!.checkOut}"),
            ],
          ),
          pw.Text(
              "Duration: ${widget.bookings!.totalNight} ${widget.bookings!.totalNight == "1" ? "day" : "days"}"),
          pw.SizedBox(height: 10),
          pw.Text("Billing",
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (widget.bookings?.perNight != null &&
                  widget.bookings!.perNight != "0.00")
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Amount:"),
                    pw.Text(
                      "${widget.bookings!.currencyCode} ${widget.bookings?.basePrice ?? ""}",
                    ),
                  ],
                ),
              if (widget.bookings?.doorStepPrice != null &&
                  widget.bookings!.doorStepPrice != "0.00")
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Doorstep Price:"),
                    pw.Text(
                        "${widget.bookings!.currencyCode} ${widget.bookings!.doorStepPrice}"),
                  ],
                ),
              if (widget.bookings?.ivaTax != null &&
                  widget.bookings!.ivaTax != "0.00")
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Tax:"),
                    pw.Text(
                        "${widget.bookings!.currencyCode} ${widget.bookings!.ivaTax}"),
                  ],
                ),
              if (widget.bookings?.serviceCharge != null &&
                  widget.bookings!.serviceCharge != "0.00")
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Service Charge:"),
                    pw.Text(
                        "${widget.bookings!.currencyCode} ${widget.bookings!.serviceCharge}"),
                  ],
                ),
              if (widget.bookings?.securityMoney != null &&
                  widget.bookings!.securityMoney != "0.00")
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Security Money:"),
                    pw.Text(
                        "${widget.bookings!.currencyCode} ${widget.bookings!.securityMoney}"),
                  ],
                ),
              if (widget.bookings?.cancelledCharge != null &&
                  widget.bookings!.cancelledCharge != "0.00")
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Cancelled Charge:"),
                    pw.Text(
                        "${widget.bookings!.currencyCode} ${widget.bookings!.cancelledCharge}"),
                  ],
                ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("Total:",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      "${widget.bookings!.currencyCode} ${widget.bookings!.total}",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 15),
          pw.Text("Terms and Conditions",
              style:
                  pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 5),
          ...termsWidgets,
          pw.SizedBox(height: 15),
          // Add Vehicle Interior Images section
          if (vehicleImages.isNotEmpty) ...[
            pw.Text(
              "Vehicle Interior Images",
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 5),
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: vehicleImages.map((image) {
                return pw.Container(
                  width: 150,
                  height: 150,
                  child: pw.ClipRRect(
                    horizontalRadius:
                        12, // Curved border radius for horizontal edges
                    verticalRadius:
                        12, // Curved border radius for vertical edges
                    child: pw.Image(image, fit: pw.BoxFit.contain),
                  ),
                );
              }).toList(),
            ),
          ],
          pw.SizedBox(height: 20),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Renter Signature (${widget.bookings!.userName})"),
                  pw.Image(userSignature, width: 150, height: 80),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text("Owner Signature (${widget.bookings!.hostName})"),
                  pw.Image(vendorSignature, width: 150, height: 80),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    }

    if (directory != null) {
      final file = File(
          "${directory.path}/booking_${widget.bookings?.token ?? 'unknown'}.pdf");
      await file.writeAsBytes(await pdf.save());
      closeLoading();
      await OpenFile.open(file.path);
    } else {
      closeLoading();
      showErrorToastMessage("Failed to save PDF: Unable to access storage.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => staticController.string.value.isEmpty
        ? Scaffold(
            backgroundColor: notifires.getblackwhitecolor,
            appBar: CustomAppBars(
              title: 'Booking Agreement'.tr,
              backgroundColor: notifires.getbgcolor,
              iconColor: notifires.getwhiteblackcolor,
              titleColor: notifires.getwhiteblackcolor,
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            backgroundColor: notifires.getblackwhitecolor,
            appBar: CustomAppBars(
              title: 'Booking Agreement'.tr,
              backgroundColor: notifires.getbgcolor,
              iconColor: notifires.getwhiteblackcolor,
              titleColor: notifires.getwhiteblackcolor,
            ),
            body: Padding(
              padding: const EdgeInsets.all(15.0),
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  ListView(
                    children: [
                      flutter_html.Html(
                        data: staticController.string.value,
                        style: {
                          "body": flutter_html.Style(
                            color: notifires.getwhiteblackcolor,
                            fontSize: flutter_html.FontSize(16.0),
                          ),
                          "h2": flutter_html.Style(
                            fontSize: flutter_html.FontSize(20.0),
                            fontWeight: FontWeight.bold,
                          ),
                          "li": flutter_html.Style(
                            fontSize: flutter_html.FontSize(14.0),
                            margin: flutter_html.Margins.symmetric(vertical: 5),
                          ),
                        },
                      ),
                    ],
                  ),
                  ListView(
                    children: [
                      Text(
                        "${"Receipt".tr} #${widget.bookings!.id}",
                        style: heading1(context),
                      ),
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.all(18),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: notifires.getboxcolor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  notifires.getGrey3Whitecolor.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(5, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Booked Date".tr,
                                style: heading3Grey1(context)),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(
                              widget.bookings!.createdAt!.split(" ")[0],
                              style: regular2(context),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              "Booked by".tr,
                              style: heading3Grey1(context),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              "#${widget.bookings!.userName}",
                              style: regular2(context),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              "Reservation code".tr,
                              style: heading3Grey1(context),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              "#${widget.bookings!.token}",
                              style: regular2(context),
                            ),
                            const SizedBox(height: 10),
                            widget.bookings!.transaction == null
                                ? const SizedBox()
                                : Text(
                                    "Transaction Id".tr,
                                    style: heading3Grey1(context),
                                  ),
                            widget.bookings!.transaction == null
                                ? const SizedBox()
                                : const SizedBox(height: 7),
                            widget.bookings!.transaction == null
                                ? const SizedBox()
                                : Text(
                                    "#${widget.bookings!.transaction}",
                                    style: regular2(context),
                                  ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            "${bookingController.bookingTypeDetail}".tr,
                            style: heading2Grey1(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: notifires.getboxcolor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  notifires.getGrey3Whitecolor.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(5, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${widget.bookings!.propTitle}",
                              style: regular2(context),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                widget.bookings!.module == "1"
                                    ? Text(
                                        itemDetails!.beds == "1"
                                            ? "bed"
                                            : "beds",
                                        style: heading3Grey1(context),
                                      )
                                    : Text(
                                        bookingController.bookingDetailType
                                            .toString()
                                            .tr,
                                        style: heading3Grey1(context),
                                      ),
                                Text(
                                  bookingController.bookingDetailMake
                                      .toString()
                                      .tr,
                                  style: heading3Grey1(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                widget.bookings!.module == "1"
                                    ? Text(
                                        "${itemDetails!.beds}",
                                        style: regular2(context),
                                      )
                                    : Text(
                                        "${bookingController.vehicleType}",
                                        style: regular2(context),
                                      ),
                                widget.bookings!.module == "1"
                                    ? Text("${widget.bookings!.totalGuest}",
                                        style: regular2(context))
                                    : Text("${bookingController.vehicleModel}",
                                        style: regular2(context)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${bookingController.bookingType}".tr,
                                  style: heading3Grey1(context),
                                ),
                                widget.bookings!.module == "1"
                                    ? const SizedBox()
                                    : Text(
                                        "Make".tr,
                                        style: heading3Grey1(context),
                                      ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                widget.bookings!.module == "1"
                                    ? Text(
                                        "${itemDetails!.itemType}".tr,
                                        style: regular2(context),
                                      )
                                    : Text(
                                        "${bookingController.vehicleYear}",
                                        style: regular2(context),
                                      ),
                                widget.bookings!.module == "1"
                                    ? const SizedBox()
                                    : Text(
                                        "${bookingController.vehicleMake}",
                                        style: regular2(context),
                                      ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            widget.bookings!.module == "1"
                                ? const SizedBox()
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Transmission".tr,
                                        style: heading3Grey1(context),
                                      ),
                                      Text(
                                        "Odometer".tr,
                                        style: heading3Grey1(context),
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 3),
                            widget.bookings!.module == "1"
                                ? const SizedBox()
                                : Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${bookingController.vehicleTransmission}",
                                        style: regular2(context),
                                      ),
                                      Text(
                                        "${bookingController.vehicleOdometer}",
                                        style: regular2(context),
                                      ),
                                    ],
                                  ),
                            const SizedBox(height: 3),
                            Text(
                              "Location".tr,
                              style: heading3Grey1(context),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              bookingController.address.toString(),
                              style: regular2(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Owner Details".tr,
                        style: heading2Grey1(context),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: notifires.getboxcolor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  notifires.getGrey3Whitecolor.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(5, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Name".tr,
                                  style: heading3Grey1(context),
                                ),
                                Text(
                                  "Phone".tr,
                                  style: heading3Grey1(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${widget.bookings!.hostName}",
                                  style: regular2(context),
                                ),
                                Text(
                                  "${widget.bookings!.hostNumber}",
                                  style: regular2(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Email".tr,
                              style: heading3Grey1(context),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.bookings!.hostEmail.toString(),
                              style: regular2(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Rental Details".tr,
                        style: heading2Grey1(context),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: notifires.getboxcolor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  notifires.getGrey3Whitecolor.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(5, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Name".tr,
                                  style: heading3Grey1(context),
                                ),
                                Text(
                                  "Phone".tr,
                                  style: heading3Grey1(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${widget.bookings!.userName}",
                                  style: regular2(context),
                                ),
                                Text(
                                  "${widget.bookings!.userNumber}",
                                  style: regular2(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Email".tr,
                              style: heading3Grey1(context),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.bookings!.userEmail.toString(),
                              style: regular2(context),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        "Trip Details".tr,
                        style: heading2Grey1(context),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: notifires.getboxcolor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  notifires.getGrey3Whitecolor.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(5, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${bookingController.bookingDateStart}"
                                          .tr,
                                      style: heading3Grey1(context),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${widget.bookings!.checkIn}",
                                      style: regular2(context),
                                    ),
                                    const SizedBox(height: 5),
                                    widget.bookings!.module == "1"
                                        ? const SizedBox()
                                        : Text(
                                            "${widget.bookings!.startTime}",
                                            style: regular2(context),
                                          ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${bookingController.bookingDateEnd}".tr,
                                      style: heading3Grey1(context),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "${widget.bookings!.checkOut}",
                                      style: regular2(context),
                                    ),
                                    const SizedBox(height: 5),
                                    widget.bookings!.module == "1"
                                        ? const SizedBox()
                                        : Text(
                                            "${widget.bookings!.endTime}",
                                            style: regular2(context),
                                          ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Duration".tr,
                              style: heading3Grey1(context),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.bookings!.totalNight == "1"
                                  ? "${widget.bookings!.totalNight} ${"day".tr}"
                                  : "${widget.bookings!.totalNight} ${"days".tr}",
                              style: regular2(context),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Billing".tr, style: heading2Grey1(context)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: notifires.getboxcolor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  notifires.getGrey3Whitecolor.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(5, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            widget.bookings?.perNight != null &&
                                    widget.bookings!.perNight != "0.00"
                                ? eReceiptWidget(
                                    name: widget.bookings!.totalNight == "1"
                                        ? "${"Amount".tr} (${widget.bookings!.totalNight} ${"day".tr}${")".tr}"
                                        : "${"Amount".tr} (${widget.bookings!.totalNight} ${"days".tr}${")".tr}",
                                    value:
                                        "${widget.bookings!.currencyCode} ${widget.bookings?.basePrice ?? ""}",
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 5),
                            widget.bookings?.doorStepPrice != null &&
                                    widget.bookings!.doorStepPrice != "0.00"
                                ? eReceiptWidget(
                                    name: "Doorstep Price".tr,
                                    value:
                                        "${widget.bookings!.currencyCode} ${widget.bookings?.doorStepPrice ?? ""}",
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 5),
                            widget.bookings?.ivaTax != null &&
                                    widget.bookings!.ivaTax != "0.00"
                                ? eReceiptWidget(
                                    name: "Tax".tr,
                                    value:
                                        "${widget.bookings!.currencyCode} ${widget.bookings!.ivaTax}",
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 5),
                            widget.bookings?.serviceCharge != null &&
                                    widget.bookings!.serviceCharge != "0.00"
                                ? eReceiptWidget(
                                    name: "Service Charge".tr,
                                    value:
                                        "${widget.bookings!.currencyCode} ${widget.bookings!.serviceCharge}",
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 5),
                            widget.bookings?.securityMoney != null &&
                                    widget.bookings!.securityMoney != "0.00"
                                ? eReceiptWidget(
                                    name: "Security Money".tr,
                                    value:
                                        "${widget.bookings!.currencyCode} ${widget.bookings!.securityMoney}",
                                  )
                                : const SizedBox(),
                            const SizedBox(height: 5),
                            widget.bookings!.cancelledCharge == null ||
                                    widget.bookings!.cancelledCharge == "0.00"
                                ? const SizedBox()
                                : eReceiptWidget(
                                    name: "Cancelled Charge".tr,
                                    value:
                                        "${widget.bookings!.currencyCode} ${widget.bookings!.cancelledCharge}",
                                  ),
                            const SizedBox(height: 5),
                            eReceiptWidget(
                              name: "Total".tr,
                              value:
                                  "${widget.bookings!.currencyCode} ${widget.bookings!.total}",
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text("Status".tr, style: heading2Grey1(context)),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(18),
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          color: notifires.getboxcolor,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  notifires.getGrey3Whitecolor.withOpacity(0.2),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(5, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Payment Status".tr,
                                    style: heading3Grey1(context)),
                                Text(
                                  "${widget.bookings!.paymentStatus.toString() == "paid" ? "Paid" : widget.bookings!.paymentStatus}"
                                      .tr,
                                  style: regular2(context).copyWith(
                                      fontSize: 16, color: themeColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Booking Status".tr,
                                    style: heading3Grey1(context)),
                                Text(
                                  "${widget.bookings!.status}".tr,
                                  style: regular2(context).copyWith(
                                      fontSize: 16, color: themeColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Payment Method".tr,
                                    style: heading3Grey1(context)),
                                Text(
                                  "${widget.bookings!.paymentMethod}".tr,
                                  style: regular2(context).copyWith(
                                      fontSize: 16, color: themeColor),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      imageUrls.isEmpty
                          ? SizedBox()
                          :
                          // Add Vehicle Images section
                          Text("Vehicle Interior Images".tr,
                              style: heading2Grey1(context)),
                      const SizedBox(height: 10),
                      imageUrls.isEmpty
                          ? SizedBox()
                          : Container(
                              width: double.maxFinite,
                              decoration: BoxDecoration(
                                color: notifires.getboxcolor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: notifires.getGrey3Whitecolor
                                        .withOpacity(0.2),
                                    spreadRadius: 5,
                                    blurRadius: 15,
                                    offset: const Offset(5, 5),
                                  ),
                                ],
                              ),
                              child: FullScreenImageView(
                                imagesList:
                                    imageUrls.isNotEmpty ? imageUrls : [],
                              ),
                            ),
                      const SizedBox(height: 100),
                    ],
                  ),
                  ListView(
                    children: [
                      // User Signature
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.bookings!.userName} (Renter) Signature:"
                                .tr,
                            style: heading2Grey1(context),
                          ),
                          const SizedBox(height: 10),
                          AbsorbPointer(
                            absorbing: isHostMode.value,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: isHostMode.value || _userSigned
                                  ? _userSignatureUrl != null
                                      ? SizedBox(
                                          height: 350,
                                          width: double.infinity,
                                          child:
                                              myNetworkImage(_userSignatureUrl))
                                      : const Text("Signature not provided")
                                  : Signature(
                                      controller: userSignController,
                                      height: 350,
                                      backgroundColor: Colors.white,
                                    ),
                            ),
                          ),
                          if (!isHostMode.value && !_userSigned) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: CustomsButtons(
                                    text: "Clear",
                                    backgroundColor:
                                        getColorBasedOnActiveModuleid(),
                                    onPressed: () {
                                      userSignController.clear();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomsButtons(
                                    backgroundColor: greensColor,
                                    text: 'Accept',
                                    onPressed: () {
                                      if (userSignController.isEmpty) {
                                        showErrorToastMessage(
                                            "Please Sign the terms and Conditions"
                                                .tr);
                                        return;
                                      }

                                      showDialog<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                notifires.getbgcolor,
                                            // title: Text('Are you sure?'.tr,style: TextStyle(color: CustomTheme.theamColor,fontSize: 16, fontFamily: FontStyles.gilroyMedium, fontWeight: FontWeight.w700),),
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  SizedBox(
                                                      height: 100,
                                                      child: Image.asset(
                                                          "assets/images/alert.png")),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Icon(
                                                    Icons.error,
                                                    size: 32,
                                                    color:
                                                        getColorBasedOnActiveModuleid(),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    'Are you sure you want to accept the terms and conditions?'
                                                        .tr,
                                                    textAlign: TextAlign.center,
                                                    style: regular2(context),
                                                  ),
                                                  // Text('Would you like to approve of this message?'),
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
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8,
                                                                          right:
                                                                              8),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: notifires
                                                                              .getBoxColor),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    "No".tr,
                                                                    style: heading3Grey1(
                                                                        context),
                                                                  ))))),
                                                      Expanded(
                                                          child: InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    context);
                                                                if (userSignController
                                                                    .isNotEmpty) {
                                                                  _saveSignature(
                                                                    controller:
                                                                        userSignController,
                                                                    type:
                                                                        'user',
                                                                  );
                                                                }
                                                              },
                                                              child: Container(
                                                                  margin: const EdgeInsets
                                                                      .only(
                                                                      left: 8,
                                                                      right: 8),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                              getColorBasedOnActiveModuleid()),
                                                                      color:
                                                                          getColorBasedOnActiveModuleid(),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    "Yes".tr,
                                                                    style: heading3(
                                                                            context)
                                                                        .copyWith(
                                                                      color: Colors
                                                                          .white,
                                                                      // fontFamily:
                                                                      // FontStyles.gilroyMedium,
                                                                    ),
                                                                  ))))),
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
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${widget.bookings!.hostName} (Owner) Signature:"
                                .tr,
                            style: heading2Grey1(context),
                          ),
                          const SizedBox(height: 10),
                          AbsorbPointer(
                            absorbing: !isHostMode.value,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.black),
                              ),
                              child: !isHostMode.value || _vendorSigned
                                  ? _vendorSignatureUrl != null
                                      ? SizedBox(
                                          height: 350,
                                          width: double.infinity,
                                          child: myNetworkImage(
                                              _vendorSignatureUrl))
                                      : const Text("Signature not provided")
                                  : Signature(
                                      controller: vendorSignController,
                                      height: 350,
                                      backgroundColor: Colors.white,
                                    ),
                            ),
                          ),
                          if (isHostMode.value && !_vendorSigned) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: CustomsButtons(
                                    text: "Clear",
                                    backgroundColor:
                                        getColorBasedOnActiveModuleid(),
                                    onPressed: () {
                                      vendorSignController.clear();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: CustomsButtons(
                                    text: "Accept",
                                    backgroundColor: greensColor,
                                    onPressed: () {
                                      if (vendorSignController.isEmpty) {
                                        showErrorToastMessage(
                                            "Please Sign the terms and Conditions"
                                                .tr);
                                        return;
                                      }

                                      showDialog<void>(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            backgroundColor:
                                                notifires.getbgcolor,
                                            // title: Text('Are you sure?'.tr,style: TextStyle(color: CustomTheme.theamColor,fontSize: 16, fontFamily: FontStyles.gilroyMedium, fontWeight: FontWeight.w700),),
                                            content: SingleChildScrollView(
                                              child: ListBody(
                                                children: <Widget>[
                                                  SizedBox(
                                                      height: 100,
                                                      child: Image.asset(
                                                          "assets/images/alert.png")),
                                                  const SizedBox(
                                                    height: 20,
                                                  ),
                                                  Icon(
                                                    Icons.error,
                                                    size: 32,
                                                    color:
                                                        getColorBasedOnActiveModuleid(),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  Text(
                                                    'Are you sure you want to deliver this vehicle and accept the terms and conditions?'
                                                        .tr,
                                                    textAlign: TextAlign.center,
                                                    style: regular2(context),
                                                  ),
                                                  // Text('Would you like to approve of this message?'),
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
                                                                Navigator.pop(
                                                                    context);
                                                              },
                                                              child: Container(
                                                                  margin:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              8,
                                                                          right:
                                                                              8),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color: notifires
                                                                              .getBoxColor),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    "No".tr,
                                                                    style: heading3Grey1(
                                                                        context),
                                                                  ))))),
                                                      Expanded(
                                                          child: InkWell(
                                                              onTap: () async {
                                                                Navigator.pop(
                                                                    context);
                                                                if (vendorSignController
                                                                    .isNotEmpty) {
                                                                  _saveSignature(
                                                                    controller:
                                                                        vendorSignController,
                                                                    type:
                                                                        'vendor',
                                                                  );
                                                                }
                                                              },
                                                              child: Container(
                                                                  margin: const EdgeInsets
                                                                      .only(
                                                                      left: 8,
                                                                      right: 8),
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          10),
                                                                  decoration: BoxDecoration(
                                                                      border: Border.all(
                                                                          color:
                                                                              getColorBasedOnActiveModuleid()),
                                                                      color:
                                                                          getColorBasedOnActiveModuleid(),
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10)),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    "Yes".tr,
                                                                    style: heading3(
                                                                            context)
                                                                        .copyWith(
                                                                      color: Colors
                                                                          .white,
                                                                      // fontFamily:
                                                                      // FontStyles.gilroyMedium,
                                                                    ),
                                                                  ))))),
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
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      if (_userSigned && _vendorSigned) ...[
                        const SizedBox(height: 20),
                        CustomsButtons(
                          text: "Generate PDF".tr,
                          backgroundColor: getColorBasedOnActiveModuleid(),
                          onPressed: _generatePDF,
                        ),
                      ],
                    ],
                  )
                ],
              ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: CustomsButtons(
                        text: "Previous".tr,
                        backgroundColor: Colors.grey,
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 10),
                  if (_currentPage < 2)
                    Expanded(
                      child: CustomsButtons(
                        text: "Next".tr,
                        backgroundColor: getColorBasedOnActiveModuleid(),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ));
  }
}
