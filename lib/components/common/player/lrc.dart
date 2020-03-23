part of player;

class PlayerLrc extends StatefulWidget {
  final String lrc;
  final int position;

  PlayerLrc({this.lrc, this.position = 0});

  @override
  State<StatefulWidget> createState() {
    return _PlayerLrcState();
  }
}

class _PlayerLrcState extends State<PlayerLrc> {
  List<String> lines;
  Map<int, int> idx;
  int index = 0;
  bool lock = false;
  List<GlobalKey> keys = [];
  ScrollController controller = ScrollController();

  static final lrcSplitRegExp = RegExp(r'[\r\n]+');
  static final lrcLineSplitRegExp = RegExp(r'\[(\d{2}):(\d{2})[^\]]+\]([\S\s]*)');

  @override
  void initState() {
    super.initState();
    analyseLrc();
  }

  analyseLrc() {
    if (widget.lrc == null || widget.lrc == '') return;

    int i = 0;
    lines = List();
    idx = Map();
    keys = [];
    int position = widget.position;
    int a = 0;

    widget.lrc.split(lrcSplitRegExp).forEach((String line) {
      Match m = lrcLineSplitRegExp.firstMatch(line);
      int pos = int.parse(m[1]) * 60 + int.parse(m[2]);

      lines.add(m[3] ?? '');
      keys.add(GlobalKey(debugLabel: 'player_lrc_$i'));
      idx[pos] = i;

      if (position >= pos) {
        a = pos;
      }

      i++;
    });
    
    index = a;
    Future.delayed(Duration(milliseconds: 100), () => highlightLrc());
  }

  highlightLrc() {
    controller.animateTo(
      getRenderObjectDy(index) - getRenderObjectDy(0) - 150,
      duration: Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  getRenderObjectDy(int index) {
    GlobalKey key = index == 0 ? keys[0] : keys[idx[index]];
    RenderBox box = key.currentContext.findRenderObject();
    Offset os = box.localToGlobal(Offset.zero);
    return os.dy;
  }

  @override
  void didUpdateWidget(PlayerLrc oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.lrc != oldWidget.lrc) {
      index = 0;
      analyseLrc();
      return ;
    }

    if (!lock && widget.lrc != null && widget.lrc != '' && idx[widget.position] != null) {
      index = widget.position;
      setState(() {});
      highlightLrc();
    }
  }

  dispose() {
    keys = null;
    super.dispose();
  }

  Widget createLrcContainer() {
    if (widget.lrc == null || widget.lrc == '') {
      return Text('歌词加载中...', style: TextStyle(color: Colors.grey.shade400),);
    }

    return Column(
      children: lines.asMap().keys.map((int key) {
        return Container(
          key: keys[key],
          padding: EdgeInsets.only(left: 30, right: 30, top: 10),
          alignment: Alignment.center,
          child: Text(
            '${lines[key]}',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: idx[index] == key ? Colors.white : Colors.grey.shade400,
              fontWeight:
                  idx[index] == key ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
              height: 1.2,
              letterSpacing: 1.3,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 15),
      child: Listener(
        onPointerDown: (x) => lock = true,
        onPointerUp: (x) => lock = false,
        child: Scrollbar(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            controller: controller,
            child: Center(
              child: createLrcContainer(),
            ),
          ),
        ),
      ),
    );
  }
}
