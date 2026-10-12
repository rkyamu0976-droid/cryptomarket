import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../providers/market_provider.dart';
import '../utils/format.dart';
import '../widgets/coin_tile.dart';
import '../widgets/common.dart';
import '../widgets/state_views.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openSort(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheetContext) => SafeArea(
        child: Consumer<MarketProvider>(
          builder: (_, m, __) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Text('Sort by', style: AppText.heading(18)),
              ),
              for (final s in CoinSort.values)
                ListTile(
                  title: Text(s.label,
                      style: AppText.body(15.5,
                          weight: FontWeight.w600,
                          color: m.sort == s ? AppColors.accent : AppColors.text)),
                  trailing: m.sort == s
                      ? Icon(m.ascending ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                          color: AppColors.accent, size: 20)
                      : null,
                  onTap: () => m.setSort(s),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Text('Tap the selected option again to reverse the order.',
                    style: AppText.muted(12.5)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = context.watch<MarketProvider>();

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Crypto Markets', style: AppText.heading(28)),
                      const SizedBox(height: 4),
                      _subtitle(m),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: TextField(
              controller: _search,
              onChanged: m.setQuery,
              textInputAction: TextInputAction.search,
              style: AppText.body(15),
              decoration: InputDecoration(
                hintText: 'Search by name or symbol',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.muted),
                suffixIcon: m.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                        onPressed: () {
                          _search.clear();
                          m.setQuery('');
                        },
                      ),
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                AppChip(
                    label: 'All',
                    selected: m.filter == CoinFilter.all,
                    onTap: () => m.setFilter(CoinFilter.all)),
                const SizedBox(width: 8),
                AppChip(
                    label: 'Gainers',
                    selected: m.filter == CoinFilter.gainers,
                    onTap: () => m.setFilter(CoinFilter.gainers)),
                const SizedBox(width: 8),
                AppChip(
                    label: 'Losers',
                    selected: m.filter == CoinFilter.losers,
                    onTap: () => m.setFilter(CoinFilter.losers)),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _openSort(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.swap_vert_rounded, size: 18, color: AppColors.accent),
                        const SizedBox(width: 6),
                        Text(m.sort.label,
                            style: AppText.body(13, weight: FontWeight.w700, color: AppColors.text)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (m.stale)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.down.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text("Couldn't refresh. Showing the last loaded prices.",
                  style: AppText.body(12.5, color: AppColors.down)),
            ),
          const SizedBox(height: 6),
          Expanded(child: _body(m)),
        ],
      ),
    );
  }

  Widget _subtitle(MarketProvider m) {
    if (m.isMock) {
      return Row(
        children: [
          const Icon(Icons.science_outlined, size: 14, color: AppColors.accent),
          const SizedBox(width: 5),
          Text('Sample data (live source unavailable)',
              style: AppText.body(12.5, color: AppColors.accent)),
        ],
      );
    }
    return Text(
      m.updatedAt == null ? 'Loading prices…' : 'Live prices · updated ${Fmt.time(m.updatedAt!)}',
      style: AppText.muted(12.5),
    );
  }

  Widget _body(MarketProvider m) {
    if (m.status == LoadStatus.loading && m.coins.isEmpty) return const LoadingList();
    if (m.status == LoadStatus.error && m.coins.isEmpty) {
      return ErrorView(message: m.error ?? 'Something went wrong.', onRetry: m.load);
    }
    final coins = m.visible;
    if (coins.isEmpty) {
      return EmptyView(
        icon: Icons.search_off_rounded,
        title: 'No coins found',
        message: m.query.trim().isNotEmpty
            ? 'Nothing matches "${m.query.trim()}". Try a different name or symbol.'
            : 'No coins match this filter right now.',
        actionLabel: m.hasActiveFilters ? 'Clear search and filters' : null,
        actionIcon: Icons.filter_alt_off_rounded,
        onAction: () {
          _search.clear();
          m.clearFilters();
        },
      );
    }
    return RefreshIndicator(
      color: AppColors.accent,
      backgroundColor: AppColors.surfaceHigh,
      onRefresh: m.load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: coins.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 68, color: AppColors.border),
        itemBuilder: (_, i) => CoinTile(coin: coins[i]),
      ),
    );
  }
}
