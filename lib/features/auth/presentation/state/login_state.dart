import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginState {
  const LoginState({
    this.useEmail = true,
    this.rememberMe = false,
    this.identity = '',
    this.password = '',
    this.showErrors = false,
  });

  final bool useEmail;
  final bool rememberMe;
  final String identity;
  final String password;
  final bool showErrors;

  bool get isValid => identity.trim().isNotEmpty && password.trim().isNotEmpty;

  bool get identityError => showErrors && identity.trim().isEmpty;
  bool get passwordError => showErrors && password.trim().isEmpty;

  LoginState copyWith({
    bool? useEmail,
    bool? rememberMe,
    String? identity,
    String? password,
    bool? showErrors,
  }) {
    return LoginState(
      useEmail: useEmail ?? this.useEmail,
      rememberMe: rememberMe ?? this.rememberMe,
      identity: identity ?? this.identity,
      password: password ?? this.password,
      showErrors: showErrors ?? this.showErrors,
    );
  }
}

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(const LoginState());

  void toggleMode(bool useEmail) {
    state = state.copyWith(useEmail: useEmail, identity: '', showErrors: false);
  }

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  void setIdentity(String value) {
    state = state.copyWith(identity: value);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  void showValidationErrors() {
    state = state.copyWith(showErrors: true);
  }
}

final loginProvider = StateNotifierProvider<LoginController, LoginState>(
  (ref) => LoginController(),
);
