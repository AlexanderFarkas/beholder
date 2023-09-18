import 'package:meta/meta.dart';

abstract class PersistentStorage<TSerialized extends Object?> {
  @protected
  final customSerializers = <Type, CustomSerializer<dynamic, TSerialized>>{};

  void registerType<TDeserialized>({
    required TSerialized Function(TDeserialized value) serialize,
    required TDeserialized Function(TSerialized value) deserialize,
  }) {
    customSerializers[TDeserialized] = CustomSerializer<TDeserialized, TSerialized>(
      serialize: serialize,
      deserialize: deserialize,
    );
  }

  @protected
  CustomSerializer<TDeserialized, TSerialized>? getSerializer<TDeserialized>() {
    return customSerializers[TDeserialized] as CustomSerializer<TDeserialized, TSerialized>?;
  }

  void write<TValue>(String key, TValue value);

  TValue? read<TValue>(String key);
}

class CustomSerializer<TDeserialized, TSerialized> {
  final TSerialized Function(TDeserialized value) serialize;
  final TDeserialized Function(TSerialized value) deserialize;

  CustomSerializer({required this.serialize, required this.deserialize});
}
