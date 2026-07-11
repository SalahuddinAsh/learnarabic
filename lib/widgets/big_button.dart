import 'package:flutter/material.dart';
import '../theme.dart';

/// Mirrors `.big-btn` — full-width gradient call-to-action button.
class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Gradient gradient;
  final bool secondary;

  const BigButton({
    super.key,
    required this.label,
    required this.onTap,
    this.gradient = AppColors.bigBtnGradient,
    this.secondary = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onTap == null;
    return Opacity(
      opacity: disabled ? 0.4 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: secondary ? null : gradient,
              color: secondary ? AppColors.chipSoftBg : null,
              borderRadius: BorderRadius.circular(20),
              boxShadow: secondary || disabled
                  ? null
                  : [BoxShadow(color: AppColors.amber.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: secondary ? 19 : 24,
                fontWeight: FontWeight.w800,
                color: secondary ? AppColors.teal : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
