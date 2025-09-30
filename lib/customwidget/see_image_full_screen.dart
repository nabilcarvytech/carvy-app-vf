import 'dart:io';
import 'package:flutter/material.dart';
import 'project_color.dart';

class SeeImageFullScreen extends StatefulWidget {
  final String image;
  const SeeImageFullScreen({super.key, required this.image});

  @override
  State<SeeImageFullScreen> createState() => _SeeImageFullScreenState();
}

class _SeeImageFullScreenState extends State<SeeImageFullScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon:Icon(
            Icons.arrow_back,
            color: notifires.getwhiteblackcolor,
          ),
        ),
      ),
      body: Center(
        child: Hero(
          tag: widget.image, // Hero tag to create smooth transition
          child: InteractiveViewer(
            panEnabled: true, // Enable panning
            boundaryMargin: const EdgeInsets.all(20), // Made const
            minScale: 0.5, // Minimum zoom level
            maxScale: 4.0, // Maximum zoom level
            child: widget.image.contains("http")
                ? Image.network(
              widget.image,
              fit: BoxFit.contain, // Ensures the image scales appropriately
              width: double.infinity, // Make the image as wide as the screen
              height: double.infinity, // Make the image as tall as the screen
            )
                : Image.file(
              File(widget.image),
              fit: BoxFit.contain, // Adjusts for local files too
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}