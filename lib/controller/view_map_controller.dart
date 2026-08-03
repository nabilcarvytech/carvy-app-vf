
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:ui' as ui;
import '../customwidget/project_color.dart';
import '../utils/common_widget.dart';
import '../utils/theme_style.dart';
import '../work_space.dart';

class MapViewController extends GetxController implements GetxService{

  Future<Uint8List> getBytesFromCanvasImage(int width, int height) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final ByteData vehicleImageData = await rootBundle.load('assets/images/car_marker.png');
    final Uint8List vehicleImageBytes = vehicleImageData.buffer.asUint8List();
    final ui.Codec vehicleImageCodec = await ui.instantiateImageCodec(vehicleImageBytes);
    final ui.FrameInfo vehicleImageFrame = await vehicleImageCodec.getNextFrame();
    final double vehicleImageSize = width.toDouble();
    const double vehicleImageX = 0.0;
    const double vehicleImageY = 0.0;
    canvas.drawImageRect(
      vehicleImageFrame.image,
      Rect.fromLTRB(0, 0, vehicleImageFrame.image.width.toDouble(), vehicleImageFrame.image.height.toDouble()),
      Rect.fromLTWH(vehicleImageX, vehicleImageY, vehicleImageSize, vehicleImageSize), // Position and size
      Paint(),
    );
    final ui.Image markerImage = await pictureRecorder.endRecording().toImage(width, height);
    final ByteData? byteData = await markerImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<Uint8List> getBytesFromCanvas(
      String price, int baseWidth, int height) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: price,
        style: const TextStyle(
          fontSize: 14.0,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    // Largeur adaptée au texte (l'ancien clamp 30–50 écrasait le badge prix).
    final int width =
        (textPainter.width.toInt() + 28).clamp(baseWidth > 70 ? baseWidth : 70, 220);
    final Paint backgroundPaint = Paint()
      ..color = getColorBasedOnActiveModuleid();
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0.0, 0.0, width.toDouble(), height.toDouble()),
        const Radius.circular(8),
      ),
      backgroundPaint,
    );

    final double textX = (width - textPainter.width) / 2;
    final double textY = (height - textPainter.height) / 2;
    textPainter.paint(canvas, Offset(textX, textY));
    final ui.Image markerImage =
        await pictureRecorder.endRecording().toImage(width, height);
    final ByteData? byteData =
        await markerImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  void showCustomInfoWindow(BuildContext context,String title, String description, int itemId,
      String image, String address) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: notifires.getboxcolor,
          titlePadding: const EdgeInsets.all(10),
          title: InkWell(
            onTap: () {
              Navigator.pop(context);

            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    height: 150,
                    width: double.maxFinite,
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: myNetworkImageWithShimmer(image))),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Row(
                    children: [
                      Text(
                        "$currency $title",
                        style: heading3(context).copyWith(),
                      ),
                      const Spacer(),
                      Text(
                        description,
                        style: heading3(context)
                            .copyWith(color: getColorBasedOnActiveModuleid()),
                      ),
                      Text(
                        " /day".tr,
                        style: regular(context),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const SizedBox(
                      width: 3,
                    ),
                    Icon(
                      Icons.location_on_outlined,
                      color: getColorBasedOnActiveModuleid(),
                      size: 18,
                    ),
                    const SizedBox(
                      width: 5,
                    ),
                    Expanded(
                        child: Text(
                          address,
                          style: regular2(context)
                              .copyWith(overflow: TextOverflow.ellipsis),
                        )),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
