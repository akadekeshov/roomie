import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/birth_date_utils.dart';
import '../../../../core/utils/onboarding_route_mapper.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../data/profile_cities.dart';
import '../../data/onboarding_repository.dart';
import '../widgets/profile_flow_header.dart';
import '../widgets/profile_step_progress.dart';

class ProfileAboutPage extends ConsumerStatefulWidget {
  const ProfileAboutPage({super.key});

  @override
  ConsumerState<ProfileAboutPage> createState() => _ProfileAboutPageState();
}

class _ProfileAboutPageState extends ConsumerState<ProfileAboutPage> {
  static const _birthDateDraftKey = 'profile_birth_date_draft';
  static const _cityDraftKey = 'profile_city_draft';

  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  int? _selectedStatus;
  String? _selectedCity;
  bool _isSubmitting = false;

  bool get _isValid =>
      _selectedStatus != null &&
      _universityController.text.trim().isNotEmpty &&
      BirthDateUtils.isCompleteDateInput(_ageController.text) &&
      _selectedCity != null;

  @override
  void initState() {
    super.initState();
    _restoreDrafts();
    _prefillFromStatus();
  }

  @override
  void dispose() {
    _universityController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _restoreDrafts() async {
    final prefs = await SharedPreferences.getInstance();
    final birthDate = prefs.getString(_birthDateDraftKey);
    final city = prefs.getString(_cityDraftKey);
    if (!mounted) return;
    setState(() {
      if (birthDate != null && birthDate.isNotEmpty) {
        _ageController.text = birthDate;
      }
      if (city != null && city.isNotEmpty) {
        _selectedCity = city;
      }
    });
  }

  Future<void> _prefillFromStatus() async {
    try {
      final status = await ref.read(onboardingRepositoryProvider).getStatus();
      final profile = status.profile;
      final occupation = profile['occupationStatus'] as String?;
      final university = profile['university'] as String?;
      final city = profile['city'] as String?;
      final age = profile['age'] as int?;

      if (!mounted) return;
      setState(() {
        if (occupation == 'STUDY') _selectedStatus = 0;
        if (occupation == 'WORK') _selectedStatus = 1;
        if (occupation == 'STUDY_WORK') _selectedStatus = 2;
        if (university != null && university.isNotEmpty) {
          _universityController.text = university;
        }
        if (city != null && city.isNotEmpty) {
          _selectedCity = city;
        }
        if (age != null && _ageController.text.trim().isEmpty) {
          _ageController.text = age.toString();
        }
      });
    } catch (_) {
      // Keep usable without prefill.
    }
  }

  String _mapStatus(int status) {
    switch (status) {
      case 0:
        return 'STUDY';
      case 1:
        return 'WORK';
      default:
        return 'STUDY_WORK';
    }
  }

  Future<void> _submit() async {
    if (!_isValid || _selectedStatus == null || _selectedCity == null) return;
    final age = BirthDateUtils.ageFromInput(_ageController.text);
    if (age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите корректную дату рождения')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final nextStep =
          await ref.read(onboardingRepositoryProvider).submitAboutStep(
                AboutStepPayload(
                  occupationStatus: _mapStatus(_selectedStatus!),
                  university: _universityController.text.trim(),
                  age: age,
                  city: _selectedCity!,
                ),
              );
      if (!mounted) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_birthDateDraftKey, _ageController.text.trim());
      await prefs.setString(_cityDraftKey, _selectedCity!);
      if (!mounted) return;

      final route = OnboardingRouteMapper.fromStep(nextStep);
      Navigator.of(context).pushNamed(route);
    } on DioException catch (e) {
      if (!mounted) return;
      final serverMessage = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(serverMessage ?? 'Не удалось сохранить шаг')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _openCitiesSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      sheetAnimationStyle: const AnimationStyle(
        duration: Duration(milliseconds: 360),
        reverseDuration: Duration(milliseconds: 260),
      ),
      builder: (context) {
        return AnimatedPadding(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: _CityPickerSheet(
            cities: ProfileCities.values,
            selected: _selectedCity,
          ),
        );
      },
    );

    if (result != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cityDraftKey, result);
      setState(() => _selectedCity = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            children: [
              ProfileFlowHeader(
                progress: const ProfileStepProgress(activeStep: 1),
                onBack: () => Navigator.of(
                  context,
                ).pushReplacementNamed(AppRoutes.profile),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Расскажите о себе',
                        style: textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _Label(text: 'Я'),
                      const SizedBox(height: 8),
                      _OptionButton(
                        label: 'Учусь',
                        selected: _selectedStatus == 0,
                        onTap: () => setState(() => _selectedStatus = 0),
                      ),
                      const SizedBox(height: 8),
                      _OptionButton(
                        label: 'Работаю',
                        selected: _selectedStatus == 1,
                        onTap: () => setState(() => _selectedStatus = 1),
                      ),
                      const SizedBox(height: 8),
                      _OptionButton(
                        label: 'Учусь и работаю',
                        selected: _selectedStatus == 2,
                        onTap: () => setState(() => _selectedStatus = 2),
                      ),
                      const SizedBox(height: 20),
                      const _Label(text: 'Учебное заведение'),
                      const SizedBox(height: 8),
                      _TextInput(
                        controller: _universityController,
                        hint: 'Начните вводить...',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      const _Label(text: 'День рождения'),
                      const SizedBox(height: 8),
                      _TextInput(
                        controller: _ageController,
                        hint: 'дд.мм.гггг',
                        keyboardType: TextInputType.number,
                        inputFormatters: const [BirthDateInputFormatter()],
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      const _Label(text: 'Город'),
                      const SizedBox(height: 8),
                      _CitySelectField(
                        value: _selectedCity,
                        onTap: _openCitiesSheet,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AppPrimaryButton(
                label: _isSubmitting ? 'Сохранение...' : 'Продолжить',
                onPressed: (_isValid && !_isSubmitting) ? _submit : null,
                textStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: const Color(0xFF4E556F),
            fontWeight: FontWeight.w500,
          ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFFC6CAD6),
          ),
          color: selected ? const Color(0x147C3AED) : Colors.transparent,
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF001561),
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}

class _TextInput extends StatelessWidget {
  const _TextInput({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: const TextStyle(
        color: Color(0xFF001561),
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFB0B5C5),
          fontWeight: FontWeight.w600,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC6CAD6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}

class _CitySelectField extends StatelessWidget {
  const _CitySelectField({required this.value, required this.onTap});

  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC6CAD6)),
        ),
        child: Text(
          value ?? 'Выберите свой город...',
          style: TextStyle(
            color: value == null
                ? const Color(0xFFB0B5C5)
                : const Color(0xFF001561),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  const _CityPickerSheet({required this.cities, required this.selected});

  final List<String> cities;
  final String? selected;

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final query = _searchController.text.trim().toLowerCase();
    final filtered =
        widget.cities.where((c) => c.toLowerCase().contains(query)).toList();

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 26),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0x1A001561),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Поиск',
                  hintStyle: const TextStyle(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w400,
                    color: Color(0x80001561),
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0x80001561),
                  ),
                  filled: true,
                  fillColor: const Color(0x1A7C3AED),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final city = filtered[index];
                  final active = city == _selected;
                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => setState(() => _selected = city),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: active
                            ? const Color(0x337C3AED)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              city,
                              style: textTheme.titleLarge?.copyWith(
                                fontFamily: 'Gilroy',
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF001561),
                              ),
                            ),
                          ),
                          if (active)
                            const Icon(Icons.check, color: Color(0xFF001561)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
              child: AppPrimaryButton(
                label: 'Выбрать',
                onPressed: _selected == null
                    ? null
                    : () => Navigator.of(context).pop(_selected),
                textStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  height: 1,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
