import 'package:flutter/material.dart';

class ProfileFlowHeader extends StatelessWidget {
  const ProfileFlowHeader({
    super.key,
    this.title,
    this.progress,
    this.trailing,
    this.onBack,
  });

  final String? title;
  final Widget? progress;
  final Widget? trailing;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    if (progress != null) {
      return Row(
        children: [
          _BackButton(onPressed: onBack ?? () => Navigator.of(context).pop()),
          const SizedBox(width: 12),
          Expanded(child: progress!),
        ],
      );
    }

    return Row(
      children: [
        _BackButton(onPressed: onBack ?? () => Navigator.of(context).pop()),
        Expanded(
          child: Text(
            title ?? '',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: const Color(0xFF001561),
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
          ),
        ),
        trailing ?? const SizedBox(width: 24),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_ios_new),
      iconSize: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minHeight: 24, minWidth: 24),
      color: const Color(0xFF001561),
    );
  }
}
