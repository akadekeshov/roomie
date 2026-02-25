import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_segmented_control.dart';

class BioAuthPage extends StatefulWidget {
  const BioAuthPage({super.key});

  @override
  State<BioAuthPage> createState() => _BioAuthPageState();
}

class _BioAuthPageState extends State<BioAuthPage> {
  bool _usePhone = true;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screenHorizontal,
            AppSpacing.screenTop,
            AppSpacing.screenHorizontal,
            AppSpacing.screenBottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.heroTopOffset),
              const _AvatarRow(),
              const SizedBox(height: AppSpacing.spaceTitle),
              _AuthHeader(textTheme: textTheme),
              const SizedBox(height: AppSpacing.spaceBeforeSwitcher),
              AppSegmentedControl(
                isLeftSelected: _usePhone,
                onChanged: (value) => setState(() => _usePhone = value),
                leftLabel: AppStrings.authPhone,
                rightLabel: AppStrings.authEmail,
                leftIcon: Icons.phone_outlined,
                rightIcon: Icons.mail_outline,
              ),
              const SizedBox(height: AppSpacing.spaceAfterSwitcher),
              _AuthForm(isPhone: _usePhone, textTheme: textTheme),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  const _AuthHeader({required this.textTheme});

  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.authTitle,
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: AppSpacing.spaceSubtitle),
        Text(
          AppStrings.authSubtitle,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.mutedText),
        ),
      ],
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({required this.isPhone, required this.textTheme});

  final bool isPhone;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPhone ? AppStrings.authPhoneLabel : AppStrings.authEmailLabel,
          style: textTheme.labelLarge?.copyWith(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceLabel),
        TextField(
          keyboardType: isPhone
              ? TextInputType.phone
              : TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: isPhone
                ? AppStrings.authPhoneHint
                : AppStrings.authEmailHint,
            filled: true,
            fillColor: AppColors.fieldFill,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceAfterField),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () =>
                Navigator.of(context).pushReplacementNamed(AppRoutes.otp),
            child: const Text(AppStrings.authContinue),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceAfterButton),
        SizedBox(
          width: double.infinity,
          child: Text(
            AppStrings.authTerms,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade500),
          ),
        ),
      ],
    );
  }
}

class _AvatarRow extends StatelessWidget {
  const _AvatarRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.avatarRowHeight,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          _AvatarCircle(),
          SizedBox(width: AppSpacing.avatarGap),
          _AvatarCircle(),
          SizedBox(width: AppSpacing.avatarGap),
          _AvatarCircle(),
          SizedBox(width: AppSpacing.avatarGap),
          _AvatarCircle(),
          SizedBox(width: AppSpacing.avatarGap),
          _AvatarCircle(),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.avatarSize,
      width: AppSpacing.avatarSize,
      decoration: BoxDecoration(
        color: AppColors.avatarPlaceholder,
        borderRadius: BorderRadius.circular(AppSpacing.avatarSize / 2),
      ),
    );
  }
}
