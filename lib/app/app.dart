import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/auth/presentation/pages/bio_auth_page.dart';
import '../features/auth/presentation/pages/verify_email_page.dart';
import '../features/auth/presentation/pages/registration_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/profile/presentation/pages/profile_intro_page.dart';
import '../features/profile/presentation/pages/gender_page.dart';
import '../features/profile/presentation/pages/location_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/profile_about_page.dart';
import '../features/profile/presentation/pages/profile_lifestyle_page.dart';
import '../features/profile/presentation/pages/profile_search_page.dart';
import '../features/profile/presentation/pages/profile_finish_page.dart';
import '../features/profile/presentation/pages/profile_completed_page.dart';
import '../features/profile/presentation/pages/profile_verification_page.dart';
import '../features/profile/presentation/pages/profile_verification_upload_page.dart';
import '../features/home/presentation/pages/home_page.dart';
<<<<<<< HEAD
import '../features/main/main_shell.dart';
import '../features/onboarding/presentation/pages/welcome_page.dart';
import 'app_routes.dart';
import 'app_theme.dart';
import 'package:roommate_app/features/profile/presentation/pages/profile_edit_page.dart';
import '../features/admin/presentation/pages/admin_verifications_page.dart';

=======
import '../features/onboarding/presentation/pages/welcome_page.dart';
import 'app_routes.dart';
import 'app_theme.dart';
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750

class RoommateApp extends StatelessWidget {
  const RoommateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: AppTheme.light(),
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.register,
<<<<<<< HEAD
      //initialRoute: AppRoutes.adminVerifications,
=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
      routes: {
        AppRoutes.welcome: (context) => const WelcomePage(),
        AppRoutes.auth: (context) => const BioAuthPage(),
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.otp: (context) => const OtpPage(),
        AppRoutes.register: (context) => const RegistrationPage(),
        AppRoutes.verifyEmail: (context) => const VerifyEmailPage(),
        AppRoutes.profileIntro: (context) => const ProfileIntroPage(),
        AppRoutes.gender: (context) => const GenderPage(),
        AppRoutes.location: (context) => const LocationPage(),
<<<<<<< HEAD
        AppRoutes.home: (context) => const MainShell(),
=======
        AppRoutes.home: (context) => const HomePage(),
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
        AppRoutes.profile: (context) => const ProfilePage(),
        AppRoutes.profileAbout: (context) => const ProfileAboutPage(),
        AppRoutes.profileLifestyle: (context) => const ProfileLifestylePage(),
        AppRoutes.profileSearch: (context) => const ProfileSearchPage(),
        AppRoutes.profileFinish: (context) => const ProfileFinishPage(),
        AppRoutes.profileCompleted: (context) => const ProfileCompletedPage(),
        AppRoutes.profileVerification: (context) =>
            const ProfileVerificationPage(),
        AppRoutes.profileVerificationUpload: (context) =>
            const ProfileVerificationUploadPage(),
<<<<<<< HEAD
          
       AppRoutes.profileEdit: (_) =>  ProfileEditPage(),

        AppRoutes.shell: (context) => const MainShell(),

        AppRoutes.adminVerifications: (context) => const AdminVerificationsPage(),
=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
      },
    );
  }
}
