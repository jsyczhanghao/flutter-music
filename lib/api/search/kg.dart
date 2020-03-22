import 'dart:convert';
import '../../libs/libs.dart';
import '../../configs/configs.dart';

class KGSearchApi {
  static const _SEARCH_URL = 'http://songsearch.kugou.com/song_search_v2?callback=x&platform=WebFilter&pagesize=10';

  static Future<List> query(String word, int page) async {
    try {
      Response data = await Helper.fetch.get(
        _SEARCH_URL,
        queryParameters: {
          'keyword': word,
          'page': page,
        },
      );

      Map res =
          jsonDecode(data.toString().substring(2, data.toString().length - 2));

      if (res['status'] == 1) {
        return List.castFrom(res['data']['lists']).map((song) {
          return {
            'id': '${song['FileHash']}#${song['AlbumID']}#${song['ID']}',
            'name': song['SongName'],
            'type': Types.KG,
            'singers': song['SingerName'].toString(),
            'vip': song['AlbumPrivilege'] > 8,
          };
        }).toList();
      }

      return List<Map>();
    } catch (e) {
      return List<Map>();
    }
  }
}
