import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';

class AboutStepPayload {
  const AboutStepPayload({
    required this.occupationStatus,
    required this.university,
    required this.age,
    required this.city,
  });

  final String occupationStatus;
  final String university;
  final int age;
  final String city;
}

class NameAgePayload {
  const NameAgePayload({required this.firstName, required this.age});

  final String firstName;
  final int age;
}

class OnboardingStepResult {
  const OnboardingStepResult({required this.nextStep});

  final String? nextStep;
}

class LifestyleStepPayload {
  const LifestyleStepPayload({
    required this.chronotype,
    required this.noisePreference,
    required this.personalityType,
    required this.smokingPreference,
    required this.petsPreference,
  });

  final String chronotype;
  final String noisePreference;
  final String personalityType;
  final String smokingPreference;
  final String petsPreference;
}

class SearchStepPayload {
  const SearchStepPayload({
    required this.budgetMin,
    required this.budgetMax,
    required this.district,
    required this.roommateGenderPreference,
    required this.stayTerm,
  });

  final int budgetMin;
  final int budgetMax;
  final String district;
  final String roommateGenderPreference;
  final String stayTerm;
}

class FinalizeStepPayload {
  const FinalizeStepPayload({required this.bio, required this.photos});

  final String bio;
  final List<String> photos;
}

class OnboardingStatus {
  const OnboardingStatus({
    required this.onboardingStep,
    required this.onboardingCompleted,
    required this.profile,
  });

  final String? onboardingStep;
  final bool onboardingCompleted;
  final Map<String, dynamic> profile;
}

class OnboardingRepository {
  const OnboardingRepository(this._dio);

  final Dio _dio;

  Future<OnboardingStepResult> submitNameAge(NameAgePayload payload) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/onboarding/name-age',
      data: {'firstName': payload.firstName, 'age': payload.age},
    );
    return OnboardingStepResult(
      nextStep: response.data?['nextStep'] as String?,
    );
  }

  Future<OnboardingStepResult> submitGender(String gender) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/onboarding/gender',
      data: {'gender': gender},
    );
    return OnboardingStepResult(
      nextStep: response.data?['nextStep'] as String?,
    );
  }

  Future<OnboardingStepResult> submitCity(String city) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/onboarding/city',
      data: {'city': city},
    );
    return OnboardingStepResult(
      nextStep: response.data?['nextStep'] as String?,
    );
  }

  Future<String?> submitAboutStep(AboutStepPayload payload) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/onboarding/about',
      data: {
        'occupationStatus': payload.occupationStatus,
        'university': payload.university,
        'age': payload.age,
        'city': payload.city,
      },
    );
    return response.data?['nextStep'] as String?;
  }

  Future<String?> submitLifestyleStep(LifestyleStepPayload payload) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/onboarding/lifestyle',
      data: {
        'chronotype': payload.chronotype,
        'noisePreference': payload.noisePreference,
        'personalityType': payload.personalityType,
        'smokingPreference': payload.smokingPreference,
        'petsPreference': payload.petsPreference,
      },
    );
    return response.data?['nextStep'] as String?;
  }

  Future<String?> submitSearchStep(SearchStepPayload payload) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/onboarding/search',
      data: {
        'budgetMin': payload.budgetMin,
        'budgetMax': payload.budgetMax,
        'district': payload.district,
        'roommateGenderPreference': payload.roommateGenderPreference,
        'stayTerm': payload.stayTerm,
      },
    );
    return response.data?['nextStep'] as String?;
  }

  Future<String?> submitFinalizeStep(FinalizeStepPayload payload) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/onboarding/finalize',
      data: {'bio': payload.bio, 'photos': payload.photos},
    );
    return response.data?['nextStep'] as String?;
  }

  Future<void> uploadVerificationDocument(String documentUrl) async {
    await _dio.patch<Map<String, dynamic>>(
      '/onboarding/verification/document',
      data: {'documentUrl': documentUrl},
    );
  }

  Future<void> submitVerification() async {
    await _dio.patch<Map<String, dynamic>>('/onboarding/verification/submit');
  }

  Future<OnboardingStatus> getStatus() async {
    final response = await _dio.get<Map<String, dynamic>>('/onboarding/status');
    final data = response.data ?? <String, dynamic>{};
    return OnboardingStatus(
      onboardingStep: data['onboardingStep'] as String?,
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? false,
      profile: (data['profile'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
    );
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepository(ref.read(dioProvider));
});
