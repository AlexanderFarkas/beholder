import 'package:beholder/beholder.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  setUp(() {
    ObservableContext.reset();
  });

  test("Computed doesn't rebuild if its stream is not listened", () async {
    final counter = ObservableState(0);
    final doubled = createComputed((watch) => watch(counter) * 2);
    final stream = doubled.computed.asStream();
    counter.value++;
    await ObservableContext.pump();
    expect(doubled.rebuildCounter.value, equals(1));

    final subscription = stream.listen((event) {});
    await ObservableContext.pump();
    counter.value++;
    await ObservableContext.pump();
    expect(doubled.rebuildCounter.value, equals(2));

    subscription.cancel();
    counter.value++;
    await ObservableContext.pump();
    expect(doubled.rebuildCounter.value, equals(2));
  });
}
