import 'dart:io';
import 'package:flutter/material.dart';
import 'package:carvy/customwidget/project_color.dart';

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
            icon: Icon(
              Icons.arrow_back,
              color: notifires.getwhiteblackcolor,
            )),
      ),
      body: Center(
        child: widget.image.contains("http")
            ? Image.network(widget.image)
            : Image.file(File(widget.image)),
      ),
    );
  }
}
