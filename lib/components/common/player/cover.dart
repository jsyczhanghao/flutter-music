part of player;

class PlayerCover extends StatefulWidget {
  final ImageProvider image;

  PlayerCover({this.image});

  @override
  State<StatefulWidget> createState() {
    return _PlayerCoverState();
  }
}

class _PlayerCoverState extends State<PlayerCover>
    with TickerProviderStateMixin {
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: Duration(seconds: 30),
      vsync: this,
      animationBehavior: AnimationBehavior.normal,
    );
    controller.repeat();
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        height: 290,
        width: 290,
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(
            color: Colors.black87,
            width: 10,
          ),
          borderRadius: BorderRadius.all(Radius.circular(300)),
        ),
        child: RotationTransition(
          turns: controller,
          alignment: Alignment.center,
          child: CircleAvatar(backgroundImage: widget.image),
        ),
      ),
    );
  }
}
