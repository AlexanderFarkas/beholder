import 'package:warden/warden.dart';

class LoginFormVm extends ViewModel with FormMixin {
  late final username = field(
    value: '',
    validate: (value) => value.length > 8 ? null : 'Username must be at least 8 characters long',
  );

  late final password = field(
    value: '',
    validate: (value) => value.length > 8 ? null : 'Password must be at least 8 characters long',
  );

  late final repeatPassword = field(
    value: '',
    computeError: (watch, state) {
      if (watch(password) != watch(state.value)) {
        return 'Passwords do not match';
      }
      return null;
    },
  );

  late final wasEverSubmitted = state(false);
  void submit() async {
    wasEverSubmitted.value = true;
    if (isValid.value) {
      username.error.value = "Username is already taken";
      print("Success");
    } else {
      print("Failure");
    }
  }

  @override
  String? errorInterceptor<T>(Watch watch, FieldState<T> state, String? error) {
    if (watch(wasEverSubmitted) || watch(state.wasEverUnfocused)) {
      return error;
    }

    return null;
  }
}
