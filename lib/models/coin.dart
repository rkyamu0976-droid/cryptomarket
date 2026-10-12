double _d(dynamic v) => v is num ? v.toDouble() : 0.0;
double? _dn(dynamic v) => v is num ? v.toDouble() : null;

class Coin {
  const Coin({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.rank,
    required this.price,
    required this.marketCap,
    required this.volume,
    required this.high24h,
    required this.low24h,
    required this.change1h,
    required this.change24h,
    required this.change7d,
    required this.change30d,
    required this.circulating,
    required this.totalSupply,
    required this.maxSupply,
    required this.ath,
    required this.sparkline,
  });

  final String id, symbol, name, image;
  final int rank;
  final double price, marketCap, volume, high24h, low24h;
  final double change1h, change24h, change7d, change30d;
  final double circulating, ath;
  final double? totalSupply, maxSupply;
  final List<double> sparkline;

  factory Coin.fromJson(Map<String, dynamic> j) {
    final spark = (j['sparkline_in_7d']?['price'] as List?) ?? const [];
    return Coin(
      id: j['id'] as String,
      symbol: ((j['symbol'] as String?) ?? '').toUpperCase(),
      name: (j['name'] as String?) ?? '',
      image: (j['image'] as String?) ?? '',
      rank: (j['market_cap_rank'] as num?)?.toInt() ?? 0,
      price: _d(j['current_price']),
      marketCap: _d(j['market_cap']),
      volume: _d(j['total_volume']),
      high24h: _d(j['high_24h']),
      low24h: _d(j['low_24h']),
      change1h: _d(j['price_change_percentage_1h_in_currency']),
      change24h: _d(j['price_change_percentage_24h']),
      change7d: _d(j['price_change_percentage_7d_in_currency']),
      change30d: _d(j['price_change_percentage_30d_in_currency']),
      circulating: _d(j['circulating_supply']),
      totalSupply: _dn(j['total_supply']),
      maxSupply: _dn(j['max_supply']),
      ath: _d(j['ath']),
      sparkline: spark.map((e) => _d(e)).toList(),
    );
  }
}

class GlobalStats {
  const GlobalStats({
    required this.marketCap,
    required this.volume,
    required this.change24h,
    required this.btcDominance,
    required this.ethDominance,
    required this.activeCoins,
  });

  final double marketCap, volume, change24h, btcDominance, ethDominance;
  final int activeCoins;

  factory GlobalStats.fromJson(Map<String, dynamic> j) => GlobalStats(
        marketCap: _d(j['total_market_cap']?['usd']),
        volume: _d(j['total_volume']?['usd']),
        change24h: _d(j['market_cap_change_percentage_24h_usd']),
        btcDominance: _d(j['market_cap_percentage']?['btc']),
        ethDominance: _d(j['market_cap_percentage']?['eth']),
        activeCoins: (j['active_cryptocurrencies'] as num?)?.toInt() ?? 0,
      );
}

class ChartPoint {
  const ChartPoint(this.time, this.price);
  final DateTime time;
  final double price;
}

class CoinAbout {
  const CoinAbout(this.description);
  final String description;
}
