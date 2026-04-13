import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/onboarding_route_mapper.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../../data/onboarding_repository.dart';

class LocationPage extends ConsumerStatefulWidget {
  const LocationPage({super.key});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  static const _cityDraftKey = 'profile_city_draft';
  String? _selectedCity;
  bool _isSubmitting = false;

  static const List<String> _cities = [
    '\u0410\u0441\u0442\u0430\u043d\u0430',
    '\u0410\u043a\u0442\u043e\u0431\u0435',
    '\u0410\u043b\u043c\u0430\u0442\u044b',
    '\u0422\u0430\u043b\u0434\u044b\u043a\u043e\u0440\u0433\u0430\u043d',
    '\u0422\u0430\u0440\u0430\u0437',
    '\u0428\u044b\u043c\u043a\u0435\u043d\u0442',
    '\u0416\u0435\u0437\u043a\u0430\u0437\u0433\u0430\u043d',
    '\u041e\u0440\u0430\u043b',
    '\u0421\u0435\u043c\u0435\u0439',
    '\u041a\u0430\u0440\u0430\u0433\u0430\u043d\u0434\u0430',
    '\u041a\u043e\u0441\u0442\u0430\u043d\u0430\u0439',
    '\u041a\u044b\u0437\u044b\u043b\u043e\u0440\u0434\u0430',
    '\u041f\u0430\u0432\u043b\u043e\u0434\u0430\u0440',
    '\u041f\u0435\u0442\u0440\u043e\u043f\u0430\u0432\u043b\u043e\u0432\u0441\u043a',
    '\u0423\u0441\u0442\u044c-\u041a\u0430\u043c\u0435\u043d\u043e\u0433\u043e\u0440\u0441\u043a',
    '\u0422\u0443\u0440\u043a\u0435\u0441\u0442\u0430\u043d',
    '\u0410\u0442\u044b\u0440\u0430\u0443',
    '\u0410\u043a\u0442\u0430\u0443',
  ];

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
          child: _CityPickerSheet(cities: _cities, selected: _selectedCity),
        );
      },
    );

    if (result != null) {
      setState(() => _selectedCity = result);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cityDraftKey, result);
    }
  }

  Future<void> _onContinue() async {
    final city = _selectedCity;
    if (city == null || _isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      final result =
          await ref.read(onboardingRepositoryProvider).submitCity(city);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cityDraftKey, city);
      if (!mounted) return;
      final route = OnboardingRouteMapper.fromStep(result.nextStep);
      Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
    } on DioException catch (e) {
      if (!mounted) return;
      final serverMessage = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message']?.toString())
          : null;
      final message = (serverMessage != null && serverMessage.isNotEmpty)
          ? serverMessage
          : 'Не удалось сохранить город';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
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
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.gender),
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
              const SizedBox(height: 20),
              Text(
                AppStrings.locationTitle,
                style: textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF001561),
                ),
              ),
              const SizedBox(height: 140),
              GestureDetector(
                onTap: _openCitiesSheet,
                child: Text(
                  _selectedCity ?? AppStrings.locationYourCity,
                  style: textTheme.displaySmall?.copyWith(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                    color: _selectedCity == null
                        ? const Color(0x80001561)
                        : const Color(0xFF001561),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                AppStrings.locationSkip,
                style: textTheme.titleSmall?.copyWith(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w600,
                  color: const Color(0x33001561),
                ),
              ),
              const SizedBox(height: 18),
              AppPrimaryButton(
                label: AppStrings.profileContinue,
                onPressed: (_selectedCity != null && !_isSubmitting)
                    ? _onContinue
                    : null,
                textStyle: const TextStyle(
                  fontFamily: 'Gilroy',
                  fontSize: 16,
                  height: 1,
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
    final filtered = widget.cities
        .where((city) => city.toLowerCase().contains(query))
        .toList();

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
                  hintText: AppStrings.locationSearch,
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
                separatorBuilder: (_, index) => const SizedBox(height: 8),
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
                label: AppStrings.locationPick,
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
