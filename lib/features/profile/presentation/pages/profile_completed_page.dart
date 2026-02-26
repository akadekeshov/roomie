import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';

class ProfileCompletedPage extends StatelessWidget {
  const ProfileCompletedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 94,
                height: 94,
                decoration: const BoxDecoration(
                  color: Color(0x1A7C3AED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Профиль заполнен на 100%',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF001561),
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 8),
              const Text('🎉', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 20),
              Text(
                'Теперь у вас больше шансов найти\nидеального сожителя',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF8E93A4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              AppPrimaryButton(
                label: 'Перейти к поиску',
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
                textStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFC6CAD6)),
                    foregroundColor: const Color(0xFF4E556F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(99),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  onPressed: () => Navigator.of(context)
                      .pushNamed(AppRoutes.profileVerification),
                  child: const Text(
                    'Подтвердить личность (необязательно)',
                    style: TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
