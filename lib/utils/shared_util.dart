import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils {
  final SharedPreferences? _prefs;
  static SharedPreferencesUtils? _instance;
  static const String kCurrentUser = 'current_user';
  SharedPreferencesUtils._(this._prefs);

  static Future<SharedPreferencesUtils?> getInstance() async {
    _instance ??=
        SharedPreferencesUtils._(await SharedPreferences.getInstance());
    return _instance;
  }

  SharedPreferences? get prefs => _prefs;

  // getSavedUser() {
  //   currentUser.value = Users.fromJSON(
  //       json.decode(_prefs?.get('current_user').toString() ?? ''));
  //   currentUser.value.isNewUser = false;
  // }
}
