import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import 'ai_search_model.dart';
import 'ai_search_repository.dart';

enum AiSearchStatus {
  initial,
  loading,
  loaded,
  empty,
  error,
}

class AiSearchState {
  const AiSearchState({
    required this.status,
    required this.results,
    this.errorMessage,
    this.lastQuery,
    this.sessionId,
  });

  final AiSearchStatus status;
  final List<AiSearchResult> results;
  final String? errorMessage;
  final String? lastQuery;
  final String? sessionId;

  bool get isLoading => status == AiSearchStatus.loading;
  bool get hasResults => results.isNotEmpty;

  AiSearchState copyWith({
    AiSearchStatus? status,
    List<AiSearchResult>? results,
    String? errorMessage,
    bool clearError = false,
    String? lastQuery,
    bool clearLastQuery = false,
    String? sessionId,
    bool clearSessionId = false,
  }) {
    return AiSearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      lastQuery: clearLastQuery ? null : (lastQuery ?? this.lastQuery),
      sessionId: clearSessionId ? null : (sessionId ?? this.sessionId),
    );
  }

  static const initialState = AiSearchState(
    status: AiSearchStatus.initial,
    results: <AiSearchResult>[],
    errorMessage: null,
    lastQuery: null,
    sessionId: null,
  );
}

final aiSearchRepositoryProvider = Provider<AiSearchRepository>((ref) {
  return AiSearchRepository(ref.read(dioProvider));
});

final aiSearchControllerProvider =
    StateNotifierProvider.autoDispose<AiSearchController, AiSearchState>(
  (ref) => AiSearchController(
    ref.read(aiSearchRepositoryProvider),
  ),
);

class AiSearchController extends StateNotifier<AiSearchState> {
  AiSearchController(this._repository) : super(AiSearchState.initialState);

  final AiSearchRepository _repository;

  Future<void> search(String rawQuery, {int limit = 20}) async {
    final query = rawQuery.trim();
    if (query.isEmpty) {
      state = state.copyWith(
        status: AiSearchStatus.error,
        errorMessage: 'Введите запрос для AI-поиска.',
      );
      return;
    }

    state = state.copyWith(
      status: AiSearchStatus.loading,
      clearError: true,
      lastQuery: query,
      clearSessionId: true,
    );

    try {
      final response = await _repository.search(query: query, limit: limit);
      final results = response.results;

      state = state.copyWith(
        status: results.isEmpty ? AiSearchStatus.empty : AiSearchStatus.loaded,
        results: results,
        clearError: true,
        lastQuery: query,
        sessionId: response.meta.sessionId,
      );
    } catch (error) {
      state = state.copyWith(
        status: AiSearchStatus.error,
        errorMessage: _errorMessage(error),
        results: const <AiSearchResult>[],
        lastQuery: query,
      );
    }
  }

  void reset() {
    state = AiSearchState.initialState;
  }

  String _errorMessage(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        final message = data['message'];
        if (message is String && message.trim().isNotEmpty) {
          return message.trim();
        }
      }
      if (error.message != null && error.message!.trim().isNotEmpty) {
        return error.message!.trim();
      }
    }
    return 'Не удалось выполнить AI-поиск. Попробуйте позже.';
  }
}
