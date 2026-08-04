import 'package:flutter/material.dart';

import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// ป้ายสถานะเล็ก (pill) — สื่อ state ด้วยสี + ข้อความ (ไม่ใช้สีเพียงอย่างเดียว)
///
/// [accent] = สี role, [label] = ข้อความอธิบาย
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.accent,
    this.icon,
  });

  final String label;
  final Color accent;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: AppRadius.pill,
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: accent, size: 14),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: AppTextStyles.label(context).copyWith(color: accent),
            ),
          ],
        ),
      ),
    );
  }
}
