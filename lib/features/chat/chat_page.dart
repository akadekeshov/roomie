import 'package:flutter/material.dart';
import 'package:roommate_app/features/chat/chat_detail_page.dart';
import 'package:roommate_app/core/theme/app_colors.dart';
import 'package:roommate_app/core/theme/app_sizes.dart';
import 'package:roommate_app/core/theme/app_spacing.dart';
import 'package:roommate_app/core/theme/app_radius.dart';
import 'package:roommate_app/core/theme/app_text_styles.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final chats = [
      _Chat(
        name: "Жанар Муратова",
        last: "Звучит отлично! Когда м...",
        time: "2 мин",
        unread: 2,
        online: true,
        letter: "Ж",
        imagePath: "assets/images/ava1.png",
      ),
      _Chat(
        name: "Нурсултан Куандыков",
        last: "Спасибо за отклик! Я хо...",
        time: "1 ч",
        unread: 1,
        online: false,
        letter: "Н",
        imagePath: "assets/images/ava2.png",
      ),
      _Chat(
        name: "Динара Алимиханова",
        last: "Отлично! Пришло детали с...",
        time: "3 ч",
        unread: 0,
        online: true,
        letter: "Д",
        imagePath: "assets/images/ava3.png",
      ),
      _Chat(
        name: "Айбек Жумабаев",
        last: "Договорились, до связи!",
        time: "1 дн",
        unread: 0,
        online: false,
        letter: "А",
        imagePath: "assets/images/ava6.png",
      ),
      _Chat(
        name: "Екатерина Родина",
        last: "Привет! Рада познакомиться 😊",
        time: "2 дн",
        unread: 0,
        online: false,
        letter: "Е",
        imagePath: "assets/images/ava5.png",
      ),
    ];

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
                  Text("Сообщения", style: AppTextStyles.title),
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
                child: const Row(
                  children: [
                    Icon(Icons.search, size: 18, color: Colors.black38),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        "Поиск",
                        style: TextStyle(
                          color: Colors.black38,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.searchGap),
              Expanded(
                child: ListView.separated(
                  itemCount: chats.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.chatItemGap),
                  itemBuilder: (_, i) => _ChatTile(
                    chat: chats[i],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailPage(
                            title: chats[i].name,
                            online: chats[i].online,
                            letter: chats[i].letter,
                            imagePath: chats[i].imagePath,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chat {
  final String name, last, time, letter;
  final int unread;
  final bool online;
  final String imagePath;

  _Chat({
    required this.name,
    required this.last,
    required this.time,
    required this.unread,
    required this.online,
    required this.letter,
    required this.imagePath,
  });
}

class _ChatTile extends StatelessWidget {
  final _Chat chat;
  final VoidCallback onTap;

  const _ChatTile({
    super.key,
    required this.chat,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: AppSizes.avatarRadius,
                backgroundImage: AssetImage(chat.imagePath),
              ),
              Positioned(
                right: -1,
                bottom: -1,
                child: Container(
                  width: AppSizes.onlineDot,
                  height: AppSizes.onlineDot,
                  decoration: BoxDecoration(
                    color: chat.online ? AppColors.online : AppColors.offline,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.avatarToTextGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(chat.name, style: AppTextStyles.name),
                const SizedBox(height: AppSpacing.nameToLastGap),
                Text(
                  chat.last,
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
              Text(chat.time, style: AppTextStyles.secondary12),
              const SizedBox(height: AppSpacing.timeToBadgeGap),
              if (chat.unread > 0)
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
                    "${chat.unread}",
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
}
