import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'filter_repository.dart';
import 'recommended_user_model.dart';

/// Единое состояние фильтров для главной страницы.
class FilterState {
  const FilterState({
    this.district,
    this.priceMin,
    this.priceMax,
    this.gender,
    this.petsPreference,
    this.smokingPreference,
    this.noisePreference,
  });

  /// Район (searchDistrict на бэкенде).
  final String? district;

  /// Нижняя граница бюджета.
  final int? priceMin;

  /// Верхняя граница бюджета.
  final int? priceMax;

  final String? gender;
  final String? petsPreference;
  final String? smokingPreference;
  final String? noisePreference;

  /// Есть ли вообще активные фильтры.
  bool get hasAnyFilter =>
      (district != null && district!.trim().isNotEmpty) ||
      priceMin != null ||
      priceMax != null ||
      (gender != null && gender!.trim().isNotEmpty) ||
      (petsPreference != null && petsPreference!.trim().isNotEmpty) ||
      (smokingPreference != null && smokingPreference!.trim().isNotEmpty) ||
      (noisePreference != null && noisePreference!.trim().isNotEmpty);

  FilterState copyWith({
    Object? district = _unset,
    Object? priceMin = _unset,
    Object? priceMax = _unset,
    Object? gender = _unset,
    Object? petsPreference = _unset,
    Object? smokingPreference = _unset,
    Object? noisePreference = _unset,
  }) {
    return FilterState(
      district:
          identical(district, _unset) ? this.district : district as String?,
      priceMin:
          identical(priceMin, _unset) ? this.priceMin : priceMin as int?,
      priceMax:
          identical(priceMax, _unset) ? this.priceMax : priceMax as int?,
      gender: identical(gender, _unset) ? this.gender : gender as String?,
      petsPreference: identical(petsPreference, _unset)
          ? this.petsPreference
          : petsPreference as String?,
      smokingPreference: identical(smokingPreference, _unset)
          ? this.smokingPreference
          : smokingPreference as String?,
      noisePreference: identical(noisePreference, _unset)
          ? this.noisePreference
          : noisePreference as String?,
    );
  }
}

const _unset = Object();

class FilterNotifier extends StateNotifier<FilterState> {
  FilterNotifier() : super(const FilterState());

  void setDistrict(String? value) {
    state = state.copyWith(
      district: value == null || value.trim().isEmpty ? null : value.trim(),
    );
  }

  void setPriceRange(int? min, int? max) {
    state = state.copyWith(
      priceMin: min,
      priceMax: max,
    );
  }

  void setGender(String? value) {
    state = state.copyWith(
      gender: value == null || value.trim().isEmpty ? null : value.trim(),
    );
  }

  void setPetsPreference(String? value) {
    state = state.copyWith(
      petsPreference:
          value == null || value.trim().isEmpty ? null : value.trim(),
    );
  }

  void setSmokingPreference(String? value) {
    state = state.copyWith(
      smokingPreference:
          value == null || value.trim().isEmpty ? null : value.trim(),
    );
  }

  void setNoisePreference(String? value) {
    state = state.copyWith(
      noisePreference:
          value == null || value.trim().isEmpty ? null : value.trim(),
    );
  }

  void clear() {
    state = const FilterState();
  }
}

final filterRepositoryProvider = Provider<FilterRepository>((ref) {
  return FilterRepository(ref.read(dioProvider));
});

final filterStateProvider =
    StateNotifierProvider<FilterNotifier, FilterState>((ref) {
  return FilterNotifier();
});

final filteredUsersProvider =
    FutureProvider.autoDispose<List<RecommendedUser>>((ref) async {
  final repo = ref.watch(filterRepositoryProvider);
  final state = ref.watch(filterStateProvider);

  if (!state.hasAnyFilter) {
    return const <RecommendedUser>[];
  }

  return repo.filterUsers(
    district: state.district,
    priceMin: state.priceMin,
    priceMax: state.priceMax,
    gender: state.gender,
    petsPreference: state.petsPreference,
    smokingPreference: state.smokingPreference,
    noisePreference: state.noisePreference,
  );
});