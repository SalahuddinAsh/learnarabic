import 'package:flutter/material.dart';
import '../theme.dart';

/// Plain text chip — mirrors `.chip` in style.css (count/timer/game-score/letter chips).
class SimpleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double fontSize;
  final EdgeInsets padding;
  final TextDirection? textDirection;

  const SimpleChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.fontSize = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          constraints: const BoxConstraints(minWidth: 56, minHeight: 56),
          padding: padding,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.teal : AppColors.chipBg,
            border: Border.all(color: selected ? AppColors.teal : AppColors.chipBorder, width: 2.5),
            borderRadius: BorderRadius.circular(18),
            boxShadow: selected
                ? [BoxShadow(color: AppColors.teal.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 4))]
                : null,
          ),
          child: Text(
            label,
            textDirection: textDirection,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textMid,
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon(symbol) + name chip — mirrors `.op-chip` (level/mode selectors).
class OptionChip extends StatelessWidget {
  final String symbol;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  const OptionChip({
    super.key,
    required this.symbol,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 108, minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.teal : AppColors.chipBg,
            border: Border.all(color: selected ? AppColors.teal : AppColors.chipBorder, width: 2.5),
            borderRadius: BorderRadius.circular(18),
            boxShadow: selected
                ? [BoxShadow(color: AppColors.teal.withValues(alpha: 0.4), blurRadius: 14, offset: const Offset(0, 4))]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(symbol, style: const TextStyle(fontSize: 26, height: 1.3)),
              const SizedBox(height: 2),
              Text(
                name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : AppColors.textMid,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small pill chip — mirrors `.lang-chip` (language switch + sound toggle).
class LangChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const LangChip({super.key, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minWidth: 44, minHeight: 40),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.teal : AppColors.chipSoftBg2,
            border: Border.all(color: selected ? AppColors.teal : AppColors.chipBorder, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.teal,
            ),
          ),
        ),
      ),
    );
  }
}
