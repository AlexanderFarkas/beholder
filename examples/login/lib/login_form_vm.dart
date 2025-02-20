import 'package:beholder/beholder.dart';
import 'package:beholder_form/beholder_form.dart';

class LoginFormVm extends ViewModel with FormMixin {
  late final username = textField(
    '',
    validate: (value) => value.length > 8 //
        ? null
        : 'Username must be at least 8 characters long',
  );

  late final password = textField(
    '',
    validate: (value) => value.length > 8 //
        ? null
        : 'Password must be at least 8 characters long',
  );

  late final repeatPassword = textField(
    '',
    computeError: (watch, value) {
      if (watch(password) != value) {
        return 'Passwords do not match';
      }
      return null;
    },
  );

  late final wasEverSubmitted = state(false);
  void submit() async {
    wasEverSubmitted.value = true;
    if (isValid) {
      username.error.value = "Username is already taken";
      print("Success");
    } else {
      print("Failure");
    }
  }

  late final fields = [username, password, repeatPassword];
  late final isSubmittable = computed((watch) {
    return fields.every((e) => watch(e.displayError) == null);
  });

  bool get isValid => fields.every((element) => element.error.value == null);

  @override
  String? interceptDisplayError<T>(
    Watch watch,
    Field<T> state,
    ComputeDisplayError<T> inner,
  ) {
    if (watch(wasEverSubmitted) || watch(state.wasEverUnfocused)) {
      return inner(watch, state);
    }

    return null;
  }
}
