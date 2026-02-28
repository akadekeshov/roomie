import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../home/data/recommended_user_model.dart';

// favorites
import '../people/data/favorites_users_providers.dart';

// hidden
import 'package:roommate_app/features/people/data/hidden_users_provider.dart';

// recommended users provider (Home)
import '../home/data/home_providers.dart';

// chat
import 'package:roommate_app/features/chat/chat_detail_page.dart';

class SavedUserProfilePage extends ConsumerWidget {
  const SavedUserProfilePage({super.key, required this.user});

  final RecommendedUser user;

  // ChatDetailPage asset image expects local asset path
  static const String _defaultChatAvatarAsset = 'assets/images/ava1.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = user.avatarUrl;
    final isComplete = user.isProfileComplete; // backend field
    final lifestyleItems = _lifestyleToItems(user.lifestyle); // backend map -> UI items

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                // ===== Header photo =====
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.15,
                      child: (photo != null && photo.isNotEmpty)
                          ? Image.network(photo, fit: BoxFit.cover)
                          : Container(
                              color: Colors.grey.shade300,
                              alignment: Alignment.center,
                              child: const Icon(Icons.person, size: 72),
                            ),
                    ),

                    Positioned(
                      top: 36,
                      left: 10,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: Colors.white, size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),

                    // Verified pill (optional)
                    Positioned(
                      bottom: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0x801C1C1D),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: user.isVerified
                                  ? const Color(0xFF00C853)
                                  : Colors.white54,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.isVerified ? 'Подтверждён' : 'Не подтверждён',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // ===== Content =====
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Warning if profile incomplete
                      if (!isComplete) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.orange.shade300),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.warning_amber_rounded,
                                  color: Colors.orange),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Профиль заполнен не полностью. '
                                  'Чат может быть недоступен.',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Name + match%
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          user.displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF001561),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ===== Match card (placeholder progress) =====
                      _Card(
                        child: Column(
                          children: [
                            _ProgressRow(
                              label: 'Совместимость',
                              value: (user.matchPercent.clamp(0, 100)) / 100.0,
                              rightText: '${user.matchPercent}%',
                            ),
                            const SizedBox(height: 10),
                            _ProgressRow(
                              label: 'Бюджет',
                              value: 0.90,
                              rightText: '90%',
                            ),
                            const SizedBox(height: 10),
                            _ProgressRow(
                              label: 'Образ жизни',
                              value: 0.85,
                              rightText: '85%',
                            ),
                            const SizedBox(height: 10),
                            _ProgressRow(
                              label: 'Локация',
                              value: 0.86,
                              rightText: '86%',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ===== Info card =====
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

                      const SizedBox(height: 14),

                      // ===== About =====
                      if ((user.bio ?? '').trim().isNotEmpty) ...[
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'О себе',
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF001561),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.bio!.trim(),
                                style: const TextStyle(height: 1.35),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ===== Lifestyle (FROM BACKEND) =====
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Образ жизни',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF001561),
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (lifestyleItems.isEmpty)
                              const Text(
                                'Информация не заполнена',
                                style: TextStyle(color: Colors.black54),
                              )
                            else
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: lifestyleItems.length,
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 10,
                                  childAspectRatio: 3.6,
                                ),
                                itemBuilder: (_, i) {
                                  final it = lifestyleItems[i];
                                  return _LifestyleTile(
                                    icon: it.icon,
                                    text: it.text,
                                  );
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ===== Rules (қазір placeholder, кейін backend) =====
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Правила дома',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF001561),
                              ),
                            ),
                            SizedBox(height: 8),
                            _Bullet('Тишина после 22:00'),
                            _Bullet('Уборка по графику'),
                            _Bullet('Общие продукты обсуждаем'),
                            _Bullet('Гости — по договорённости'),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // ===== Preferences chips (placeholder tag + examples) =====
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Предпочтения по соседям',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF001561),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                if ((user.preferenceTag ?? '').trim().isNotEmpty)
                                  _Chip((user.preferenceTag ?? '').trim()),
                                const _Chip('Не курит'),
                                const _Chip('Работает/учится'),
                              ],
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

          // ===== Bottom buttons =====
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
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
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        onPressed: () {
                          if (!isComplete) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Пользователь не заполнил профиль полностью',
                                ),
                              ),
                            );
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatDetailPage(
                                title: user.displayName,
                                online: true, // backend жоқ әзірге
                                letter: _firstLetter(user.displayName),
                                imagePath: _defaultChatAvatarAsset,
                              ),
                            ),
                          );
                        },
                        icon:
                            const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Написать'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF6B7280),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        onPressed: () async {
                          // 1) remove from favorites (saved)
                          final repo =
                              ref.read(favoritesUsersRepositoryProvider);
                          await repo.removeFavorite(user.id);

                          // 2) if hidden earlier -> show again on Home
                          ref
                              .read(hiddenUserIdsProvider.notifier)
                              .unhide(user.id);

                          // 3) refresh lists
                          ref.invalidate(favoriteUsersProvider);
                          ref.invalidate(recommendedUsersProvider);

                          if (context.mounted) Navigator.pop(context);
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('Удалить'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* ===================== helpers ===================== */

String _firstLetter(String s) {
  final t = s.trim();
  if (t.isEmpty) return '?';
  return t.characters.first.toUpperCase();
}

class _LifestyleItem {
  final IconData icon;
  final String text;
  const _LifestyleItem(this.icon, this.text);
}

/// Converts backend lifestyle map into UI tiles.
/// Adjust keys here to match your backend fields.
List<_LifestyleItem> _lifestyleToItems(Map<String, dynamic>? lifestyle) {
  if (lifestyle == null || lifestyle.isEmpty) return const [];

  final items = <_LifestyleItem>[];

  // Example keys (adapt to your real backend):
  // smoking: true/false
  final smoking = lifestyle['smoking'];
  if (smoking is bool) {
    items.add(
      _LifestyleItem(
        Icons.smoke_free_rounded,
        smoking ? 'Курит' : 'Не курит',
      ),
    );
  }

  // pets: true/false OR petsAllowed
  final pets = lifestyle['pets'] ?? lifestyle['petsAllowed'];
  if (pets is bool) {
    items.add(
      _LifestyleItem(
        Icons.pets_outlined,
        pets ? 'Есть питомец' : 'Без животных',
      ),
    );
  }

  // chronotype: OWL/LARK or evening/morning
  final chronotype = lifestyle['chronotype'];
  if (chronotype is String && chronotype.trim().isNotEmpty) {
    final c = chronotype.toUpperCase();
    items.add(
      _LifestyleItem(
        Icons.nightlight_round,
        c.contains('OWL') || c.contains('EVEN')
            ? 'Вечерний человек'
            : 'Утренний человек',
      ),
    );
  }

  // workFormat: remote/office/hybrid
  final workFormat = lifestyle['workFormat'] ?? lifestyle['remoteWork'];
  if (workFormat is bool) {
    items.add(
      _LifestyleItem(
        Icons.home_work_outlined,
        workFormat ? 'Работаю удалённо' : 'Офис/аралас',
      ),
    );
  } else if (workFormat is String && workFormat.trim().isNotEmpty) {
    final w = workFormat.toLowerCase();
    items.add(
      _LifestyleItem(
        Icons.home_work_outlined,
        w.contains('remote') ? 'Работаю удалённо' : workFormat,
      ),
    );
  }

  // cleanliness: 1..5 or string
  final cleanliness = lifestyle['cleanliness'];
  if (cleanliness is num) {
    items.add(_LifestyleItem(
      Icons.cleaning_services_outlined,
      cleanliness >= 4 ? 'Таза адам' : 'Қарапайым',
    ));
  } else if (cleanliness is String && cleanliness.trim().isNotEmpty) {
    items.add(_LifestyleItem(Icons.cleaning_services_outlined, cleanliness));
  }

  // cooking: true/false
  final cooking = lifestyle['cooking'];
  if (cooking is bool) {
    items.add(
      _LifestyleItem(
        Icons.restaurant_outlined,
        cooking ? 'Люблю готовить' : 'Көп пісірмеймін',
      ),
    );
  }

  // If backend filled nothing recognized, show nothing (UI will show "не заполнена")
  return items;
}

/* ===================== UI widgets ===================== */

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
      ),
      child: child,
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.rightText,
  });

  final String label;
  final double value;
  final String rightText;

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF001561),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 42,
          child: Text(
            rightText,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Color(0xFF001561),
            ),
          ),
        ),
      ],
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
        const SizedBox(width: 6),
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7F889D),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF001561),
              fontWeight: FontWeight.w900,
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

class _LifestyleTile extends StatelessWidget {
  const _LifestyleTile({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF001561)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF001561),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.w900)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(height: 1.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEBFF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Color(0xFF5B4CF5),
        ),
      ),
    );
  }
}