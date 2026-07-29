import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// การ์ดสถิติ reusable สำหรับหน้า Progress — แสดงป้าย + ค่า
///
/// เป็น UI ล้วน ๆ — รับข้อความที่จัดรูปแล้วเข้ามาแสดง ไม่มี business logic
/// ใช้ซ้ำได้กับทุกตัวเลขสถิติ (Today/Week/Total/Session Count/Average)
class ProgressStatCard extends StatelessWidget {
  const ProgressStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  /// ป้ายของสถิติ (เช่น "Today's Study Time")
  final String label;

  /// ค่าที่จัดรูปแล้ว (เช่น "1 hr 30 min", "5")
  final String value;

  /// ไอคอนประกอบ (ไม่บังคับ)
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    label,
                    style: AppTextStyles.label(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              value,
              style: AppTextStyles.value(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
