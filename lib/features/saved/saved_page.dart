import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../home/data/recommended_user_model.dart';
import '../people/data/favorites_users_providers.dart';
import 'package:roommate_app/features/people/data/hidden_users_provider.dart';

import 'package:roommate_app/features/chat/chat_detail_page.dart';
import 'package:roommate_app/features/saved/saved_profile_page.dart';

class SavedPage extends ConsumerWidget {
  const SavedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(favoriteUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сохранённые'),
        centerTitle: true,
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
      ),
      body: async.when(
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
          final hiddenIds = ref.watch(hiddenUserIdsProvider);
          final visibleUsers =
              users.where((u) => !hiddenIds.contains(u.id)).toList();

          if (visibleUsers.isEmpty) {
            return const Center(child: Text('Пока пусто'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(AppSizes.gridPadding),
            itemCount: visibleUsers.length, // ✅ дұрыс
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSizes.gridSpacing,
              mainAxisSpacing: AppSizes.gridSpacing,
              childAspectRatio: AppSizes.gridAspectRatio,
            ),
            itemBuilder: (_, i) {
              final user = visibleUsers[i]; // ✅ дұрыс
              return _SavedUserCard(user: user);
            },
          );
        },
      ),
    );
  }
}

class _SavedUserCard extends StatelessWidget {
  const _SavedUserCard({required this.user});

  final RecommendedUser user;

  // ✅ чатқа керек дефолт аватар (asset)
  static const String _defaultChatAvatar = 'assets/images/ava1.png';

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(AppSizes.cardRadius);
    final imageUrl = user.avatarUrl ?? '';

    final match = user.matchPercent;
    final verified = user.isVerified;
    final tag = (user.preferenceTag ?? '').trim();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: r,
        onTap: () {
           Navigator.push(
             context,
             MaterialPageRoute(
                builder: (_) => SavedUserProfilePage(user: user),
                ),
               );
              },
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
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person,
                            size: 46,
                            color: AppColors.mutedText,
                          ),
                        ),
                ),

                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _BottomOverlay(height: 150),
                ),

                Positioned(
                  top: 10,
                  left: 10,
                  child: _MatchBadge(percent: match),
                ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: _TopCheck(isActive: verified),
                ),

                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.overlayHPad,
                      12,
                      AppSizes.overlayHPad,
                      AppSizes.overlayBottomPad,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          user.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.nameText,
                            fontSize: AppSizes.nameFont,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          user.locationText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.locationText,
                            fontSize: AppSizes.locationFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (tag.isNotEmpty) ...[
                          _TagPill(text: tag),
                          const SizedBox(height: 10),
                        ],

                        _WriteButton(
                          onPressed: () {
                            // ✅ "Написать" -> ChatDetailPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailPage(
                                  title: user.displayName,
                                  online: true, // қазір бек жоқ, placeholder
                                  letter: user.displayName.isNotEmpty
                                      ? user.displayName.trim()[0]
                                      : '?',
                                  imagePath: _defaultChatAvatar,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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
  const _BottomOverlay({required this.height});
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.overlayTop, AppColors.overlayBottom],
        ),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.percent});
  final int percent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$percent%',
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
      ),
    );
  }
}

class _TopCheck extends StatelessWidget {
  const _TopCheck({required this.isActive});
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 14,
      backgroundColor:
          isActive ? AppColors.primary : Colors.white.withOpacity(0.55),
      child: Icon(
        Icons.check,
        size: 16,
        color: isActive ? Colors.white : Colors.transparent,
      ),
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.28),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withOpacity(0.35)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _WriteButton extends StatelessWidget {
  const _WriteButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: const Text('Написать'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}