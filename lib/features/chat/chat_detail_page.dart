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
  final input = TextEditingController();
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
      final repo = ref.read(chatRepositoryProvider);
      var conversationId = widget.conversationId;

      if ((conversationId == null || conversationId.isEmpty) &&
          widget.peerUserId != null &&
          widget.peerUserId!.isNotEmpty) {
        conversationId =
            await repo.getOrCreateDirectConversation(widget.peerUserId!);
      }

      if (conversationId == null || conversationId.isEmpty) {
        throw Exception('Conversation id is missing');
      }

      _conversationId = conversationId;
      await _loadMessages();

      _pollTimer?.cancel();
      _pollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        _loadMessages(silent: true);
      });
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _loadMessages({bool silent = false}) async {
    final conversationId = _conversationId;
    if (conversationId == null || conversationId.isEmpty) return;

    try {
      final repo = ref.read(chatRepositoryProvider);
      final list = await repo.getMessages(conversationId, limit: 100);
      await repo.markRead(conversationId);

      if (!mounted) return;
      setState(() {
        _messages = list;
      });

      if (!silent) {
        _scrollToBottom(animated: false);
      }
    } catch (e) {
      if (!silent && mounted) {
        setState(() => _error = '$e');
      }
    }
  }

  void _scrollToBottom({required bool animated}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      final target = _scrollController.position.maxScrollExtent;
      if (animated) {
        _scrollController.animateTo(
          target,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(target);
      }
    });
  }

  Future<void> _send() async {
    final t = input.text.trim();
    final conversationId = _conversationId;
    if (t.isEmpty || conversationId == null || _sending) return;

    setState(() => _sending = true);
    try {
      final repo = ref.read(chatRepositoryProvider);
      final sent = await repo.sendMessage(conversationId, t);
      if (!mounted) return;
      setState(() {
        _messages = [..._messages, sent];
      });
      input.clear();
      _scrollToBottom(animated: true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    input.dispose();
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
                title: widget.title ?? 'Chat',
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
                          const Icon(Icons.message_outlined,
                              size: 18, color: Colors.black38),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: input,
                              minLines: 1,
                              maxLines: 4,
                              decoration: const InputDecoration(
                                hintText: 'Write a message...',
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
                      final hasText = input.text.trim().isNotEmpty && !_sending;
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
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_messages.isEmpty) {
      return const Center(child: Text('No messages yet. Start chatting.'));
    }

    return RefreshIndicator(
      onRefresh: _loadMessages,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        itemCount: _messages.length,
        itemBuilder: (_, i) {
          final msg = _messages[i];
          final isMe = currentUserId != null && msg.senderId == currentUserId;
          return _Bubble(
            text: msg.text,
            isMe: isMe,
            time: _hhmm(msg.createdAt),
          );
        },
      ),
    );
  }

  static String _hhmm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
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
              child: (imageUrl == null || imageUrl!.isEmpty) &&
                      (imagePath == null || imagePath!.isEmpty)
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
              Text(online ? 'Online' : 'Offline', style: AppTextStyles.secondary12),
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
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72),
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(color: bubbleColor, borderRadius: radius),
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
