import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../models/song.dart';
import '../../api/api.dart';
import './song.dart';
import './actionsPanel.dart';

export './actionsPanel.dart';
export './actions.dart';

class Songs extends StatefulWidget {
  final Function api;
  final List<SongModel> songs;
  final dynamic param;
  final Function(SongModel, int, List<SongModel>) onClickSong;
  final Future<List<SongAction>> Function(SongModel song, int index)
      actionsBuilder;
  final Widget Function(Widget, int) onRenderItem;

  Songs({
    Key key,
    this.api,
    this.songs,
    this.param,
    this.onClickSong,
    this.onRenderItem,
    this.actionsBuilder,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _SongsState();
  }
}

class _SongsState extends State<Songs> {
  List<SongModel> rows = List<SongModel>();
  ScrollController controller = ScrollController(initialScrollOffset: 0.0);
  int page = 0;
  bool loading = false;
  bool completed = false;
  StreamSubscription listener;

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      if (!completed &&
          controller.position.pixels >
              controller.position.maxScrollExtent - 50) {
        load();
      }
    });

    load();
  }

  @override
  void didUpdateWidget(Songs oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.songs != null && (widget.songs != oldWidget.songs || widget.songs.length != oldWidget.songs.length)) {
      setState(() {
        loading = false;
        completed = true;
        rows = widget.songs;
      });
    } else {
      controller.animateTo(0.0,
          duration: Duration(microseconds: 10), curve: Curves.bounceIn);
      page = 0;
      loading = false;
      completed = false;
      load();
    }
  }

  load() async {
    if (loading || page > 0 && completed) return;

    setState(() {
      loading = true;
    });

    if (page == 0) {
      rows = [];
    }

    if (widget.api != null) {
      List<SongModel> songs = List<SongModel>();
      dynamic res = await widget.api(widget.param, page + 1);

      if (res.runtimeType == List) {
        rows.addAll(songs = List.from(res));
        loadDone(songs);
      } else if (res == null) {
        loadDone([]);
      } else {
        listener = Stream.castFrom(res).listen((list) {
          rows.addAll(list);
          songs.addAll(list);
          setState(() {
            
          });
        }, onDone: () => loadDone(songs));
      }
    } else if (widget.songs != null){
      rows = widget.songs;
      loading = false;
    }
  }

  loadDone(List<SongModel> songs) {
    stopListen();
    setState(() {
      ++page;
      loading = false;
      
      if (songs.length == 0) {
        completed = true;
      }
    });
  }

  stopListen() {
    if (listener != null) {
      listener.cancel();
      listener = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    stopListen();
  }

  Widget renderLoading([Widget other]) {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CupertinoActivityIndicator(
            animating: true,
            radius: 10,
          ),
          Container(
            child: Text(
              '加载中...',
              style: TextStyle(fontSize: 14),
            ),
            margin: EdgeInsets.only(left: 10),
          )
        ],
      ),
    );
  }

  Widget renderScrollbar() {
    return Scrollbar(
      child: ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            color: Colors.grey,
            height: 1,
          );
        },
        controller: controller,
        itemCount: rows.length,
        itemBuilder: (BuildContext context, int index) {
          SongModel song = rows[index];
          Song item = Song(
            song: song,
            onClickSong: (SongModel song) async {
              PlayApi api = PlayApi();
              await api.batch(rows);

              if (widget.onClickSong != null) {
                await widget.onClickSong(song, index, rows);
              }

              Navigator.pushNamed(context, '/player', arguments: song); 
            },
            onClickActions: (SongModel song) => openActionPanel(song, index),
            key: Key('${song.type}~${song.id}'),
          );

          if (index == rows.length - 1 && !completed) {
            return Column(
              children: <Widget>[item, renderLoading()],
            );
          }

          return item;
        },
      ),
    );
  }

  openActionPanel(SongModel song, int index) async {
    List<SongAction> actions = await widget.actionsBuilder(song, index);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SongActionsPanel(
          actions: actions
              .map(
                (SongAction action) => SongAction(
                  icon: action.icon,
                  title: action.title,
                  onPressed: () {
                    Navigator.pop(context);
                    action.onPressed();
                  },
                ),
              )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return page == 0 && loading ? renderLoading() : renderScrollbar();
  }
}
