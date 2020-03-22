import '../libs/libs.dart';
import '../models/models.dart';
import '../configs/configs.dart';
import './song/factory.dart';

class UserApi {
  static const _PAGESIZE = 1000;
  static UserApi _instance;

  factory UserApi() {
    if (_instance == null) {
      _instance = UserApi._internal();
    }

    return _instance;
  }

  UserApi._internal();

  Future collect(SongModel song) async {
    Database database = await DatabaseFactory.getInstance();
    await database.insert(Tables.MYS, {
      'id': song.id,
      'type': song.type,
      'name': song.name,
      'singers': song.singers,
    });
  }

  Future batch(List<SongModel> songs) async {
    Database database = await DatabaseFactory.getInstance();
    await database.transaction((tx) async {
      Batch batch = tx.batch();

      songs.forEach((song) {
        batch.execute(
          'REPLACE INTO ${Tables.MYS} VALUES(?, ?, ?, ?, ?, current_timestamp)',
          [null, song.id, song.type, song.name, song.singers, null],
        );
      });

      await batch.commit();
    });
  }

  Future uncollect(SongModel song) async {
    Database database = await DatabaseFactory.getInstance();
    await database.delete(Tables.MYS,
        where: 'id = ? AND type = ?', whereArgs: [song.id, song.type]);
  }

  Future<List<SongModel>> collects([int page = 1]) async {
    Database database = await DatabaseFactory.getInstance();
    List<Map> list = await database.rawQuery(
        'SELECT * FROM ${Tables.MYS} ORDER BY time DESC LIMIT $_PAGESIZE OFFSET ${_PAGESIZE * (page - 1)}');

    return list.map((song) {
      return SongModel.fromJson(Map.from(song));
    }).toList();
  }
}
