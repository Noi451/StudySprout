import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// การ์ด "เป้าหมายของวันนี้" ของหน้า Home
///
/// สถานะว่าง (Empty State): ยังไม่มีเป้าหมาย
/// ดีไซน์เป็น Productivity App — มีไอคอนในวงกลมพื้นหลัง ข้อความบอกสถานะ
/// และคำชวน "Create your first goal"
/// ยังไม่มี logic สร้าง/โหลดเป้าหมายจริง — เป็น UI เพียงอย่างเดียว
class GoalCard extends StatelessWidget {
  const GoalCard({super.key});

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
        // พื้นหลังโทนเทาอ่อน ใกล้พื้นหลัง เน้นความ "ว่าง"
        color: AppColors.emptyGoalSurface,
        borderRadius: AppRadius.card,
        boxShadow: cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            // ไอคอนธงในวงกลมพื้นหลัง — สื่อ "เป้าหมาย" แบบ empty state
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // หัวข้อการ์ด
            Text("Today's Goal", style: AppTextStyles.cardTitle(context)),
            const SizedBox(height: AppSpacing.xs),
            // สถานะ "ยังไม่มีเป้าหมาย"
            Text('No Goal Yet', style: AppTextStyles.body(context)),
            const SizedBox(height: AppSpacing.sm),
            // คำชวนสร้างเป้าหมายแรก
            Text('Create your first goal', style: AppTextStyles.action(context)),
          ],
        ),
      ),
    );
  }
}
