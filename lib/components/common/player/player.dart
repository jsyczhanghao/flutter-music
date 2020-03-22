library player;

import 'package:flutter/material.dart';

part './cover.dart';
part './lrc.dart';
part './controller.dart';
part './status.dart';
part './config.dart';

class Player extends StatefulWidget {
  final String lrc;
  final ImageProvider image;
  final PlayerConfig config;

  Player({
    this.image,
    this.lrc,
    this.config,
  });

  @override
  State<StatefulWidget> createState() {
    return PlayerState();
  }
}

class PlayerState extends State<Player> with SingleTickerProviderStateMixin {
  bool _cover = true;
  TabController controller;

  @override
  void initState() {
    super.initState();
    controller = TabController(vsync: this, length: 2);
  }

  @override
  void didUpdateWidget(Player oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    controller = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _cover = !_cover;
                });
              },
              onVerticalDragEnd: (detail) {
                if (detail.primaryVelocity < -200) {
                  widget.config.onSkipPrevious();
                } else if (detail.primaryVelocity > 200) {
                  widget.config.onSkipNext();
                }
              },
              child: TabBarView(controller: controller, children: [
                PlayerCover(image: widget.image),
                PlayerLrc(lrc: widget.lrc, position: widget.config.position),
              ]),
            ),
          ),
          PlayerController(
            config: widget.config,
          ),
        ],
      ),
    );
  }
}
