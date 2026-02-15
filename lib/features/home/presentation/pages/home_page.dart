import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  late final List<_RoommateProfile> _profiles;

  @override
  void initState() {
    super.initState();
    final allProfiles = <_RoommateProfile>[
      const _RoommateProfile(
        name: 'Диана Ерланова',
        age: 26,
        location: 'Ауезовский район',
        status: 'Работает и учится',
        budget: '50 000-100 000 /месяц',
        imageUrl:
            'https://images.unsplash.com/photo-1525134479668-1bee5c7c6845?w=1400&auto=format&fit=crop',
        verified: true,
      ),
      const _RoommateProfile(
        name: 'Еркебулан Нурлан',
        age: 24,
        location: 'Бостандыкский район',
        status: 'Работает в IT',
        budget: '90 000-140 000 /месяц',
        imageUrl:
            'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=1400&auto=format&fit=crop',
        verified: false,
      ),
      const _RoommateProfile(
        name: 'Алина Тулеу',
        age: 23,
        location: 'Алмалинский район',
        status: 'Студент и фрилансер',
        budget: '70 000-120 000 /месяц',
        imageUrl:
            'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=1400&auto=format&fit=crop',
        verified: true,
      ),
      const _RoommateProfile(
        name: 'Максат Сарсен',
        age: 27,
        location: 'Наурызбайский район',
        status: 'Полный рабочий день',
        budget: '100 000-160 000 /месяц',
        imageUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=1400&auto=format&fit=crop',
        verified: true,
      ),
    ];

    allProfiles.shuffle(Random());
    _profiles = allProfiles.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

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
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune, color: Color(0xFF001561)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: _profiles.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _RoommateCard(profile: _profiles[index]),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onChanged: (value) => setState(() => _currentIndex = value),
      ),
    );
  }
}

class _RoommateCard extends StatelessWidget {
  const _RoommateCard({required this.profile});

  final _RoommateProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
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
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.23,
                  child: Image.network(profile.imageUrl, fit: BoxFit.cover),
                ),
                if (profile.verified)
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
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
                  '${profile.name}, ${profile.age}',
                  style: textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF001561),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'Локация',
                  value: profile.location,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: 'Статус',
                  value: profile.status,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Бюджет',
                  value: profile.budget,
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: Color(0xFFD0D0D0)),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Expanded(
                      child: _ActionOutlinedButton(
                        icon: Icons.block,
                        label: 'Скрыть',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _ActionOutlinedButton(
                        icon: Icons.favorite_border,
                        label: 'Сохранить',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
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
          ),
        ),
      ],
    );
  }
}

class _ActionOutlinedButton extends StatelessWidget {
  const _ActionOutlinedButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF9CA3AF), width: 1.2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF6B7280), size: 20),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF707070),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.currentIndex, required this.onChanged});

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x14000000))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            icon: Icons.home_rounded,
            selected: currentIndex == 0,
            onTap: () => onChanged(0),
          ),
          _NavIcon(
            icon: Icons.favorite_border,
            selected: currentIndex == 1,
            onTap: () => onChanged(1),
          ),
          _NavIcon(
            icon: Icons.chat_bubble_outline,
            selected: currentIndex == 2,
            onTap: () => onChanged(2),
          ),
          _NavIcon(
            icon: Icons.person_outline,
            selected: currentIndex == 3,
            onTap: () => onChanged(3),
          ),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: selected ? Colors.white : const Color(0xFF7A7A7A),
          size: 24,
        ),
      ),
    );
  }
}

class _RoommateProfile {
  const _RoommateProfile({
    required this.name,
    required this.age,
    required this.location,
    required this.status,
    required this.budget,
    required this.imageUrl,
    required this.verified,
  });

  final String name;
  final int age;
  final String location;
  final String status;
  final String budget;
  final String imageUrl;
  final bool verified;
}
