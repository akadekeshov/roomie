import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'home_repository.dart';
import 'listing_model.dart';
import 'recommended_user_model.dart';

class HomeSearchFilters {
  const HomeSearchFilters({
    this.budgetMax,
    this.district,
    this.gender,
    this.ageRange,
  });

  final int? budgetMax;
  final String? district;
  final String? gender;
  final String? ageRange;

  HomeSearchFilters copyWith({
    int? budgetMax,
    String? district,
    String? gender,
    String? ageRange,
    bool clearBudgetMax = false,
    bool clearDistrict = false,
    bool clearGender = false,
    bool clearAgeRange = false,
  }) {
    return HomeSearchFilters(
      budgetMax: clearBudgetMax ? null : (budgetMax ?? this.budgetMax),
      district: clearDistrict ? null : (district ?? this.district),
      gender: clearGender ? null : (gender ?? this.gender),
      ageRange: clearAgeRange ? null : (ageRange ?? this.ageRange),
    );
  }
}

class HomeSearchFiltersNotifier extends StateNotifier<HomeSearchFilters> {
  HomeSearchFiltersNotifier() : super(const HomeSearchFilters());

  void setFilters(HomeSearchFilters value) => state = value;

  void clear() => state = const HomeSearchFilters();
}

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
  final filters = ref.watch(homeSearchFiltersProvider);
  return repo.getRecommendedUsers(
    budgetMax: filters.budgetMax,
    district: filters.district,
    gender: filters.gender,
    ageRange: filters.ageRange,
  );
});

final homeSearchFiltersProvider =
    StateNotifierProvider<HomeSearchFiltersNotifier, HomeSearchFilters>(
  (ref) => HomeSearchFiltersNotifier(),
);

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
