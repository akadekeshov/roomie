import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_strings.dart';
import '../core/localization/app_locale.dart';
import '../core/localization/locale_provider.dart';
import '../l10n/app_localizations.dart';
import '../features/auth/presentation/pages/bio_auth_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/auth/presentation/pages/registration_page.dart';
import '../features/auth/presentation/pages/verify_email_page.dart';
import '../features/home/presentation/pages/ai_search_page.dart';
import '../features/main/main_shell.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';
import '../features/profile/presentation/pages/gender_page.dart';
import '../features/profile/presentation/pages/location_page.dart';
import '../features/profile/presentation/pages/profile_about_page.dart';
import '../features/profile/presentation/pages/profile_completed_page.dart';
import '../features/profile/presentation/pages/profile_edit_page.dart';
import '../features/profile/presentation/pages/profile_finish_page.dart';
import '../features/profile/presentation/pages/profile_intro_page.dart';
import '../features/profile/presentation/pages/profile_lifestyle_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/profile_search_page.dart';
import '../features/profile/presentation/pages/profile_verification_page.dart';
import '../features/profile/presentation/pages/profile_verification_upload_page.dart';
import '../features/roomie_splash_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';

import 'app_routes.dart';
import 'app_theme.dart';

class RoommateApp extends ConsumerWidget {
  const RoommateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: supportedAppLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (context) => const RoomieSplashPage(),
        AppRoutes.welcome: (context) => const WelcomePage(),
        AppRoutes.auth: (context) => const BioAuthPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.otp: (context) => const OtpPage(),
        AppRoutes.register: (context) => const RegistrationPage(),
        AppRoutes.verifyEmail: (context) => const VerifyEmailPage(),
        AppRoutes.profileIntro: (context) => const ProfileIntroPage(),
        AppRoutes.gender: (context) => const GenderPage(),
        AppRoutes.location: (context) => const LocationPage(),
        AppRoutes.home: (context) => const MainShell(),
        AppRoutes.shell: (context) => const MainShell(),
        AppRoutes.profile: (context) => const ProfilePage(),
        AppRoutes.profileEdit: (context) => const ProfileEditPage(),
        AppRoutes.profileAbout: (context) => const ProfileAboutPage(),
        AppRoutes.profileLifestyle: (context) => const ProfileLifestylePage(),
        AppRoutes.profileSearch: (context) => const ProfileSearchPage(),
        AppRoutes.profileFinish: (context) => const ProfileFinishPage(),
        AppRoutes.profileCompleted: (context) => const ProfileCompletedPage(),
        AppRoutes.profileVerification: (context) =>
            const ProfileVerificationPage(),
        AppRoutes.profileVerificationUpload: (context) =>
            const ProfileVerificationUploadPage(),
        AppRoutes.aiSearch: (context) => const AiSearchPage(),
        AppRoutes.settings: (context) => const SettingsPage(),
      },
    );
  }
}
