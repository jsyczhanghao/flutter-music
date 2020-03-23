import 'package:flutter/material.dart';
import '../api/api.dart';
import '../libs/libs.dart';
import '../components/songs/songs.dart';

class UserView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UserViewState();
  }
}

class _UserViewState extends State<UserView>
    with AutomaticKeepAliveClientMixin {
  bool wantKeepAlive = false;
  List<SongModel> songs;

  @override
  void initState() {
    super.initState();
    loadSongs();
  }

  loadSongs() async {
    songs = await UserApi().collects();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('我的音乐'),
      ),
      body: Songs(
        songs: songs,
        actionsBuilder: (SongModel song, int index) async {
          return [
            SongActions.creator(SongActions.uncollect, () async {
              await UserApi().uncollect(song);
              Toast.show(context,
                  title: '已取消收藏', duration: 1, type: ToastShowType.success);
              setState(() {
                songs.removeAt(index);
              });
            }),
          ];
        },
      ),
    );
  }
}
