import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// การ์ด Streak (จำนวนวันที่เรียนติดต่อกัน) ของหน้า Home
///
/// Layout ใหม่: ป้าย "Current Streak" อยู่บน → ไอคอนไฟ 🔥 กึ่งกลาง → "0 Days" ล่าง
/// ยังไม่มี logic นับวันจริง — เป็น UI เพียงอย่างเดียว
class StreakCard extends StatelessWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final cardShadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        boxShadow: cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ป้าย — "Current Streak" เล็ก สีอ่อน อยู่บนสุด
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Current Streak', style: AppTextStyles.label(context)),
            ),
            const SizedBox(height: AppSpacing.sm),
            // ไอคอนไฟ — สีส้ม เป็นสัญลักษณ์ streak อยู่กึ่งกลาง
            const Icon(
              Icons.local_fire_department,
              color: AppColors.flame,
              size: 32,
            ),
            const SizedBox(height: AppSpacing.xs),
            // จำนวนวัน — ตัวใหญ่ เด่น
            Text('0 Days', style: AppTextStyles.value(context)),
          ],
        ),
      ),
    );
  }
}
