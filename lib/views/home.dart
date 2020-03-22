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

  InputDecoration get _decoration {
    return InputDecoration(
      prefixIcon: Icon(
        Icons.search,
        color: Colors.black54,
      ),
      hintText: '输入音乐进行搜索',
      hintStyle: TextStyle(color: Colors.black),
      border: OutlineInputBorder(borderSide: BorderSide.none),
    );
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
          cursorColor: Colors.black87,
          onSubmitted: (String str) {
            setState(() {
              word = str;
            });
          },
          decoration: _decoration,
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
                  collected ? SongActions.UNCOLLECT : SongActions.COLLECT,
                  collected
                      ? () async {
                          await UserApi().uncollect(song);
                          Toast.show(context,
                              title: '已取消收藏',
                              duration: 1,
                              type: ToastShowType.success);
                        }
                      : () async {
                          await UserApi().collect(song);
                          Toast.show(context,
                              title: '已收藏',
                              duration: 1,
                              type: ToastShowType.success);
                        }),
              SongActions.creator(SongActions.ADD2PLAYLIST, () async {
                PlayApi api = PlayApi();
                await api.add(song);
                Toast.show(context,
                    title: '已添加', duration: 1, type: ToastShowType.success);
              }),
            ];
          },
        ),
      ),
    );
  }
}
