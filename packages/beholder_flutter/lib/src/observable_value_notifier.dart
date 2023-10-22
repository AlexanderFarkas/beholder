import 'package:beholder/beholder.dart';
import 'package:beholder_flutter/beholder_flutter.dart';
import 'package:flutter/widgets.dart';

typedef CreateNotifier<T> = T Function();

class ObservableNotifier<K, T extends ValueNotifier<K>>
    with ObservableStateProxyMixin<K> {
  ObservableNotifier(CreateNotifier<T> createNotifier)
      : notifier = createNotifier() {
    inner = RootObservableState(notifier.value);
    notifier.addListener(_listener);
  }

  final T notifier;

  @override
  late final RootObservableState<K> inner;

  @override
  bool setValue(K value) {
    final oldValue = notifier.value;
    notifier.value = value;
    return oldValue != value;
  }

  @override
  void dispose() {
    notifier.dispose();
    inner.dispose();
  }

  void _listener() {
    inner.value = notifier.value;
  }
}
