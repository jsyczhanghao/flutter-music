import 'dart:ui';
import 'package:flutter/material.dart';

class GaussianBlur extends StatelessWidget {
  final Widget child;
  final ImageProvider image;

  GaussianBlur({this.child, this.image});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned(
          child: new Container(
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: image,
                fit: BoxFit.cover,
                colorFilter: new ColorFilter.mode(
                  Colors.black54,
                  BlendMode.overlay,
                ),
              ),
            ),
          ),
        ),
        new Container(
          child: new BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Opacity(
              opacity: 0.6,
              child: new Container(
                decoration: new BoxDecoration(
                  color: Colors.grey.shade900,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
