import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../progress/domain/progress_store_provider.dart';

/// การ์ด XP (ค่าประสบการณ์) ของหน้า Home
///
/// Sprint 5: แสดงข้อมูลจริงจาก [ProgressStore]
///  - "Level N" (derive จาก totalXp)
///  - "XP current / levelEnd" เช่น "30 / 100 XP" (XP ในเลเวลปัจจุบัน ไม่ใช่ totalXp ตรง ๆ)
///  - แถบความคืบหน้า = XP ในเลเวลปัจจุบัน / 100 (เช่น 30/100 = 0.30)
///
/// เป็น UI ล้วน ๆ — ทุกค่ามาจาก store (logic คำนวณอยู่ใน domain layer)
/// rebuild อัตโนมัติผ่าน [ProgressStoreProvider]/InheritedNotifier เมื่อ XP เปลี่ยน
class XpCard extends StatelessWidget {
  const XpCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = ProgressStoreProvider.of(context);

    // ค่าทั้งหมด derive จาก store (logic อยู่ใน calculator ของ domain)
    final level = store.level;
    final currentLevelXp = store.currentLevelXp; // XP ในเลเวลปัจจุบัน (reset ทุก 100)
    final levelEndXp = store.currentLevelEndXp; // 100 (XP ต้องสะสมต่อเลเวล)
    final progress = currentLevelXp / levelEndXp; // 0.0–1.0

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
            Text('Level $level', style: AppTextStyles.label(context)),
            const SizedBox(height: AppSpacing.sm),
            // ค่า XP — ตัวใหญ่ เด่น (XP ในเลเวลปัจจุบัน / 100)
            Text(
              'XP $currentLevelXp / $levelEndXp',
              style: AppTextStyles.value(context),
            ),
            const SizedBox(height: AppSpacing.md),
            // แถบความคืบหน้า — ค่าจริงจาก store (0.0–1.0)
            ClipRRect(
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadius.sm),
              ),
              child: LinearProgressIndicator(
                value: progress,
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
