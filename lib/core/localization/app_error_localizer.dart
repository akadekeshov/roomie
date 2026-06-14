import 'package:flutter/widgets.dart';

import '../errors/app_exception.dart';
import 'build_context_l10n.dart';

extension AppExceptionLocalizationX on AppException {
  String localized(BuildContext context) {
    final l10n = context.l10n;

    return switch (code) {
      AppErrorCode.invalidCredentials => l10n.errorInvalidCredentials,
      AppErrorCode.emailAlreadyExists => l10n.errorEmailExists,
      AppErrorCode.phoneAlreadyExists => l10n.errorPhoneExists,
      AppErrorCode.invalidOrExpiredToken => l10n.errorSessionExpired,
      AppErrorCode.network => l10n.errorNetwork,
      AppErrorCode.validation => _localizedValidationMessage(l10n),
      AppErrorCode.unknown => _localizedUnknownMessage(l10n),
    };
  }

  String _localizedValidationMessage(dynamic l10n) {
    if (field == 'identity' && message == 'account_not_verified') {
      return l10n.errorAccountNotVerified;
    }
    if (field == 'identity' && message == 'user_not_found') {
      return l10n.errorUserNotFound;
    }
    if (message == 'no_access') {
      return l10n.errorNoAccess;
    }
    if (message == 'too_many_attempts') {
      return l10n.errorTooManyAttempts;
    }
    return l10n.errorValidation;
  }

  String _localizedUnknownMessage(dynamic l10n) {
    return switch (message) {
      'auth_login_failed' => l10n.errorAuthLoginFailed,
      'auth_register_failed' => l10n.errorAuthRegisterFailed,
      'otp_confirm_failed' => l10n.errorOtpConfirmFailed,
      'otp_resend_failed' => l10n.errorOtpResendFailed,
      'profile_load_failed' => l10n.errorProfileLoadFailed,
      'social_google_cancelled' => l10n.socialGoogleCancelled,
      'social_google_config' => l10n.socialGoogleConfigError,
      'social_google_missing_token' => l10n.socialGoogleTokenMissing,
      'social_facebook_cancelled' => l10n.socialFacebookCancelled,
      'social_facebook_config' => l10n.socialFacebookConfigError,
      'social_facebook_data' => l10n.socialFacebookDataError,
      _ => l10n.errorGeneric,
    };
  }
}
