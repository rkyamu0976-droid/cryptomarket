import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/coin.dart';
import '../services/api_service.dart';

enum LoadStatus { loading, loaded, error }

enum CoinFilter { all, gainers, losers }

enum CoinSort { rank, price, change24h, volume, marketCap }

extension CoinSortLabel on CoinSort {
  String get label => switch (this) {
        CoinSort.rank => 'Rank',
        CoinSort.price => 'Price',
        CoinSort.change24h => '24h change',
        CoinSort.volume => '24h volume',
        CoinSort.marketCap => 'Market cap',
      };
}

class MarketProvider extends ChangeNotifier {
  MarketProvider(this._api) {
    load();
    // Auto-refresh so prices feel live.
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => load());
  }

  final ApiService _api;
  Timer? _timer;

  LoadStatus status = LoadStatus.loading;
  String? error;
  List<Coin> coins = [];
  GlobalStats? global;
  bool isMock = false;
  bool stale = false; // last refresh failed but old data is still shown
  DateTime? updatedAt;

  String query = '';
  CoinFilter filter = CoinFilter.all;
  CoinSort sort = CoinSort.rank;
  bool ascending = true;

  Future<void> load() async {
    if (coins.isEmpty) {
      status = LoadStatus.loading;
      error = null;
      notifyListeners();
    }

    final globalFuture =
        _api.fetchGlobal().then<GlobalStats?>((v) => v, onError: (_) => null);

    try {
      final r = await _api.fetchCoins();
      coins = r.coins;
      isMock = r.isMock;
      stale = false;
      status = LoadStatus.loaded;
      error = null;
      updatedAt = DateTime.now();
    } on ApiException catch (e) {
      if (coins.isEmpty) {
        status = LoadStatus.error;
        error = e.message;
      } else {
        stale = true;
      }
    }
    notifyListeners();

    final g = await globalFuture;
    if (g != null) {
      global = g;
      notifyListeners();
    }
  }

  Coin? byId(String id) {
    for (final c in coins) {
      if (c.id == id) return c;
    }
    return null;
  }

  void setQuery(String v) {
    query = v;
    notifyListeners();
  }

  void setFilter(CoinFilter f) {
    filter = f;
    notifyListeners();
  }

  void setSort(CoinSort s) {
    if (s == sort) {
      ascending = !ascending;
    } else {
      sort = s;
      ascending = s == CoinSort.rank;
    }
    notifyListeners();
  }

  void clearFilters() {
    query = '';
    filter = CoinFilter.all;
    notifyListeners();
  }

  bool get hasActiveFilters => query.trim().isNotEmpty || filter != CoinFilter.all;

  List<Coin> get visible {
    final q = query.trim().toLowerCase();
    final list = coins.where((c) {
      if (q.isNotEmpty &&
          !(c.name.toLowerCase().contains(q) || c.symbol.toLowerCase().contains(q))) {
        return false;
      }
      return switch (filter) {
        CoinFilter.all => true,
        CoinFilter.gainers => c.change24h > 0,
        CoinFilter.losers => c.change24h < 0,
      };
    }).toList();

    int cmp(Coin a, Coin b) => switch (sort) {
          CoinSort.rank => a.rank.compareTo(b.rank),
          CoinSort.price => a.price.compareTo(b.price),
          CoinSort.change24h => a.change24h.compareTo(b.change24h),
          CoinSort.volume => a.volume.compareTo(b.volume),
          CoinSort.marketCap => a.marketCap.compareTo(b.marketCap),
        };
    list.sort((a, b) => ascending ? cmp(a, b) : cmp(b, a));
    return list;
  }

  List<Coin> get topGainers =>
      ([...coins]..sort((a, b) => b.change24h.compareTo(a.change24h))).take(5).toList();
  List<Coin> get topLosers =>
      ([...coins]..sort((a, b) => a.change24h.compareTo(b.change24h))).take(5).toList();
  List<Coin> get topVolume =>
      ([...coins]..sort((a, b) => b.volume.compareTo(a.volume))).take(5).toList();

  int get advancing => coins.where((c) => c.change24h > 0).length;
  int get declining => coins.where((c) => c.change24h < 0).length;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
