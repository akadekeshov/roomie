import 'package:flutter/material.dart';

class AppInputField extends StatelessWidget {
  const AppInputField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.showError = false,
    this.errorText = '',
    this.inputTextStyle,
    this.hintTextStyle,
    this.fillColor = const Color(0x1A7C3AED),
    this.borderRadius = 12,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool showError;
  final String errorText;
  final TextStyle? inputTextStyle;
  final TextStyle? hintTextStyle;
  final Color fillColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: inputTextStyle,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: hintTextStyle,
            filled: true,
            fillColor: fillColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
        if (showError) ...[
          const SizedBox(height: 10),
          Text(
            errorText,
            style: const TextStyle(
              fontFamily: 'Gilroy',
              fontSize: 12,
              height: 18 / 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFF0D0D),
            ),
          ),
        ],
      ],
    );
  }
}
