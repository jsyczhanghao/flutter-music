import '../../configs/configs.dart';
import '../../libs/libs.dart';
import '../../models/models.dart';
import './song.dart';

class TTSongApi extends SongApi {
  final int type = Types.TT;
  static const String _INFO_URL =
      'http://musicapi.taihe.com/v1/restserver/ting?format=json&from=webapp_music&method=baidu.ting.song.playAAC&songid=';
  static const String _LRC_PR_URL =
      'http://music.taihe.com/data/tingapi/v1/restserver/ting?method=baidu.ting.song.baseInfo&from=web&songid=';
  static const String _REAL_LRC_URL =
      'http://music.taihe.com/data/song/lrc?lrc_link=';

  TTSongApi(String id) : super(id);

  Future<SongSourceModel> getOnlineInfo() async {
    List res = await Future.wait([getOnlineLrc(), getPlayInfo()]);
    return SongSourceModel(
        lrc: res[0], file: res[1]['file'], img: res[1]['img'], duration: res[1]['duration']);
  }

  Future<Map> getPlayInfo() async {
    try {
      Response data = await Helper.fetch.get('$_INFO_URL$id');
      Map res = Map.from(data.data);

      if (res['bitrate'] != null) {
        return {
          'file': res['bitrate']['file_link'],
          'img': res['songinfo']['pic_radio'],
          'duration': res['bitrate']['file_duration'] * 1000,
        };
      }
    } catch (e) {}
    
    return Map();
  }

  Future<String> getOnlineLrc() async {
    try {
      return Helper.fetch.get('$_LRC_PR_URL$id').then((Response data) {
        Map res = Map.from(data.data);
        String url = res['content']['lrclink'];

        if (url != null) {
          return Helper.fetch.get('$_REAL_LRC_URL$url').then((Response data) {
            return data.data['content'];
          });
        }

        return '';
      });
    } catch (e) {
      return '';
    }
  }
}
