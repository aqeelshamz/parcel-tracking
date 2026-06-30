import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around [SharedPreferences]. Keep raw prefs calls out of the UI.
///
/// Call [init] once in `main()` before `runApp`.
class StorageService {
  StorageService._();

  static late SharedPreferences _prefs;

  // Key constants — add new persisted values here.
  static const String kAuthToken = 'auth_token';
  static const String kThemeMode = 'theme_mode';
  static const String kShipments = 'shipments';
  static const String kSeeded = 'seeded_v1';
  static const String kNotifications = 'notifications_enabled';

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? getString(String key) => _prefs.getString(key);

  static Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  static bool getBool(String key, {bool defaultValue = false}) =>
      _prefs.getBool(key) ?? defaultValue;

  static Future<void> setBool(String key, bool value) =>
      _prefs.setBool(key, value);

  static Future<void> remove(String key) => _prefs.remove(key);
}
