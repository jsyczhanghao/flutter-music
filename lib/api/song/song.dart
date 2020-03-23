import 'dart:io';
import '../../libs/libs.dart';
import '../../configs/configs.dart';
import '../../models/models.dart';

abstract class SongApi {
  final String id;
  final int type = -1;
  static final RegExp _extRegExp = RegExp(r'\.[^\.\?\@\#]+(?=\?|@|$)');

  SongApi(this.id);

  Future<bool> isCollected() async {
    Database database = await DatabaseFactory.getInstance();
    List list = await database.rawQuery(
      'SELECT * FROM ${Tables.MYS} WHERE id = ? AND type = ? LIMIT 1',
      [id, type],
    );

    return list.length == 1;
  }

  Future<SongSourceModel> source({bool download = true}) async {
    Database database = await DatabaseFactory.getInstance();
    List list = await database.rawQuery(
      'SELECT * FROM ${Tables.FILES} WHERE id =? AND type = ? LIMIT 1',
      [id, type],
    );

    if (list.length == 1) {
      SongSourceModel model = SongSourceModel.fromJson(list.first);
      Fs file = Fs(model.file);
      bool exists = await file.exists();

      if (exists) {
        return model;
      }
    }

    if (download) return await cache();
    return null;
  }

  Future<SongSourceModel> cache() async {
    SongSourceModel model = await getOnlineInfo();
    bool collected = await isCollected();
    print(model.file);
    if (model.file == null) {
      return null;
    }

    String ext = _extRegExp.stringMatch(model.file);
    String prefix = '${collected ? "song" : "cache"}/$type@$id';

    List<dynamic> res = await Future.wait([
      Future<dynamic>(() async {
        String filename = '$prefix$ext';
        File file = await Fs.file(filename, try2create: true);

        try {
          await Helper.fetch.download(model.file, file.path);
          return filename;
        } catch (e) {
          return false;
        }
      }),
      Future<dynamic>(() async {
        try {
          String imgFilename = '$prefix${_extRegExp.stringMatch(model.img)}';
          File img = await Fs.file(imgFilename, try2create: true);
          await Helper.fetch.download(model.img, img.path);
          return imgFilename;
        } catch (e) {
          return '';
        }
      }),
      Future<String>(() async {
        Fs lrc = Fs('$prefix.lrc');
        await lrc.write(_washLrc(model.lrc));
        return lrc.filename;
      }),
    ]);

    if (res[0] == false) {
      return null;
    }

    Database database = await DatabaseFactory.getInstance();
    await database.execute(
      'REPLACE INTO ${Tables.FILES} VALUES(?, ?, ?, ?, ?, ?, ?)',
      [null, id, type, res[0], res[2], res[1], model.duration],
    );

    return SongSourceModel(
      id: id,
      type: type,
      file: res[0],
      lrc: res[2],
      img: res[1],
      duration: model.duration,
    );
  }

  Future<SongSourceModel> getOnlineInfo();

  static String _washLrc(String lrc) {
    if (lrc == '' || lrc == null) return '';

    return lrc
        .split(RegExp(r'[\r\n]'))
        .where((String line) {
          return line.indexOf(RegExp(r'\[\d')) == 0;
        })
        .toList()
        .join('\r\n');
  }
}
