import 'package:dio/dio.dart';

import '../../home/data/recommended_user_model.dart';

class SavedRepository {
  const SavedRepository(this._dio);
  final Dio _dio;

  /// GET /favorites/users?page&limit
  /// Returns response like: { data: [...], meta: {...} }  (ең жиі формат)
  /// Егер сенде { items: [...] } болса, төменде айтып кетем.
  Future<List<RecommendedUser>> getSavedUsers({int page = 1, int limit = 50}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/favorites/users',
      queryParameters: {'page': page, 'limit': limit},
    );

    final body = res.data ?? {};

    // формат 1: { data: [...] }
    final data = body['data'];
    if (data is List) {
      return data
          .whereType<Map>()
          .map((e) => RecommendedUser.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    // формат 2: { items: [...] }
    final items = body['items'];
    if (items is List) {
      return items
          .whereType<Map>()
          .map((e) => RecommendedUser.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    // формат 3: backend тупо List қайтарса
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => RecommendedUser.fromJson(e.cast<String, dynamic>()))
          .toList();
    }

    return [];
  }

  /// POST /favorites/users/:targetUserId
  Future<void> saveUser(String targetUserId) async {
    await _dio.post('/favorites/users/$targetUserId');
  }

  /// DELETE /favorites/users/:targetUserId
  Future<void> unsaveUser(String targetUserId) async {
    await _dio.delete('/favorites/users/$targetUserId');
  }
}