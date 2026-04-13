import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../widgets/profile_flow_header.dart';

class ProfileVerificationPage extends StatelessWidget {
  const ProfileVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              const ProfileFlowHeader(title: 'Профиль'),
              const SizedBox(height: 28),
              Container(
                width: 92,
                height: 92,
                decoration: const BoxDecoration(
                  color: Color(0x1A7C3AED),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0436\u0434\u0435\u043d\u0438\u0435 \u043b\u0438\u0447\u043d\u043e\u0441\u0442\u0438',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF001561),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0436\u0434\u0435\u043d\u043d\u044b\u0435 \u043f\u043e\u043b\u044c\u0437\u043e\u0432\u0430\u0442\u0435\u043b\u0438\n\u0432\u044b\u0437\u044b\u0432\u0430\u044e\u0442 \u0431\u043e\u043b\u044c\u0448\u0435 \u0434\u043e\u0432\u0435\u0440\u0438\u044f',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF9AA1B9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 26),
              const _BenefitTile(
                icon: Icons.check,
                title:
                    '\u0421\u0438\u043d\u044f\u044f \u0433\u0430\u043b\u043e\u0447\u043a\u0430 \u0432 \u043f\u0440\u043e\u0444\u0438\u043b\u0435',
              ),
              const SizedBox(height: 10),
              const _BenefitTile(
                icon: Icons.auto_awesome_outlined,
                title:
                    '\u041f\u0440\u0438\u043e\u0440\u0438\u0442\u0435\u0442 \u0432 \u0440\u0435\u043a\u043e\u043c\u0435\u043d\u0434\u0430\u0446\u0438\u044f\u0445',
              ),
              const SizedBox(height: 10),
              const _BenefitTile(
                icon: Icons.chat_bubble_outline,
                title:
                    '\u0411\u043e\u043b\u044c\u0448\u0435 \u043e\u0442\u043a\u043b\u0438\u043a\u043e\u0432',
              ),
              const Spacer(),
              AppPrimaryButton(
                label:
                    '\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0434\u0438\u0442\u044c \u043b\u0438\u0447\u043d\u043e\u0441\u0442\u044c',
                onPressed: () => Navigator.of(
                  context,
                ).pushNamed(AppRoutes.profileVerificationUpload),
                textStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
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

class _BenefitTile extends StatelessWidget {
  const _BenefitTile({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC6CAD6)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0x1A7C3AED),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF001561),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
