import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImagePreview extends StatelessWidget {
  String imgUrl;

  ImagePreview({required this.imgUrl});

  @override
  Widget build(BuildContext context) {
    return PhotoView(imageProvider: NetworkImage(imgUrl));
  }
}
