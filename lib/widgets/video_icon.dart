import 'package:flutter/material.dart';
import 'package:wordpress_app/models/article.dart';

class VideoIcon extends StatelessWidget {
  final Article article;
  final double iconSize;
  const VideoIcon({Key? key, required this.article, required this.iconSize}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: article.videoPost ?? false,
        child: Align(
          alignment: Alignment.center,
          child: Icon(Icons.play_circle_fill_outlined, color: Colors.white, size: iconSize),
        ));
  }
}
