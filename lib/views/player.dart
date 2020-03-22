import 'package:flutter/material.dart';
import 'dart:async';
import '../api/api.dart';
import '../configs/configs.dart';
import '../libs/libs.dart';
import '../components/common/common.dart';
import '../components/player/player.dart';
import '../tasks/play/play.dart';

class PlayerView extends StatefulWidget {
  final SongModel song;

  PlayerView({this.song});

  @override
  State<StatefulWidget> createState() {
    return _PlayerViewState();
  }
}

class _PlayerViewState extends PlayerObserver<PlayerView> {
  SongModel song;
  ImageProvider image = DEFAULT_MUSIC_IMAGE;
  String lrc;
  int position = 0;
  int duration = 1;
  PlayerStatus status = PlayerStatus.READY;
  Timer timer;

  @override
  void initState() {
    super.initState();

    if (widget.song != null) {
      play(widget.song);
    }
  }

  play(SongModel model) async {
    await PlayApi().play(model);
    model != null ? PlayController.start() : false;
  }

  @override
  onConnection() async {
    song = await PlayApi().getPlaying();
    status = PlayerStatus.READY;
    position = 0;
    duration = 0;
    cancelTimer();
    setState(() {});
  }

  @override
  onWillPlay() async {
    song = await PlayApi().getPlaying();
    SongApi api = SongApiFactory.create(song.id, song.type);
    SongSourceModel source = await api.source(download: false);
   
    if (source == null) return ;
  
    lrc = await Fs(source.lrc).read();

    if (source.img != '') {
      image = FileImage(await Fs.file(source.img));
    } else {
      image = DEFAULT_MUSIC_IMAGE;
    }

    setState(() {});
  }

  @override
  onLifecyclePaused() {
    cancelTimer();
  }

  @override
  onPlaying(int pos, int dur) {
    position = pos ~/ 1000;
    duration = dur ~/ 1000;

    setState(() {  
      status = PlayerStatus.PLAYING;
    });

    cancelTimer();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (position < duration) {
        setState(() {
          ++position;
        });
      }
    });
  }

    @override
  onPaused(int pos, int dur) {
    setState(() {
      position = pos ~/ 1000;
      duration = dur ~/ 1000;
      status = PlayerStatus.PAUSED;
    });

    cancelTimer();
  }

  cancelTimer() {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
  }

  @override 
  void dispose() {
    super.dispose();
    cancelTimer();
  }

  @override
  Widget build(BuildContext context) {
    return GaussianBlur(
      image: image,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          backgroundColor: Colors.transparent,
          title: Column(
            children: <Widget>[
              Text(song != null ? song.name : widget.song != null ? widget.song.name : ''),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        body: Column(
          children: <Widget>[
            Container(
              height: 20,
              alignment: Alignment.center,
              child: GestureDetector(
                child: Text(
                  '-  ${Helper.ellipsis(song?.singers ?? '加载中...', 20)}  -',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Expanded(
              child: Player(
                image: image,
                lrc: lrc,
                config: PlayerConfig(
                  status: status,
                  position: position,
                  duration: duration,
                  onPause: PlayController.pause,
                  onPlay: PlayController.resume,
                  onSkipPrevious: PlayController.skip2previous,
                  onSkipNext: PlayController.skip2next,
                  onSeek: PlayController.seek,
                  controllerLeading: PlayerModeSwitcher(),
                  controllerAction: PlayerListButton(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
