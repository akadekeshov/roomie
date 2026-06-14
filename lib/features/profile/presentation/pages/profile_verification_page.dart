import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/localization/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../widgets/profile_flow_header.dart';

class ProfileVerificationPage extends StatelessWidget {
  const ProfileVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              ProfileFlowHeader(title: l10n.profileTitle),
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
                l10n.profileVerificationTitle,
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF001561),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.profileVerificationSubtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF9AA1B9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 26),
              _BenefitTile(
                icon: Icons.check,
                title: l10n.profileVerificationBenefitBadge,
              ),
              const SizedBox(height: 10),
              _BenefitTile(
                icon: Icons.auto_awesome_outlined,
                title: l10n.profileVerificationBenefitPriority,
              ),
              const SizedBox(height: 10),
              _BenefitTile(
                icon: Icons.chat_bubble_outline,
                title: l10n.profileVerificationBenefitReplies,
              ),
              const Spacer(),
              AppPrimaryButton(
                label: l10n.verificationConfirmIdentity,
                onPressed: () => Navigator.of(context)
                    .pushNamed(AppRoutes.profileVerificationUpload),
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
