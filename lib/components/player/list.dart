import 'package:flutter/material.dart';
import '../../api/api.dart';
import '../../libs/libs.dart';
import '../../tasks/play/play.dart';

class PlayerListButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.playlist_play,
        color: Colors.white,
      ),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) => PlayerList(),
        );
      },
    );
  }
}

class PlayerList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PlayListState();
  }
}

class _PlayListState extends State<PlayerList> {
  ScrollController controller = ScrollController(initialScrollOffset: 0);
  List<SongModel> songs = [];
  SongModel playing;

  @override
  void initState() {
    super.initState();
    load();
  }

  load() async {
    songs = await PlayApi().list();
    playing = await PlayApi().getPlaying();
    setState(() {});
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Widget renderItem(SongModel song) {
    return _PlayerItem(
      song: song,
      isPlaying:
          playing != null && playing.id == song.id && song.type == playing.type,
      notDelete: songs.length == 1,
      onDelete: () async {
        await PlayApi().del(song);
        songs.remove(song);
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Column(
        children: <Widget>[
          _PlayerListHeader(
            onClickCollect: () async {
              await UserApi().batch(songs);
              Toast.show(context, title: '收藏成功', duration: 1, type: ToastShowType.success);
              Navigator.pop(context);
            },
          ),
          Expanded(
            child: Scrollbar(
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) =>
                    Divider(color: Colors.grey, height: 1),
                controller: controller,
                itemCount: songs.length,
                itemBuilder: (BuildContext context, int index) =>
                    renderItem(songs[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerListHeader extends StatelessWidget {
  final Function onClickCollect;

  _PlayerListHeader({this.onClickCollect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: Navigator.of(context).pop,
          ),
          FlatButton(
            padding: EdgeInsets.all(15),
            color: Colors.transparent,
            onPressed: onClickCollect,
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.favorite_border,
                  color: Colors.red,
                  size: 20,
                ),
                Text(
                  ' 收藏全部',
                  style: TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _PlayerItem extends StatelessWidget {
  final SongModel song;
  final bool isPlaying;
  final bool notDelete;
  final Function onDelete;

  _PlayerItem({
    this.song,
    this.isPlaying,
    this.notDelete,
    this.onDelete,
  }) : super(key: Key('${song.id}@${song.type}'));

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        GestureDetector(
          child: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(5),
                child: isPlaying
                    ? Icon(
                        Icons.equalizer,
                        color: Colors.red,
                      )
                    : null,
              ),
              Container(
                child: Text(
                  Helper.ellipsis(song.name, 12),
                  style: TextStyle(
                      fontSize: 14,
                      color: isPlaying ? Colors.red : Colors.black),
                ),
              ),
              Text(
                '  -  ${Helper.ellipsis(song.singers, 10)}',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              )
            ],
          ),
          onTap: () async {
            await PlayApi().play(song);
            PlayController.start();
            Navigator.of(context).pop();
          },
        ),
        IconButton(
          icon: Icon(Icons.delete),
          onPressed: notDelete ? null : onDelete,
        ),
      ],
    );
  }
}
