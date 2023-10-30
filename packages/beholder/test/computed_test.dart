import 'package:beholder/beholder.dart';
import 'package:test/test.dart';

import 'utils.dart';

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

  test("Consecutive", () async {
    final obs = ObservableState(1);
    final (computed: computed1, rebuildCounter: rebuildCounter1) =
        createComputed((watch) => watch(obs) * 2);
    final (computed: computed2, rebuildCounter: rebuildCounter2) =
        createComputed((watch) => watch(computed1) * 2);
    final (computed: computed3, rebuildCounter: rebuildCounter3) =
        createComputed((watch) => watch(computed2) * 2);

    computed3.listen((previous, current) {});
    expect(
      [rebuildCounter1.value, rebuildCounter2.value, rebuildCounter3.value],
      equals([1, 1, 1]),
    );
    obs.value = 3;
    await ObservableContext.pump();
    expect(
      [rebuildCounter1.value, rebuildCounter2.value, rebuildCounter3.value],
      equals([2, 2, 2]),
    );
  });

  test("_", () async {
    final obs = ObservableState(1);
    final (:computed, :rebuildCounter) = createComputed((watch) => watch(obs) * 2);

    computed.value;
    for (var i = 0; i < 5; i++) {
      expect(rebuildCounter.value, equals(1));
    }
    obs.value = 3;
    computed.value;
    for (var i = 0; i < 5; i++) {
      expect(rebuildCounter.value, equals(2));
    }
  });

  test("_d", () async {
    final obs = ObservableState(1);
    final (:computed, :rebuildCounter) = createComputed((watch) => watch(obs) * 2);

    computed.listen((previous, current) {});
    for (var i = 0; i < 5; i++) {
      expect(rebuildCounter.value, equals(1));
    }
    obs.value = 3;
    await ObservableContext.pump();
    for (var i = 0; i < 5; i++) {
      expect(rebuildCounter.value, equals(2));
    }
  });

  test("Case 1", () async {
    final textField = RootObservableState("");
    final textFieldError =
        ObservableComputed((watch) => watch(textField).isEmpty ? "Field is empty" : null);
    final checked = RootObservableState(false);

    bool isValidInner = false;
    final isValid = ObservableComputed((watch) => watch(checked) && watch(textFieldError) == null);
    isValid.listen((previous, current) {
      isValidInner = current;
    });

    expect(textFieldError.value, equals("Field is empty"));
    await ObservableContext.pump();
    expect(isValidInner, equals(false));

    textField.value = "some text";
    await ObservableContext.pump();
    expect(textFieldError.value, equals(null));
    expect(isValidInner, equals(false));

    checked.value = true;
    await ObservableContext.pump();
    expect(textFieldError.value, equals(null));
    expect(isValidInner, equals(true));

    checked.value = false;
    await ObservableContext.pump();
    expect(textFieldError.value, equals(null));
    expect(isValidInner, equals(false));

    textField.value = "";
    await ObservableContext.pump();
    expect(textFieldError.value, equals("Field is empty"));
    expect(isValidInner, equals(false));
  });
}
