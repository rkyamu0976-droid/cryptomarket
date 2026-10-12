import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/coin.dart';
import '../providers/market_provider.dart';
import '../providers/watchlist_provider.dart';
import '../services/api_service.dart';
import '../utils/format.dart';
import '../widgets/common.dart';
import '../widgets/price_chart.dart';
import '../widgets/state_views.dart';

class CoinDetailScreen extends StatelessWidget {
  const CoinDetailScreen({super.key, required this.coin});
  final Coin coin;

  @override
  Widget build(BuildContext context) {
    // Pick up fresh prices whenever the market list auto-refreshes.
    final c = context.select<MarketProvider, Coin?>((m) => m.byId(coin.id)) ?? coin;
    final starred = context.select<WatchlistProvider, bool>((w) => w.contains(coin.id));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CoinAvatar(url: c.image, symbol: c.symbol, size: 30),
            const SizedBox(width: 10),
            Flexible(child: Text(c.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: starred ? 'Remove from watchlist' : 'Add to watchlist',
            icon: Icon(starred ? Icons.star_rounded : Icons.star_border_rounded,
                color: starred ? AppColors.accent : AppColors.muted, size: 28),
            onPressed: () => context.read<WatchlistProvider>().toggle(c.id),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Row(
            children: [
              _Badge('Rank #${c.rank}'),
              const SizedBox(width: 8),
              _Badge(c.symbol),
            ],
          ),
          const SizedBox(height: 14),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(Fmt.price(c.price), style: AppText.number(38, weight: FontWeight.w700)),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              ChangePill(c.change24h, large: true),
              const SizedBox(width: 10),
              Text('past 24 hours', style: AppText.muted(13.5)),
            ],
          ),
          const SizedBox(height: 20),
          PriceChart(coinId: c.id),
          const SectionTitle('Performance'),
          Row(
            children: [
              _Perf('1h', c.change1h),
              const SizedBox(width: 10),
              _Perf('24h', c.change24h),
              const SizedBox(width: 10),
              _Perf('7d', c.change7d),
              const SizedBox(width: 10),
              _Perf('30d', c.change30d),
            ],
          ),
          const SectionTitle('Market data'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.15,
            children: [
              StatBox(label: 'Market cap', value: Fmt.compactUsd(c.marketCap)),
              StatBox(label: '24h volume', value: Fmt.compactUsd(c.volume)),
              StatBox(label: '24h high', value: Fmt.price(c.high24h)),
              StatBox(label: '24h low', value: Fmt.price(c.low24h)),
              StatBox(label: 'All-time high', value: Fmt.price(c.ath)),
              StatBox(
                  label: 'Volume / market cap',
                  value: c.marketCap == 0 ? '—' : (c.volume / c.marketCap).toStringAsFixed(3)),
            ],
          ),
          const SectionTitle('Supply'),
          _SupplyCard(coin: c),
          _AboutCard(coinId: c.id),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(text, style: AppText.body(12.5, weight: FontWeight.w700, color: AppColors.muted)),
      );
}

class _Perf extends StatelessWidget {
  const _Perf(this.label, this.value);
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) {
    final color = value >= 0 ? AppColors.up : AppColors.down;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Text(label, style: AppText.muted(12)),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(Fmt.percent(value), style: AppText.number(13, color: color)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SupplyCard extends StatelessWidget {
  const _SupplyCard({required this.coin});
  final Coin coin;

  @override
  Widget build(BuildContext context) {
    final max = coin.maxSupply;
    final progress = (max != null && max > 0) ? (coin.circulating / max).clamp(0.0, 1.0) : null;

    Widget row(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppText.muted(14)),
              Text(value, style: AppText.number(14)),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          row('Circulating supply', '${Fmt.compact(coin.circulating)} ${coin.symbol}'),
          row('Total supply', coin.totalSupply == null ? '—' : Fmt.compact(coin.totalSupply!)),
          row('Max supply', max == null ? '∞  (no cap)' : Fmt.compact(max)),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.surfaceHigh,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('${(progress * 100).toStringAsFixed(1)}% of max supply is in circulation',
                  style: AppText.muted(12.5)),
            ),
          ],
        ],
      ),
    );
  }
}

class _AboutCard extends StatefulWidget {
  const _AboutCard({required this.coinId});
  final String coinId;
  @override
  State<_AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<_AboutCard> {
  bool _loading = true;
  String _text = '';
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final about = await context.read<ApiService>().fetchAbout(widget.coinId);
      if (!mounted) return;
      setState(() {
        _text = about.description;
        _loading = false;
      });
    } on ApiException {
      if (!mounted) return;
      setState(() => _loading = false); // About is optional: hide on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.only(top: 22),
        child: SkeletonBox(height: 90, radius: 16),
      );
    }
    if (_text.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('About'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_text,
                  maxLines: _expanded ? null : 5,
                  overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                  style: AppText.body(14, color: AppColors.text.withOpacity(0.85)).copyWith(height: 1.5)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Text(_expanded ? 'Show less' : 'Read more',
                    style: AppText.body(13.5, weight: FontWeight.w700, color: AppColors.accent)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
