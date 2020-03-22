import 'dart:async';

import '../../models/models.dart';
import './mg.dart';
import './qq.dart';
import './kg.dart';
import './tt.dart';

class SearchApi {
  static Stream<List<SongModel>> query(String word, [int page = 1]) {
    if (word == '') return null;

    return Stream.fromFutures([
      MGSearchApi.query(word, page),
      KGSearchApi.query(word, page),
      QQSearchApi.query(word, page),
      TTSearchApi.query(word, page),
    ]).map((List list) {
      return list.where((song) {
        return song['vip'] != true;
      }).map((song){
        return SongModel.fromJson(song);
      }).toList();
    });
  }
}
