import 'package:flutter/foundation.dart';

import 'SharedPreferencesManager.dart';

class PreferenceItem<T> extends ValueNotifier<T> {
  static final List<PreferenceItem> _allItems = [];

  final String key;
  final T defaultValue;

  PreferenceItem(this.key, this.defaultValue) : super(defaultValue) {
    _allItems.add(this);
    load();
  }

  void load() {
    final prefs = SharedPreferencesManager.sharedPreferences;
    if (prefs == null) return;

    Object? val = prefs.get(key);
    if (val != null) {
      if (T == double && val is int) {
        value = val.toDouble() as T;
      } else if (val is T) {
        value = val as T;
      }
    }
  }

  @override
  set value(T newValue) {
    super.value = newValue;
    final prefs = SharedPreferencesManager.sharedPreferences;
    if (prefs != null) {
      if (newValue is bool) {
        prefs.setBool(key, newValue);
      } else if (newValue is int) {
        prefs.setInt(key, newValue);
      } else if (newValue is double) {
        prefs.setDouble(key, newValue);
      } else if (newValue is String) {
        prefs.setString(key, newValue);
      }
    }
  }

  static void loadAll() {
    for (var item in _allItems) {
      item.load();
    }
  }
}
