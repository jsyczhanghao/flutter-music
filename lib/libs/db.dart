import 'package:sqflite/sqflite.dart';
import './fs.dart';

export 'package:sqflite/sqflite.dart';

class DatabaseFactory {
  static Database _instance;

  static Future close() async {
    await _instance.close();
    _instance = null;
  }

  static Future<Database> getInstance() async {
    if (_instance == null) {
      String home = await Fs.root();
      String path = '$home/_.db';

      _instance = await openDatabase(
        path,
        version: 1,
        onCreate: (Database instance, int version) async {
          await instance.execute('''
            CREATE TABLE files (
              autoid INTEGER PRIMARY KEY AUTOINCREMENT,
              id TEXT NOT NULL,
              type INT NOT NULL,
              file TEXT,
              lrc TEXT,
              img TEXT,
              duration INT NOT NULL DEFAULT 0
            )
          ''');

          await instance
              .execute('CREATE UNIQUE INDEX file_idx ON files (id, type)');

          await instance.execute('''
            CREATE TABLE mys (
              autoid INTEGER PRIMARY KEY AUTOINCREMENT,
              id TEXT NOT NULL,
              type INT NOT NULL,
              name TEXT NOT NULL,
              singers TEXT,
              time TIMESTAMP NOT NULL DEFAULT current_timestamp
            )
          ''');

          await instance.execute('CREATE UNIQUE INDEX my_idx ON mys (id, type)');

          await instance.execute('''
            CREATE TABLE plays (
              autoid INTEGER PRIMARY KEY AUTOINCREMENT,
              id TEXT NOT NULL,
              type INT NOT NULL,
              name TEXT NOT NULL,
              singers TEXT,
              status INT NOT NULL DEFAULT 0,
              time TIMESTAMP NOT NULL DEFAULT current_timestamp
            )
          ''');

          await instance
              .execute('CREATE UNIQUE INDEX play_idx ON plays (id, type)');

          await instance.execute('''
            CREATE TABLE historys (
              autoid INTEGER PRIMARY KEY AUTOINCREMENT,
              id TEXT NOT NULL,
              type INT NOT NULL,
              name TEXT NOT NULL,
              singers TEXT,
              status INT NOT NULL DEFAULT 0,
              time TIMESTAMP NOT NULL DEFAULT current_timestamp
            )
          ''');

          await instance
              .execute('CREATE INDEX history_song_idx ON historys (id, type)');
        },
      );
    }

    return _instance;
  }
}
