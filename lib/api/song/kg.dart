import 'dart:convert';
import '../../configs/configs.dart';
import '../../libs/libs.dart';
import '../../models/models.dart';
import './song.dart';



class KGSongApi extends SongApi {
  final int type = Types.KG;
  static const String _INFO_URL = 'https://wwwapi.kugou.com/yy/index.php?r=play/getdata&callback=x';
  
  KGSongApi(String id) : super(id);

  Future<SongSourceModel> getOnlineInfo() async {
    try {
      List ids = id.split('#');

      Response data = await Helper.fetch.get(
        '$_INFO_URL',
        options: Options(
          headers: {
            'cookie': 'kg_mid=$id'
          },
        ),
        queryParameters: {
          'hash': ids[0],
          'album_id': ids[1],
        }
      );

      Map res =
          jsonDecode(data.toString().substring(2, data.toString().length - 2));

      if (res['status'] == 1) {
        Map data = res['data'];
        return SongSourceModel(file: data['play_url'], img: data['img'], lrc: data['lyrics'], duration: data['timelength']);
      }
    } catch (e) {
      
    }

    return SongSourceModel();
  }
}
