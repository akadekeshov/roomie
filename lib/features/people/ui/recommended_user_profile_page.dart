import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../chat/chat_detail_page.dart';
import '../../home/data/home_providers.dart';
import '../../home/data/recommended_user_model.dart';
import '../../people/data/favorites_users_providers.dart';

class RecommendedUserProfilePage extends ConsumerWidget {
  const RecommendedUserProfilePage({
    super.key,
    required this.user,
  });

  final RecommendedUser user;

  static const String _defaultChatAvatar = 'assets/images/ava1.png';

  // Backend толық profileComplete бермей тұр -> уақытша heuristic
  bool get _isProbablyComplete {
    final hasBio = (user.bio ?? '').trim().isNotEmpty;
    final hasStatus = (user.occupationStatus ?? '').trim().isNotEmpty;
    final hasLocation =
        (user.searchDistrict ?? user.city ?? '').trim().isNotEmpty;
    final hasBudget =
        user.searchBudgetMin != null || user.searchBudgetMax != null;
    final hasPhoto = user.photos.isNotEmpty;
    return hasBio && hasStatus && hasLocation && hasBudget && hasPhoto;
  }

  void _snack(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _showProfileNotReadySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: const [
                  Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFF59E0B)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Профиль заполнен не полностью',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Чат ашу үшін бұл адам профилін толық толтыруы керек. Қазір чат уақытша қолжетімсіз.',
                style: TextStyle(color: Colors.black54, height: 1.35),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context), // ✅ OK -> жабылады
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Ок',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _openChat(BuildContext context) {
    if (!_isProbablyComplete) {
      _showProfileNotReadySheet(context);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatDetailPage(
          title: user.displayName,
          online: true, // уақытша
          letter: user.displayName.isNotEmpty ? user.displayName.trim()[0] : '?',
          imagePath: _defaultChatAvatar,
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
        _snack(context, 'Удалено из сохранённых');
      } else {
        await repo.saveUser(user.id);
        _snack(context, 'Сохранено ✅');
      }

      // ✅ Екі жақты жаңарту
      ref.invalidate(recommendedUsersProvider);
      ref.invalidate(favoriteUsersProvider);
    } catch (e) {
      _snack(context, 'Ошибка: $e');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ✅ Saved status нақты болу үшін provider-дан аламыз
    final favoriteIds = ref.watch(favoriteUserIdsProvider);
    final isSaved = favoriteIds.contains(user.id);

    final photo = user.avatarUrl;

    // Егер Home recommendation-да келсе — пайдалана береміз
    final match = user.matchPercent.clamp(0, 100);

    // Скриндегідей: budget/lifestyle/location проценттері бек жоқта — placeholder
    const budgetPct = 90;
    const lifestylePct = 85;
    const locationPct = 86;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // ✅ Image header
                    Stack(
                      children: [
                        AspectRatio(
                          aspectRatio: 1.06,
                          child: photo != null
                              ? Image.network(photo, fit: BoxFit.cover)
                              : Container(
                                  color: const Color(0xFFE5E7EB),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.person,
                                      size: 70, color: Colors.black26),
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

                        // ✅ Verified статус (backend бермесе — “Профиль заполнен/не заполнен” көрсетеміз)
                        Positioned(
                          right: 12,
                          bottom: 12,
                          child: _Pill(
                            text: _isProbablyComplete
                                ? 'Профиль заполнен'
                                : 'Не заполнен',
                            icon: _isProbablyComplete
                                ? Icons.check_circle
                                : Icons.info_outline,
                            bg: _isProbablyComplete
                                ? const Color(0x1A16A34A)
                                : const Color(0x1A6B7280),
                            fg: _isProbablyComplete
                                ? const Color(0xFF16A34A)
                                : const Color(0xFF6B7280),
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

                          if (!_isProbablyComplete) const _WarningBox(),
                          if (!_isProbablyComplete) const SizedBox(height: 12),

                          // ✅ Compatibility card (скринге ұқсас)
                          _Card(
                            child: Column(
                              children: [
                                _ProgressRow(
                                  title: 'Совместимость',
                                  value: match,
                                  bigRight: true,
                                ),
                                const SizedBox(height: 12),
                                const _ProgressRow(title: 'Бюджет', value: budgetPct),
                                const SizedBox(height: 12),
                                const _ProgressRow(title: 'Образ жизни', value: lifestylePct),
                                const SizedBox(height: 12),
                                const _ProgressRow(title: 'Локация', value: locationPct),
                              ],
                            ),
                          ),

                          const SizedBox(height: 12),

                          // ✅ Info (Локация/Статус/Бюджет)
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
                                  icon: Icons.account_balance_wallet_outlined,
                                  label: 'Бюджет',
                                  value: user.budgetText,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ✅ Bottom buttons
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
                        icon:
                            const Icon(Icons.chat_bubble_outline, size: 18),
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

/* ---------------- UI widgets ---------------- */

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
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
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
            style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _WarningBox extends StatelessWidget {
  const _WarningBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFED7AA)),
      ),
      child: Row(
        children: const [
          Icon(Icons.warning_amber_rounded, color: Color(0xFFF59E0B)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Профиль заполнен не полностью. Чат может быть недоступен.',
              style: TextStyle(
                color: Color(0xFF9A3412),
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
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
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF111827)),
            ),
          ),
        ),
      ],
    );
  }
}