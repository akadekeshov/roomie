import '../../../core/network/api_config.dart';

class ChatConversation {
  const ChatConversation({
    required this.id,
    required this.peerId,
    required this.peerName,
    required this.peerAvatarRaw,
    required this.lastMessageText,
    required this.lastMessageAt,
    required this.unreadCount,
  });

  final String id;
  final String? peerId;
  final String peerName;
  final String? peerAvatarRaw;
  final String? lastMessageText;
  final DateTime? lastMessageAt;
  final int unreadCount;

  String? get peerAvatarUrl {
    final raw = (peerAvatarRaw ?? '').trim();
    if (raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    return '${ApiConfig.publicBaseUrl}${raw.startsWith('/') ? '' : '/'}$raw';
  }

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    final peer = (json['peer'] as Map?)?.cast<String, dynamic>() ?? const {};
    final last = (json['lastMessage'] as Map?)?.cast<String, dynamic>();

    final unreadRaw = json['unreadCount'];
    final unread = unreadRaw is num
        ? unreadRaw.toInt()
        : int.tryParse('${unreadRaw ?? 0}') ?? 0;

    final lastAtRaw = last?['createdAt'];

    return ChatConversation(
      id: '${json['conversationId'] ?? json['id'] ?? ''}',
      peerId: peer['id']?.toString(),
      peerName: (peer['name']?.toString().trim().isNotEmpty ?? false)
          ? peer['name'].toString().trim()
          : 'Пользователь',
      peerAvatarRaw: peer['avatarUrl']?.toString(),
      lastMessageText: last?['text']?.toString(),
      lastMessageAt: lastAtRaw == null ? null : DateTime.tryParse('$lastAtRaw'),
      unreadCount: unread < 0 ? 0 : unread,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.createdAt,
  });

  final String id;
  final String senderId;
  final String text;
  final DateTime createdAt;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: '${json['id'] ?? ''}',
      senderId: '${json['senderId'] ?? ''}',
      text: '${json['text'] ?? ''}',
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}') ?? DateTime.now(),
    );
  }
}
