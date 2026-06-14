import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/errors/app_exception.dart';
import '../../../../l10n/app_localizations.dart';

class LoginState {
  const LoginState({
    this.useEmail = true,
    this.rememberMe = false,
    this.identity = '',
    this.password = '',
    this.identityErrorMessage,
    this.passwordErrorMessage,
    this.generalErrorMessage,
  });

  final bool useEmail;
  final bool rememberMe;
  final String identity;
  final String password;
  final String? identityErrorMessage;
  final String? passwordErrorMessage;
  final String? generalErrorMessage;

  LoginState copyWith({
    bool? useEmail,
    bool? rememberMe,
    String? identity,
    String? password,
    String? identityErrorMessage,
    String? passwordErrorMessage,
    String? generalErrorMessage,
  }) {
    return LoginState(
      useEmail: useEmail ?? this.useEmail,
      rememberMe: rememberMe ?? this.rememberMe,
      identity: identity ?? this.identity,
      password: password ?? this.password,
      identityErrorMessage: identityErrorMessage ?? this.identityErrorMessage,
      passwordErrorMessage: passwordErrorMessage ?? this.passwordErrorMessage,
      generalErrorMessage: generalErrorMessage ?? this.generalErrorMessage,
    );
  }
}

class LoginController extends StateNotifier<LoginState> {
  LoginController() : super(const LoginState());

  void toggleMode(bool useEmail) {
    state = LoginState(
      useEmail: useEmail,
      rememberMe: state.rememberMe,
    );
  }

  void setRememberMe(bool value) {
    state = state.copyWith(rememberMe: value);
  }

  void setIdentity(String value) {
    state = state.copyWith(identity: value, identityErrorMessage: null);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value, passwordErrorMessage: null);
  }

  bool validate(AppLocalizations l10n) {
    String? idError;
    String? passError;

    final id = state.identity.trim();
    final pwd = state.password.trim();

    if (id.isEmpty) {
      idError = state.useEmail ? l10n.registerEmailError : l10n.errorValidation;
    } else if (state.useEmail && !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(id)) {
      idError = l10n.registerEmailError;
    }

    if (pwd.isEmpty) {
      passError = l10n.registerPasswordError;
    } else if (pwd.length < 6) {
      passError = l10n.errorValidation;
    }

    state = state.copyWith(
      identityErrorMessage: idError,
      passwordErrorMessage: passError,
      generalErrorMessage: null,
    );

    return idError == null && passError == null;
  }

  void applyBackendError(AppException exception, AppLocalizations l10n) {
    final localized = switch (exception.code) {
      AppErrorCode.invalidCredentials => l10n.errorInvalidCredentials,
      AppErrorCode.emailAlreadyExists => l10n.errorEmailExists,
      AppErrorCode.phoneAlreadyExists => l10n.errorPhoneExists,
      AppErrorCode.invalidOrExpiredToken => l10n.errorSessionExpired,
      AppErrorCode.network => l10n.errorNetwork,
      AppErrorCode.validation => exception.field == 'identity' &&
              exception.message == 'account_not_verified'
          ? l10n.errorAccountNotVerified
          : exception.field == 'identity' && exception.message == 'user_not_found'
              ? l10n.errorUserNotFound
              : l10n.errorValidation,
      AppErrorCode.unknown => l10n.errorGeneric,
    };

    switch (exception.code) {
      case AppErrorCode.invalidCredentials:
        state = state.copyWith(
          passwordErrorMessage: localized,
          generalErrorMessage: null,
        );
        break;
      case AppErrorCode.emailAlreadyExists:
      case AppErrorCode.phoneAlreadyExists:
        state = state.copyWith(identityErrorMessage: localized);
        break;
      case AppErrorCode.invalidOrExpiredToken:
      case AppErrorCode.validation:
        if (exception.field == 'identity') {
          state = state.copyWith(
            identityErrorMessage: localized,
            generalErrorMessage: null,
          );
        } else {
          state = state.copyWith(generalErrorMessage: localized);
        }
        break;
      case AppErrorCode.network:
      case AppErrorCode.unknown:
        state = state.copyWith(generalErrorMessage: localized);
        break;
    }
  }
}

final loginProvider = StateNotifierProvider<LoginController, LoginState>(
  (ref) => LoginController(),
);
