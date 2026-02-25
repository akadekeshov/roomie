import 'package:flutter_riverpod/flutter_riverpod.dart';

<<<<<<< HEAD
import '../../../../core/errors/app_exception.dart';

=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
class LoginState {
  const LoginState({
    this.useEmail = true,
    this.rememberMe = false,
    this.identity = '',
    this.password = '',
<<<<<<< HEAD
    this.identityErrorMessage,
    this.passwordErrorMessage,
    this.generalErrorMessage,
=======
    this.showErrors = false,
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
  });

  final bool useEmail;
  final bool rememberMe;
  final String identity;
  final String password;
<<<<<<< HEAD

  final String? identityErrorMessage;
  final String? passwordErrorMessage;
  final String? generalErrorMessage;

  bool get isValid =>
      identityErrorMessage == null &&
      passwordErrorMessage == null &&
      identity.trim().isNotEmpty &&
      password.trim().isNotEmpty;
=======
  final bool showErrors;

  bool get isValid => identity.trim().isNotEmpty && password.trim().isNotEmpty;

  bool get identityError => showErrors && identity.trim().isEmpty;
  bool get passwordError => showErrors && password.trim().isEmpty;
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750

  LoginState copyWith({
    bool? useEmail,
    bool? rememberMe,
    String? identity,
    String? password,
<<<<<<< HEAD
    String? identityErrorMessage,
    String? passwordErrorMessage,
    String? generalErrorMessage,
=======
    bool? showErrors,
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
  }) {
    return LoginState(
      useEmail: useEmail ?? this.useEmail,
      rememberMe: rememberMe ?? this.rememberMe,
      identity: identity ?? this.identity,
      password: password ?? this.password,
<<<<<<< HEAD
      identityErrorMessage:
          identityErrorMessage ?? this.identityErrorMessage,
      passwordErrorMessage:
          passwordErrorMessage ?? this.passwordErrorMessage,
      generalErrorMessage:
          generalErrorMessage ?? this.generalErrorMessage,
    );
  }

  LoginState clearErrors() => copyWith(
        identityErrorMessage: null,
        passwordErrorMessage: null,
        generalErrorMessage: null,
      );
=======
      showErrors: showErrors ?? this.showErrors,
    );
  }
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
}

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(const LoginState());

  void toggleMode(bool useEmail) {
<<<<<<< HEAD
    state = LoginState(
      useEmail: useEmail,
      rememberMe: state.rememberMe,
    );
=======
    state = state.copyWith(useEmail: useEmail, identity: '', showErrors: false);
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
  }

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  void setIdentity(String value) {
<<<<<<< HEAD
    state =
        state.copyWith(identity: value, identityErrorMessage: null);
  }

  void setPassword(String value) {
    state =
        state.copyWith(password: value, passwordErrorMessage: null);
  }

  bool validate() {
    String? idError;
    String? passError;

    final id = state.identity.trim();
    final pwd = state.password.trim();

    if (id.isEmpty) {
      idError = state.useEmail ? 'Введите email' : 'Введите номер телефона';
    } else if (state.useEmail &&
        !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(id)) {
      idError = 'Неверный формат email';
    }

    if (pwd.isEmpty) {
      passError = 'Введите пароль';
    } else if (pwd.length < 6) {
      passError = 'Пароль слишком короткий';
    }

    state = state.copyWith(
      identityErrorMessage: idError,
      passwordErrorMessage: passError,
      generalErrorMessage: null,
    );

    return idError == null && passError == null;
  }

  void applyBackendError(AppException exception) {
    switch (exception.code) {
      case AppErrorCode.invalidCredentials:
        state = state.copyWith(
          passwordErrorMessage: exception.message,
          generalErrorMessage: null,
        );
        break;
      case AppErrorCode.emailAlreadyExists:
      case AppErrorCode.phoneAlreadyExists:
        state = state.copyWith(
          identityErrorMessage: exception.message,
        );
        break;
      case AppErrorCode.network:
        state = state.copyWith(
          generalErrorMessage: exception.message,
        );
        break;
      case AppErrorCode.invalidOrExpiredToken:
      case AppErrorCode.validation:
      case AppErrorCode.unknown:
        state = state.copyWith(
          generalErrorMessage: exception.message,
        );
        break;
    }
=======
    state = state.copyWith(identity: value);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value);
  }

  void showValidationErrors() {
    state = state.copyWith(showErrors: true);
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
  }
}

final loginProvider = StateNotifierProvider<LoginController, LoginState>(
  (ref) => LoginController(),
);
<<<<<<< HEAD

=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
