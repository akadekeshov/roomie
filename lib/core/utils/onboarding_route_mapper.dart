import '../../app/app_routes.dart';

class OnboardingRouteMapper {
  static String fromStep(String? step) {
    switch (step) {
      case 'NAME_AGE':
        return AppRoutes.profileIntro;
      case 'GENDER':
        return AppRoutes.gender;
      case 'CITY':
        return AppRoutes.location;
      case 'ABOUT':
        return AppRoutes.profileAbout;
      case 'LIFESTYLE':
        return AppRoutes.profileLifestyle;
      case 'SEARCH':
        return AppRoutes.profileSearch;
      case 'FINALIZE':
        return AppRoutes.profileFinish;
      case 'DONE':
        return AppRoutes.home;
      default:
        return AppRoutes.home;
    }
  }

  const OnboardingRouteMapper._();
}
