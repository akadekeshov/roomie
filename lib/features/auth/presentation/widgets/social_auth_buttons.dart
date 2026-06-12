import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({
    super.key,
    required this.isLoading,
    required this.onGoogle,
    required this.onFacebook,
  });

  final bool isLoading;
  final VoidCallback onGoogle;
  final VoidCallback onFacebook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.55)),
      backgroundColor: theme.colorScheme.surface,
      foregroundColor: theme.colorScheme.onSurface,
      textStyle: const TextStyle(
        fontFamily: 'Gilroy',
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );

    return Column(
      children: [
        _SocialButton(
          style: baseStyle,
          label: 'Войти через Google',
          iconText: 'G',
          iconColor: const Color(0xFFDB4437),
          onPressed: isLoading ? null : onGoogle,
        ),
        const SizedBox(height: 10),
        _SocialButton(
          style: baseStyle,
          label: 'Войти через Facebook',
          iconText: 'f',
          iconColor: AppColors.primary,
          onPressed: isLoading ? null : onFacebook,
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.style,
    required this.label,
    required this.iconText,
    required this.iconColor,
    required this.onPressed,
  });

  final ButtonStyle style;
  final String label;
  final String iconText;
  final Color iconColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: style,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            iconText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}
