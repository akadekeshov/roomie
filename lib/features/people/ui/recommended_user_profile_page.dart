import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../chat/chat_detail_page.dart';
import '../../home/data/home_providers.dart';
import '../../home/data/recommended_user_model.dart';
import '../data/favorites_users_providers.dart';

class RecommendedUserProfilePage extends ConsumerWidget {
  const RecommendedUserProfilePage({
    super.key,
    required this.user,
  });

  final RecommendedUser user;

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _openChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          peerUserId: user.id,
          title: user.displayName,
          imageUrl: user.avatarUrl,
          online: true,
          letter: user.displayName.isNotEmpty ? user.displayName.trim()[0] : '?',
        ),
      ),
    );
  }

  Future<void> _toggleSave(
    BuildContext context,
    WidgetRef ref, {
    required bool isSavedNow,
  }) async {
    final repo = ref.read(homeRepositoryProvider);

    try {
      if (isSavedNow) {
        await repo.unsaveUser(user.id);
        _snack(context, 'Удалено из сохраненных');
      } else {
        await repo.saveUser(user.id);
        _snack(context, 'Сохранено');
      }

      ref.invalidate(homeAutoRecommendationsProvider);
      ref.invalidate(recommendedUsersProvider);
      ref.invalidate(favoriteUsersProvider);
    } catch (e) {
      _snack(context, 'Ошибка: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(favoriteUserIdsProvider);
    final isSaved = favoriteIds.contains(user.id);
    final photo = user.avatarUrl;

    final match = user.compatibilityPercent;
    final budgetPct = user.budgetMatchPercent;
    final lifestylePct = user.lifestyleMatchPercent;
    final locationPct = user.locationMatchPercent;
    final bio = (user.bio ?? '').trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.06,
                          child: photo != null
                              ? Image.network(photo, fit: BoxFit.cover)
                              : Container(
                                  color: const Color(0xFFE5E7EB),
                                  alignment: Alignment.center,
                                  child: const Icon(
                                    Icons.person,
                                    size: 70,
                                    color: Colors.black26,
                                  ),
                                ),
                        ),
                        Positioned(
                          top: 10,
                          left: 10,
                          child: _CircleButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                        ),
                        if (user.isVerified)
                          const Positioned(
                            right: 12,
                            bottom: 12,
                            child: _Pill(
                              text: 'Подтвержден',
                              icon: Icons.check_circle,
                              bg: Color(0x1A16A34A),
                              fg: Color(0xFF16A34A),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            style: const TextStyle(
                              color: Color(0xFF001561),
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _Card(
                            child: Column(
                              children: [
                                _ProgressRow(
                                  title: 'Совместимость',
                                  value: match,
                                  bigRight: true,
                                ),
                                const SizedBox(height: 12),
                                _ProgressRow(
                                  title: 'Бюджет',
                                  value: budgetPct,
                                ),
                                const SizedBox(height: 12),
                                _ProgressRow(
                                  title: 'Образ жизни',
                                  value: lifestylePct,
                                ),
                                const SizedBox(height: 12),
                                _ProgressRow(
                                  title: 'Локация',
                                  value: locationPct,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (user.quickBadges.isNotEmpty)
                            _Card(
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: user.quickBadges
                                    .map((badge) => _QuickBadge(text: badge))
                                    .toList(),
                              ),
                            ),
                          if (user.quickBadges.isNotEmpty)
                            const SizedBox(height: 12),
                          if ((user.aiReasoning ?? '').trim().isNotEmpty)
                            _Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Почему вы подходите друг другу',
                                    style: TextStyle(
                                      color: Color(0xFF001561),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    user.aiReasoning!,
                                    style: const TextStyle(
                                      color: Color(0xFF111827),
                                      fontSize: 13,
                                      height: 1.35,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if ((user.aiReasoning ?? '').trim().isNotEmpty)
                            const SizedBox(height: 12),
                          if (user.aiStrengths.isNotEmpty)
                            _Card(
                              child: _BulletSection(
                                title: 'Сильные стороны',
                                items: user.aiStrengths,
                              ),
                            ),
                          if (user.aiStrengths.isNotEmpty)
                            const SizedBox(height: 12),
                          if (user.aiRisks.isNotEmpty)
                            _Card(
                              child: _BulletSection(
                                title: 'Риски',
                                items: user.aiRisks,
                              ),
                            ),
                          if (user.aiRisks.isNotEmpty)
                            const SizedBox(height: 12),
                          _Card(
                            child: Column(
                              children: [
                                _InfoLine(
                                  icon: Icons.map_outlined,
                                  label: 'Локация',
                                  value: user.locationText,
                                ),
                                const SizedBox(height: 10),
                                _InfoLine(
                                  icon: Icons.person_outline,
                                  label: 'Статус',
                                  value: user.statusText,
                                ),
                                const SizedBox(height: 10),
                                _InfoLine(
                                  icon:
                                      Icons.account_balance_wallet_outlined,
                                  label: 'Бюджет',
                                  value: user.budgetText,
                                ),
                              ],
                            ),
                          ),
                          if (bio.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            _Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'О себе',
                                    style: TextStyle(
                                      color: Color(0xFF001561),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    bio,
                                    style: const TextStyle(
                                      color: Color(0xFF111827),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, -6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        onPressed: () => _openChat(context),
                        icon: const Icon(
                          Icons.chat_bubble_outline,
                          size: 18,
                        ),
                        label: const Text('Написать'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF111827),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () => _toggleSave(
                          context,
                          ref,
                          isSavedNow: isSaved,
                        ),
                        icon: Icon(
                          isSaved ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                        ),
                        label: Text(isSaved ? 'Сохранено' : 'Сохранить'),
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

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Icon(icon, size: 18),
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.icon,
    required this.bg,
    required this.fg,
  });

  final String text;
  final IconData icon;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: fg.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
        const SizedBox(width: 8),
        SizedBox(
          width: 66,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF001561),
              fontWeight: FontWeight.w800,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.title,
    required this.value,
    this.bigRight = false,
  });

  final String title;
  final int value;
  final bool bigRight;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0, 100);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          '$v%',
          style: TextStyle(
            color: const Color(0xFF111827),
            fontWeight: bigRight ? FontWeight.w900 : FontWeight.w700,
            fontSize: bigRight ? 18 : 14,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 8,
              value: v / 100,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF111827),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickBadge extends StatelessWidget {
  const _QuickBadge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEBFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4C1D95),
        ),
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.title,
    required this.items,
  });

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF001561),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '• ',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(height: 1.35),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
