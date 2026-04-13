import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabledColor = const Color(0xFF7C3AED),
    this.disabledColor = const Color(0x4D7C3AED),
    this.enabledTextColor = Colors.white,
    this.disabledTextColor = const Color(0x80FFFFFF),
    this.radius = 99,
    this.verticalPadding = 14,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color enabledColor;
  final Color disabledColor;
  final Color enabledTextColor;
  final Color disabledTextColor;
  final double radius;
  final double verticalPadding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) => states.contains(WidgetState.disabled)
                ? disabledColor
                : enabledColor,
          ),
          foregroundColor: WidgetStateProperty.resolveWith<Color>(
            (states) => states.contains(WidgetState.disabled)
                ? disabledTextColor
                : enabledTextColor,
          ),
          padding: WidgetStateProperty.all(
            EdgeInsets.symmetric(vertical: verticalPadding),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: textStyle),
      ),
    );
  }
}
