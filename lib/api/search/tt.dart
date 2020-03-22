import 'dart:convert';
import '../../libs/libs.dart';
import '../../configs/configs.dart';

class TTSearchApi {
  static const _SEARCH_URL = 'http://music.taihe.com/search';
  static const _SIZE = 20;
  static final _options = Options(headers: {
    'Referer': 'http://music.taihe.com/',
  });
  static final _songReg =
      RegExp(r"data-songitem\s*=\s*'([^']+)(?:(?!song-message-gray)[\s\S])+?>");
  static final _ignoreReg = RegExp(r'&lt;(?:\\\/)?em&gt;');

  static Future<List> query(String word, int page) async {
    try {
      Response data = await Helper.fetch.get(
        _SEARCH_URL,
        options: _options,
        queryParameters: {
          'key': word,
          'size': _SIZE,
          'start': (page - 1) * _SIZE
        },
      );

      Map<String, bool> hash = {};
      List<Map<String, dynamic>> arr = List<Map<String, dynamic>>();

      _songReg.allMatches(data.data).forEach((Match m) {
        Map song = jsonDecode(
          m[1].toString().replaceAll('&quot;', '"').replaceAll(_ignoreReg, ''),
        );
        String id = song['songItem']['sid'].toString();

        if (hash[id] == null) {
          hash[id] = true;
          arr.add({
            'id': id,
            'type': Types.TT,
            'name': song['songItem']['sname'],
            'singers': song['songItem']['author'].toString(),
          });
        }
      });

      return arr;
    } catch (e) {
      return List<Map>();
    }
  }
}
