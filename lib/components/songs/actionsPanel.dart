import 'package:flutter/material.dart';
import './action.dart';

export './action.dart';

class SongActionsPanel extends StatelessWidget {
  final List<SongAction> actions;
  static const double _PER_HEIGHT = 50;

  SongActionsPanel({this.actions});

  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).padding.bottom;
    
    return Container(
      padding: EdgeInsets.only(bottom: bottom),
      height: actions.length * _PER_HEIGHT + bottom,
      child: Column(children: actions.map((SongAction action) {
        return _SongActionContainer(action: action,);
      }).toList()),
    );
  }
}

class _SongActionContainer extends StatelessWidget {
  final SongAction action;

  _SongActionContainer({this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              action.icon.icon,
              color: action.icon.color,
              size: 18,
            ),
            Container(
              margin: EdgeInsets.only(left: 10),
              child: Text(
                action.title,
                style: TextStyle(fontSize: 18),
              ),
            )
          ],
        ),
        height: 49.5,
      ),
      onTap: action.onPressed,
    );
  }
}