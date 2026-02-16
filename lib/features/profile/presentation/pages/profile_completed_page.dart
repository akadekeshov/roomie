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
                '\u041f\u0440\u043e\u0444\u0438\u043b\u044c \u0437\u0430\u043f\u043e\u043b\u043d\u0435\u043d \u043d\u0430 100%',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF001561),
                  fontWeight: FontWeight.w700,
                  fontSize: 34 / 2,
                ),
              ),
              const SizedBox(height: 8),
              const Text('\ud83c\udf89', style: TextStyle(fontSize: 22)),
              const SizedBox(height: 20),
              Text(
                '\u0422\u0435\u043f\u0435\u0440\u044c \u0443 \u0432\u0430\u0441 \u0431\u043e\u043b\u044c\u0448\u0435 \u0448\u0430\u043d\u0441\u043e\u0432 \u043d\u0430\u0439\u0442\u0438\n\u0438\u0434\u0435\u0430\u043b\u044c\u043d\u043e\u0433\u043e \u0441\u043e\u0436\u0438\u0442\u0435\u043b\u044f',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF8E93A4),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              AppPrimaryButton(
                label:
                    '\u041f\u0435\u0440\u0435\u0439\u0442\u0438 \u043a \u043f\u043e\u0438\u0441\u043a\u0443',
                onPressed: () => Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false),
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
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.profileVerification),
                  child: const Text(
                    '\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0434\u0438\u0442\u044c \u043b\u0438\u0447\u043d\u043e\u0441\u0442\u044c (\u043d\u0435\u043e\u0431\u044f\u0437\u0430\u0442\u0435\u043b\u044c\u043d\u043e)',
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
