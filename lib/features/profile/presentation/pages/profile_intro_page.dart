import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/birth_date_utils.dart';
import '../../../../core/utils/onboarding_route_mapper.dart';
import '../../data/onboarding_repository.dart';

class ProfileIntroPage extends ConsumerStatefulWidget {
  const ProfileIntroPage({super.key});

  @override
  ConsumerState<ProfileIntroPage> createState() => _ProfileIntroPageState();
}

class _ProfileIntroPageState extends ConsumerState<ProfileIntroPage> {
  static const _birthDateDraftKey = 'profile_birth_date_draft';
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _ageFocusNode = FocusNode();
  bool _showError = false;
  bool _isSubmitting = false;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      BirthDateUtils.isCompleteDateInput(_ageController.text);

  @override
  void initState() {
    super.initState();
    _restoreBirthDateDraft();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _nameFocusNode.requestFocus();
      SystemChannels.textInput.invokeMethod('TextInput.show');
    });
  }

  Future<void> _restoreBirthDateDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_birthDateDraftKey);
    if (value == null || value.isEmpty || !mounted) return;
    _ageController.text = value;
    setState(() {});
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _nameFocusNode.dispose();
    _ageFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    if (!_isValid || _isSubmitting) {
      setState(() => _showError = true);
      return;
    }
    final age = BirthDateUtils.ageFromInput(_ageController.text);
    if (age == null) {
      setState(() => _showError = true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введите корректный возраст или дату рождения'),
        ),
      );
      return;
    }

    setState(() {
      _showError = false;
      _isSubmitting = true;
    });
    try {
      final result = await ref
          .read(onboardingRepositoryProvider)
          .submitNameAge(
            NameAgePayload(firstName: _nameController.text.trim(), age: age),
          );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_birthDateDraftKey, _ageController.text.trim());
      if (!mounted) return;
      final route = OnboardingRouteMapper.fromStep(result.nextStep);
      Navigator.of(context).pushReplacementNamed(route);
    } on DioException catch (e) {
      if (!mounted) return;
      final serverMessage = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;
      final message = (serverMessage != null && serverMessage.isNotEmpty)
          ? serverMessage
          : 'Ошибка сохранения. Попробуйте снова.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось сохранить данные')),
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

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushReplacementNamed(AppRoutes.verifyEmail),
                                icon: const Icon(Icons.arrow_back_ios_new),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 24,
                                  minHeight: 24,
                                ),
                                iconSize: 18,
                                color: const Color(0xFF001561),
                              ),
                            ),
                            Text(
                              AppStrings.appBrand,
                              style: textTheme.titleMedium?.copyWith(
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF001561),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Text(
                                AppStrings.profileRuTitle,
                                style: textTheme.headlineSmall?.copyWith(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF001561),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                AppStrings.profileRuSubtitle,
                                style: textTheme.bodyLarge?.copyWith(
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0x80001561),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            const _FieldLabel(
                              text: AppStrings.profileRuNameLabel,
                            ),
                            const SizedBox(height: 8),
                            _Input(
                              controller: _nameController,
                              focusNode: _nameFocusNode,
                              hint: AppStrings.profileRuNameHint,
                              onChanged: (_) {
                                if (_showError) {
                                  setState(() => _showError = false);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            const _FieldLabel(
                              text: AppStrings.profileRuAgeLabel,
                            ),
                            const SizedBox(height: 8),
                            _Input(
                              controller: _ageController,
                              focusNode: _ageFocusNode,
                              hint: AppStrings.profileRuAgeHint,
                              keyboardType: TextInputType.number,
                              inputFormatters: const [
                                BirthDateInputFormatter(),
                              ],
                              onChanged: (_) {
                                if (_showError) {
                                  setState(() => _showError = false);
                                }
                              },
                            ),
                            const SizedBox(height: 20),
                            if (_showError)
                              Row(
                                children: [
                                  const Icon(
                                    Icons.error,
                                    color: Color(0xFFFF0D0D),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppStrings.profileRuFillAll,
                                    style: textTheme.bodySmall?.copyWith(
                                      fontFamily: 'Gilroy',
                                      fontWeight: FontWeight.w400,
                                      color: const Color(0xFFFF0D0D),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.resolveWith(
                                (states) => _isValid
                                    ? const Color(0xFF7C3AED)
                                    : const Color(0x4D7C3AED),
                              ),
                              foregroundColor: WidgetStateProperty.resolveWith(
                                (states) => _isValid
                                    ? Colors.white
                                    : const Color(0x80FFFFFF),
                              ),
                              padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(vertical: 14),
                              ),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                            onPressed: _isSubmitting ? null : _onContinue,
                            child: const Text(
                              AppStrings.profileContinue,
                              style: TextStyle(
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                height: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            );
          },
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
        fontWeight: FontWeight.w600,
        fontSize: 14,
        height: 18 / 14,
        color: Color(0xFF001561),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      onTap: () => SystemChannels.textInput.invokeMethod('TextInput.show'),
      style: const TextStyle(
        fontFamily: 'Gilroy',
        fontWeight: FontWeight.w600,
        fontSize: 16,
        height: 20 / 16,
        color: Color(0xFF001561),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontFamily: 'Gilroy',
          fontWeight: FontWeight.w600,
          fontSize: 16,
          height: 20 / 16,
          color: Color(0x33001561),
        ),
        filled: true,
        fillColor: const Color(0x1A7C3AED),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}
