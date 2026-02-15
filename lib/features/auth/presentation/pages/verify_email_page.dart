import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  static const int _codeLength = 6;

  final TextEditingController _codeController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _timer;
  int _secondsLeft = 35;
  bool _showError = false;

  String get _code => _codeController.text;
  bool get _isButtonEnabled => _code.length == _codeLength;

  @override
  void initState() {
    super.initState();
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusCodeInput();
      }
    });
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

  void _onConfirm() {
    if (_isButtonEnabled) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.profileIntro);
      return;
    }
    setState(() => _showError = true);
  }

  void _focusCodeInput() {
    _focusNode.requestFocus();
    SystemChannels.textInput.invokeMethod('TextInput.show');
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                    onPressed: () => Navigator.of(context).pop(),
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
                AppStrings.verifyTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF001561),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                AppStrings.verifySubtitle,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w400,
                  color: const Color(0x80001561),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'dias@gmail.com',
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w800,
                  color: const Color(0x80001561),
                ),
              ),
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
                      AppStrings.verifyInvalidCode,
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
                  AppStrings.verifyResendNow,
                  style: textTheme.titleSmall?.copyWith(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                    color: const Color(0x80001561),
                  ),
                ),
              ] else if (_code.isEmpty) ...[
                Text(
                  _secondsLeft > 0
                      ? '${AppStrings.verifyResendInPrefix}$_secondsLeft${AppStrings.verifyResendInSuffix}'
                      : AppStrings.verifyResendNow,
                  style: textTheme.titleSmall?.copyWith(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                    color: const Color(0x80001561),
                  ),
                ),
              ],
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showError = false;
                    _codeController.clear();
                  });
                  _startTimer();
                  _focusCodeInput();
                },
                child: Text(
                  AppStrings.verifyChangeEmail,
                  style: textTheme.titleSmall?.copyWith(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                    color: const Color(0x80001561),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AppPrimaryButton(
                label: AppStrings.verifyConfirm,
                enabledColor: const Color(0xFF7C3AED),
                disabledColor: const Color(0x4D7C3AED),
                enabledTextColor: Colors.white,
                disabledTextColor: const Color(0x80FFFFFF),
                onPressed: _isButtonEnabled ? _onConfirm : null,
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
