import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/goal.dart';

/// การ์ดแสดงรายการเป้าหมายหนึ่งรายการใน Goals Page
///
/// แสดงชื่อเป้าหมายและเป้าหมายเวลา (นาที) ในรูปแบบการ์ด Material 3
/// ไม่มี business logic — เป็น UI แสดงข้อมูลของ [Goal] เท่านั้น
class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal});

  final Goal goal;

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
        child: Row(
          children: [
            // ไอคอนธงในวงกลมเขียวโปร่ง — สื่อ "เป้าหมาย"
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
            // ชื่อเป้าหมาย + เป้าหมายเวลา
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(goal.title, style: AppTextStyles.cardTitle(context)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${goal.targetMinutes} min',
                    style: AppTextStyles.body(context),
                  ),
                ],
              ),
            ),
            // ลูกศรบอกว่าเป็นรายการ (visual cue)
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
