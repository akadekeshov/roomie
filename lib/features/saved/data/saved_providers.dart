import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';
import '../../home/data/listing_model.dart';
import 'saved_repository.dart';

final savedRepositoryProvider = Provider<SavedRepository>((ref) {
  return SavedRepository(ref.read(dioProvider));
});

/// All saved listings (from GET /saved).
final savedListingsProvider =
    FutureProvider.autoDispose<List<Listing>>((ref) async {
  final repo = ref.watch(savedRepositoryProvider);
  return repo.getSavedListings();
});

/// Set of saved listing IDs (derived from savedListings). Use for "isSaved" on Home cards.
final savedIdsProvider = Provider.autoDispose<Set<String>>((ref) {
  final async = ref.watch(savedListingsProvider);
  return async.when(
    data: (list) => list.map((e) => e.id).toSet(),
    loading: () => <String>{},
    error: (_, __) => <String>{},
  );
});
