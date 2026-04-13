import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../profile/data/me_repository.dart';
import 'home_repository.dart';
import 'recommended_user_model.dart';
import 'filter_providers.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(dioProvider));
});

/// Статус автоматических рекомендаций.
enum HomeAutoState {
  profileIncomplete,
  verificationPending,
  verificationRejected,
  noRecommendations,
  loaded,
}

class HomeAutoRecommendations {
  const HomeAutoRecommendations(this.state, this.users);

  final HomeAutoState state;
  final List<RecommendedUser> users;
}

/// Автоматические рекомендации на основе профиля текущего пользователя.
final homeAutoRecommendationsProvider =
    FutureProvider<HomeAutoRecommendations>((ref) async {
  final me = await ref.read(meProvider.future);

  if (!me.onboardingCompleted) {
    return const HomeAutoRecommendations(
      HomeAutoState.profileIncomplete,
      <RecommendedUser>[],
    );
  }

  final status = me.verificationStatus;
  if (status == 'PENDING' || status == null) {
    return const HomeAutoRecommendations(
      HomeAutoState.verificationPending,
      <RecommendedUser>[],
    );
  }
  if (status == 'REJECTED') {
    return const HomeAutoRecommendations(
      HomeAutoState.verificationRejected,
      <RecommendedUser>[],
    );
  }

  final repo = ref.read(homeRepositoryProvider);
  final users = await repo.getPersonalizedRecommendations();

  if (users.isEmpty) {
    return const HomeAutoRecommendations(
      HomeAutoState.noRecommendations,
      <RecommendedUser>[],
    );
  }

  return HomeAutoRecommendations(HomeAutoState.loaded, users);
});

/// VERIFIED recommended users c учётом базовых фильтров
/// (district / budgetMax / gender) из FilterState.
final recommendedUsersProvider =
    FutureProvider.autoDispose<List<RecommendedUser>>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  final filters = ref.watch(filterStateProvider);

  return repo.getRecommendedUsers(
    budgetMax: filters.priceMax,
    district: filters.district,
    gender: filters.gender,
    // ageRange в текущей версии фильтра не задаётся — оставляем null
  );
});