import 'package:flutter_test/flutter_test.dart';
import 'package:beholder/src/core.dart';
import 'package:beholder/beholder.dart';

import 'utils.dart';

void main() {
  test("Computed tracks changes in all observables", () async {
    final (counter1, counter2, counter3) = (
      ObservableState(1),
      ObservableState(2),
      ObservableState(3),
    );

    final arr = ObservableComputed((watch) => [
          watch(counter1),
          watch(counter2),
          watch(counter3),
        ]);

    expect(arr.value, equals([1, 2, 3]));
    counter1.value = 2;
    counter2.value = 4;
    counter3.value = 8;
    await ObservableScope.waitForUpdate();
    expect(arr.value, equals([2, 4, 8]));
  });
}
