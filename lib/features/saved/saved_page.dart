import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../home/data/recommended_user_model.dart';
import '../people/data/favorites_users_providers.dart';

class SavedPage extends ConsumerWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(favoriteUsersProvider);

    return async.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Не удалось загрузить избранных пользователей',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => ref.invalidate(favoriteUsersProvider),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      ),
      data: (users) {
        if (users.isEmpty) {
          return const Center(child: Text('Пока пусто'));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(AppSizes.gridPadding),
          itemCount: users.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSizes.gridSpacing,
            mainAxisSpacing: AppSizes.gridSpacing,
            childAspectRatio: AppSizes.gridAspectRatio,
          ),
          itemBuilder: (_, i) {
            final user = users[i];
            return _SavedUserCard(user: user);
          },
        );
      },
    );
  }
}

class _SavedUserCard extends StatelessWidget {
  const _SavedUserCard({required this.user});

  final RecommendedUser user;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(AppSizes.cardRadius);
    final imageUrl = user.avatarUrl ?? '';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: r,
        onTap: () {},
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: r,
            color: AppColors.cardBg,
            boxShadow: const [
              BoxShadow(
                blurRadius: AppSizes.shadowBlur,
                offset: Offset(0, AppSizes.shadowOffsetY),
                color: AppColors.shadow,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: r,
            child: Stack(
              children: [
                Positioned.fill(
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.avatarPlaceholder,
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: AppColors.mutedText,
                          ),
                        ),
                ),
                const _BottomOverlay(),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _Info(
                    title: user.displayName,
                    location: user.city ?? user.searchDistrict ?? '',
                    subtitle: (user.bio ?? '').trim(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomOverlay extends StatelessWidget {
  const _BottomOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        height: 110,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.overlayTop, AppColors.overlayBottom],
          ),
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final String title;
  final String location;
  final String subtitle;

  const _Info({
    required this.title,
    required this.location,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubtitle = subtitle.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.overlayHPad,
        AppSizes.overlayTopPad,
        AppSizes.overlayHPad,
        AppSizes.overlayBottomPad,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.nameText,
              fontSize: AppSizes.nameFont,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSizes.textGap),
          Text(
            location,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.locationText,
              fontSize: AppSizes.locationFont,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasSubtitle) ...[
            const SizedBox(height: AppSizes.textGap),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.subtitleText,
                fontSize: AppSizes.subtitleFont,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
