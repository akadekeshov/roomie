import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/localization/app_error_localizer.dart';
import '../../../../core/localization/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/ui/app_snackbar.dart';
import '../../../../core/utils/onboarding_route_mapper.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../../home/data/home_providers.dart';
import '../../../people/data/favorites_users_providers.dart';
import '../../../profile/data/me_repository.dart';
import '../../data/auth_repository.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  static const _birthDateDraftKey = 'profile_birth_date_draft';
  static const _cityDraftKey = 'profile_city_draft';
  static const int _codeLength = 6;

  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _timer;

  int _secondsLeft = 35;
  bool _showError = false;
  bool _isSubmitting = false;
  bool _isResending = false;
  bool _useEmail = true;
  String _identity = '';
  String? _debugOtp;

  String get _code => _codeController.text;
  bool get _isButtonEnabled => _code.length == _codeLength;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusCodeInput();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _useEmail = args?['useEmail'] as bool? ?? true;
    _identity = args?['identity'] as String? ?? '';
    _debugOtp = args?['debugOtp'] as String?;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _codeController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 35);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_secondsLeft == 0) {
        timer.cancel();
        return;
      }
      setState(() => _secondsLeft--);
    });
  }

  void _onCodeChanged(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly != value) {
      _codeController.value = TextEditingValue(
        text: digitsOnly,
        selection: TextSelection.collapsed(offset: digitsOnly.length),
      );
    }
    setState(() => _showError = false);
  }

  Future<void> _onConfirm() async {
    if (!_isButtonEnabled || _isSubmitting) {
      setState(() => _showError = true);
      return;
    }

    setState(() {
      _isSubmitting = true;
      _showError = false;
    });

    try {
      final result = await ref.read(authRepositoryProvider).verifyRegisterOtp(
            useEmail: _useEmail,
            identity: _identity,
            code: _code,
          );

      ref.invalidate(meProvider);
      ref.invalidate(homeAutoRecommendationsProvider);
      ref.invalidate(recommendedUsersProvider);
      ref.invalidate(favoriteUsersProvider);

      if (!mounted) return;

      final nextRoute = OnboardingRouteMapper.fromStep(result.onboardingStep);
      if (nextRoute == AppRoutes.profileIntro) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_birthDateDraftKey);
        await prefs.remove(_cityDraftKey);
        if (!mounted) return;
      }

      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(nextRoute, (route) => false);
    } on AppException catch (error) {
      if (!mounted) return;
      setState(() => _showError = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.localized(context))));
    } catch (_) {
      if (!mounted) return;
      setState(() => _showError = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.errorOtpConfirmFailed)));
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _onResend() async {
    if (_secondsLeft > 0 || _isResending) return;

    setState(() => _isResending = true);
    try {
      final result = await ref
          .read(authRepositoryProvider)
          .resendOtp(useEmail: _useEmail, identity: _identity);
      if (!mounted) return;
      setState(() => _debugOtp = result.debugOtp);
      _startTimer();
      showAppSnackBar(context, context.l10n.codeResent);
    } on AppException catch (error) {
      if (!mounted) return;
      showAppSnackBar(context, error.localized(context), isError: true);
    } finally {
      if (mounted) {
        setState(() => _isResending = false);
      }
    }
  }

  Future<void> _copyDebugOtp() async {
    final code = _debugOtp;
    if (code == null || code.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: code));
    if (!mounted) return;
    showAppSnackBar(context, context.l10n.otpDebugCodeCopied);
  }

  void _focusCodeInput() {
    _focusNode.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).pushReplacementNamed(AppRoutes.register),
                    icon: const Icon(Icons.arrow_back_ios_new),
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 24,
                      minHeight: 24,
                    ),
                    color: const Color(0xFF001561),
                  ),
                  const Spacer(),
                  Text(
                    AppStrings.appBrand,
                    style: textTheme.titleMedium?.copyWith(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF001561),
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 24),
                ],
              ),
              const SizedBox(height: 28),
              Text(
                l10n.verifyTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF001561),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l10n.verifySubtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w400,
                  color: const Color(0x80001561),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _identity.isEmpty ? 'email@example.com' : _identity,
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w800,
                  color: const Color(0x80001561),
                ),
              ),
              if (_debugOtp != null && _debugOtp!.isNotEmpty) ...[
                const SizedBox(height: 18),
                InkWell(
                  onTap: _copyDebugOtp,
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F1FF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE3D8FF)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 40,
                          width: 40,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE9DFFF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.key_rounded,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.otpDebugCodeTitle,
                                style: textTheme.titleSmall?.copyWith(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF001561),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _debugOtp!,
                                style: textTheme.titleLarge?.copyWith(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 4,
                                  color: const Color(0xFF7C3AED),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n.otpDebugCodeHint,
                                style: textTheme.bodySmall?.copyWith(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0x99001561),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.copy_rounded,
                          color: Color(0xFF7C3AED),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 26),
              GestureDetector(
                onTap: _focusCodeInput,
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 220,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(_codeLength, (index) {
                          final hasDigit = index < _code.length;
                          return SizedBox(
                            width: 28,
                            child: Center(
                              child: Text(
                                hasDigit ? _code[index] : '\u2022',
                                style: textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w400,
                                  color: hasDigit
                                      ? const Color(0xFF001561)
                                      : const Color(0x80828DB7),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.01,
                          child: TextField(
                            controller: _codeController,
                            focusNode: _focusNode,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            maxLength: _codeLength,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(_codeLength),
                            ],
                            onChanged: _onCodeChanged,
                            cursorColor: Colors.transparent,
                            style: const TextStyle(color: Colors.transparent),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (_showError) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error, color: Color(0xFFFF0D0D), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      l10n.verifyInvalidCode,
                      style: textTheme.bodyMedium?.copyWith(
                        fontFamily: 'Gilroy',
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFFFF0D0D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.verifyResendNow,
                  style: textTheme.titleSmall?.copyWith(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                    color: const Color(0x80001561),
                  ),
                ),
              ] else if (_code.isEmpty) ...[
                Text(
                  _secondsLeft > 0
                      ? l10n.verifyResendIn(_secondsLeft)
                      : l10n.verifyResendNow,
                  style: textTheme.titleSmall?.copyWith(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                    color: const Color(0x80001561),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: _secondsLeft == 0 ? _onResend : null,
                child: Text(
                  _secondsLeft == 0
                      ? l10n.verifyResendNow
                      : l10n.verifyChangeEmail,
                  style: textTheme.titleSmall?.copyWith(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                    color: const Color(0x80001561),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AppPrimaryButton(
                label: l10n.verifyConfirm,
                enabledColor: const Color(0xFF7C3AED),
                disabledColor: const Color(0x4D7C3AED),
                enabledTextColor: Colors.white,
                disabledTextColor: const Color(0x80FFFFFF),
                onPressed:
                    (_isButtonEnabled && !_isSubmitting) ? _onConfirm : null,
                textStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).viewInsets.bottom > 0 ? 8 : 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
