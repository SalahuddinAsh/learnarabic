import 'package:flutter/material.dart';
import '../theme.dart';

/// Mirrors `.card` in style.css: white 28px-radius card, centered, max 620 wide.
class AppCard extends StatelessWidget {
  final Widget child;
  const AppCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(color: AppColors.teal.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 12)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Full-screen gradient backdrop + safe-area padded, scrollable centered content —
/// mirrors `.screen`/`body` background in style.css.
class AppScreenBackground extends StatelessWidget {
  final Widget child;
  const AppScreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppColors.bgGradient),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
