import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchlistProvider extends ChangeNotifier {
  WatchlistProvider() {
    _restore();
  }

  static const _key = 'watchlist_ids';
  final List<String> _ids = [];
  bool loaded = false;

  List<String> get ids => List.unmodifiable(_ids);
  bool contains(String id) => _ids.contains(id);

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    _ids
      ..clear()
      ..addAll(prefs.getStringList(_key) ?? const []);
    loaded = true;
    notifyListeners();
  }

  Future<void> toggle(String id) async {
    if (_ids.contains(id)) {
      _ids.remove(id);
    } else {
      _ids.insert(0, id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, _ids);
  }
}
