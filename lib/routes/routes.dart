import 'package:flutter/material.dart';
import '../views/player.dart';

Map<String, Widget Function(BuildContext)> initializeRoutes() {
  return {
    '/player': (BuildContext context) =>
        PlayerView(song: ModalRoute.of(context).settings.arguments),
  };
}
