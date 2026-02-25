import 'package:flutter/foundation.dart';
import 'package:roommate_app/features/home/roommate_profile.dart';

class SavedController extends ChangeNotifier {
  SavedController._();
  static final SavedController instance = SavedController._();

  final List<RoommateProfile> _items = [];
  List<RoommateProfile> get items => List.unmodifiable(_items);

  bool isSaved(RoommateProfile p) => _items.any((x) => x.id == p.id);

  void add(RoommateProfile p) {
    if (isSaved(p)) return;
    _items.add(p);
    notifyListeners();
  }

  void remove(RoommateProfile p) {
    _items.removeWhere((x) => x.id == p.id);
    notifyListeners();
  }
}
