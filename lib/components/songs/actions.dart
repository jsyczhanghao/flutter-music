import 'package:flutter/material.dart';
import './action.dart';

class SongActions {
  static final COLLECT = SongAction(icon: Icon(Icons.favorite_border, color: Colors.red,), title: '收藏');
  static final UNCOLLECT = SongAction(icon: Icon(Icons.favorite, color: Colors.red,), title: '取消收藏');
  static final ADD2PLAYLIST = SongAction(icon: Icon(Icons.send, color: Colors.black,), title: '下一首播放');

  static SongAction creator(SongAction action, Function api) {
    return SongAction(
      icon: action.icon,
      title: action.title,
      onPressed: api,
    );
  }
}