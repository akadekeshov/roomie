import 'package:flutter/material.dart';

enum AppLanguage {
  russian('ru'),
  kazakh('kk');

  const AppLanguage(this.code);

  final String code;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) {
    return switch ((code ?? '').toLowerCase()) {
      'kk' => AppLanguage.kazakh,
      _ => AppLanguage.russian,
    };
  }

  static AppLanguage resolveFromSystem(Locale locale) {
    return locale.languageCode.toLowerCase() == 'kk'
        ? AppLanguage.kazakh
        : AppLanguage.russian;
  }
}

const supportedAppLocales = <Locale>[
  Locale('ru'),
  Locale('kk'),
];
