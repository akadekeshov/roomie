import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/localization/app_text_localizer.dart';
import '../../../../core/localization/build_context_l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../admin/presentation/pages/admin_disputes_page.dart';
import '../../../agreements/presentation/pages/my_agreements_page.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../disputes/presentation/pages/my_disputes_page.dart';
import '../../../home/data/filter_providers.dart';
import '../../../home/data/home_providers.dart';
import '../../../payments/data/payment_service.dart';
import '../../../payments/presentation/pages/agreement_payments_page.dart';
import '../../../payments/presentation/pages/my_cards_page.dart';
import '../../../people/data/favorites_users_providers.dart';
import '../../../people/data/hidden_users_provider.dart';
import '../../data/me_repository.dart';
import '../../data/onboarding_repository.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with WidgetsBindingObserver {
  Timer? _autoRefreshTimer;
  bool _completed = false;
  bool _redirectingToLogin = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => ref.invalidate(meProvider));
    _loadStatus();
    _autoRefreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (!mounted) return;
      ref.invalidate(meProvider);
    });
  }

  void _handleProfileLoadFailure() {
    if (_redirectingToLogin || !mounted) return;
    _redirectingToLogin = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _resetSessionAndOpenLogin();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(meProvider);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _autoRefreshTimer?.cancel();
    super.dispose();
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

  Future<void> _resetSessionAndOpenLogin() async {
    await ref.read(authRepositoryProvider).logout();
    ref.read(hiddenUserIdsProvider.notifier).clear();
    ref.read(filterStateProvider.notifier).clear();
    ref.invalidate(meProvider);
    ref.invalidate(homeAutoRecommendationsProvider);
    ref.invalidate(recommendedUsersProvider);
    ref.invalidate(filteredUsersProvider);
    ref.invalidate(favoriteUsersProvider);

    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
  }

  Future<void> _logout() => _resetSessionAndOpenLogin();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final meAsync = ref.watch(meProvider);

    ref.listen<AsyncValue<MeUser>>(meProvider, (previous, next) {
      next.whenOrNull(
        error: (_, __) => _handleProfileLoadFailure(),
      );
    });

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
                      l10n.profileTitle,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: const Color(0xFF001561),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed(AppRoutes.settings),
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
                    const SizedBox(height: 12),
                    const _PaymentRemindersCard(),
                    const SizedBox(height: 18),
                    _MenuItem(
                      icon: Icons.edit_outlined,
                      title: l10n.editProfile,
                      onTap: () =>
                          Navigator.of(context).pushNamed(AppRoutes.profileEdit),
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.description_outlined,
                      title: l10n.myAgreements,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MyAgreementsPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.credit_card_outlined,
                      title: l10n.myCards,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MyCardsPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.report_gmailerrorred_outlined,
                      title: l10n.myDisputes,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const MyDisputesPage(),
                          ),
                        );
                      },
                    ),
                    if ((meAsync.valueOrNull?.role == 'ADMIN') ||
                        (meAsync.valueOrNull?.role == 'MODERATOR')) ...[
                      const SizedBox(height: 8),
                      _MenuItem(
                        icon: Icons.admin_panel_settings_outlined,
                        title: l10n.userDisputes,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const AdminDisputesPage(),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.notifications_none,
                      title: l10n.notifications,
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.remove_red_eye_outlined,
                      title: l10n.privacy,
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.lock_outline,
                      title: l10n.security,
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.support_agent,
                      title: l10n.support,
                    ),
                    const SizedBox(height: 8),
                    _MenuItem(
                      icon: Icons.info_outline,
                      title: l10n.aboutApp,
                    ),
                    const SizedBox(height: 22),
                    InkWell(
                      onTap: _logout,
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
                            l10n.logout,
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

class _PaymentRemindersCard extends ConsumerWidget {
  const _PaymentRemindersCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final remindersAsync = ref.watch(paymentRemindersProvider);

    return remindersAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (payments) {
        if (payments.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.paymentRemindersTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF001561),
                  ),
                ),
                const SizedBox(height: 6),
                Text(l10n.paymentRemindersEmpty),
              ],
            ),
          );
        }

        final visible = payments.take(3).toList();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.paymentRemindersTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF001561),
                ),
              ),
              const SizedBox(height: 10),
              ...visible.map(
                (payment) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    payment.type.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    l10n.paymentDueDate(
                      formatLocalizedDate(context, payment.dueDate),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AgreementPaymentsPage(
                          agreementId: payment.agreementId,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends ConsumerWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final meAsync = ref.watch(meProvider);

    return meAsync.when(
      loading: () => Row(
        children: [
          Container(
            height: 64,
            width: 64,
            decoration: const BoxDecoration(
              color: Color(0xFFD3D5DB),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 140,
                  color: const Color(0xFFE5E7EB),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 12,
                  width: 180,
                  color: const Color(0xFFE5E7EB),
                ),
              ],
            ),
          ),
        ],
      ),
      error: (_, __) => Row(
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.userFallback,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF001561),
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.errorProfileLoadFailed,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8A93B1),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      data: (me) => Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: const Color(0xFFD3D5DB),
            backgroundImage: (me.avatarUrl != null && me.avatarUrl!.isNotEmpty)
                ? NetworkImage(me.avatarUrl!)
                : null,
            child: (me.avatarUrl == null || me.avatarUrl!.isEmpty)
                ? const Icon(Icons.person, color: Colors.white, size: 34)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  me.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF001561),
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  me.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8A93B1),
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

class _ProfileDoneCard extends StatelessWidget {
  const _ProfileDoneCard();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
          const Icon(
            Icons.check_box_outlined,
            color: Color(0xFF2EC766),
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileCompleted,
                  style: textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF001561),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.profileCompletedSubtitle,
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
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${l10n.profileTitle} 40%',
                style: textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF4E5884),
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
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
    final l10n = context.l10n;
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
              l10n.profileContinueCompletion,
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.profileContinueCompletionSubtitle,
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
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final meAsync = ref.watch(meProvider);

    return meAsync.when(
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
      data: (me) {
        if (me.verificationStatus == 'VERIFIED') {
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
                const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF2ECC71),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.verificationIdentityVerified,
                        style: textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF001561),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.verificationTrustSubtitle,
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

        if (me.verificationStatus == 'PENDING') {
          return Container(
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
                const Icon(
                  Icons.hourglass_top_rounded,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.verificationStatusPending,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.verificationPendingSubtitle,
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
                        l10n.verificationConfirmIdentity,
                        style: textTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.verificationTrustSubtitle,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFA7AEBD), size: 22),
          ],
        ),
      ),
    );
  }
}
