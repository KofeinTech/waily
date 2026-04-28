import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'local_storage.dart';

@LazySingleton(as: LocalStorage)
class LocalStorageImpl implements LocalStorage {
  LocalStorageImpl();

  SharedPreferences? _prefs;

  Future<SharedPreferences> _ensure() async =>
      _prefs ??= await SharedPreferences.getInstance();

  @override
  Future<String?> readString(String key) async => (await _ensure()).getString(key);

  @override
  Future<void> writeString(String key, String value) async {
    final prefs = await _ensure();
    await prefs.setString(key, value);
  }

  @override
  Future<bool?> readBool(String key) async => (await _ensure()).getBool(key);

  @override
  Future<void> writeBool(String key, bool value) async {
    final prefs = await _ensure();
    await prefs.setBool(key, value);
  }

  @override
  Future<int?> readInt(String key) async => (await _ensure()).getInt(key);

  @override
  Future<void> writeInt(String key, int value) async {
    final prefs = await _ensure();
    await prefs.setInt(key, value);
  }

  @override
  Future<void> remove(String key) async {
    final prefs = await _ensure();
    await prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    final prefs = await _ensure();
    await prefs.clear();
  }
}
