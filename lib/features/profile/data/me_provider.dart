// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import '../../../core/network/network_providers.dart';

// final meProvider = FutureProvider<Map<String, dynamic>>((ref) async {
//   final dio = ref.read(dioProvider);

//   final response = await dio.get<Map<String, dynamic>>('/auth/me');

//   return response.data ?? <String, dynamic>{};
// });