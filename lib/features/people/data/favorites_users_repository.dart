import 'package:dio/dio.dart';
import '../../home/data/recommended_user_model.dart';

class FavoritesUsersRepository {
  const FavoritesUsersRepository(this._dio);

  final Dio _dio;

  Future<List<RecommendedUser>> getFavorites({
    int page = 1,
    int limit = 50,
  }) async {
    final response = await _dio.get<dynamic>(
      '/favorites/users',
      queryParameters: {'page': page, 'limit': limit},
    );

    final body = response.data;
    if (body == null) return const <RecommendedUser>[];

    // ✅ Accept multiple backend shapes:
    // 1) { data: [...] }
    // 2) { items: [...] }
    // 3) { results: [...] }
    // 4) [...] (direct list)
    List<dynamic>? rawList;

    if (body is List) {
      rawList = body;
    } else if (body is Map<String, dynamic>) {
      final d = body['data'];
      final i = body['items'];
      final r = body['results'];

      if (d is List) rawList = d;
      if (rawList == null && i is List) rawList = i;
      if (rawList == null && r is List) rawList = r;
    } else if (body is Map) {
      final map = body.cast<String, dynamic>();
      final d = map['data'];
      final i = map['items'];
      final r = map['results'];

      if (d is List) rawList = d;
      if (rawList == null && i is List) rawList = i;
      if (rawList == null && r is List) rawList = r;
    }

    if (rawList == null) return const <RecommendedUser>[];

    final result = <RecommendedUser>[];
    for (final e in rawList) {
      if (e is Map<String, dynamic>) {
        result.add(RecommendedUser.fromJson(e));
      } else if (e is Map) {
        result.add(RecommendedUser.fromJson(e.cast<String, dynamic>()));
      }
    }
    return result;
  }

  Future<void> addFavorite(String targetUserId) async {
    await _dio.post<void>('/favorites/users/$targetUserId');
  }

  Future<void> removeFavorite(String targetUserId) async {
    await _dio.delete<void>('/favorites/users/$targetUserId');
  }
}