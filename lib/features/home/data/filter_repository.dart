import 'package:dio/dio.dart';

import 'recommended_user_model.dart';

class FilterRepository {
  const FilterRepository(this._dio);

  final Dio _dio;

  Future<List<RecommendedUser>> filterUsers({
    String? district,
    int? priceMin,
    int? priceMax,
    String? gender,
    String? petsPreference,
    String? smokingPreference,
    String? noisePreference,
    int page = 1,
    int limit = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (district != null && district.trim().isNotEmpty) {
      query['district'] = district.trim();
    }
    if (priceMin != null) query['priceMin'] = priceMin;
    if (priceMax != null) query['priceMax'] = priceMax;
    if (gender != null && gender.trim().isNotEmpty) {
      query['gender'] = gender.trim();
    }
    if (petsPreference != null && petsPreference.trim().isNotEmpty) {
      query['petsPreference'] = petsPreference.trim();
    }
    if (smokingPreference != null && smokingPreference.trim().isNotEmpty) {
      query['smokingPreference'] = smokingPreference.trim();
    }
    if (noisePreference != null && noisePreference.trim().isNotEmpty) {
      query['noisePreference'] = noisePreference.trim();
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '/users/filter',
      queryParameters: query,
    );

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
}

