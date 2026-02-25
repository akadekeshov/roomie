import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/onboarding_route_mapper.dart';
import '../../../../core/widgets/app_primary_button.dart';
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
    if (_selected == null || _isSubmitting) return;
    final genderValue = _selected == GenderChoice.male ? 'MALE' : 'FEMALE';
    setState(() => _isSubmitting = true);
    try {
      final result = await ref
          .read(onboardingRepositoryProvider)
          .submitGender(genderValue);
      if (!mounted) return;
      final route = OnboardingRouteMapper.fromStep(result.nextStep);
      Navigator.of(context).pushReplacementNamed(route);
    } on DioException catch (e) {
      if (!mounted) return;
      final serverMessage = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;
      final message = (serverMessage != null && serverMessage.isNotEmpty)
          ? serverMessage
          : 'Не удалось сохранить пол';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.profileIntro),
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
                AppStrings.genderRuTitle,
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
                      onTap: () =>
                          setState(() => _selected = GenderChoice.male),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: _GenderButton(
                      isSelected: _selected == GenderChoice.female,
                      activeColor: AppColors.genderFemale,
                      icon: Icons.woman,
                      onTap: () =>
                          setState(() => _selected = GenderChoice.female),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              AppPrimaryButton(
                label: AppStrings.profileContinue,
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
    required this.onTap,
  });

  final bool isSelected;
  final Color activeColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = isSelected ? activeColor : const Color(0xFFCAD0E1);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Container(
          height: 92,
          width: 92,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF001561), size: 38),
        ),
      ),
    );
  }
}
