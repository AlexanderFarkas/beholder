import 'package:beholder/beholder.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    ObservableContext.reset();
  });

  test("Computed tracks changes in all observables", () async {
    final (counter1, counter2, counter3) = (
      RootObservableState(1),
      RootObservableState(2),
      RootObservableState(3),
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
    await ObservableContext.pump();
    expect(arr.value, equals([2, 4, 8]));
  });
}
