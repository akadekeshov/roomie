import 'package:dio/dio.dart';

import 'chat_models.dart';

class ChatRepository {
  ChatRepository(this._dio);

  final Dio _dio;

  Future<List<ChatConversation>> getConversations() async {
    final response = await _dio.get('/chat/conversations');
    final payload = response.data;
    final raw = payload is Map<String, dynamic> ? payload['data'] : payload;
    final list = (raw as List?)?.cast<dynamic>() ?? const [];
    return list
        .whereType<Map>()
        .map((e) => ChatConversation.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<String> getOrCreateDirectConversation(String peerUserId) async {
    final response = await _dio.post('/chat/direct/$peerUserId');
    final data = (response.data as Map?)?.cast<String, dynamic>() ?? const {};
    final conversationId = data['conversationId']?.toString() ?? '';
    if (conversationId.isEmpty) {
      throw Exception('Не удалось получить идентификатор чата');
    }
    return conversationId;
  }

  Future<List<ChatMessage>> getMessages(
    String conversationId, {
    String? beforeIso,
    int limit = 50,
  }) async {
    final response = await _dio.get(
      '/chat/conversations/$conversationId/messages',
      queryParameters: {
        if (beforeIso != null && beforeIso.isNotEmpty) 'before': beforeIso,
        'limit': limit,
      },
    );

    final payload = response.data;
    final raw = payload is Map<String, dynamic> ? payload['data'] : payload;
    final list = (raw as List?)?.cast<dynamic>() ?? const [];

    return list
        .whereType<Map>()
        .map((e) => ChatMessage.fromJson(e.cast<String, dynamic>()))
        .toList();
  }

  Future<ChatMessage> sendMessage(String conversationId, String text) async {
    final response = await _dio.post(
      '/chat/conversations/$conversationId/messages',
      data: {'text': text},
    );
    final data = (response.data as Map?)?.cast<String, dynamic>() ?? const {};
    return ChatMessage.fromJson(data);
  }

  Future<void> markRead(String conversationId) async {
    await _dio.patch('/chat/conversations/$conversationId/read');
  }
}
