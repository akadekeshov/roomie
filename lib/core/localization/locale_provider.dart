import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_locale.dart';

const _localePreferenceKey = 'app_locale_code';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main().');
});

class AppLocaleController extends Notifier<Locale> {
  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedCode = prefs.getString(_localePreferenceKey);
    if (savedCode != null && savedCode.isNotEmpty) {
      return AppLanguage.fromCode(savedCode).locale;
    }

    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    return AppLanguage.resolveFromSystem(systemLocale).locale;
  }

  Future<void> setLanguage(AppLanguage language) async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.setString(_localePreferenceKey, language.code);
    state = language.locale;
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleController, Locale>(
  AppLocaleController.new,
);
