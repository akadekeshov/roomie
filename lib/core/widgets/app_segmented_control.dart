import 'package:flutter/material.dart';

class AppSegmentedControl extends StatelessWidget {
  const AppSegmentedControl({
    super.key,
    required this.isLeftSelected,
    required this.onChanged,
    required this.leftLabel,
    required this.rightLabel,
    required this.leftIcon,
    required this.rightIcon,
    this.height = 40,
    this.backgroundColor = const Color(0x339CA3AF),
    this.activeColor = const Color(0xFF9CA3AF),
    this.activeTextColor = const Color(0xFF001561),
    this.inactiveTextColor = const Color(0x80001561),
    this.textStyle,
  });

  final bool isLeftSelected;
  final ValueChanged<bool> onChanged;
  final String leftLabel;
  final String rightLabel;
  final IconData leftIcon;
  final IconData rightIcon;
  final double height;
  final Color backgroundColor;
  final Color activeColor;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final halfWidth = constraints.maxWidth / 2;
        return Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                left: isLeftSelected ? 0 : halfWidth,
                top: 0,
                bottom: 0,
                width: halfWidth,
                child: Container(
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _SegmentOption(
                      isActive: isLeftSelected,
                      label: leftLabel,
                      icon: leftIcon,
                      activeTextColor: activeTextColor,
                      inactiveTextColor: inactiveTextColor,
                      textStyle: textStyle,
                      onTap: () => onChanged(true),
                    ),
                  ),
                  Expanded(
                    child: _SegmentOption(
                      isActive: !isLeftSelected,
                      label: rightLabel,
                      icon: rightIcon,
                      activeTextColor: activeTextColor,
                      inactiveTextColor: inactiveTextColor,
                      textStyle: textStyle,
                      onTap: () => onChanged(false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SegmentOption extends StatelessWidget {
  const _SegmentOption({
    required this.isActive,
    required this.label,
    required this.icon,
    required this.activeTextColor,
    required this.inactiveTextColor,
    required this.onTap,
    this.textStyle,
  });

  final bool isActive;
  final String label;
  final IconData icon;
  final Color activeTextColor;
  final Color inactiveTextColor;
  final VoidCallback onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeTextColor : inactiveTextColor;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: (textStyle ??
                      const TextStyle(
                        fontFamily: 'Gilroy',
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w700,
                      ))
                  .copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
