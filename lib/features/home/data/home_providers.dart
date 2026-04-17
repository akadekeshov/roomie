import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../profile/data/me_repository.dart';
import 'filter_providers.dart';
import 'home_repository.dart';
import 'recommended_user_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository(ref.read(dioProvider));
});

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

final homeAutoRecommendationsProvider =
    FutureProvider<HomeAutoRecommendations>((ref) async {
  final repo = ref.read(homeRepositoryProvider);
  MeUser? me;

  try {
    me = await ref
        .read(meProvider.future)
        .timeout(const Duration(seconds: 6));
  } catch (_) {
    me = null;
  }

  List<RecommendedUser> users = const <RecommendedUser>[];
  Object? personalizedError;
  StackTrace? personalizedStackTrace;

  if (me?.onboardingCompleted == true) {
    try {
      users = await repo
          .getPersonalizedRecommendations()
          .timeout(const Duration(seconds: 8));
    } catch (error, stackTrace) {
      personalizedError = error;
      personalizedStackTrace = stackTrace;
    }
  }

  if (users.isEmpty && (me?.onboardingCompleted != true || personalizedError == null)) {
    try {
      users = await repo.discoverUsers().timeout(const Duration(seconds: 8));
    } catch (error) {
      if (personalizedError != null && personalizedStackTrace != null) {
        Error.throwWithStackTrace(personalizedError, personalizedStackTrace);
      }
      rethrow;
    }
  }

  if (me == null) {
    return HomeAutoRecommendations(HomeAutoState.loaded, users);
  }

  if (!me.onboardingCompleted) {
    return HomeAutoRecommendations(HomeAutoState.profileIncomplete, users);
  }

  final status = me.verificationStatus;
  if (status == 'PENDING') {
    return HomeAutoRecommendations(HomeAutoState.verificationPending, users);
  }
  if (status == 'REJECTED') {
    return HomeAutoRecommendations(HomeAutoState.verificationRejected, users);
  }

  if (users.isEmpty) {
    if (personalizedError != null) {
      return const HomeAutoRecommendations(
        HomeAutoState.noRecommendations,
        <RecommendedUser>[],
      );
    }
    return const HomeAutoRecommendations(
      HomeAutoState.noRecommendations,
      <RecommendedUser>[],
    );
  }

  return HomeAutoRecommendations(HomeAutoState.loaded, users);
});

final recommendedUsersProvider =
    FutureProvider.autoDispose<List<RecommendedUser>>((ref) async {
  final repo = ref.watch(homeRepositoryProvider);
  final filters = ref.watch(filterStateProvider);

  try {
    return await repo.getRecommendedUsers(
      budgetMax: filters.priceMax,
      district: filters.district,
      gender: filters.gender,
      // ageRange is not set by the current filter UI yet, so it stays null.
    );
  } catch (_) {
    if (!filters.hasAnyFilter) {
      return repo.discoverUsers();
    }
    rethrow;
  }
});
