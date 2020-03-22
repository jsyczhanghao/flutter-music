import 'dart:async';
import '../../libs/libs.dart';
import '../../configs/configs.dart';

class MGSearchApi {
  static const _SEARCH_URL =
      'http://m.music.migu.cn/migu/remoting/scr_search_tag?type=2&rows=10';
  static final _options = Options(
    headers: {
      'user-agent': MOBILE_UA,
    },
  );

  static Future<List> query(String word, int page) async {
    try {
      Response data = await Helper.fetch.get(
        _SEARCH_URL,
        options: _options,
        queryParameters: {'keyword': word, 'pgc': page},
      );

      return List.from(data.data['musics']).map((song) {
        return {
          'id': song['copyrightId'],
          'name': song['songName'],
          'type': Types.MG,
          'singers': song['singerName'].toString(),
        };
      }).toList();
    } catch (e) {
      return List<Map>();
    }
  }
}
