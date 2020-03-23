import 'dart:async';

import '../../models/models.dart';
import './mg.dart';
import './qq.dart';
import './kg.dart';
import './tt.dart';

class SearchApi {
  static Future<List<SongModel>> query(String word, [int page = 1]) {
    if (word == '') return null;

    return Future.wait([
      MGSearchApi.query(word, page),
      KGSearchApi.query(word, page),
      QQSearchApi.query(word, page),
      TTSearchApi.query(word, page),
    ]).then((List<List> arr) {
      List list = [], temp = [];
      int i = 0;

      do {
        list.addAll(temp = arr.fold([], (List a, b) {
          return b.length > i ? (a..add(b[i])) : a;
        }));
        i++;
      } while (temp.length > 0);

      return list.where((song) {
        return song['vip'] != true;
      }).map((song) {
        return SongModel.fromJson(song);
      }).toList();
    });
  }
}
