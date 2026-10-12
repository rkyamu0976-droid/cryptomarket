import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../utils/format.dart';

/// Rounded filter / range chip.
class AppChip extends StatelessWidget {
  const AppChip({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Text(
          label,
          style: AppText.body(13,
              weight: FontWeight.w700,
              color: selected ? AppColors.onAccent : AppColors.muted),
        ),
      ),
    );
  }
}

/// Green / red percentage pill.
class ChangePill extends StatelessWidget {
  const ChangePill(this.value, {super.key, this.large = false});
  final double value;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final up = value >= 0;
    final color = up ? AppColors.up : AppColors.down;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: large ? 10 : 7, vertical: large ? 5 : 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.14),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(up ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
              color: color, size: large ? 22 : 18),
          Text(Fmt.percent(value.abs()).replaceFirst('+', ''),
              style: AppText.number(large ? 14 : 12, color: color)),
        ],
      ),
    );
  }
}

/// Coin logo with a letter fallback (works offline / with mock data).
class CoinAvatar extends StatelessWidget {
  const CoinAvatar({super.key, required this.url, required this.symbol, this.size = 40});
  final String url;
  final String symbol;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.surfaceHigh, shape: BoxShape.circle),
      child: Text(
        symbol.isEmpty ? '?' : symbol.substring(0, 1),
        style: AppText.heading(size * 0.42, color: AppColors.accent),
      ),
    );
    if (url.isEmpty) return fallback;
    return ClipOval(
      child: Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => fallback,
        loadingBuilder: (_, child, progress) => progress == null ? child : fallback,
      ),
    );
  }
}

/// Label + value box used in grids.
class StatBox extends StatelessWidget {
  const StatBox({super.key, required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.muted(12.5)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: AppText.number(16, color: valueColor ?? AppColors.text)),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 12),
        child: Text(text, style: AppText.heading(16)),
      );
}
