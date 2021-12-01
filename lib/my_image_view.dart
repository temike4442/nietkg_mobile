import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:swipedetector/swipedetector.dart';

class MyPhotoView extends StatefulWidget {
  List<String> images;
  MyPhotoView({required this.images});

  @override
  MyPhotoViewState createState() => MyPhotoViewState();
}

class MyPhotoViewState extends State<MyPhotoView> {
  int _currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Фото ' +
            (_currentIndex + 1).toString() +
            ' из ' +
            widget.images.length.toString()),
      ),
      body: SwipeDetector(
        onSwipeDown: () {
          Navigator.pop(context);
        },
        child: PhotoViewGallery.builder(
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
                imageProvider: NetworkImage(widget.images[index]),
                initialScale: PhotoViewComputedScale.contained * 0.8,
                heroAttributes: PhotoViewHeroAttributes(
                    tag: index.toString() +
                        '|' +
                        widget.images.length.toString()));
          },
          itemCount: widget.images.length,
          loadingBuilder: (context, event) => Center(
            child: Container(
              width: 20.0,
              height: 20.0,
              child: CircularProgressIndicator(),
            ),
          ),
          onPageChanged: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
