import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/localization/app_error_localizer.dart';
import '../../../../core/localization/build_context_l10n.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_snackbar.dart';
import '../../../../core/utils/onboarding_route_mapper.dart';
import '../../../../core/widgets/app_input_field.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../../core/widgets/app_segmented_control.dart';
import '../../../home/data/home_providers.dart';
import '../../../people/data/favorites_users_providers.dart';
import '../../../profile/data/me_repository.dart';
import '../../data/auth_repository.dart';
import '../../data/social_auth_service.dart';
import '../state/login_state.dart';
import '../widgets/social_auth_buttons.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  bool _isSubmitting = false;
  bool _isSocialSubmitting = false;

  Future<void> _submit() async {
    final l10n = context.l10n;
    final controller = ref.read(loginProvider.notifier);
    var state = ref.read(loginProvider);

    final ok = controller.validate(l10n);
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

      ref.invalidate(meProvider);
      ref.invalidate(homeAutoRecommendationsProvider);
      ref.invalidate(recommendedUsersProvider);
      ref.invalidate(favoriteUsersProvider);

      if (!mounted) return;

      final route = result.onboardingCompleted
          ? AppRoutes.shell
          : OnboardingRouteMapper.fromStep(result.onboardingStep);

      Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
    } on AppException catch (error) {
      controller.applyBackendError(error, l10n);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, l10n.errorAuthLoginFailed, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _submitSocial(SocialProvider provider) async {
    if (_isSubmitting || _isSocialSubmitting) return;
    setState(() => _isSocialSubmitting = true);

    try {
      final result = await ref
          .read(authRepositoryProvider)
          .loginWithSocial(provider: provider, rememberMe: true);

      ref.invalidate(meProvider);
      ref.invalidate(homeAutoRecommendationsProvider);
      ref.invalidate(recommendedUsersProvider);
      ref.invalidate(favoriteUsersProvider);

      if (!mounted) return;
      final route = result.onboardingCompleted
          ? AppRoutes.shell
          : OnboardingRouteMapper.fromStep(result.onboardingStep);
      Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
    } on AppException catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.localized(context), isError: true);
    } catch (_) {
      if (!mounted) return;
      showAppSnackBar(context, context.l10n.errorServer, isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSocialSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
                  l10n.loginTitle,
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
                    leftLabel: l10n.registerEmailTab,
                    rightLabel: l10n.registerPhoneTab,
                    leftIcon: Icons.mail_outline,
                    rightIcon: Icons.phone_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _FieldLabel(
                text:
                    state.useEmail ? l10n.registerEmailLabel : l10n.registerPhoneTab,
              ),
              const SizedBox(height: 8),
              AppInputField(
                key: ValueKey('login-identity-${state.useEmail}'),
                hint: state.useEmail ? l10n.registerEmailHint : l10n.authPhoneHint,
                keyboardType: state.useEmail
                    ? TextInputType.emailAddress
                    : TextInputType.phone,
                showError: state.identityErrorMessage != null,
                errorText: state.identityErrorMessage ?? '',
                onChanged: controller.setIdentity,
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
              _FieldLabel(text: l10n.registerPasswordLabel),
              const SizedBox(height: 8),
              AppInputField(
                hint: l10n.registerPasswordHint,
                obscureText: true,
                showError: state.passwordErrorMessage != null,
                errorText: state.passwordErrorMessage ?? '',
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
              _RememberRow(
                label: l10n.registerRemember,
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
                label: _isSubmitting ? l10n.loginButtonLoading : l10n.loginButton,
                onPressed: _isSubmitting || _isSocialSubmitting ? null : _submit,
              ),
              const SizedBox(height: 16),
              SocialAuthButtons(
                isLoading: _isSocialSubmitting || _isSubmitting,
                onGoogle: () => _submitSocial(SocialProvider.google),
                onFacebook: () => _submitSocial(SocialProvider.facebook),
              ),
              const SizedBox(height: 20),
              Center(
                child: InkWell(
                  onTap: () =>
                      Navigator.of(context).pushReplacementNamed(AppRoutes.register),
                  child: Text.rich(
                    TextSpan(
                      text: l10n.loginRegisterPrefix,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xCC001561),
                      ),
                      children: [
                        TextSpan(
                          text: l10n.loginRegisterLink,
                          style: const TextStyle(
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
  const _RememberRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
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
        Text(
          label,
          style: const TextStyle(
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
