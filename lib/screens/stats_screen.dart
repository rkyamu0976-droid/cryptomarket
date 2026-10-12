import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/coin.dart';
import '../providers/market_provider.dart';
import '../utils/format.dart';
import '../widgets/coin_tile.dart';
import '../widgets/common.dart';
import '../widgets/state_views.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});
  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final m = context.watch<MarketProvider>();

    Widget content;
    if (m.status == LoadStatus.loading && m.coins.isEmpty) {
      content = const LoadingList(itemCount: 6);
    } else if (m.status == LoadStatus.error && m.coins.isEmpty) {
      content = ErrorView(message: m.error ?? 'Something went wrong.', onRetry: m.load);
    } else {
      final list = switch (_tab) {
        0 => m.topGainers,
        1 => m.topLosers,
        _ => m.topVolume,
      };
      content = RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surfaceHigh,
        onRefresh: m.load,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            if (m.global != null) _GlobalSection(g: m.global!) else _GlobalUnavailable(onRetry: m.load),
            const SizedBox(height: 14),
            _Breadth(up: m.advancing, down: m.declining),
            const SectionTitle('Movers'),
            Row(
              children: [
                AppChip(label: 'Top gainers', selected: _tab == 0, onTap: () => setState(() => _tab = 0)),
                const SizedBox(width: 8),
                AppChip(label: 'Top losers', selected: _tab == 1, onTap: () => setState(() => _tab = 1)),
                const SizedBox(width: 8),
                AppChip(label: 'Volume', selected: _tab == 2, onTap: () => setState(() => _tab = 2)),
              ],
            ),
            const SizedBox(height: 8),
            _MoverList(coins: list, showVolume: _tab == 2),
          ],
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Text('Market statistics', style: AppText.heading(28)),
          ),
          Expanded(child: content),
        ],
      ),
    );
  }
}

class _GlobalSection extends StatelessWidget {
  const _GlobalSection({required this.g});
  final GlobalStats g;

  @override
  Widget build(BuildContext context) {
    final other = (100 - g.btcDominance - g.ethDominance).clamp(0.0, 100.0);
    int flex(double v) => v.round().clamp(1, 100);

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total market cap', style: AppText.muted(13.5)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(Fmt.compactUsd(g.marketCap), style: AppText.number(30, weight: FontWeight.w700)),
                  const SizedBox(width: 12),
                  ChangePill(g.change24h, large: true),
                ],
              ),
              const SizedBox(height: 2),
              Text('change over 24 hours', style: AppText.muted(12.5)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: SizedBox(height: 80, child: StatBox(label: '24h volume', value: Fmt.compactUsd(g.volume)))),
            const SizedBox(width: 10),
            Expanded(child: SizedBox(height: 80, child: StatBox(label: 'Active coins', value: Fmt.compact(g.activeCoins.toDouble())))),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Market dominance', style: AppText.heading(15)),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      Expanded(flex: flex(g.btcDominance), child: Container(color: AppColors.accent)),
                      const SizedBox(width: 2),
                      Expanded(flex: flex(g.ethDominance), child: Container(color: const Color(0xFF7C9CFF))),
                      const SizedBox(width: 2),
                      Expanded(flex: flex(other), child: Container(color: AppColors.border)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Legend(AppColors.accent, 'Bitcoin', g.btcDominance),
                  _Legend(const Color(0xFF7C9CFF), 'Ethereum', g.ethDominance),
                  _Legend(AppColors.muted, 'Others', other),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend(this.color, this.label, this.value);
  final Color color;
  final String label;
  final double value;
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(label, style: AppText.muted(12.5)),
          ]),
          const SizedBox(height: 4),
          Text('${value.toStringAsFixed(1)}%', style: AppText.number(15)),
        ],
      );
}

class _GlobalUnavailable extends StatelessWidget {
  const _GlobalUnavailable({required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline_rounded, color: AppColors.muted),
            const SizedBox(width: 12),
            Expanded(child: Text('Global figures are unavailable right now.', style: AppText.muted(14))),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
}

class _Breadth extends StatelessWidget {
  const _Breadth({required this.up, required this.down});
  final int up, down;
  @override
  Widget build(BuildContext context) {
    final total = up + down;
    if (total == 0) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Market mood (top coins, 24h)', style: AppText.heading(15)),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 10,
              child: Row(
                children: [
                  if (up > 0) Expanded(flex: up, child: Container(color: AppColors.up)),
                  if (up > 0 && down > 0) const SizedBox(width: 2),
                  if (down > 0) Expanded(flex: down, child: Container(color: AppColors.down)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$up rising', style: AppText.body(13.5, weight: FontWeight.w700, color: AppColors.up)),
              Text('$down falling', style: AppText.body(13.5, weight: FontWeight.w700, color: AppColors.down)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MoverList extends StatelessWidget {
  const _MoverList({required this.coins, required this.showVolume});
  final List<Coin> coins;
  final bool showVolume;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < coins.length; i++) ...[
          CoinTile(coin: coins[i], showStar: false),
          if (i != coins.length - 1) const Divider(height: 1, indent: 68, color: AppColors.border),
        ],
      ],
    );
  }
}
