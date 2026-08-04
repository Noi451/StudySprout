import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';

/// Progress bar แบบ Hero — animate จากค่าเดิม → ใหม่ (ห้ามกระโดด)
///
/// ใช้ TweenAnimationBuilder (ไม่ใช่ AnimationController) เคารพ reduceMotion
/// แถบสี accent (default emerald) บน track โทน container
class HeroProgressBar extends StatelessWidget {
  const HeroProgressBar({
    super.key,
    required this.progress,
    this.accent = AppColors.emerald,
    this.height = 10,
    this.showGlow = false,
  });

  /// 0.0–1.0
  final double progress;
  final Color accent;
  final double height;

  /// true = เพิ่ม glow นุ่ม ๆ ที่ปลายแถบ (Hero เท่านั้น)
  final bool showGlow;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: clamped),
      duration: AppMotion.bar,
      curve: AppMotion.easeOutCubic,
      builder: (context, value, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill.topLeft.x),
          child: SizedBox(
            height: height,
            child: Stack(
              children: [
                // track
                Container(
                  height: height,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(AppRadius.pill.topLeft.x),
                  ),
                ),
                // fill
                FractionallySizedBox(
                  widthFactor: value,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: height,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(AppRadius.pill.topLeft.x),
                      boxShadow: showGlow
                          ? [
                              BoxShadow(
                                color: accent.withValues(alpha: 0.5),
                                blurRadius: 12,
                                spreadRadius: -2,
                              ),
                            ]
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// เลขกำกับ progress ของ Hero — "current / total" แบบเล็ก อ่านง่าย
class ProgressLegend extends StatelessWidget {
  const ProgressLegend({
    super.key,
    required this.current,
    required this.total,
    required this.accent,
    this.unit = '',
  });

  final String current;
  final String total;
  final Color accent;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(current, style: TextStyle(
          color: accent, fontWeight: FontWeight.bold, fontSize: 13,
        )),
        Text(' / $total$unit',
            style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
      ],
    );
  }
}
