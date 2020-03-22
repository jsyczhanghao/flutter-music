import 'package:audio_service/audio_service.dart';
import './background.dart';

class PlayController {
  static start() async {
    if (await AudioService.running) {
      play();
      return ;
    } 

    await AudioService.start(
      backgroundTaskEntrypoint: backgroundEntry,
      resumeOnClick: true,
      androidNotificationChannelName: 'js.zhang music',
      androidNotificationIcon: 'mipmap/ic_launcher',
    );
  }

  static stop() async {
    if (await AudioService.running) {
      await AudioService.stop();
    }
  }

  static resume() async {
    if (!await AudioService.running) {
      await start();
    } else {
      play();
    }
  }

  static play() async {
    AudioService.play();  
  }

  static pause() {
    AudioService.pause();
  }

  static seek(int i) {
    AudioService.seekTo(i * 1000);
  }

  static skip2next() async {
    if (!await AudioService.running) {
      await start();
    }

    AudioService.skipToNext();
  }

  static skip2previous() async {
    if (!await AudioService.running) {
      await start();
    }

    AudioService.skipToPrevious();
  }
}
