import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_primary_button.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  String? _selectedCity;

  static const List<String> _cities = [
    'Астана',
    'Актобе',
    'Алматы',
    'Талдыкорган',
    'Тараз',
    'Шымкент',
    'Жезказган',
    'Орал',
    'Семей',
    'Караганда',
    'Костанай',
    'Кызылорда',
    'Павлодар',
    'Петропавловск',
    'Усть-Каменогорск',
    'Туркестан',
    'Атырау',
    'Актау',
  ];

  Future<void> _openCitiesSheet() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CityPickerSheet(
        cities: _cities,
        selected: _selectedCity,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedCity = result;
      });
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
                      onPressed: () => Navigator.of(context).pop(),
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
                    'Roomie',
                    style: textTheme.titleMedium?.copyWith(
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF001561),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'Где вы находитесь?',
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
                  _selectedCity ?? 'Ваш город',
                  style: textTheme.displaySmall?.copyWith(
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w600,
                    color: (_selectedCity == null
                            ? const Color(0x80001561)
                            : const Color(0xFF001561))
                        .withValues(alpha: _selectedCity == null ? 0.5 : 1),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Пропустить',
                style: textTheme.titleSmall?.copyWith(
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w600,
                  color: const Color(0x33001561),
                ),
              ),
              const SizedBox(height: 18),
              AppPrimaryButton(
                label: 'Продолжить',
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.home),
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
  const _CityPickerSheet({
    required this.cities,
    required this.selected,
  });

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

    return Container(
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
              separatorBuilder: (_, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final city = filtered[index];
                final active = city == _selected;
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => setState(() => _selected = city),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: active ? const Color(0x337C3AED) : Colors.transparent,
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
              onPressed:
                  _selected == null ? null : () => Navigator.of(context).pop(_selected),
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
    );
  }
}
