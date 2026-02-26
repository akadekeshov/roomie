import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'home_repository.dart';
import 'listing_model.dart';
import 'recommended_user_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(dioProvider));
});

/// Legacy listings feed (not used on main screen anymore, kept for compatibility).
final listingsProvider = FutureProvider.autoDispose<List<Listing>>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getListings();
});

/// Recommended roommates for the main screen.
final recommendedUsersProvider =
    FutureProvider.autoDispose<List<RecommendedUser>>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  return repo.getRecommendedUsers();
});

class HiddenUsersNotifier extends StateNotifier<Set<String>> {
  HiddenUsersNotifier() : super(<String>{});

  void hide(String userId) => state = {...state, userId};
  void unhide(String userId) {
    final next = {...state};
    next.remove(userId);
    state = next;
  }

  void clear() => state = <String>{};
}

final hiddenUsersProvider =
    StateNotifierProvider<HiddenUsersNotifier, Set<String>>(
  (ref) => HiddenUsersNotifier(),
);
