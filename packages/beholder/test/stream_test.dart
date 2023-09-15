import 'package:flutter_test/flutter_test.dart';
import 'package:beholder/src/core.dart';

import 'utils.dart';

void main() {
  test("Computed doesn't rebuild if its stream is not listened", () async {
    final counter = ObservableState(0);
    final doubled = createComputed((watch) => watch(counter) * 2);
    final stream = doubled.computed.asStream();
    counter.value++;
    await ObservableScope.waitForUpdate();
    expect(doubled.rebuildCounter.value, equals(1));

    final subscription = stream.listen((event) {});
    await ObservableScope.waitForUpdate();
    counter.value++;
    await ObservableScope.waitForUpdate();
    expect(doubled.rebuildCounter.value, equals(2));

    subscription.cancel();
    counter.value++;
    await ObservableScope.waitForUpdate();
    expect(doubled.rebuildCounter.value, equals(2));
  });
}
