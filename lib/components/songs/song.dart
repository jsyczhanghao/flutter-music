import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../configs/configs.dart';
import '../../api/api.dart';

class Song extends StatelessWidget {
  final SongModel song;
  final Function(SongModel) onClickSong;
  final Function(SongModel) onClickActions;

  Song({this.song, this.onClickSong, this.onClickActions, key})
      : super(key: key);

  onClickName() {
    SongApi api = SongApiFactory.create(song.id, song.type);
    onClickSong(song);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              GestureDetector(
                child: Container(
                  width: 300,
                  child: Text(
                    song.name,
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ),
                onTap: onClickName,
              ),
              Container(
                height: 30,
                width: 30,
                child: IconButton(
                  padding: EdgeInsets.all(0),
                  icon: Icon(Icons.more_vert),
                  iconSize: 16,
                  onPressed: () => onClickActions(song),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  width: 250,
                  child: _renderSource(song.singers),
                ),
                _renderSource('by ${Types.values[song.type]}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Text _renderSource(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey,
      ),
    );
  }
}
