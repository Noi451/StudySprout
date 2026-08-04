import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';
import 'app_surface.dart';

/// Metric Tile แบบ compact — ไม่ใช่การ์ดใหญ่
///
/// ใช้สำหรับแถบ metric บน Home (Level/XP, Study Today, ...) —
/// icon chip สี accent + ค่าเด่น + ป้ายจาง ๆ
///
/// [accent] = สี semantic role (growth/time/streak) ไม่ใช่ตกแต่ง
class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.accent,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      level: AppSurfaceLevel.high,
      radius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Icon(icon, color: accent, size: 20),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(value, style: AppTextStyles.metricValue(context)),
                  Text(label, style: AppTextStyles.metricLabel(context)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
