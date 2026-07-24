import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// การ์ด XP (ค่าประสบการณ์) ของหน้า Home
///
/// แสดง "Level 1", "XP 0 / 100" และแถบความคืบหน้า (static, 0%)
/// ยังไม่มี logic คำนวณระดับหรือ XP จริง — ค่าทั้งหมดเป็นค่าคงที่สำหรับ UI
class XpCard extends StatelessWidget {
  const XpCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // เงานุ่ม ๆ ให้การ์ดลอยเล็กน้อย (calm/minimal)
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ป้ายระดับ — เล็ก สีอ่อน อยู่บนสุด
            Text('Level 1', style: AppTextStyles.label(context)),
            const SizedBox(height: AppSpacing.sm),
            // ค่า XP — ตัวใหญ่ เด่น
            Text('XP 0 / 100', style: AppTextStyles.value(context)),
            const SizedBox(height: AppSpacing.md),
            // แถบความคืบหน้า — static (ค่า 0.0) ตามข้อกำหนด ห้ามมี logic
            ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadius.sm),
              ),
              child: LinearProgressIndicator(
                value: 0.0,
                minHeight: 8,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
