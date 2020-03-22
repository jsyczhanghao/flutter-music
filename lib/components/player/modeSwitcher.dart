import 'package:flutter/material.dart';
import '../../configs/configs.dart';
import '../../libs/libs.dart';
import '../../api/api.dart';

class PlayerModeSwitcher extends StatefulWidget {
  final Function(int mode) onChange;

  PlayerModeSwitcher({this.onChange});

  @override
  State<StatefulWidget> createState() {
    return PlayerModeSwitcherState();
  }
}

class PlayerModeSwitcherState extends State<PlayerModeSwitcher> {
  int mode = PlayerModes.LIST;

  @override
  void initState() {
    super.initState();
    readConfig();
  }

  readConfig() async {
    Fs fs = Fs('playmode');
    mode = int.parse(await fs.read(PlayerModes.LIST.toString()));
    setState(() {
      
    });
  }

  switchMode() async {
    String toast;

    if (mode == PlayerModes.LIST) {
      mode = PlayerModes.RANDOM;
      toast = '已切换随机播放模式';
    } else if (mode == PlayerModes.RANDOM) {
      mode = PlayerModes.SINGLE;
      toast = '已切换单曲循环模式';
    } else {
      mode = PlayerModes.LIST;
      toast = '已切换列表循环模式';
    }

    Toast.show(context, title: toast, duration: 1, type: ToastShowType.success);
    HistoryApi().clear();
    Fs fs = Fs('playmode');
    await fs.write(mode.toString());
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        mode == PlayerModes.LIST ? Icons.sync : mode == PlayerModes.RANDOM ? Icons.all_inclusive : Icons.sync_problem,
        color: Colors.white,
      ),
      onPressed: switchMode,
    );
  }
}