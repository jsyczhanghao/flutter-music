import '../libs/libs.dart';
import '../configs/configs.dart';
import '../models/models.dart';
import './song/factory.dart';
import './history.dart';

class PlayApi {
  static PlayApi _instance;

  factory PlayApi() {
    if (_instance == null) {
      _instance = PlayApi._internal();
    }

    return _instance;
  }

  PlayApi._internal();

  Future<List> test() async {
    Database database = await DatabaseFactory.getInstance();
    return await database.rawQuery(
      'SELECT * FROM ${Tables.PLAYS} WHERE autoid > 100000 OR autoid > 0'
    );
  }

  Future add(SongModel song) async {
    Database database = await DatabaseFactory.getInstance();
    await database.execute(
      'REPLACE INTO ${Tables.PLAYS} VALUES(?, ?, ?, ?, ?, ?, current_timestamp)',
      [null, song.id, song.type, song.name, song.singers, null],
    );
  }

  Future del(SongModel song) async {
    Database database = await DatabaseFactory.getInstance();
    await database.delete(
      Tables.PLAYS,
      where: 'id = ? AND type = ?',
      whereArgs: [song.id, song.type],
    );
  }

  Future clear() async {
    Database database = await DatabaseFactory.getInstance();
    await database.delete(Tables.PLAYS);
  }

  Future batch(List<SongModel> songs) async {
    await clear();
    list();

    Database database = await DatabaseFactory.getInstance();
    await database.transaction((tx) async {
      Batch batch = tx.batch();
      
      songs.forEach((song) {
        batch.insert(Tables.PLAYS, {
          'id': song.id,
          'type': song.type,
          'name': song.name,
          'singers': song.singers,
        });
      });

      await batch.commit();
    });
  }

  Future<List<SongModel>> list() async {
    Database database = await DatabaseFactory.getInstance();
    List<Map> list = await database
        .rawQuery('SELECT * FROM ${Tables.PLAYS} ORDER BY time DESC');
    return list.map((song) {
      return SongModel.fromJson(song);
    }).toList();
  }

  Future stop() async {
    Database database = await DatabaseFactory.getInstance();
    await database.update(Tables.PLAYS, {
      'status': PlayStatus.STOP
    });
  }

  Future play(SongModel song) async {
    await _play(song);
    await HistoryApi().add(song);
  }

  Future _play(SongModel song) async {
    await stop();
    Database database = await DatabaseFactory.getInstance();
    await database.update(Tables.PLAYS, {
      'status': PlayStatus.PLAY,
    }, where: 'id = ? AND type = ?', whereArgs: [song.id, song.type]);
  }

  Future<SongModel> getPlaying() async {
    Database database = await DatabaseFactory.getInstance();
    List<Map> res = await database.rawQuery(
      'SELECT * FROM ${Tables.PLAYS} WHERE status = ? LIMIT 1',
      [PlayStatus.PLAY],
    );

    return res.length == 1 ? SongModel.fromJson(res.first) : null;
  }

  Future<SongModel> next({bool random: false, bool single: false}) async {
    SongModel song;

    if (single == true) {
      song = await getPlaying();
      return song != null ? song : await next(random: random);
    }

    song = await HistoryApi().forward();

    if (song != null) {
      await _play(song);
    } else {
      String sql;

      if (random) {
        sql =
            'SELECT * FROM ${Tables.PLAYS} WHERE status != ? ORDER BY RANDOM() LIMIT 1';
      } else {
        sql =
            'SELECT * FROM ${Tables.PLAYS} WHERE autoid > (SELECT autoid FROM ${Tables.PLAYS} WHERE status = ?) ORDER BY autoid LIMIT 1';
      }

      Database database = await DatabaseFactory.getInstance();
      List res = await database.rawQuery(sql, [PlayStatus.PLAY]);
      song = res.length == 1
          ? SongModel.fromJson(res.first)
          : random ? (await getPlaying()) : (await header());
      await play(song);
    }

    return song;
  }

  Future previous({bool random: false, bool single: false}) async {
    SongModel song;

    if (single == true) {
      song = await getPlaying();
      return song != null ? song : await previous(random: random);
    }

    song = await HistoryApi().back();
    
    if (song != null) {
      await _play(song);
    } else {
      song = random ? await next(random: true) : await header(last: true);
      await play(song);
    }

    return song;
  }

  Future header({bool last = false}) async {
    Database database = await DatabaseFactory.getInstance();
    List<Map> res = await database.rawQuery(
      'SELECT * FROM ${Tables.PLAYS} ORDER BY autoid ${last ? 'DESC' : 'ASC'} LIMIT 1',
    );

    return res.length == 1 ? SongModel.fromJson(res.first) : null;
  }
}
