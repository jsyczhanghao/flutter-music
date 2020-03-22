import 'package:audio_service/audio_service.dart';

const MediaControl PLAY_CONTROL = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);

const MediaControl PAUSE_CONTROL = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);

const MediaControl STOP_CONTROL = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

const MediaControl NEXT_CONTROL = MediaControl(
  label: 'SkipNext',
  action: MediaAction.skipToNext,
);

const MediaControl PREV_CONTROL = MediaControl(
  label: 'SkipPrevious',
  action: MediaAction.skipToPrevious,
);
