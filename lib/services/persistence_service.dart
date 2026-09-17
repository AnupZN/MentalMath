import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/progress_data.dart';

class PersistenceService {
  final SharedPreferences _prefs;
  
  static const _settingsKey = 'app_settings';
  static const _progressKey = 'app_progress';

  PersistenceService(this._prefs);

  void saveSettings(AppSettings settings) {
    _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  AppSettings loadSettings() {
    final str = _prefs.getString(_settingsKey);
    if (str != null) {
      try {
        return AppSettings.fromJson(jsonDecode(str) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const AppSettings();
  }

  void saveProgressData(ProgressData data) {
    _prefs.setString(_progressKey, jsonEncode(data.toJson()));
  }

  ProgressData loadProgressData() {
    final str = _prefs.getString(_progressKey);
    if (str != null) {
      try {
        return ProgressData.fromJson(jsonDecode(str) as Map<String, dynamic>);
      } catch (_) {}
    }
    return const ProgressData();
  }
}