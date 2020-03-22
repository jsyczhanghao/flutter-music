import 'dart:convert';
import '../../libs/libs.dart';
import '../../configs/configs.dart';

class QQSearchApi {
  static const _SEARCH_URL =
      'https://c.y.qq.com/soso/fcgi-bin/search_for_qq_cp?format=json';
  static final _options = Options(headers: {
    'user-agent': MOBILE_UA,
    'referer': 'https://y.qq.com/m/index.html',
  });

  static Future<List> query(String word, int page) async {
    try {
      Response data = await Helper.fetch.get(
        _SEARCH_URL,
        options: _options,
        queryParameters: {'w': word, 'p': page},
      );

      Map res = jsonDecode(data.toString());

      if (res['code'] == 0) {
        return List.castFrom(res['data']['song']['list']).where((song) {
          return song['songmid'] != '';
        }).map((song) {
          return {
            'id': song['songmid'],
            'name': song['songname'],
            'type': Types.QQ,
            'singers': List.castFrom(song['singer']).map((singer) {
              return singer['name'].toString();
            }).toList().join('/'),
            'vip': song['isonly'] == 1,
          };
        }).toList();
      }

      return List<Map>();
    } catch (e) {
      return List<Map>();
    }
  }
}
