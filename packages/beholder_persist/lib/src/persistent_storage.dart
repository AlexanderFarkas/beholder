abstract class PersistentStorage {
  void write<TValue>(String key, TValue value);
  TValue? read<TValue>(String key);
}
