import 'package:flutter/material.dart';

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
    final baseStyle = OutlinedButton.styleFrom(
      minimumSize: const Size.fromHeight(48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      side: const BorderSide(color: Color(0xFFCCD5E3)),
      foregroundColor: const Color(0xFF001561),
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
          label: 'Continue with Google',
          iconText: 'G',
          onPressed: isLoading ? null : onGoogle,
        ),
        const SizedBox(height: 10),
        _SocialButton(
          style: baseStyle,
          label: 'Continue with Facebook',
          iconText: 'f',
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
    required this.onPressed,
  });

  final ButtonStyle style;
  final String label;
  final String iconText;
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}

