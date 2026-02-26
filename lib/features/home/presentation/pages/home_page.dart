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
  final Set<String> _hiddenIds = HashSet<String>();

  void _msg(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
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
    // TODO: мұнда кейін profile details route ашасың
    _msg('Профиль: ${user.displayName}');
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
                    onPressed: () {},
                    icon: const Icon(Icons.tune, color: Color(0xFF001561)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: asyncUsers.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Ошибка: $e')),
                  data: (users) {
                    final visible =
                        users.where((u) => !_hiddenIds.contains(u.id)).toList();

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
            if (photo != null && photo.trim().isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: AspectRatio(
                  aspectRatio: 1.23,
                  child: Image.network(photo, fit: BoxFit.cover),
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
                  const SizedBox(height: 10),
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
