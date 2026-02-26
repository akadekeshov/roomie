import 'package:dio/dio.dart';
import 'listing_model.dart';
import 'recommended_user_model.dart';

class HomeRepository {
  const HomeRepository(this._dio);
  final Dio _dio;

  /// Legacy listings
  Future<List<Listing>> getListings({int page = 1, int limit = 20}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/listings',
      queryParameters: {'page': page, 'limit': limit},
    );

    final list = response.data?['data'];
    if (list is! List) return [];

    return list
        .map((e) => Listing.fromJson(
            (e as Map<String, dynamic>).cast<String, dynamic>()))
        .toList();
  }

  /// VERIFIED recommended users
  Future<List<RecommendedUser>> getRecommendedUsers({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/users/recommendations',
      queryParameters: {'page': page, 'limit': limit},
    );

    print('RESPONSE >>> ${response.data}');

    final list = response.data?['data'];
    if (list is! List) return [];

    return list
        .map(
          (e) => RecommendedUser.fromJson(
            (e as Map<String, dynamic>).cast<String, dynamic>(),
          ),
        )
        .toList();
  }

  /// Save roommate
  Future<void> saveUser(String targetUserId) async {
    await _dio.post('/favorites/users/$targetUserId');
  }

  /// Unsave roommate
  Future<void> unsaveUser(String targetUserId) async {
    await _dio.delete('/favorites/users/$targetUserId');
  }
}
