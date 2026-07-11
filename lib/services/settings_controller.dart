import 'package:flutter/foundation.dart';
import '../models/settings.dart';
import 'storage.dart';

/// App-wide settings, persisted to SharedPreferences on every change —
/// mirrors the web app's `settings`/loadSettings()/saveSettings() globals.
class SettingsController extends ChangeNotifier {
  static const _storageKey = "readstars-settings";

  Settings _settings = Settings.defaults();
  Settings get settings => _settings;

  void load() {
    final json = Storage.getJson(_storageKey);
    _settings = json != null ? Settings.fromJson(json) : Settings.defaults();
    notifyListeners();
  }

  void _save() {
    Storage.setJson(_storageKey, _settings.toJson());
  }

  /// Runs [mutator] on the current settings, persists, and notifies —
  /// mirrors the pattern of "mutate settings.x then call refreshSetup()".
  void update(void Function(Settings s) mutator) {
    mutator(_settings);
    _save();
    notifyListeners();
  }
}
