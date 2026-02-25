import 'package:dio/dio.dart';

import '../../home/data/recommended_user_model.dart';

class FavoritesUsersRepository {
  const FavoritesUsersRepository(this._dio);

  final Dio _dio;

  Future<List<RecommendedUser>> getFavorites({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/favorites/users',
      queryParameters: {'page': page, 'limit': limit},
    );
    final data = response.data;
    if (data == null) return [];
    final list = data['data'];
    if (list is! List) return [];
    return list
        .map(
          (e) => RecommendedUser.fromJson(
            (e as Map<String, dynamic>).cast<String, dynamic>(),
          ),
        )
        .toList();
  }

  Future<void> addFavorite(String targetUserId) async {
    await _dio.post<void>('/favorites/users/$targetUserId');
  }

  Future<void> removeFavorite(String targetUserId) async {
    await _dio.delete<void>('/favorites/users/$targetUserId');
  }
}

