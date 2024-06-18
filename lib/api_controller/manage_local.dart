import 'package:shared_preferences/shared_preferences.dart';

class ManageLocalData {
  static saveToLocal({
    required String key,
    required String value,
  }) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(key, value);
  }

  static Future<String?> getFromLocal(String key) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(key);
  }

}
