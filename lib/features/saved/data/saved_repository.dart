import 'package:dio/dio.dart';

import '../../home/data/recommended_user_model.dart';

class SavedRepository {
  const SavedRepository(this._dio);
  final Dio _dio;

  /// GET /favorites/users?page&limit.
  /// Supports both response shapes:
  /// - { data: [...] }
  /// - { items: [...] }
  /// - raw list: [ ... ]
  Future<List<RecommendedUser>> getSavedUsers({
    int page = 1,
    int limit = 50,
  }) async {
    final res = await _dio.get<dynamic>(
      '/favorites/users',
      queryParameters: {'page': page, 'limit': limit},
    );

    final body = res.data;
    if (body == null) return [];

    if (body is Map<String, dynamic>) {
      final data = body['data'];
      if (data is List) {
        return data
            .whereType<Map>()
            .map((e) => RecommendedUser.fromJson(e.cast<String, dynamic>()))
            .toList();
      }

      final items = body['items'];
      if (items is List) {
        return items
            .whereType<Map>()
            .map((e) => RecommendedUser.fromJson(e.cast<String, dynamic>()))
            .toList();
      }
    }

    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => RecommendedUser.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    return [];
  }

  Future<void> saveUser(String targetUserId) async {
    await _dio.post('/favorites/users/$targetUserId');
  }

  Future<void> unsaveUser(String targetUserId) async {
    await _dio.delete('/favorites/users/$targetUserId');
  }
}
