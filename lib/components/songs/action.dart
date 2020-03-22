import 'package:flutter/material.dart';

class SongAction {
  final Icon icon;
  final String title;
  final Function() onPressed;

  SongAction({this.icon, this.title, this.onPressed});
}