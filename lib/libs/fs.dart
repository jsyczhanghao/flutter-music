import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class Fs {
  final String filename;

  Fs(this.filename);

  Future<dynamic> readJson([dynamic def]) async {
    String content = await read();

    if (content != null && content != '') {
      return jsonDecode(content);
    }

    return def;
  }

  Future<void> writeJson(dynamic json) async {
    await write(jsonEncode(json));
  }

  Future<String> read([dynamic def]) async {
    try {
      File file = await Fs.file(filename);
      return await file.readAsString();
    } on FileSystemException {
      return def;
    }
  }

  Future<void> write(String content) async {
    File file = await Fs.file(filename, try2create: true);
    await file.writeAsString(content);
  }

  static Future<String> root() async {
    return (await getApplicationDocumentsDirectory()).path;
  }

  Future<bool> exists() async {
    File file = await Fs.file(filename);
    return await file.exists();
  }

  static Future<File> file(path, {try2create: false}) async {
    String home = await Fs.root(); 
    File file = new File('$home/$path');

    if (try2create) {
      try {
        await file.create(recursive: true);
      } catch (e) {}
    }

    return file;
  }

  static Future<Directory> directory(path, {try2create: false}) async {
    String home = await Fs.root();
    Directory directory = new Directory('$home/$path');

    if (try2create) {
      try {
        await directory.create(recursive: true);
      } catch (e) {}
    }

    return directory;
  }
}