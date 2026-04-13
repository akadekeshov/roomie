import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/filter_providers.dart';

class FilterPage extends ConsumerStatefulWidget {
  const FilterPage({super.key});

  @override
  ConsumerState<FilterPage> createState() => _FilterPageState();
}

class _FilterPageState extends ConsumerState<FilterPage> {
  static const double _minBudget = 50000;
  static const double _maxBudget = 500000;

  static const List<String> _districts = [
    'Алмалинский',
    'Ауэзовский',
    'Бостандыкский',
    'Жетысуский',
    'Медеуский',
    'Наурызбайский',
    'Турксибский',
  ];

  late RangeValues _budgetRange;
  String? _district;
  String? _gender;
  String? _petsPreference;
  String? _smokingPreference;
  String? _noisePreference;

  @override
  void initState() {
    super.initState();

    final state = ref.read(filterStateProvider);

    final start = (state.priceMin?.toDouble() ?? _minBudget).clamp(
      _minBudget,
      _maxBudget,
    );
    final end = (state.priceMax?.toDouble() ?? _maxBudget).clamp(
      _minBudget,
      _maxBudget,
    );

    _budgetRange = RangeValues(
      start <= end ? start : _minBudget,
      start <= end ? end : _maxBudget,
    );

    _district = state.district;
    _gender = state.gender;
    _petsPreference = state.petsPreference;
    _smokingPreference = state.smokingPreference;
    _noisePreference = state.noisePreference;
  }

  void _applyFilters() {
    final controller = ref.read(filterStateProvider.notifier);

    final isDefaultBudget =
        _budgetRange.start.round() == _minBudget.round() &&
        _budgetRange.end.round() == _maxBudget.round();

    controller.setDistrict(_district);
    controller.setPriceRange(
      isDefaultBudget ? null : _budgetRange.start.round(),
      isDefaultBudget ? null : _budgetRange.end.round(),
    );
    controller.setGender(_gender);
    controller.setPetsPreference(_petsPreference);
    controller.setSmokingPreference(_smokingPreference);
    controller.setNoisePreference(_noisePreference);

    ref.invalidate(filteredUsersProvider);

    Navigator.of(context).pop();
  }

  void _resetFilters() {
    setState(() {
      _budgetRange = const RangeValues(_minBudget, _maxBudget);
      _district = null;
      _gender = null;
      _petsPreference = null;
      _smokingPreference = null;
      _noisePreference = null;
    });

    ref.read(filterStateProvider.notifier).clear();
    ref.invalidate(filteredUsersProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF001561)),
        title: const Text(
          'Фильтры',
          style: TextStyle(
            color: Color(0xFF001561),
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _resetFilters,
            child: const Text(
              'Сбросить',
              style: TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Район',
                      style: TextStyle(
                        color: Color(0xFF001561),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String?>(
                      value: _district,
                      hint: const Text('Выберите район'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E5ED),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E5ED),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('Любой район'),
                        ),
                        ..._districts.map(
                          (district) => DropdownMenuItem<String?>(
                            value: district,
                            child: Text(district),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _district = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Бюджет на аренду',
                      style: TextStyle(
                        color: Color(0xFF001561),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          RangeSlider(
                            min: _minBudget,
                            max: _maxBudget,
                            values: _budgetRange,
                            divisions: 9,
                            labels: RangeLabels(
                              _budgetRange.start.round().toString(),
                              _budgetRange.end.round().toString(),
                            ),
                            onChanged: (RangeValues values) {
                              setState(() {
                                _budgetRange = values;
                              });
                            },
                          ),
                          Text(
                            'От ${_budgetRange.start.round()} до ${_budgetRange.end.round()} тг/месяц',
                            style: const TextStyle(
                              color: Color(0xFFA3A8B9),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Пол соседа',
                      style: TextStyle(
                        color: Color(0xFF001561),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ChoiceChipsRow<String?>(
                      value: _gender,
                      onChanged: (value) {
                        setState(() {
                          _gender = value;
                        });
                      },
                      items: const [
                        (null, 'Не важно'),
                        ('FEMALE', 'Женский'),
                        ('MALE', 'Мужской'),
                        ('OTHER', 'Другое'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Животные',
                      style: TextStyle(
                        color: Color(0xFF001561),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ChoiceChipsRow<String?>(
                      value: _petsPreference,
                      onChanged: (value) {
                        setState(() {
                          _petsPreference = value;
                        });
                      },
                      items: const [
                        (null, 'Не важно'),
                        ('WITH_PETS', 'С животными'),
                        ('NO_PETS', 'Без животных'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Курение',
                      style: TextStyle(
                        color: Color(0xFF001561),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ChoiceChipsRow<String?>(
                      value: _smokingPreference,
                      onChanged: (value) {
                        setState(() {
                          _smokingPreference = value;
                        });
                      },
                      items: const [
                        (null, 'Не важно'),
                        ('NON_SMOKER', 'Некурящий'),
                        ('SMOKER', 'Курящий'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Образ жизни / шум',
                      style: TextStyle(
                        color: Color(0xFF001561),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _ChoiceChipsRow<String?>(
                      value: _noisePreference,
                      onChanged: (value) {
                        setState(() {
                          _noisePreference = value;
                        });
                      },
                      items: const [
                        (null, 'Не важно'),
                        ('QUIET', 'Тихий'),
                        ('SOCIAL', 'Коммуникабельный'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: _applyFilters,
                  child: const Text(
                    'Применить фильтры',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChipsRow<T> extends StatelessWidget {
  const _ChoiceChipsRow({
    required this.value,
    required this.onChanged,
    required this.items,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final List<(T, String)> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        final selected = item.$1 == value;

        return ChoiceChip(
          label: Text(item.$2),
          selected: selected,
          onSelected: (_) => onChanged(item.$1),
          selectedColor: AppColors.primary,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: selected ? AppColors.primary : const Color(0xFFE5E7EB),
            ),
          ),
          labelStyle: TextStyle(
            color: selected ? Colors.white : const Color(0xFF111827),
            fontWeight: FontWeight.w600,
          ),
        );
      }).toList(),
    );
  }
}