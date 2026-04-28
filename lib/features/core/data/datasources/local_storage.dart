abstract class LocalStorage {
  Future<String?> readString(String key);
  Future<void> writeString(String key, String value);

  Future<bool?> readBool(String key);
  Future<void> writeBool(String key, bool value);

  Future<int?> readInt(String key);
  Future<void> writeInt(String key, int value);

  Future<void> remove(String key);
  Future<void> clear();
}
