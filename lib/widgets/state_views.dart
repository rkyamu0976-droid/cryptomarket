import 'package:flutter/material.dart';

import '../core/theme.dart';

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({super.key, this.width, required this.height, this.radius = 8});
  final double? width;
  final double height;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

/// Pulsing placeholder rows shown while the first request is loading.
class LoadingList extends StatefulWidget {
  const LoadingList({super.key, this.itemCount = 9});
  final int itemCount;
  @override
  State<LoadingList> createState() => _LoadingListState();
}

class _LoadingListState extends State<LoadingList> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Opacity(
        opacity: 0.35 + 0.45 * _c.value,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: widget.itemCount,
          itemBuilder: (_, __) => const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                SkeletonBox(width: 40, height: 40, radius: 20),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(width: 110, height: 13),
                      SizedBox(height: 8),
                      SkeletonBox(width: 60, height: 11),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SkeletonBox(width: 80, height: 13),
                    SizedBox(height: 8),
                    SkeletonBox(width: 50, height: 11),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });
  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(color: AppColors.surface, shape: BoxShape.circle),
              child: Icon(icon, size: 34, color: AppColors.accent),
            ),
            const SizedBox(height: 20),
            Text(title, style: AppText.heading(18), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(message, style: AppText.muted(14.5), textAlign: TextAlign.center),
            if (actionLabel != null) ...[
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: onAction,
                icon: Icon(actionIcon ?? Icons.refresh_rounded, size: 18),
                label: Text(actionLabel!),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => _Message(
        icon: Icons.cloud_off_rounded,
        title: "Couldn't load data",
        message: message,
        actionLabel: 'Try again',
        onAction: onRetry,
      );
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
  });
  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => _Message(
        icon: icon,
        title: title,
        message: message,
        actionLabel: actionLabel,
        actionIcon: actionIcon,
        onAction: onAction,
      );
}
