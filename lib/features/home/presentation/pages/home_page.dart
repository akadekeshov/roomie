import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../chat/chat_detail_page.dart';
import '../../../people/data/favorites_users_providers.dart';
import '../../../people/data/hidden_users_provider.dart';
import '../../../people/ui/recommended_user_profile_page.dart';
import '../../data/filter_providers.dart' as filter;
import '../../data/home_providers.dart' as home;
import '../../data/recommended_user_model.dart';
import 'filter_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  void _invalidateHomeData() {
    ref.invalidate(home.homeAutoRecommendationsProvider);
    ref.invalidate(home.recommendedUsersProvider);
    ref.invalidate(filter.filteredUsersProvider);
    ref.invalidate(favoriteUsersProvider);
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  Future<void> _hideUser(
    RecommendedUser user, {
    required bool isSaved,
  }) async {
    final repository = ref.read(home.homeRepositoryProvider);

    try {
      if (isSaved) {
        await repository.unsaveUser(user.id);
      }

      ref.read(hiddenUserIdsProvider.notifier).hide(user.id);
      _invalidateHomeData();
      _showMessage('Пользователь скрыт');
    } catch (error) {
      _showMessage('Ошибка: $error');
    }
  }

  Future<void> _toggleSave(
    RecommendedUser user, {
    required bool isSaved,
  }) async {
    final repository = ref.read(home.homeRepositoryProvider);

    try {
      if (isSaved) {
        await repository.unsaveUser(user.id);
        _showMessage('Удалено из сохранённых');
      } else {
        await repository.saveUser(user.id);
        _showMessage('Сохранено');
      }

      _invalidateHomeData();
    } catch (error) {
      _showMessage('Ошибка: $error');
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

  void _openChat(RecommendedUser user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          peerUserId: user.id,
          title: user.displayName,
          imageUrl: user.avatarUrl,
          online: true,
          letter: user.displayName.trim().isNotEmpty
              ? user.displayName.trim()[0]
              : '?',
        ),
      ),
    );
  }

  Future<void> _openFilters() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FilterPage()),
    );

    _invalidateHomeData();
  }

  void _openAiSearch() {
    Navigator.of(context).pushNamed(AppRoutes.aiSearch);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final filterState = ref.watch(filter.filterStateProvider);
    final hasFilters = filterState.hasAnyFilter;
    final favoriteIds = ref.watch(favoriteUserIdsProvider);

    final asyncUsers = hasFilters
        ? ref.watch(filter.filteredUsersProvider).whenData(
              (users) => home.HomeAutoRecommendations(
                home.HomeAutoState.loaded,
                users,
              ),
            )
        : ref.watch(home.homeAutoRecommendationsProvider);

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
                    onPressed: _openAiSearch,
                    tooltip: 'AI-поиск',
                    icon: const Icon(
                      Icons.auto_awesome_rounded,
                      color: Color(0xFF001561),
                    ),
                  ),
                  IconButton(
                    onPressed: _openFilters,
                    icon: Icon(
                      Icons.tune,
                      color: hasFilters
                          ? AppColors.primary
                          : const Color(0xFF001561),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (hasFilters)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E5ED)),
                  ),
                  child: const Text(
                    'Показаны пользователи по выбранным фильтрам',
                    style: TextStyle(
                      color: Color(0xFF001561),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              Expanded(
                child: asyncUsers.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text('Ошибка: $error'),
                  ),
                  data: (autoData) {
                    final hiddenIds = ref.watch(hiddenUserIdsProvider);
                    final visibleUsers = autoData.users
                        .where((user) => !hiddenIds.contains(user.id))
                        .toList();
                    final showBanner = !hasFilters &&
                        autoData.state != home.HomeAutoState.loaded;

                    if (visibleUsers.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () async => _invalidateHomeData(),
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 12),
                          children: [
                            if (showBanner)
                              _HomeStateBanner(state: autoData.state),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: Text(
                                  hasFilters
                                      ? 'По этим фильтрам пользователи не найдены'
                                      : 'Пока нет видимых пользователей',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _invalidateHomeData(),
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 12),
                        itemCount: visibleUsers.length + (showBanner ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          if (showBanner && index == 0) {
                            return _HomeStateBanner(state: autoData.state);
                          }

                          final user =
                              visibleUsers[index - (showBanner ? 1 : 0)];
                          final isSaved = favoriteIds.contains(user.id);

                          return _RoommateCard(
                            user: user,
                            isSaved: isSaved,
                            onHide: () => _hideUser(user, isSaved: isSaved),
                            onSave: () => _toggleSave(user, isSaved: isSaved),
                            onChat: () => _openChat(user),
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

class _HomeStateBanner extends StatelessWidget {
  const _HomeStateBanner({required this.state});

  final home.HomeAutoState state;

  @override
  Widget build(BuildContext context) {
    late final String title;
    late final String subtitle;
    late final Color background;
    late final Color border;
    late final Color accent;
    late final IconData icon;

    switch (state) {
      case home.HomeAutoState.profileIncomplete:
        title = 'Заполните профиль для лучших совпадений';
        subtitle =
            'Пользователи всё равно показываются, но рекомендации станут точнее после завершения анкеты.';
        background = const Color(0xFFFFF7ED);
        border = const Color(0xFFFED7AA);
        accent = const Color(0xFFC2410C);
        icon = Icons.person_search_outlined;
        break;
      case home.HomeAutoState.verificationPending:
        title = 'Проверка ещё идёт';
        subtitle =
            'Ваш профиль остаётся активным, пока модерация не завершена.';
        background = const Color(0xFFF4F2FF);
        border = const Color(0xFFD8CBFF);
        accent = AppColors.primary;
        icon = Icons.hourglass_top_rounded;
        break;
      case home.HomeAutoState.verificationRejected:
        title = 'Проверка требует внимания';
        subtitle =
            'Вы всё ещё можете смотреть пользователей. Обновите данные для верификации, чтобы вернуть значок доверия.';
        background = const Color(0xFFFFF1F2);
        border = const Color(0xFFFDA4AF);
        accent = const Color(0xFFE11D48);
        icon = Icons.error_outline;
        break;
      case home.HomeAutoState.noRecommendations:
        title = 'Пока нет сильных совпадений';
        subtitle =
            'Пока собираются новые сигналы для рекомендаций, показывается более широкий список пользователей.';
        background = const Color(0xFFEFF6FF);
        border = const Color(0xFFBFDBFE);
        accent = const Color(0xFF1D4ED8);
        icon = Icons.auto_awesome_outlined;
        break;
      case home.HomeAutoState.loaded:
        return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoommateCard extends StatelessWidget {
  const _RoommateCard({
    required this.user,
    required this.isSaved,
    required this.onHide,
    required this.onSave,
    required this.onChat,
    required this.onOpen,
  });

  final RecommendedUser user;
  final bool isSaved;
  final VoidCallback onHide;
  final VoidCallback onSave;
  final VoidCallback onChat;
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
                      child: Image.network(
                        photo,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          color: const Color(0xFFE5E7EB),
                          child: const Center(
                            child: Icon(
                              Icons.person,
                              size: 48,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (user.isVerified)
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
                  const SizedBox(height: 6),
                  Text(
                    'Совместимость: ${user.compatibilityPercent}%',
                    style: textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF4C1D95),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (user.quickBadges.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      user.quickBadges.first,
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onChat,
                      icon: const Icon(Icons.chat_bubble_outline, size: 18),
                      label: const Text('Написать'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionOutlinedButton(
                          icon: Icons.block,
                          label: 'Скрыть',
                          onTap: onHide,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ActionOutlinedButton(
                          icon:
                              isSaved ? Icons.favorite : Icons.favorite_border,
                          label: isSaved ? 'Сохранено' : 'Сохранить',
                          onTap: onSave,
                          isActive: isSaved,
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
