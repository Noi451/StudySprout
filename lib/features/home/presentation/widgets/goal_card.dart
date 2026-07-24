import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../goals/domain/goal.dart';

/// การ์ด "เป้าหมายของวันนี้" ของหน้า Home
///
/// มีสองสถานะ:
///  - ว่าง (empty state): [goal] == null → แสดง empty state แบบ Productivity App
///  - มีเป้าหมาย: [goal] != null → แสดงชื่อเป้าหมายล่าสุดแทน "No Goal Yet"
///
/// ไม่มี business logic — เป็น UI แสดงข้อมูลของ [Goal] (หรือสถานะว่าง) เท่านั้น
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, this.goal});

  /// เป้าหมายล่าสุด (ถ้ามี) — null = ยังไม่มีเป้าหมาย
  final Goal? goal;

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

    // มีเป้าหมาย → แสดงข้อมูลเป้าหมายล่าสุด
    if (goal != null) {
      return _filledCard(context, theme, cardShadow);
    }

    // ไม่มีเป้าหมาย → แสดง empty state
    return _emptyCard(context, theme, cardShadow);
  }

  Widget _filledCard(
    BuildContext context,
    ThemeData theme,
    List<BoxShadow> cardShadow,
  ) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        boxShadow: cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            // ไอคอนธงในวงกลมเขียวโปร่ง
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // หัวข้อ + ชื่อเป้าหมาย + เป้าหมายเวลา
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Today's Goal", style: AppTextStyles.label(context)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(goal!.title, style: AppTextStyles.cardTitle(context)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${goal!.targetMinutes} min',
                    style: AppTextStyles.body(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyCard(
    BuildContext context,
    ThemeData theme,
    List<BoxShadow> cardShadow,
  ) {
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
            // ไอคอนธงในวงกลมพื้นหลังเขียวโปร่ง — empty state
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
            Text("Today's Goal", style: AppTextStyles.cardTitle(context)),
            const SizedBox(height: AppSpacing.xs),
            Text('No Goal Yet', style: AppTextStyles.body(context)),
            const SizedBox(height: AppSpacing.sm),
            Text('Create your first goal', style: AppTextStyles.action(context)),
          ],
        ),
      ),
    );
  }
}
