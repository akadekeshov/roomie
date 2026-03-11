import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keeps IDs of users that should be hidden from UI (Home + Saved).
final hiddenUserIdsProvider =
    StateNotifierProvider<HiddenUserIdsNotifier, Set<String>>((ref) {
  return HiddenUserIdsNotifier();
});

class HiddenUserIdsNotifier extends StateNotifier<Set<String>> {
  HiddenUserIdsNotifier() : super(<String>{});

  void hide(String userId) {
    state = {...state, userId};
  }

  void unhide(String userId) {
    final next = {...state}..remove(userId);
    state = next;
  }

  void clear() {
    state = <String>{};
  }
}