import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../state/registration_state.dart';

class RegistrationPage extends ConsumerWidget {
  const RegistrationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(registrationProvider);
    final controller = ref.read(registrationProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(30, 120, 30, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  AppStrings.registerTitle,
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    fontFamily: 'Gilroy',
                    fontSize: 25,
                    height: 28 / 25,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF001561),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: 240,
                  child: AppSegmentedControl(
                    isLeftSelected: state.useEmail,
                    onChanged: controller.toggleMode,
                    leftLabel: AppStrings.registerEmailTab,
                    rightLabel: AppStrings.registerPhoneTab,
                    leftIcon: Icons.mail_outline,
                    rightIcon: Icons.phone_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _FieldLabel(
                text: state.useEmail
                    ? AppStrings.registerEmailLabel
                    : AppStrings.registerPhoneTab,
              ),
              const SizedBox(height: 8),
              AppInputField(
                hint: state.useEmail
                    ? AppStrings.registerEmailHint
                    : '+7 777 123 45 67',
                keyboardType: state.useEmail
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                showError: state.emailError,
                errorText: AppStrings.registerEmailError,
                onChanged: controller.setEmail,
                inputTextStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  height: 20 / 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF001561),
                ),
                hintTextStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  height: 20 / 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0x33001561),
                ),
              ),
              const SizedBox(height: 20),
              _FieldLabel(text: AppStrings.registerPasswordLabel),
              const SizedBox(height: 8),
              AppInputField(
                hint: AppStrings.registerPasswordHint,
                obscureText: true,
                showError: state.passwordError,
                errorText: AppStrings.registerPasswordError,
                onChanged: controller.setPassword,
                inputTextStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  height: 20 / 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF001561),
                ),
                hintTextStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  height: 20 / 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0x33001561),
                ),
              ),
              const SizedBox(height: 20),
              _FieldLabel(text: AppStrings.registerConfirmLabel),
              const SizedBox(height: 8),
              AppInputField(
                hint: AppStrings.registerConfirmHint,
                obscureText: true,
                showError: state.confirmError,
                errorText: AppStrings.registerConfirmError,
                onChanged: controller.setConfirm,
                inputTextStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  height: 20 / 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF001561),
                ),
                hintTextStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  height: 20 / 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0x33001561),
                ),
              ),
              const SizedBox(height: 20),
              _RememberRow(
                value: state.rememberMe,
                onChanged: (value) => controller.setRememberMe(value ?? false),
              ),
              const SizedBox(height: 20),
              AppPrimaryButton(
                label: AppStrings.registerButton,
                onPressed: state.isValid
                    ? () => Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.verifyEmail)
                    : null,
                textStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: AppStrings.registerLoginPrefix,
                    style: const TextStyle(
                      fontFamily: 'Gilroy',
                      fontSize: 12,
                      height: 20 / 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xCC001561),
                    ),
                    children: [
                      TextSpan(
                        text: AppStrings.registerLoginLink,
                        style: const TextStyle(
                          color: Color(0xFF6C4BFF),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontFamily: 'Gilroy',
        fontSize: 14,
        height: 18 / 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF001561),
      ),
    );
  }
}

class _RememberRow extends StatelessWidget {
  const _RememberRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          height: 18,
          width: 18,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            side: const BorderSide(color: Color(0x4D001561)),
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          AppStrings.registerRemember,
          style: TextStyle(
            fontFamily: 'Gilroy',
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
            color: Color(0x80001561),
          ),
        ),
      ],
    );
  }
}
