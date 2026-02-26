import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../home/data/recommended_user_model.dart';
import 'favorites_users_repository.dart';

final favoritesUsersRepositoryProvider =
    Provider<FavoritesUsersRepository>((ref) {
  return FavoritesUsersRepository(ref.read(dioProvider));
});

/// List of favorite users (GET /favorites/users).
final favoriteUsersProvider =
    FutureProvider.autoDispose<List<RecommendedUser>>((ref) async {
  final repo = ref.watch(favoritesUsersRepositoryProvider);
  return repo.getFavorites();
});

/// Set of favorite user IDs.
final favoriteUserIdsProvider = Provider.autoDispose<Set<String>>((ref) {
  final async = ref.watch(favoriteUsersProvider);
  return async.maybeWhen(
    data: (list) => list.map((u) => u.id).toSet(),
    orElse: () => <String>{},
  );
});
