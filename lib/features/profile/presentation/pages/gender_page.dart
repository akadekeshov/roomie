import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/localization/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/onboarding_route_mapper.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../home/data/home_providers.dart';
import '../../data/me_repository.dart';
import '../../data/onboarding_repository.dart';

enum GenderChoice { male, female }

class GenderPage extends ConsumerStatefulWidget {
  const GenderPage({super.key});

  @override
  ConsumerState<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends ConsumerState<GenderPage> {
  GenderChoice? _selected;
  bool _isSubmitting = false;

  Future<void> _onContinue() async {
    final l10n = context.l10n;
    if (_selected == null || _isSubmitting) return;

    final genderValue = _selected == GenderChoice.male ? 'MALE' : 'FEMALE';
    setState(() => _isSubmitting = true);

    try {
      final result = await ref
          .read(onboardingRepositoryProvider)
          .submitGender(genderValue);
      if (!mounted) return;
      ref.invalidate(meProvider);
      ref.invalidate(recommendedUsersProvider);
      ref.invalidate(homeAutoRecommendationsProvider);
      final route = OnboardingRouteMapper.fromStep(result.nextStep);
      Navigator.of(context).pushReplacementNamed(route);
    } on DioException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorSaveGenderFailed)),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final isValid = _selected != null;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context)
                          .pushReplacementNamed(AppRoutes.profileIntro),
                      icon: const Icon(Icons.arrow_back_ios_new),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 24,
                        minHeight: 24,
                      ),
                      iconSize: 18,
                      color: const Color(0xFF001561),
                    ),
                  ),
                  Text(
                    AppStrings.appBrand,
                    style: textTheme.titleMedium?.copyWith(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF001561),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                l10n.genderTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF001561),
                ),
              ),
              const SizedBox(height: 90),
              Row(
                children: [
                  Expanded(
                    child: _GenderButton(
                      isSelected: _selected == GenderChoice.male,
                      activeColor: AppColors.genderMale,
                      icon: Icons.man,
                      label: l10n.genderMale,
                      onTap: () => setState(() => _selected = GenderChoice.male),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _GenderButton(
                      isSelected: _selected == GenderChoice.female,
                      activeColor: AppColors.genderFemale,
                      icon: Icons.woman,
                      label: l10n.genderFemale,
                      onTap: () =>
                          setState(() => _selected = GenderChoice.female),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AppPrimaryButton(
                label: l10n.profileContinue,
                onPressed: (isValid && !_isSubmitting) ? _onContinue : null,
                enabledColor: const Color(0xFF7C3AED),
                disabledColor: const Color(0x4D7C3AED),
                enabledTextColor: Colors.white,
                disabledTextColor: const Color(0x80FFFFFF),
                textStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.isSelected,
    required this.activeColor,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool isSelected;
  final Color activeColor;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isSelected ? activeColor : const Color(0xFFCAD0E1);
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Center(
            child: Container(
              height: 92,
              width: 92,
              decoration: BoxDecoration(
                color: background,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFF001561), size: 38),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: const Color(0xFF001561),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
