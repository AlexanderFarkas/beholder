import 'package:beholder/beholder.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  setUp(() {
    ObservableScope.reset();
  });

  test("Computed doesn't rebuild if its stream is not listened", () async {
    final counter = ObservableState(0);
    final doubled = createComputed((watch) => watch(counter) * 2);
    final stream = doubled.computed.asStream();
    counter.value++;
    await ObservableScope.pump();
    expect(doubled.rebuildCounter.value, equals(1));

    final subscription = stream.listen((event) {});
    await ObservableScope.pump();
    counter.value++;
    await ObservableScope.pump();
    expect(doubled.rebuildCounter.value, equals(2));

    subscription.cancel();
    counter.value++;
    await ObservableScope.pump();
    expect(doubled.rebuildCounter.value, equals(2));
  });
}
