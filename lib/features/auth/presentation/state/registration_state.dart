import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationState {
  const RegistrationState({
    this.useEmail = true,
    this.rememberMe = false,
    this.email = '',
    this.password = '',
    this.confirm = '',
    this.showErrors = false,
  });

  final bool useEmail;
  final bool rememberMe;
  final String email;
  final String password;
  final String confirm;
  final bool showErrors;

  bool get isValid =>
      email.trim().isNotEmpty &&
      password.trim().isNotEmpty &&
      confirm.trim().isNotEmpty;

  bool get emailError => showErrors && email.trim().isEmpty;
  bool get passwordError => showErrors && password.trim().isEmpty;
  bool get confirmError => showErrors && confirm.trim().isEmpty;

  RegistrationState copyWith({
    bool? useEmail,
    bool? rememberMe,
    String? email,
    String? password,
    String? confirm,
    bool? showErrors,
  }) {
    return RegistrationState(
      useEmail: useEmail ?? this.useEmail,
      rememberMe: rememberMe ?? this.rememberMe,
      email: email ?? this.email,
      password: password ?? this.password,
      confirm: confirm ?? this.confirm,
      showErrors: showErrors ?? this.showErrors,
    );
  }
}

class RegistrationController extends StateNotifier<RegistrationState> {
  RegistrationController() : super(const RegistrationState());

  void toggleMode(bool useEmail) {
    state = state.copyWith(useEmail: useEmail);
  }

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  void setConfirm(String value) {
    state = state.copyWith(confirm: value);
  }

  void showValidationErrors() {
    state = state.copyWith(showErrors: true);
  }
}

final registrationProvider =
    StateNotifierProvider<RegistrationController, RegistrationState>(
  (ref) => RegistrationController(),
);
