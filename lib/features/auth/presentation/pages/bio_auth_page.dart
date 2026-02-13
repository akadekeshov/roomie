import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../app/app_routes.dart';

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
              _SegmentedSwitcher(
                isLeft: _usePhone,
                onChanged: (value) => setState(() => _usePhone = value),
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

class _SegmentedSwitcher extends StatelessWidget {
  const _SegmentedSwitcher({
    required this.isLeft,
    required this.onChanged,
  });

  final bool isLeft;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.mutedChip,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Container(
                width: (MediaQuery.of(context).size.width - 56) / 2,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(true),
                  child: Center(
                    child: Text(
                      AppStrings.authPhone,
                      style: TextStyle(
                        color: isLeft ? AppColors.primary : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(false),
                  child: Center(
                    child: Text(
                      AppStrings.authEmail,
                      style: TextStyle(
                        color: isLeft ? Colors.grey.shade600 : AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
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
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.spaceSubtitle),
        Text(
          AppStrings.authSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.mutedText,
          ),
        ),
      ],
    );
  }
}

class _AuthForm extends StatelessWidget {
  const _AuthForm({
    required this.isPhone,
    required this.textTheme,
  });

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
            hintText:
                isPhone ? AppStrings.authPhoneHint : AppStrings.authEmailHint,
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
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.otp),
            child: const Text(AppStrings.authContinue),
          ),
        ),
        const SizedBox(height: AppSpacing.spaceAfterButton),
        SizedBox(
          width: double.infinity,
          child: Text(
            AppStrings.authTerms,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
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
