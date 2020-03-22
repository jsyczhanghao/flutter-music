part of player;

class PlayerController extends StatefulWidget {
  final PlayerConfig config;

  PlayerController({this.config});

  @override
  State<StatefulWidget> createState() {
    return _PlayerControllerState();
  }
}

class _PlayerControllerState extends State<PlayerController> {
  int val;
  int time;
  int duration = 0;
  bool sliding = false;

  static const double ICON_SIZE = 30;
  static const Color COLOR = Colors.white;
  static const double TIME_WIDTH = 30;

  @override
  void initState() {
    super.initState();
    val = time = widget.config.position;
  }

  @override
  void didUpdateWidget(PlayerController oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (sliding == false) {
      val = widget.config.position;
    }

    time = widget.config.position;
    duration = widget.config.duration < 0 ? 0 : widget.config.duration;
    setState(() {});
  }

  onSlide(double value, {bool end: false}) {
    val = value.toInt();

    if (end) {
      widget.config.onSeek(time = val);
      sliding = false;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      width: double.infinity,
      child: Column(
        children: <Widget>[
          DefaultTextStyle(
            style: TextStyle(color: COLOR.withOpacity(0.9), fontSize: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: TIME_WIDTH,
                  alignment: Alignment.center,
                  child: Text(serializeTime(time)),
                ),
                Expanded(
                  child: Slider(
                    activeColor: Colors.white,
                    label: serializeTime(val),
                    value: val.toDouble(),
                    onChangeStart: (v) => sliding = true,
                    onChanged: onSlide,
                    onChangeEnd: (v) => onSlide(v, end: true),
                    inactiveColor: Colors.grey,
                    min: 0,
                    max: duration.toDouble(),
                  ),
                ),
                Container(
                  width: TIME_WIDTH,
                  alignment: Alignment.center,
                  child: Text(serializeTime(widget.config.duration)),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              widget.config.controllerLeading,
              Container(
                width: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.skip_previous, color: Colors.white),
                      iconSize: ICON_SIZE,
                      onPressed: widget.config.onSkipPrevious,
                    ),
                    IconButton(
                      icon: Icon(
                        widget.config.status != PlayerStatus.PLAYING
                            ? Icons.play_circle_filled
                            : Icons.pause_circle_filled,
                        color: Colors.white,
                      ),
                      iconSize: ICON_SIZE * 2,
                      padding: EdgeInsets.all(0),
                      onPressed: widget.config.status != PlayerStatus.PLAYING
                          ? widget.config.onPlay
                          : widget.config.onPause,
                    ),
                    IconButton(
                      icon: Icon(Icons.skip_next, color: Colors.white),
                      iconSize: ICON_SIZE,
                      onPressed: widget.config.onSkipNext,
                    ),
                  ],
                ),
              ),
              widget.config.controllerAction,
            ],
          ),
        ],
      ),
    );
  }

  static String serializeTime(dynamic time) {
    return '${(time.toInt() ~/ 60).toString().padLeft(2, '0')}:${(time.toInt() % 60).toString().padLeft(2, '0')}';
  }
}
