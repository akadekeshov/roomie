import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import 'chat_detail_page.dart';
import 'data/chat_models.dart';
import 'data/chat_providers.dart';

class ChatsPage extends ConsumerStatefulWidget {
  const ChatsPage({super.key});

  @override
  ConsumerState<ChatsPage> createState() => _ChatsPageState();
}

class _ChatsPageState extends ConsumerState<ChatsPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(chatConversationsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text('Messages', style: AppTextStyles.title),
                  Spacer(),
                  Icon(Icons.more_horiz),
                ],
              ),
              const SizedBox(height: AppSpacing.headerGap),
              Container(
                height: AppSizes.searchHeight,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.searchBg,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, size: 18, color: Colors.black38),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                          isCollapsed: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.searchGap),
              Expanded(
                child: async.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (e, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Failed to load chats\n$e',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: () =>
                                ref.invalidate(chatConversationsProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (chats) {
                    final query = _searchController.text.trim().toLowerCase();
                    final filtered = chats.where((c) {
                      if (query.isEmpty) return true;
                      return c.peerName.toLowerCase().contains(query) ||
                          (c.lastMessageText ?? '').toLowerCase().contains(query);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const Center(child: Text('No messages yet'));
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(chatConversationsProvider);
                        await ref.read(chatConversationsProvider.future);
                      },
                      child: ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.chatItemGap),
                        itemBuilder: (_, i) => _ChatTile(
                          chat: filtered[i],
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatDetailPage(
                                  conversationId: filtered[i].id,
                                  title: filtered[i].peerName,
                                  imageUrl: filtered[i].peerAvatarUrl,
                                  letter: _firstLetter(filtered[i].peerName),
                                ),
                              ),
                            );
                            ref.invalidate(chatConversationsProvider);
                          },
                        ),
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

  String _firstLetter(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return t.characters.first.toUpperCase();
  }
}

class _ChatTile extends StatelessWidget {
  const _ChatTile({
    required this.chat,
    required this.onTap,
  });

  final ChatConversation chat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lastText = (chat.lastMessageText ?? '').trim();
    final timeText = _formatTime(chat.lastMessageAt);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Row(
        children: [
          CircleAvatar(
            radius: AppSizes.avatarRadius,
            backgroundColor: const Color(0xFFE5E7EB),
            backgroundImage:
                chat.peerAvatarUrl != null ? NetworkImage(chat.peerAvatarUrl!) : null,
            child: chat.peerAvatarUrl == null
                ? Text(
                    _firstLetter(chat.peerName),
                    style: const TextStyle(
                      color: Color(0xFF001561),
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: AppSpacing.avatarToTextGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chat.peerName, style: AppTextStyles.name),
                const SizedBox(height: AppSpacing.nameToLastGap),
                Text(
                  lastText.isEmpty ? 'Start conversation' : lastText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.secondary12,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.rightColumnGap),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(timeText, style: AppTextStyles.secondary12),
              const SizedBox(height: AppSpacing.timeToBadgeGap),
              if (chat.unreadCount > 0)
                Container(
                  width: AppSizes.unreadBadge,
                  height: AppSizes.unreadBadge,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius:
                        BorderRadius.circular(AppSizes.unreadBadge / 2),
                  ),
                  child: Text(
                    '${chat.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _firstLetter(String s) {
    final t = s.trim();
    if (t.isEmpty) return '?';
    return t.characters.first.toUpperCase();
  }

  static String _formatTime(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}';
  }
}
