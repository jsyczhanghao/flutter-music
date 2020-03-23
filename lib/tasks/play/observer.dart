import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:audio_service/audio_service.dart';
import './controller.dart';

abstract class PlayerObserver<T extends StatefulWidget> extends State<T>
    with WidgetsBindingObserver {
  StreamSubscription listener;

  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    connect();
  }

  @override
  dispose() async {
    disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  connect() async {
    await AudioService.connect();
    listener = AudioService.playbackStateStream.listen(
      (PlaybackState state) => handler(state),
    );

    await onConnection();
    await onWillPlay();

    Future.delayed(Duration(milliseconds: 100), () {
      //这边连接时，主要为了触发一次设置能否拿到当前的position
      if (AudioService.playbackState == null) return;
     
      BasicPlaybackState state = AudioService.playbackState.basicState;

      if (state == BasicPlaybackState.paused) {
        PlayController.pause();
      } else if (state == BasicPlaybackState.playing) {
        PlayController.play();
      }
    });
  }

  disconnect() {
    AudioService.disconnect();
    listener.cancel();
  }

  handler(PlaybackState state) async {
    if (state == null) return;

    switch (state.basicState) {
      case BasicPlaybackState.connecting:
        await onConnection();
        break;

      case BasicPlaybackState.buffering:
        await onWillPlay();
        break;

      case BasicPlaybackState.playing:
        await onPlaying(
            state.position, AudioService.currentMediaItem.duration ?? 0);
        break;

      default:
        await onPaused(
            state.position, AudioService.currentMediaItem?.duration ?? 0);
    }
  }

  onConnection();
  onWillPlay();
  onPlaying(int position, int duration);
  onPaused(int position, int duration);
  onLifecycleResume() {}
  onLifecyclePaused() {}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        await connect();
        onLifecycleResume();
        break;
      case AppLifecycleState.paused:
        await disconnect();
        onLifecyclePaused();
        break;
      default:
        break;
    }
  }
}
