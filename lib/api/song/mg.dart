import 'dart:convert';
import '../../configs/configs.dart';
import '../../libs/libs.dart';
import '../../models/models.dart';
import './song.dart';

class MGSongApi extends SongApi {
  final int type = Types.MG;
  static const String _URL = 'http://m.music.migu.cn/migu/remoting/cms_detail_tag?cpid=';

  MGSongApi(String id) : super(id);

  Future<SongSourceModel> getOnlineInfo() async {
    try {
      return Helper.fetch.get('$_URL$id', options: Options(
        headers: {
          'User-Agent': MOBILE_UA,
        }
      )).then((Response data) {
        Map res = Map.from(data.data['data']);
        return SongSourceModel(
          file: res['listenUrl'],
          lrc: res['lyricLrc'],
          img: res['picS'] ?? '',
        );
      });
    } catch (e) {
      return SongSourceModel();
    }
  }
}