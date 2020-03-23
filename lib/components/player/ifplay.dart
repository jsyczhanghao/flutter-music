import 'dart:async';
import 'package:flutter/material.dart';
import '../../configs/configs.dart';
import '../../libs/libs.dart';
import '../../api/api.dart';
import 'package:audio_service/audio_service.dart';

class IfPlay extends StatefulWidget {
  final Widget child;

  IfPlay({Key key, this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return IfPlayState();
  }
}

class IfPlayState extends State<IfPlay> with TickerProviderStateMixin {
  AnimationController controller;
  SongModel song;
  ImageProvider image = DEFAULT_MUSIC_IMAGE;
  StreamSubscription listener;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 5));
    refreshPlaying();
    listening();
    Future(() => controller.repeat());
  }

  listening() {
    listener = AudioService.playbackStateStream.listen(
      (PlaybackState state) {
        if (state.basicState == BasicPlaybackState.buffering) {
          refreshPlaying();
        }
      },
    );
  }

  refreshPlaying() async {
    song = await PlayApi().getPlaying();

    do {
      if (song != null) {
        SongApi api = SongApiFactory.create(song.id, song.type);
        SongSourceModel source = await api.source(download: false);

        if (source != null && source.img != '') {
          image = FileImage(await Fs.file(source.img));
          break;
        }
      }

      image = DEFAULT_MUSIC_IMAGE;
    } while (false);

    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    listener.cancel();
    listener = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    refreshPlaying();
  }

  renderChild() {
    if (song == null) {
      return Container();
    }

    return Hero(
      child: RotationTransition(
        turns: controller,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed('/player');
          },
          child: ClipOval(
            child: Image(
              image: image,
              width: 50,
              height: 50,
            ),
          ),
        ),
      ),
      tag: 'player',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        Positioned(
          bottom: 100,
          left: 5,
          child: renderChild(),
        ),
      ],
    );
  }
}
