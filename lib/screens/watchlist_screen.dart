import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/coin.dart';
import '../providers/market_provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/coin_tile.dart';
import '../widgets/state_views.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key, required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final wl = context.watch<WatchlistProvider>();
    final m = context.watch<MarketProvider>();
    final coins = wl.ids.map(m.byId).whereType<Coin>().toList();

    Widget body;
    if (!wl.loaded || (m.status == LoadStatus.loading && m.coins.isEmpty)) {
      body = const LoadingList(itemCount: 4);
    } else if (wl.ids.isEmpty) {
      body = EmptyView(
        icon: Icons.star_border_rounded,
        title: 'Your watchlist is empty',
        message: 'Tap the star next to any coin to keep an eye on it here.',
        actionLabel: 'Browse markets',
        actionIcon: Icons.show_chart_rounded,
        onAction: onBrowse,
      );
    } else if (m.status == LoadStatus.error && m.coins.isEmpty) {
      body = ErrorView(message: m.error ?? 'Something went wrong.', onRetry: m.load);
    } else {
      body = RefreshIndicator(
        color: AppColors.accent,
        backgroundColor: AppColors.surfaceHigh,
        onRefresh: m.load,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: coins.length,
          separatorBuilder: (_, __) => const Divider(height: 1, indent: 68, color: AppColors.border),
          itemBuilder: (_, i) {
            final c = coins[i];
            return Dismissible(
              key: ValueKey(c.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                color: AppColors.down.withOpacity(0.2),
                child: const Icon(Icons.delete_outline_rounded, color: AppColors.down),
              ),
              onDismissed: (_) {
                final provider = context.read<WatchlistProvider>();
                provider.toggle(c.id);
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(
                    content: Text('${c.name} removed'),
                    action: SnackBarAction(
                      label: 'Undo',
                      textColor: AppColors.accent,
                      onPressed: () => provider.toggle(c.id),
                    ),
                  ));
              },
              child: CoinTile(coin: c),
            );
          },
        ),
      );
    }

    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text('Watchlist', style: AppText.heading(28)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              wl.ids.isEmpty ? 'Coins you follow' : 'Swipe left to remove a coin',
              style: AppText.muted(12.5),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
