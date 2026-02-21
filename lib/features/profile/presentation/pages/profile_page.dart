import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/onboarding_repository.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final status = await ref.read(onboardingRepositoryProvider).getStatus();
      final profile = status.profile;
      final lifestyle =
          (profile['lifestyle'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final search =
          (profile['search'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{};
      final photos =
          (profile['photos'] as List?)?.whereType<String>().toList() ??
          const <String>[];

      bool hasText(Object? value) =>
          value is String && value.trim().isNotEmpty;

      final lifestyleDone =
          hasText(lifestyle['chronotype']) &&
          hasText(lifestyle['noisePreference']) &&
          hasText(lifestyle['personalityType']) &&
          hasText(lifestyle['smokingPreference']) &&
          hasText(lifestyle['petsPreference']);

      final searchDone =
          search['budgetMin'] != null &&
          search['budgetMax'] != null &&
          hasText(search['district']) &&
          hasText(search['roommateGenderPreference']) &&
          hasText(search['stayTerm']);

      final profileDone =
          hasText(profile['occupationStatus']) &&
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
                      '\u041f\u0440\u043e\u0444\u0438\u043b\u044c',
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
                    const _ProfileHeader(),
                    const SizedBox(height: 16),
                    if (_completed) ...[
                      const _ProfileDoneCard(),
                      const SizedBox(height: 12),
                    ] else ...[
                      const _ProfileProgress(),
                      const SizedBox(height: 18),
                      _CompleteProfileCard(
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(AppRoutes.profileAbout),
                      ),
                      const SizedBox(height: 12),
                    ],
                    _VerificationCard(
                      onTap: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.profileVerification),
                    ),
                    const SizedBox(height: 18),
                    const _MenuItem(
                      icon: Icons.edit_outlined,
                      title:
                          '\u0420\u0435\u0434\u0430\u043a\u0442\u0438\u0440\u043e\u0432\u0430\u0442\u044c \u043f\u0440\u043e\u0444\u0438\u043b\u044c',
                    ),
                    const SizedBox(height: 8),
                    const _MenuItem(
                      icon: Icons.notifications_none,
                      title:
                          '\u0423\u0432\u0435\u0434\u043e\u043c\u043b\u0435\u043d\u0438\u044f',
                    ),
                    const SizedBox(height: 8),
                    const _MenuItem(
                      icon: Icons.remove_red_eye_outlined,
                      title:
                          '\u041a\u043e\u043d\u0444\u0438\u0434\u0435\u043d\u0446\u0438\u0430\u043b\u044c\u043d\u043e\u0441\u0442\u044c',
                    ),
                    const SizedBox(height: 8),
                    const _MenuItem(
                      icon: Icons.lock_outline,
                      title:
                          '\u0411\u0435\u0437\u043e\u043f\u0430\u0441\u043d\u043e\u0441\u0442\u044c',
                    ),
                    const SizedBox(height: 8),
                    const _MenuItem(
                      icon: Icons.support_agent,
                      title:
                          '\u041f\u043e\u043c\u043e\u0449\u044c \u0438 \u043f\u043e\u0434\u0434\u0435\u0440\u0436\u043a\u0430',
                    ),
                    const SizedBox(height: 8),
                    const _MenuItem(
                      icon: Icons.info_outline,
                      title:
                          '\u041e \u043f\u0440\u0438\u043b\u043e\u0436\u0435\u043d\u0438\u0438',
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
                            '\u0412\u044b\u0445\u043e\u0434',
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
      bottomNavigationBar: _BottomNav(
        onTapHome: () =>
            Navigator.of(context).pushReplacementNamed(AppRoutes.home),
      ),
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
          const Icon(Icons.check_box_outlined, color: Color(0xFF2EC766), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u041f\u0440\u043e\u0444\u0438\u043b\u044c \u0437\u0430\u043f\u043e\u043b\u043d\u0435\u043d \u043d\u0430 100%',
                  style: textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF001561),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\u0422\u0435\u043f\u0435\u0440\u044c \u0432\u0430\u0441 \u043c\u043e\u0433\u0443\u0442 \u043d\u0430\u0445\u043e\u0434\u0438\u0442\u044c \u0434\u0440\u0443\u0433\u0438\u0435 \u043f\u043e\u043b\u044c\u0437\u043e\u0432\u0430\u0442\u0435\u043b\u0438',
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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
              '\u0414\u0438\u0430\u0441 \u0418\u0441\u0435\u0435\u0432',
              style: textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF001561),
                fontWeight: FontWeight.w700,
                fontSize: 34 / 2,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'dias@gmail.com',
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
              '\u041f\u0440\u043e\u0444\u0438\u043b\u044c \u0437\u0430\u043f\u043e\u043b\u043d\u0435\u043d \u043d\u0430 40%',
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
              '\u041f\u0440\u043e\u0434\u043e\u043b\u0436\u0438\u0442\u044c \u0437\u0430\u043f\u043e\u043b\u043d\u0435\u043d\u0438\u0435 \u043f\u0440\u043e\u0444\u0438\u043b\u044f',
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 30 / 2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '\u0417\u0430\u043f\u043e\u043b\u043d\u0438\u0442\u0435 \u043f\u0440\u043e\u0444\u0438\u043b\u044c, \u0447\u0442\u043e\u0431\u044b \u043f\u043e\u043b\u0443\u0447\u0430\u0442\u044c \u0431\u043e\u043b\u044c\u0448\u0435 \u0441\u043e\u0432\u043f\u0430\u0434\u0435\u043d\u0438\u0439',
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

class _VerificationCard extends StatelessWidget {
  const _VerificationCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.75)),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_user_outlined, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\u041f\u043e\u0434\u0442\u0432\u0435\u0440\u0434\u0438\u0442\u044c \u043b\u0438\u0447\u043d\u043e\u0441\u0442\u044c',
                    style: textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF001561),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\u041f\u043e\u0432\u044b\u0448\u0430\u0435\u0442 \u0434\u043e\u0432\u0435\u0440\u0438\u0435 \u043a \u0432\u0430\u0448\u0435\u043c\u0443 \u043f\u0440\u043e\u0444\u0438\u043b\u044e',
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
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: () {},
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
                  fontSize: 32 / 2,
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
