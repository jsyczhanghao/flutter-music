import '../libs/libs.dart';
import '../configs/configs.dart';
import '../models/models.dart';
import './song/factory.dart';

class HistoryApi {
  static HistoryApi _instance;

  factory HistoryApi() {
    if (_instance == null) {
      _instance = HistoryApi._internal();
    }

    return _instance;
  }

  HistoryApi._internal();

  Future<List<SongModel>> list({int limit = 200}) async {
    Database database = await DatabaseFactory.getInstance();
    List<Map> res = await database.rawQuery(
      'SELECT * FROM ${Tables.HISTORYS} ORDER BY autoid DESC LIMIT $limit',
    );

    return res.map((song) {
      return SongModel.fromJson((song));
    }).toList();
  }

  Future<SongModel> lastest() async {
    List<SongModel> songs = await list(limit: 1);
    return songs.length == 1 ? songs.first : null;
  }

  Future add(SongModel song) async {
    await clear();
    Database database = await DatabaseFactory.getInstance();
    await database.insert(Tables.HISTORYS, {
      'id': song.id,
      'type': song.type,
      'name': song.name,
      'singers': song.singers,
      'status': PlayStatus.PLAY,
    });
  }

  Future<SongModel> forward() async {
    Database database = await DatabaseFactory.getInstance();
    List res = await database.rawQuery(
      '''
        SELECT * FROM ${Tables.HISTORYS} 
        WHERE autoid > (
          SELECT autoid FROM ${Tables.HISTORYS} WHERE status = ?
        ) 
        ORDER BY autoid LIMIT 1
      ''',
      [PlayStatus.PLAY],
    );

    if (res.length == 1) {
      await play(res[0]['autoid']);
      return SongModel.fromJson(res[0]);
    }
  }

  Future<SongModel> back() async {
    Database database = await DatabaseFactory.getInstance();
    List res = await database.rawQuery(
      '''
        SELECT A.* FROM ${Tables.HISTORYS} as A
        INNER JOIN ${Tables.PLAYS} as B USING (id, type)
        WHERE 
          A.autoid < (
            SELECT autoid FROM ${Tables.HISTORYS} WHERE status = ?
          ) 
          AND
          A.time >= (
            SELECT time FROM ${Tables.PLAYS} LIMIT 1
          )
        ORDER BY A.autoid DESC LIMIT 1
      ''',
      [PlayStatus.PLAY],
    );

    if (res.length == 1) {
      await play(res[0]['autoid']);
      return SongModel.fromJson(res[0]);
    }
  }

  Future play(int autoid) async {
    await clear();
    Database database = await DatabaseFactory.getInstance();
    await database.update(Tables.HISTORYS, {
      'status': PlayStatus.PLAY,
    }, where: 'autoid = ?', whereArgs: [autoid]);
  }

  Future clear() async {
    Database database = await DatabaseFactory.getInstance();
    await database.update(Tables.HISTORYS, {
      'status': PlayStatus.STOP,
    });
  }
}
