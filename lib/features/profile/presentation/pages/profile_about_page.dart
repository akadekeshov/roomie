import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';
import '../data/profile_cities.dart';
import '../widgets/profile_flow_header.dart';
import '../widgets/profile_step_progress.dart';

class ProfileAboutPage extends StatefulWidget {
  const ProfileAboutPage({super.key});

  @override
  State<ProfileAboutPage> createState() => _ProfileAboutPageState();
}

class _ProfileAboutPageState extends State<ProfileAboutPage> {
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  int? _selectedStatus;
  String? _selectedCity;

  bool get _isValid =>
      _selectedStatus != null &&
      _universityController.text.trim().isNotEmpty &&
      _ageController.text.trim().isNotEmpty &&
      _selectedCity != null;

  @override
  void dispose() {
    _universityController.dispose();
    _ageController.dispose();
    super.dispose();
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
              const ProfileFlowHeader(
                progress: ProfileStepProgress(activeStep: 1),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u0420\u0430\u0441\u0441\u043a\u0430\u0436\u0438\u0442\u0435 \u043e \u0441\u0435\u0431\u0435',
                        style: textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Label(text: '\u042f'),
                      const SizedBox(height: 8),
                      _OptionButton(
                        label: '\u0423\u0447\u0443\u0441\u044c',
                        selected: _selectedStatus == 0,
                        onTap: () => setState(() => _selectedStatus = 0),
                      ),
                      const SizedBox(height: 8),
                      _OptionButton(
                        label: '\u0420\u0430\u0431\u043e\u0442\u0430\u044e',
                        selected: _selectedStatus == 1,
                        onTap: () => setState(() => _selectedStatus = 1),
                      ),
                      const SizedBox(height: 8),
                      _OptionButton(
                        label:
                            '\u0423\u0447\u0443\u0441\u044c \u0438 \u0440\u0430\u0431\u043e\u0442\u0430\u044e',
                        selected: _selectedStatus == 2,
                        onTap: () => setState(() => _selectedStatus = 2),
                      ),
                      const SizedBox(height: 20),
                      _Label(
                        text:
                            '\u0423\u0447\u0435\u0431\u043d\u043e\u0435 \u0437\u0430\u0432\u0435\u0434\u0435\u043d\u0438\u0435',
                      ),
                      const SizedBox(height: 8),
                      _TextInput(
                        controller: _universityController,
                        hint:
                            '\u041d\u0430\u0447\u043d\u0438\u0442\u0435 \u0432\u0432\u043e\u0434\u0438\u0442\u044c...',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      _Label(
                        text: '\u0412\u043e\u0437\u0440\u0430\u0441\u0442',
                      ),
                      const SizedBox(height: 8),
                      _TextInput(
                        controller: _ageController,
                        hint: '18',
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 20),
                      _Label(text: '\u0413\u043e\u0440\u043e\u0434'),
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
                label:
                    '\u041f\u0440\u043e\u0434\u043e\u043b\u0436\u0438\u0442\u044c',
                onPressed: _isValid
                    ? () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.profileLifestyle)
                    : null,
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
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
          value ??
              '\u0412\u044b\u0431\u0435\u0440\u0438\u0442\u0435 \u0441\u0432\u043e\u0439 \u0433\u043e\u0440\u043e\u0434...',
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
                  hintText: '\u041f\u043e\u0438\u0441\u043a',
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
                label: '\u0412\u044b\u0431\u0440\u0430\u0442\u044c',
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
