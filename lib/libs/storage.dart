import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static SharedPreferences sp;

  static Future<void> init() async {
    sp = await SharedPreferences.getInstance();
  }

  static void set(String key, [dynamic value]) async {
    switch (value.runtimeType) {
      case bool:
        sp.setBool(key, value);
        break;

      case int:
        sp.setInt(key, value);
        break;

      case double:
        sp.setDouble(key, value);
        break;

      default:
        sp.setString(key, value.toString());
    }
  }

  static dynamic get(String key) {
    return sp.get(key);
  }
}
