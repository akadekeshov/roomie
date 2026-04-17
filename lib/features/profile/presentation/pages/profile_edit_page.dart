import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../home/data/home_providers.dart';
import '../../data/me_repository.dart';
import '../../data/onboarding_repository.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  late Future<OnboardingStatus> _statusFuture;

  @override
  void initState() {
    super.initState();
    _statusFuture = _loadStatus();
  }

  Future<OnboardingStatus> _loadStatus() {
    return ref.read(onboardingRepositoryProvider).getStatus();
  }

  Future<void> _openSection(String route) async {
    await Navigator.of(context).pushNamed(
      route,
      arguments: {'fromEdit': true},
    );
    if (!mounted) return;
    ref.invalidate(meProvider);
    ref.invalidate(recommendedUsersProvider);
    ref.invalidate(homeAutoRecommendationsProvider);
    setState(() => _statusFuture = _loadStatus());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text('Редактировать профиль'),
        backgroundColor: const Color(0xFFF3F4F6),
        foregroundColor: const Color(0xFF001561),
        elevation: 0,
      ),
      body: FutureBuilder<OnboardingStatus>(
        future: _statusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Failed to load profile'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => _statusFuture = _loadStatus()),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              ),
            );
          }

          final profile = snapshot.data!.profile;
          final _ = profile;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              _SectionTile(
                title: 'О себе',
                icon: Icons.badge_outlined,
                onTap: () => _openSection(AppRoutes.profileAbout),
              ),
              _SectionTile(
                title: 'Образ жизни',
                icon: Icons.self_improvement_outlined,
                onTap: () => _openSection(AppRoutes.profileLifestyle),
              ),
              _SectionTile(
                title: 'Параметры поиска',
                icon: Icons.tune_rounded,
                onTap: () => _openSection(AppRoutes.profileSearch),
              ),
              _SectionTile(
                title: 'Фото и био',
                icon: Icons.perm_media_outlined,
                onTap: () => _openSection(AppRoutes.profileFinish),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;

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


