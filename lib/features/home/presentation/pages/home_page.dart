<<<<<<< HEAD
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../data/home_providers.dart';
import '../../data/recommended_user_model.dart';
import 'package:roommate_app/features/people/data/favorites_users_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final Set<String> _hiddenIds = HashSet();

  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(text)));
  }

  void _hide(String userId) {
    setState(() => _hiddenIds.add(userId));
    _msg('Скрыто ✅');
  }

  Future<void> _toggleSave(RecommendedUser user) async {
  final repo = ref.read(homeRepositoryProvider);

  try {
    if (user.isSaved) {
      await repo.unsaveUser(user.id);
      _msg('Удалено из сохранённых');
    } else {
      await repo.saveUser(user.id);
      _msg('Сохранено ✅');
    }

    ref.invalidate(recommendedUsersProvider);
    ref.invalidate(favoriteUsersProvider);
  } catch (e) {
    _msg('Ошибка: $e');
  }
}
  void _openDetails(RecommendedUser user) {
  
    _msg('Профиль: ${user.displayName}');
=======
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../app/app_routes.dart';
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
        name:
            '\u0414\u0438\u0430\u043d\u0430 \u0415\u0440\u043b\u0430\u043d\u043e\u0432\u0430',
        age: 26,
        location:
            '\u0410\u0443\u0435\u0437\u043e\u0432\u0441\u043a\u0438\u0439 \u0440\u0430\u0439\u043e\u043d',
        status:
            '\u0420\u0430\u0431\u043e\u0442\u0430\u0435\u0442 \u0438 \u0443\u0447\u0438\u0442\u0441\u044f',
        budget: '50 000-100 000 /\u043c\u0435\u0441\u044f\u0446',
        imageUrl:
            'https://images.unsplash.com/photo-1525134479668-1bee5c7c6845?w=1400&auto=format&fit=crop',
        verified: true,
      ),
      const _RoommateProfile(
        name:
            '\u0415\u0440\u043a\u0435\u0431\u0443\u043b\u0430\u043d \u041d\u0443\u0440\u043b\u0430\u043d',
        age: 24,
        location:
            '\u0411\u043e\u0441\u0442\u0430\u043d\u0434\u044b\u043a\u0441\u043a\u0438\u0439 \u0440\u0430\u0439\u043e\u043d',
        status: '\u0420\u0430\u0431\u043e\u0442\u0430\u0435\u0442 \u0432 IT',
        budget: '90 000-140 000 /\u043c\u0435\u0441\u044f\u0446',
        imageUrl:
            'https://images.unsplash.com/photo-1519345182560-3f2917c472ef?w=1400&auto=format&fit=crop',
        verified: false,
      ),
      const _RoommateProfile(
        name: '\u0410\u043b\u0438\u043d\u0430 \u0422\u0443\u043b\u0435\u0443',
        age: 23,
        location:
            '\u0410\u043b\u043c\u0430\u043b\u0438\u043d\u0441\u043a\u0438\u0439 \u0440\u0430\u0439\u043e\u043d',
        status:
            '\u0421\u0442\u0443\u0434\u0435\u043d\u0442 \u0438 \u0444\u0440\u0438\u043b\u0430\u043d\u0441\u0435\u0440',
        budget: '70 000-120 000 /\u043c\u0435\u0441\u044f\u0446',
        imageUrl:
            'https://images.unsplash.com/photo-1488426862026-3ee34a7d66df?w=1400&auto=format&fit=crop',
        verified: true,
      ),
      const _RoommateProfile(
        name:
            '\u041c\u0430\u043a\u0441\u0430\u0442 \u0421\u0430\u0440\u0441\u0435\u043d',
        age: 27,
        location:
            '\u041d\u0430\u0443\u0440\u044b\u0437\u0431\u0430\u0439\u0441\u043a\u0438\u0439 \u0440\u0430\u0439\u043e\u043d',
        status:
            '\u041f\u043e\u043b\u043d\u044b\u0439 \u0440\u0430\u0431\u043e\u0447\u0438\u0439 \u0434\u0435\u043d\u044c',
        budget: '100 000-160 000 /\u043c\u0435\u0441\u044f\u0446',
        imageUrl:
            'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=1400&auto=format&fit=crop',
        verified: true,
      ),
    ];

    allProfiles.shuffle(Random());
    _profiles = allProfiles.take(3).toList();
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
<<<<<<< HEAD
    final asyncUsers = ref.watch(recommendedUsersProvider);
=======
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750

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
<<<<<<< HEAD
                    'Поиск соседей',
                    style: textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF001561),
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
=======
                    '\u041f\u043e\u0438\u0441\u043a \u0441\u043e\u0441\u0435\u0434\u0435\u0439',
                    style: textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF001561),
                      fontWeight: FontWeight.w700,
                      fontSize: 34 / 2,
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
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
<<<<<<< HEAD
                child: asyncUsers.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Ошибка: $e')),
                  data: (users) {
                    final visible = users
                        .where((u) => !_hiddenIds.contains(u.id))
                        .toList();

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
                            onHide: () => _hide(user.id),
                            onSave: () => _toggleSave(user),
                            onOpen: () => _openDetails(user),
                          );
                        },
                      ),
                    );
                  },
=======
                child: ListView.separated(
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: _profiles.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) =>
                      _RoommateCard(profile: _profiles[index]),
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
                ),
              ),
            ],
          ),
        ),
      ),
<<<<<<< HEAD
=======
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onChanged: (value) {
          if (value == 3) {
            Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
            return;
          }
          setState(() => _currentIndex = value);
        },
      ),
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
    );
  }
}

class _RoommateCard extends StatelessWidget {
<<<<<<< HEAD
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
=======
  const _RoommateCard({required this.profile});

  final _RoommateProfile profile;
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
<<<<<<< HEAD
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
=======

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
                            '\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0436\u0434\u0451\u043d',
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
                    fontSize: 32 / 2,
                  ),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: '\u041b\u043e\u043a\u0430\u0446\u0438\u044f',
                  value: profile.location,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.person_outline,
                  label: '\u0421\u0442\u0430\u0442\u0443\u0441',
                  value: profile.status,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: '\u0411\u044e\u0434\u0436\u0435\u0442',
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
                        label: '\u0421\u043a\u0440\u044b\u0442\u044c',
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _ActionOutlinedButton(
                        icon: Icons.favorite_border,
                        label:
                            '\u0421\u043e\u0445\u0440\u0430\u043d\u0438\u0442\u044c',
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
                      ),
                    ),
                  ],
                ),
<<<<<<< HEAD
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
=======
              ],
            ),
          ),
        ],
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
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
<<<<<<< HEAD
              fontSize: 14.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
=======
              fontSize: 13.5,
            ),
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
          ),
        ),
      ],
    );
  }
}

class _ActionOutlinedButton extends StatelessWidget {
<<<<<<< HEAD
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
=======
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
              fontSize: 15,
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
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750

  @override
  Widget build(BuildContext context) {
    return InkWell(
<<<<<<< HEAD
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
=======
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
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
        ),
      ),
    );
  }
<<<<<<< HEAD
}
=======
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
>>>>>>> 2ea17bf8e1c72ffdcc2e01aee5660b7f0a7a3750
