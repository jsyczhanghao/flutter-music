import '../../configs/configs.dart';
import './song.dart';
import './qq.dart';
import './kg.dart';
import './tt.dart';
import './mg.dart';

export '../../models/models.dart';
export './song.dart';

class SongApiFactory {
  static SongApi create(String id, int type) {
    SongApi instance;
    
    switch (type) {
      case Types.QQ:
        instance = QQSongApi(id);
        break;

      case Types.KG:
        instance = KGSongApi(id);
        break;

      case Types.TT:
        instance = TTSongApi(id);
        break;

      case Types.MG:
        instance = MGSongApi(id);
        break;
    }

    return instance;
  }
}