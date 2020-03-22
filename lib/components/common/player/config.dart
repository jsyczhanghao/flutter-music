part of player;

class PlayerConfig {
  final int position;
  final int duration;
  final PlayerStatus status;
  final Widget controllerLeading;
  final Widget controllerAction;
  final Function onSkipNext;
  final Function onSkipPrevious;
  final Function onPause;
  final Function onPlay;
  final Function(int) onSeek;

  PlayerConfig({
    this.position = 0,
    this.duration = 0,
    this.controllerLeading,
    this.controllerAction,
    this.status,
    this.onPause,
    this.onPlay,
    this.onSkipNext,
    this.onSkipPrevious,
    this.onSeek,
  });
}