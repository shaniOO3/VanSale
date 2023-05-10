import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static late SharedPreferences _preferences;

  static const _keyIncludingVat = 'includingvat';
  static const _keyVibration = 'vibrationstate';
  static const _keyPData = 'profiledataexist';
  static const _keyUserId = 'userid';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setIncludingvat(bool state) async =>
      await _preferences.setBool(_keyIncludingVat, state);

  static bool getIncludingVat() =>
      _preferences.getBool(_keyIncludingVat) ?? false;

  static Future setVibrationState(bool state) async =>
      await _preferences.setBool(_keyVibration, state);

  static bool getVibrationState() =>
      _preferences.getBool(_keyVibration) ?? false;

  static Future setPData(bool state) async =>
      await _preferences.setBool(_keyPData, state);

  static bool getPData() => _preferences.getBool(_keyPData) ?? false;

  static Future setUserId(int id) async =>
      await _preferences.setInt(_keyUserId, id);

  static int getUserId() => _preferences.getInt(_keyUserId) ?? 0;
}
