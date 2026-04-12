import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../home/data/recommended_user_model.dart';
import 'saved_repository.dart';

final savedRepositoryProvider = Provider<SavedRepository>((ref) {
  return SavedRepository(ref.read(dioProvider));
});

/// All saved users from GET /favorites/users.
final savedUsersProvider =
    FutureProvider.autoDispose<List<RecommendedUser>>((ref) async {
  final repo = ref.watch(savedRepositoryProvider);
  return repo.getSavedUsers();
});

/// Set of saved user IDs derived from saved users list.
final savedIdsProvider = Provider.autoDispose<Set<String>>((ref) {
  final async = ref.watch(savedUsersProvider);
  return async.when(
    data: (list) => list.map((e) => e.id).toSet(),
    loading: () => <String>{},
    error: (_, __) => <String>{},
  );
});
