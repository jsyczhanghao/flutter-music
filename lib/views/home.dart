import 'package:flutter/material.dart';
import 'package:tt/components/player/player.dart';
import '../api/api.dart';
import '../libs/libs.dart';
import '../components/songs/songs.dart';
import '../components/songs/actions.dart';

class HomeView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeViewState();
  }
}

class _HomeViewState extends State<HomeView>
    with AutomaticKeepAliveClientMixin {
  String word = '';
  bool wantKeepAlive = true;
  TextEditingController controller = TextEditingController();
  static const Color ICON_COLOR = Colors.black54;

  InputDecoration renderDecoration() {
    return InputDecoration(
      prefixIcon: Icon(
        Icons.search,
        color: ICON_COLOR,
      ),
      suffixIcon: word == ''
          ? null
          : IconButton(
              icon: Icon(Icons.close),
              color: ICON_COLOR,
              onPressed: () {
                controller.text = '';
                setState(() {
                  word = '';
                });
              },
            ),
      hintText: '输入音乐进行搜索',
      hintStyle: TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderSide: BorderSide.none),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  uncollect(SongModel song) async {
    await UserApi().uncollect(song);
    Toast.show(context, title: '已取消', duration: 1, type: ToastShowType.success);
  }

  collect(SongModel song) async {
    await UserApi().collect(song);
    Toast.show(context, title: '已收藏', duration: 1, type: ToastShowType.success);
  }

  add2playlist(SongModel song) async {
    await PlayApi().add(song);
    Toast.show(context, title: '已添加', duration: 1, type: ToastShowType.success);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          style: TextStyle(
            color: Colors.black87,
          ),
          controller: controller,
          cursorColor: Colors.black87,
          onSubmitted: (String str) {
            setState(() {
              word = str;
            });
          },
          decoration: renderDecoration(),
        ),
      ),
      body: IfPlay(
        child: Songs(
          api: SearchApi.query,
          param: word,
          actionsBuilder: (SongModel song, int) async {
            SongApi api = SongApiFactory.create(song.id, song.type);
            bool collected = await api.isCollected();
            return [
              SongActions.creator(
                collected ? SongActions.uncollect : SongActions.collect,
                collected ? () => uncollect(song) : () => collect(song),
              ),
              SongActions.creator(
                SongActions.add2playlist,
                () => add2playlist(song),
              ),
            ];
          },
        ),
      ),
    );
  }
}
