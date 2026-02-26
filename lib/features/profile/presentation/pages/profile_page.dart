import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/data/auth_repository.dart';
import '../../data/onboarding_repository.dart';
import '../../data/me_repository.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _completed = false;

  String _displayName = 'Пользователь';
  String _displayContact = '—';

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    await Future.wait([_loadStatus(), _loadHeader()]);
  }

  Future<void> _loadHeader() async {
    try {
      final me = await ref.read(authRepositoryProvider).getMe();
      final firstName = (me.firstName ?? '').trim();
      final lastName = (me.lastName ?? '').trim();
      final fullName = '$firstName $lastName'.trim();

      final email = (me.email ?? '').trim();
      final phone = (me.phone ?? '').trim();
      final contact = email.isNotEmpty ? email : phone;

      if (!mounted) return;
      setState(() {
        _displayName = fullName.isEmpty ? 'Пользователь' : fullName;
        _displayContact = contact.isEmpty ? '—' : contact;
      });
    } catch (_) {}
  }

  Future<void> _loadStatus() async {
    try {
      final status = await ref.read(onboardingRepositoryProvider).getStatus();
      final profile = status.profile;

      final lifestyle =
          (profile['lifestyle'] as Map?)?.cast<String, dynamic>() ??
              <String, dynamic>{};
      final search = (profile['search'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final photos =
          (profile['photos'] as List?)?.whereType<String>().toList() ??
              const <String>[];

      bool hasText(Object? value) => value is String && value.trim().isNotEmpty;

      final lifestyleDone = hasText(lifestyle['chronotype']) &&
          hasText(lifestyle['noisePreference']) &&
          hasText(lifestyle['personalityType']) &&
          hasText(lifestyle['smokingPreference']) &&
          hasText(lifestyle['petsPreference']);

      final searchDone = search['budgetMin'] != null &&
          search['budgetMax'] != null &&
          hasText(search['district']) &&
          hasText(search['roommateGenderPreference']) &&
          hasText(search['stayTerm']);

      final profileDone = hasText(profile['occupationStatus']) &&
          hasText(profile['university']) &&
          hasText(profile['bio']) &&
          lifestyleDone &&
          searchDone &&
          photos.any((p) => p.trim().isNotEmpty);

      if (!mounted) return;
      setState(() => _completed = profileDone);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      bottomNavigationBar: _BottomNav(
        onTapHome: () =>
            Navigator.of(context).pushReplacementNamed(AppRoutes.home),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  const SizedBox(width: 24),
                  Expanded(
                    child: Text(
                      'Профиль',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 34 / 2,
                        color: const Color(0xFF001561),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.settings, color: Color(0xFF001561)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 98),
                child: Column(
                  children: [
                    _ProfileHeader(
                      name: _displayName,
                      contact: _displayContact,
                    ),
                    const SizedBox(height: 16),
                    if (_completed) ...[
                      const _ProfileDoneCard(),
                      const SizedBox(height: 12),
                    ] else ...[
                      const _ProfileProgress(),
                      const SizedBox(height: 18),
                      _CompleteProfileCard(
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.profileAbout),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _VerificationCard(
                      onTap: () async {
                        await Navigator.of(context)
                            .pushNamed(AppRoutes.profileVerification);
                        ref.invalidate(meProvider);
                      },
                    ),
                    const SizedBox(height: 18),
                    _MenuItem(
                      icon: Icons.edit_outlined,
                      title: 'Редактировать профиль',
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.profileEdit),
                    ),
                    const SizedBox(height: 8),
                    const _MenuItem(
                      icon: Icons.notifications_none,
                      title: 'Уведомления',
                    ),
                    const SizedBox(height: 8),
                    const _MenuItem(
                      icon: Icons.remove_red_eye_outlined,
                      title: 'Конфиденциальность',
                    ),
                    const SizedBox(height: 8),
                    const _MenuItem(
                      icon: Icons.lock_outline,
                      title: 'Безопасность',
                    ),
                    const SizedBox(height: 8),
                    const _MenuItem(
                      icon: Icons.support_agent,
                      title: 'Помощь и поддержка',
                    ),
                    const SizedBox(height: 8),
                    const _MenuItem(
                      icon: Icons.info_outline,
                      title: 'О приложении',
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.admin_panel_settings,
                      title: 'Admin Panel',
                      onTap: () => Navigator.of(context)
                          .pushNamed(AppRoutes.adminVerifications),
                    ),
                    const SizedBox(height: 22),
                    InkWell(
                      onTap: () =>
                          Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.login,
                        (route) => false,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          Container(
                            height: 32,
                            width: 32,
                            decoration: BoxDecoration(
                              color: const Color(0x14FF3B30),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: Color(0xFFFF3B30),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Выход',
                            style: textTheme.titleMedium?.copyWith(
                              color: const Color(0xFFFF3B30),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.contact});

  final String name;
  final String contact;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        Container(
          height: 64,
          width: 64,
          decoration: const BoxDecoration(
            color: Color(0xFFD3D5DB),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 34),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF001561),
                fontWeight: FontWeight.w700,
                fontSize: 34 / 2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              contact,
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF8A93B1),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileDoneCard extends StatelessWidget {
  const _ProfileDoneCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0x1A2EC766),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x802EC766)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_box_outlined,
              color: Color(0xFF2EC766), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Профиль заполнен на 100%',
                  style: textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF001561),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Теперь вас могут находить другие пользователи',
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0x99001561),
                    fontWeight: FontWeight.w500,
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

class _ProfileProgress extends StatelessWidget {
  const _ProfileProgress();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            Text(
              'Профиль заполнен на 40%',
              style: textTheme.titleMedium?.copyWith(
                color: const Color(0xFF4E5884),
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const Spacer(),
            Text(
              '40/100',
              style: textTheme.titleMedium?.copyWith(
                color: const Color(0xFF001561),
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: const LinearProgressIndicator(
            value: 0.4,
            minHeight: 6,
            backgroundColor: Color(0xFFC9CDD8),
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    );
  }
}

class _CompleteProfileCard extends StatefulWidget {
  const _CompleteProfileCard({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_CompleteProfileCard> createState() => _CompleteProfileCardState();
}

class _CompleteProfileCardState extends State<_CompleteProfileCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: _pressed
                ? const [Color(0xFF6432C3), Color(0xFF5A2CB0)]
                : const [Color(0xFF7C3AED), Color(0xFF6D32F0)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Продолжить заполнение профиля',
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 30 / 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Заполните профиль, чтобы получать больше совпадений',
              style: textTheme.bodyMedium?.copyWith(
                color: const Color(0xDFFFFFFF),
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationCard extends ConsumerWidget {
  const _VerificationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final meAsync = ref.watch(meProvider);

    return meAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (me) {
        if (me.isVerified) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFFAF2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFBFE7C9)),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded,
                    color: Color(0xFF2ECC71), size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Личность подтверждена',
                        style: textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Повышает доверие к вашему профилю',
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8AA59A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F2FF),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.75),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_outlined, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Подтвердить личность',
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Повышает доверие к вашему профилю',
                        style: textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF9AA1B9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(11, 8, 0, 8),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: const BoxDecoration(
                color: Color(0x1A7C3AED),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF001561),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFA7AEBD), size: 22),
          ],
        ),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onTapHome});

  final VoidCallback onTapHome;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0x14000000))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavIcon(
            icon: Icons.home_outlined,
            selected: false,
            onTap: onTapHome,
          ),
          const _NavIcon(icon: Icons.favorite_border, selected: false),
          const _NavIcon(icon: Icons.chat_bubble_outline, selected: false),
          const _NavIcon(icon: Icons.person_outline, selected: true),
        ],
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.selected, this.onTap});

  final IconData icon;
  final bool selected;
  final VoidCallback? onTap;

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
