import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/onboarding_route_mapper.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/auth_repository.dart';
import '../state/login_state.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final controller = ref.read(loginProvider.notifier);
    var state = ref.read(loginProvider);

    final ok = controller.validate();
    state = ref.read(loginProvider);
    if (!ok) return;

    setState(() => _isSubmitting = true);

    try {
      final result = await ref.read(authRepositoryProvider).login(
            useEmail: state.useEmail,
            identity: state.identity,
            password: state.password,
            rememberMe: state.rememberMe,
          );

      if (!mounted) return;

      final route = result.onboardingCompleted
          ? AppRoutes.shell
          : OnboardingRouteMapper.fromStep(result.onboardingStep);

      Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
    } on AppException catch (e) {
      controller.applyBackendError(e);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось войти. Попробуйте снова.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(loginProvider);
    final controller = ref.read(loginProvider.notifier);

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
                  AppStrings.loginTitle,
                  style: textTheme.titleLarge?.copyWith(
                    fontFamily: 'Gilroy',
                    fontSize: 25,
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
                key: ValueKey('login-identity-${state.useEmail}'),
                hint: state.useEmail
                    ? AppStrings.registerEmailHint
                    : '+7 777 123 45 67',
                keyboardType: state.useEmail
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                showError: state.identityErrorMessage != null,
                errorText: state.identityErrorMessage ?? '',
                onChanged: controller.setIdentity,
              ),
              const SizedBox(height: 20),
              const _FieldLabel(text: AppStrings.registerPasswordLabel),
              const SizedBox(height: 8),
              AppInputField(
                hint: AppStrings.registerPasswordHint,
                obscureText: true,
                showError: state.passwordErrorMessage != null,
                errorText: state.passwordErrorMessage ?? '',
                onChanged: controller.setPassword,
              ),
              const SizedBox(height: 20),
              _RememberRow(
                value: state.rememberMe,
                onChanged: (value) => controller.setRememberMe(value ?? false),
              ),
              if (state.generalErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    state.generalErrorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              AppPrimaryButton(
                label: _isSubmitting ? 'Вход...' : AppStrings.loginButton,
                onPressed: _isSubmitting ? null : _submit,
              ),
              const SizedBox(height: 20),
              Center(
                child: InkWell(
                  onTap: () => Navigator.of(context)
                      .pushReplacementNamed(AppRoutes.register),
                  child: Text.rich(
                    TextSpan(
                      text: AppStrings.loginRegisterPrefix,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xCC001561),
                      ),
                      children: const [
                        TextSpan(
                          text: AppStrings.loginRegisterLink,
                          style: TextStyle(
                            color: Color(0xFF6C4BFF),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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
        fontSize: 14,
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
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
        const SizedBox(width: 8),
        const Text(
          AppStrings.registerRemember,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0x80001561),
          ),
        ),
      ],
    );
  }
}
