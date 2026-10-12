import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/coin.dart';
import '../providers/watchlist_provider.dart';
import '../screens/coin_detail_screen.dart';
import '../utils/format.dart';
import 'common.dart';
import 'sparkline.dart';

class CoinTile extends StatelessWidget {
  const CoinTile({super.key, required this.coin, this.showStar = true});
  final Coin coin;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    final starred = context.select<WatchlistProvider, bool>((w) => w.contains(coin.id));

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => CoinDetailScreen(coin: coin)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
        child: Row(
          children: [
            CoinAvatar(url: coin.image, symbol: coin.symbol),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(coin.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.body(15, weight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text('#${coin.rank}  ${coin.symbol}',
                      maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.muted(12.5)),
                ],
              ),
            ),
            Sparkline(values: coin.sparkline),
            const SizedBox(width: 10),
            SizedBox(
              width: 92,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(Fmt.price(coin.price), style: AppText.number(14.5)),
                  ),
                  const SizedBox(height: 4),
                  ChangePill(coin.change24h),
                ],
              ),
            ),
            if (showStar)
              IconButton(
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints.tightFor(width: 36, height: 36),
                padding: EdgeInsets.zero,
                tooltip: starred ? 'Remove from watchlist' : 'Add to watchlist',
                icon: Icon(
                  starred ? Icons.star_rounded : Icons.star_border_rounded,
                  color: starred ? AppColors.accent : AppColors.muted,
                  size: 24,
                ),
                onPressed: () => context.read<WatchlistProvider>().toggle(coin.id),
              )
            else
              const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
