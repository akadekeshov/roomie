import 'package:flutter/material.dart';
import 'package:roommate_app/core/theme/app_colors.dart';
import 'package:roommate_app/core/theme/app_sizes.dart';
import 'package:roommate_app/core/theme/app_text_styles.dart';

class ChatDetailPage extends StatefulWidget {
  final String title;
  final bool online;
  final String letter;
  final String imagePath;

  const ChatDetailPage({
    super.key,
    required this.title,
    required this.online,
    required this.letter,
    required this.imagePath,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final input = TextEditingController();

  final List<_Msg> msgs = [
    _Msg("Привет! Я видела твой профиль,\nдумаю, мы отлично подходим!", false,
        "10:30"),
    _Msg("Привет! Спасибо, что написала.\nРасскажи о себе поподробнее!", true,
        "10:32"),
    _Msg(
        "Я программист, работаю из дома\nпару дней в неделю. Я\nчистоплотная и уважаю личное\nпространство.",
        false,
        "10:33"),
    _Msg(
        "Звучит идеально! Я тоже работаю\nиз дома. У тебя есть домашние\nживотные?",
        true,
        "10:35"),
    _Msg(
        "У меня есть кошка! Надеюсь, это\nне проблема. Она очень\nдружелюбная и воспитанная.",
        false,
        "10:36"),
  ];

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void send() {
    final t = input.text.trim();
    if (t.isEmpty) return;
    setState(() => msgs.add(_Msg(t, true, _hhmm())));
    input.clear();
  }

  String _hhmm() {
    final d = DateTime.now();
    return "${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pad),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(
                        radius: AppSizes.avatarRadius,
                        backgroundImage: AssetImage(widget.imagePath),
                      ),
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: Container(
                          width: AppSizes.onlineDot,
                          height: AppSizes.onlineDot,
                          decoration: BoxDecoration(
                            color: widget.online
                                ? AppColors.online
                                : AppColors.offline,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.title, style: AppTextStyles.name),
                        const SizedBox(height: 2),
                        Text(widget.online ? "В сети" : "Не в сети",
                            style: AppTextStyles.secondary12),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_horiz),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 8),
                  itemCount: msgs.length,
                  itemBuilder: (_, i) => _Bubble(msgs[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    _Chip(
                      "Когда можно встретиться?",
                      onTap: () => setState(
                          () => input.text = "Когда можно встретиться?"),
                    ),
                    const SizedBox(width: 10),
                    _Chip(
                      "Расскажи подробнее",
                      onTap: () =>
                          setState(() => input.text = "Расскажи подробнее"),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: AppSizes.inputHeight,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.image_outlined,
                              size: 18, color: Colors.black38),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: input,
                              decoration: const InputDecoration(
                                hintText: "Напишите сообщение...",
                                border: InputBorder.none,
                                isCollapsed: true,
                              ),
                              style: AppTextStyles.input,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ValueListenableBuilder(
                    valueListenable: input,
                    builder: (_, __, ___) {
                      final hasText = input.text.trim().isNotEmpty;
                      return InkWell(
                        onTap: hasText ? send : null,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                hasText ? AppColors.primary : AppColors.border,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(Icons.send_rounded,
                              size: 18,
                              color: hasText ? Colors.white : Colors.black38),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool isMe;
  final String time;
  _Msg(this.text, this.isMe, this.time);
}

class _Bubble extends StatelessWidget {
  final _Msg msg;
  const _Bubble(this.msg);

  @override
  Widget build(BuildContext context) {
    final isMe = msg.isMe;
    final bubbleColor = isMe ? AppColors.bubbleMe : AppColors.bubbleOther;
    final textColor = isMe ? Colors.white : Colors.black87;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(AppSizes.rBig),
      topRight: const Radius.circular(AppSizes.rBig),
      bottomLeft: Radius.circular(isMe ? AppSizes.rBig : AppSizes.rSmall),
      bottomRight: Radius.circular(isMe ? AppSizes.rSmall : AppSizes.rBig),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration:
                      BoxDecoration(color: bubbleColor, borderRadius: radius),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(msg.time,
                    style:
                        const TextStyle(fontSize: 11, color: Colors.black38)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _Chip(this.text, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.chipBg,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.chipText,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
