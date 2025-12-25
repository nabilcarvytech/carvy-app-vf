import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:carvy/customwidget/project_bar.dart';
import 'package:carvy/customwidget/project_color.dart';
import '../utils/common_widget.dart';
import '../utils/theme_style.dart';

class FullScreenGallery extends StatefulWidget {
  final List<dynamic> images;
  final int imagesIndex;

  const FullScreenGallery(
      {super.key, required this.images, required this.imagesIndex});

  @override
  FullScreenGalleryState createState() => FullScreenGalleryState();
}

class FullScreenGalleryState extends State<FullScreenGallery> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.imagesIndex);
    currentIndex = widget.imagesIndex;
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: notifires.getbgcolor,
      appBar: CustomAppBars(
          title: "Images",
          backgroundColor: notifires.getbgcolor,
          titleColor: notifires.getGrey1Whitecolor),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PhotoViewGallery.builder(
            itemCount: widget.images.length,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.images[index]),
                minScale: PhotoViewComputedScale.contained * 0.8,
                maxScale: PhotoViewComputedScale.covered * 2,
              );
            },
            scrollPhysics: const BouncingScrollPhysics(),
            backgroundDecoration: BoxDecoration(
              color: notifires.getbgcolor,
            ),
            pageController: _pageController,
            onPageChanged: (index) {
              setState(() {
                currentIndex = index;
              });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              '${currentIndex + 1} / ${widget.images.length}',
              style: boldstyle(context).copyWith(
                color: notifires.getGrey1Whitecolor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageView extends StatefulWidget {
  final List<dynamic> imagesList;

  const FullScreenImageView({
    super.key,
    required this.imagesList,
  });

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late List<String> updatedImagesList;
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    updatedImagesList = widget.imagesList.cast<String>();
  }

  void _goToPage(int index) {
    if (index >= 0 && index < updatedImagesList.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex = index);
    }
  }

  void _showFullScreenImage(BuildContext context, int initialIndex) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        insetPadding: EdgeInsets.zero,
        child: FullScreenImageDialog(
          imagesList: updatedImagesList,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main image slider
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: updatedImagesList.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    return myNetworkImageFillBox(updatedImagesList[index]);
                  },
                ),
              ),
            ),
            // Zoom icon
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => _showFullScreenImage(context, _currentIndex),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.zoom_in,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
            // Left arrow
            if (_currentIndex > 0)
              Positioned(
                left: 10,
                top: 130,
                child: GestureDetector(
                  onTap: () => _goToPage(_currentIndex - 1),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            // Right arrow
            if (_currentIndex < updatedImagesList.length - 1)
              Positioned(
                right: 10,
                top: 130,
                child: GestureDetector(
                  onTap: () => _goToPage(_currentIndex + 1),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Thumbnails
        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: updatedImagesList.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _goToPage(index),
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _currentIndex == index
                          ? Theme.of(context).primaryColor
                          : Colors.grey.withOpacity(0.3),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: myNetworkImageFillBox(updatedImagesList[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class FullScreenImageDialog extends StatefulWidget {
  final List<String> imagesList;
  final int initialIndex;

  const FullScreenImageDialog({
    super.key,
    required this.imagesList,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageDialog> createState() => _FullScreenImageDialogState();
}

class _FullScreenImageDialogState extends State<FullScreenImageDialog> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
  }

  void _goToPage(int index) {
    if (index >= 0 && index < widget.imagesList.length) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InteractiveViewer(
          maxScale: 4.0,
          minScale: 0.5,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imagesList.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return Center(
                child: myNetworkImageFillBox(widget.imagesList[index]),
              );
            },
          ),
        ),
        // Close button
        Positioned(
          top: 40,
          right: 20,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
        // Left arrow
        if (_currentIndex > 0)
          Positioned(
            left: 20,
            top: MediaQuery.of(context).size.height / 2 - 20,
            child: GestureDetector(
              onTap: () => _goToPage(_currentIndex - 1),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
        // Right arrow
        if (_currentIndex < widget.imagesList.length - 1)
          Positioned(
            right: 20,
            top: MediaQuery.of(context).size.height / 2 - 20,
            child: GestureDetector(
              onTap: () => _goToPage(_currentIndex + 1),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class CustomImagesForDetails extends StatefulWidget {
  final List<dynamic> imagesList;
  final String frontImage;
  const CustomImagesForDetails(
      {super.key, required this.imagesList, required this.frontImage});

  @override
  State<CustomImagesForDetails> createState() => _CustomImagesForDetailsState();
}

class _CustomImagesForDetailsState extends State<CustomImagesForDetails> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Create a list without duplicates
    // If frontImage is already in imagesList, don't add it again
    List<String> updatedImagesList = [];
    
    if (widget.frontImage.isNotEmpty) {
      updatedImagesList.add(widget.frontImage);
    }
    
    // Add images from imagesList that are not already in the list
    for (String image in widget.imagesList) {
      if (image.isNotEmpty && !updatedImagesList.contains(image)) {
        updatedImagesList.add(image);
      }
    }
    
    // If no images at all, use frontImage as fallback
    if (updatedImagesList.isEmpty && widget.frontImage.isNotEmpty) {
      updatedImagesList = [widget.frontImage];
    }
    
    // For thumbnails, use the same list as updatedImagesList (without duplicates)
    // This ensures thumbnails match exactly the PageView images
    // The thumbnails will show the same images in the same order as the PageView
    List<String> thumbnailList = List.from(updatedImagesList);

    return Column(
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () {
                showGeneralDialog(
                  context: context,
                  barrierDismissible: true,
                  barrierLabel: MaterialLocalizations.of(context)
                      .modalBarrierDismissLabel,
                  barrierColor: Colors.black87,
                  transitionDuration: const Duration(milliseconds: 200),
                  pageBuilder: (BuildContext buildContext,
                      Animation animation, Animation secondaryAnimation) {
                    return Center(
                      child: FullScreenGallery(
                        images: updatedImagesList,
                        imagesIndex: _currentIndex,
                      ),
                    );
                  },
                );
              },
              child: Container(
                height: 287,
                width: double.maxFinite,
                decoration: BoxDecoration(
                    color: grey5,
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24))),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24)),
                  child: updatedImagesList.length > 1
                      ? PageView.builder(
                          controller: _pageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentIndex = index;
                            });
                          },
                          itemCount: updatedImagesList.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              height: 287,
                              width: double.maxFinite,
                              child: myNetworkImageFillBox(updatedImagesList[index]),
                            );
                          },
                        )
                      : SizedBox(
                          height: 287,
                          width: double.maxFinite,
                          child: myNetworkImageFillBox(updatedImagesList.isNotEmpty
                              ? updatedImagesList[0]
                              : widget.frontImage),
                        ),
                ),
              ),
            ),
            Positioned(
              right: 15,
              bottom: 12,
              child: InkWell(
                onTap: () {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: true,
                    barrierLabel: MaterialLocalizations.of(context)
                        .modalBarrierDismissLabel,
                    barrierColor: Colors.black87,
                    transitionDuration: const Duration(milliseconds: 200),
                    pageBuilder: (BuildContext buildContext,
                        Animation animation, Animation secondaryAnimation) {
                      return Center(
                        child: FullScreenGallery(
                          images: updatedImagesList,
                          imagesIndex: _currentIndex,
                        ),
                      );
                    },
                  );
                },
                child: ClipOval(
                  child: Container(
                    height: 30,
                    width: 30,
                    color: Colors.white,
                    child: Icon(Icons.fullscreen,
                        color: getColorBasedOnActiveModuleid()),
                  ),
                ),
              ),
            ),
          ],
        ),
        // Only show thumbnails if there's more than one image
        // Use thumbnailList (original imagesList) instead of updatedImagesList
        if (thumbnailList.length > 1)
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 12, top: 10),
              child: ListView.builder(
                itemBuilder: (context, index) {
                  // thumbnailList and updatedImagesList are identical, so index matches directly
                  String thumbnailImage = thumbnailList[index];
                  
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 5,
                      right: 5,
                      top: 5,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      child: Container(
                        width: 84,
                        height: 60,
                        decoration: BoxDecoration(
                            color: grey5,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _currentIndex == index
                                  ? getColorBasedOnActiveModuleid()
                                  : Colors.transparent,
                              width: 3,
                            )),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: myNetworkImageFillBox(thumbnailImage),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: thumbnailList.length,
                scrollDirection: Axis.horizontal,
              ),
            ),
          ),
      ],
    );
  }
}

Future<Object?> showFullScreen(
    List<dynamic> imageList, BuildContext context, int index) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black87,
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (BuildContext buildContext, Animation animation,
        Animation secondaryAnimation) {
      return Center(
        child: FullScreenGallery(
          images: imageList,
          imagesIndex: index,
        ),
      );
    },
  );
}
