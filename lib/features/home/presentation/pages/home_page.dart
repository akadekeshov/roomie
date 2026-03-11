import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../profile/presentation/data/profile_cities.dart';
import '../../data/home_providers.dart';
import '../../data/recommended_user_model.dart';
import 'package:roommate_app/features/people/data/favorites_users_providers.dart';
import 'package:roommate_app/features/people/data/hidden_users_provider.dart';
import 'package:roommate_app/features/people/ui/recommended_user_profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _hideUser(RecommendedUser user) async {
    final repo = ref.read(homeRepositoryProvider);

    try {
      if (user.isSaved) {
        await repo.unsaveUser(user.id);
      }

      ref.read(hiddenUserIdsProvider.notifier).hide(user.id);
      ref.invalidate(recommendedUsersProvider);
      ref.invalidate(favoriteUsersProvider);

      _msg('Скрыто');
    } catch (e) {
      _msg('Ошибка: $e');
    }
  }

  Future<void> _toggleSave(RecommendedUser user) async {
    final repo = ref.read(homeRepositoryProvider);

    try {
      if (user.isSaved) {
        await repo.unsaveUser(user.id);
        _msg('Удалено из избранного');
      } else {
        await repo.saveUser(user.id);
        _msg('Сохранено');
      }

      ref.invalidate(recommendedUsersProvider);
      ref.invalidate(favoriteUsersProvider);
    } catch (e) {
      _msg('Ошибка: $e');
    }
  }

  void _openDetails(RecommendedUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecommendedUserProfilePage(user: user),
      ),
    );
  }

  Future<void> _openFilters() async {
    final current = ref.read(homeSearchFiltersProvider);
    final result = await showModalBottomSheet<HomeSearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FiltersSheet(initial: current),
    );
    if (result == null) return;
    ref.read(homeSearchFiltersProvider.notifier).setFilters(result);
    ref.invalidate(recommendedUsersProvider);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final asyncUsers = ref.watch(recommendedUsersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    'Поиск соседей',
                    style: textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF001561),
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _openFilters,
                    icon: const Icon(Icons.tune, color: Color(0xFF001561)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: asyncUsers.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Ошибка: $e')),
                  data: (users) {
                    final hiddenIds = ref.watch(hiddenUserIdsProvider);
                    final visible =
                        users.where((u) => !hiddenIds.contains(u.id)).toList();

                    if (visible.isEmpty) {
                      return const Center(child: Text('Нет подходящих анкет'));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(recommendedUsersProvider);
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final user = visible[index];
                          return _RoommateCard(
                            user: user,
                            onHide: () => _hideUser(user),
                            onSave: () => _toggleSave(user),
                            onOpen: () => _openDetails(user),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoommateCard extends StatelessWidget {
  const _RoommateCard({
    required this.user,
    required this.onHide,
    required this.onSave,
    required this.onOpen,
  });

  final RecommendedUser user;
  final VoidCallback onHide;
  final VoidCallback onSave;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final photo = user.avatarUrl;

    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (photo != null)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.23,
                      child: Image.network(photo, fit: BoxFit.cover),
                    ),
                    Positioned(
                      right: 12,
                      bottom: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0x801C1C1D),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: Color(0xFF00C853),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Подтверждён',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName,
                    style: textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF001561),
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.map_outlined,
                    label: 'Локация',
                    value: user.locationText,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Статус',
                    value: user.statusText,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Бюджет',
                    value: user.budgetText,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionOutlinedButton(
                          icon: Icons.block,
                          label: 'Скрыть',
                          onTap: onHide,
                          isActive: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionOutlinedButton(
                          icon: user.isSaved
                              ? Icons.favorite
                              : Icons.favorite_border,
                          label: user.isSaved ? 'Сохранено' : 'Сохранить',
                          onTap: onSave,
                          isActive: user.isSaved,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 4),
        SizedBox(
          width: 58,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF7F889D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: textTheme.titleMedium?.copyWith(
              color: const Color(0xFF001561),
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ActionOutlinedButton extends StatelessWidget {
  const _ActionOutlinedButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isActive ? AppColors.primary : const Color(0xFF9CA3AF),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : const Color(0xFF6B7280),
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isActive ? Colors.white : const Color(0xFF707070),
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({required this.initial});

  final HomeSearchFilters initial;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  static const _budgetMin = 50000;
  static const _budgetMax = 500000;

  late double _budget;
  String? _district;
  String? _gender;
  String? _ageRange;

  @override
  void initState() {
    super.initState();
    _budget = (widget.initial.budgetMax ?? _budgetMax).toDouble();
    _district = widget.initial.district;
    _gender = widget.initial.gender;
    _ageRange = widget.initial.ageRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Фильтры поиска',
                    style: TextStyle(
                      color: Color(0xFF001561),
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const Text(
              'Настройте параметры для поиска идеального соседа',
              style: TextStyle(color: Color(0xFFA3A8B9), fontSize: 12),
            ),
            const SizedBox(height: 12),
            const Text(
              'Бюджет на аренду',
              style: TextStyle(
                color: Color(0xFF001561),
                fontWeight: FontWeight.w700,
              ),
            ),
            Slider(
              min: _budgetMin.toDouble(),
              max: _budgetMax.toDouble(),
              value: _budget.clamp(_budgetMin.toDouble(), _budgetMax.toDouble()),
              onChanged: (v) => setState(() => _budget = v),
            ),
            Text(
              'До ${_budget.round()} тг/месяц',
              style: const TextStyle(color: Color(0xFFA3A8B9), fontSize: 13),
            ),
            const SizedBox(height: 14),
            const Text(
              'Район',
              style: TextStyle(
                color: Color(0xFF001561),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _district,
              hint: const Text('Выберите район'),
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E5ED)),
                ),
              ),
              items: [
                const DropdownMenuItem<String>(
                  value: 'Все районы',
                  child: Text('Все районы'),
                ),
                ...ProfileCities.values.map(
                  (city) => DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _district = v),
            ),
            const SizedBox(height: 14),
            const Text(
              'Пол соседа',
              style: TextStyle(
                color: Color(0xFF001561),
                fontWeight: FontWeight.w700,
              ),
            ),
            _DotRadioLine<String?>(
              label: 'Не важно',
              value: null,
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v),
            ),
            _DotRadioLine<String?>(
              label: 'Женский',
              value: 'FEMALE',
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v),
            ),
            _DotRadioLine<String?>(
              label: 'Мужской',
              value: 'MALE',
              groupValue: _gender,
              onChanged: (v) => setState(() => _gender = v),
            ),
            const SizedBox(height: 12),
            const Text(
              'Возраст',
              style: TextStyle(
                color: Color(0xFF001561),
                fontWeight: FontWeight.w700,
              ),
            ),
            _DotRadioLine<String?>(
              label: 'Не важно',
              value: null,
              groupValue: _ageRange,
              onChanged: (v) => setState(() => _ageRange = v),
            ),
            _DotRadioLine<String?>(
              label: '18-25',
              value: '18-25',
              groupValue: _ageRange,
              onChanged: (v) => setState(() => _ageRange = v),
            ),
            _DotRadioLine<String?>(
              label: '25+',
              value: '25+',
              groupValue: _ageRange,
              onChanged: (v) => setState(() => _ageRange = v),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(
                    context,
                    HomeSearchFilters(
                      budgetMax: _budget.round(),
                      district: (_district == null || _district == 'Все районы')
                          ? null
                          : _district,
                      gender: _gender,
                      ageRange: _ageRange,
                    ),
                  );
                },
                child: const Text(
                  'Применить',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
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

class _DotRadioLine<T> extends StatelessWidget {
  const _DotRadioLine({
    required this.label,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  final String label;
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: 7,
              color: selected ? const Color(0xFF111827) : const Color(0xFFBFC4D2),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF111827))),
          ],
        ),
      ),
    );
  }
}
