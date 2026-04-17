import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_sizes.dart';
import '../../core/theme/app_text_styles.dart';
import '../profile/data/me_repository.dart';
import 'data/chat_models.dart';
import 'data/chat_providers.dart';

class ChatDetailPage extends ConsumerStatefulWidget {
  const ChatDetailPage({
    super.key,
    this.conversationId,
    this.peerUserId,
    this.title,
    this.imageUrl,
    this.online = false,
    this.letter = '?',
    this.imagePath,
  });

  final String? conversationId;
  final String? peerUserId;
  final String? title;
  final String? imageUrl;
  final bool online;
  final String letter;
  final String? imagePath;

  @override
  ConsumerState<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends ConsumerState<ChatDetailPage> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();

  List<ChatMessage> _messages = const [];
  String? _conversationId;
  bool _loading = true;
  bool _sending = false;
  String? _error;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final repository = ref.read(chatRepositoryProvider);
      var conversationId = widget.conversationId;

      if ((conversationId == null || conversationId.isEmpty) &&
          widget.peerUserId != null &&
          widget.peerUserId!.isNotEmpty) {
        conversationId =
            await repository.getOrCreateDirectConversation(widget.peerUserId!);
      }

      if (conversationId == null || conversationId.isEmpty) {
        throw Exception('Не удалось открыть чат');
      }

      _conversationId = conversationId;
      await _loadMessages(scrollToBottom: true);

      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        _loadMessages();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadMessages({bool scrollToBottom = false}) async {
    final conversationId = _conversationId;
    if (conversationId == null || conversationId.isEmpty) return;

    try {
      final repository = ref.read(chatRepositoryProvider);
      final messages = await repository.getMessages(conversationId, limit: 100);
      await repository.markRead(conversationId);
      ref.invalidate(chatConversationsProvider);

      if (!mounted) return;
      setState(() {
        _messages = messages;
      });

      if (scrollToBottom) {
        _scrollToBottom(animated: false);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = '$error');
    }
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    final conversationId = _conversationId;
    if (text.isEmpty || conversationId == null || _sending) return;

    setState(() => _sending = true);
    try {
      final repository = ref.read(chatRepositoryProvider);
      await repository.sendMessage(conversationId, text);
      _inputController.clear();
      await _loadMessages(scrollToBottom: true);
      ref.invalidate(chatConversationsProvider);
      if (!mounted) return;
      _scrollToBottom(animated: true);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Не удалось отправить сообщение: $error'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  void _scrollToBottom({required bool animated}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final position = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          position,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(position);
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(meProvider).valueOrNull;
    final currentUserId = me?.id;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.pad),
          child: Column(
            children: [
              _Header(
                title: widget.title ?? 'Чат',
                online: widget.online,
                letter: widget.letter,
                imageUrl: widget.imageUrl,
                imagePath: widget.imagePath,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: _buildBody(currentUserId),
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
                          const Icon(
                            Icons.message_outlined,
                            size: 18,
                            color: Colors.black38,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              minLines: 1,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Напишите сообщение...',
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
                    valueListenable: _inputController,
                    builder: (_, __, ___) {
                      final hasText =
                          _inputController.text.trim().isNotEmpty && !_sending;
                      return InkWell(
                        onTap: hasText ? _send : null,
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color:
                                hasText ? AppColors.primary : AppColors.border,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            size: 18,
                            color: hasText ? Colors.white : Colors.black38,
                          ),
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

  Widget _buildBody(String? currentUserId) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _error!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _init,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(
        child: Text('Сообщений пока нет. Начните общение.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadMessages(scrollToBottom: false),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        itemCount: _messages.length,
        itemBuilder: (_, index) {
          final message = _messages[index];
          final isMe = currentUserId != null && message.senderId == currentUserId;
          return _Bubble(
            text: message.text,
            isMe: isMe,
            time: _formatTime(message.createdAt),
          );
        },
      ),
    );
  }

  static String _formatTime(DateTime dateTime) {
    final hours = dateTime.hour.toString().padLeft(2, '0');
    final minutes = dateTime.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.online,
    required this.letter,
    this.imageUrl,
    this.imagePath,
  });

  final String title;
  final bool online;
  final String letter;
  final String? imageUrl;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final ImageProvider<Object>? avatarProvider;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarProvider = NetworkImage(imageUrl!);
    } else if (imagePath != null && imagePath!.isNotEmpty) {
      avatarProvider = AssetImage(imagePath!);
    } else {
      avatarProvider = null;
    }

    return Row(
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
              backgroundColor: const Color(0xFFE5E7EB),
              backgroundImage: avatarProvider,
              child: avatarProvider == null
                  ? Text(
                      letter.isEmpty ? '?' : letter[0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF001561),
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  : null,
            ),
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: AppSizes.onlineDot,
                height: AppSizes.onlineDot,
                decoration: BoxDecoration(
                  color: online ? AppColors.online : AppColors.offline,
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
              Text(title, style: AppTextStyles.name),
              const SizedBox(height: 2),
              Text(
                online ? 'В сети' : 'Не в сети',
                style: AppTextStyles.secondary12,
              ),
            ],
          ),
        ),
        const Icon(Icons.more_horiz),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.isMe,
    required this.time,
  });

  final String text;
  final bool isMe;
  final String time;

  @override
  Widget build(BuildContext context) {
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
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: radius,
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
