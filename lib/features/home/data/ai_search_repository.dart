import 'package:dio/dio.dart';

import 'ai_search_model.dart';

class AiSearchRepository {
  const AiSearchRepository(this._dio);

  final Dio _dio;

  Future<AiSearchResponse> search({
    required String query,
    int limit = 20,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/ai/search',
      data: <String, dynamic>{
        'query': query,
        'limit': limit,
      },
    );

    final data = response.data ?? <String, dynamic>{};
    return AiSearchResponse.fromJson(data);
  }
}
