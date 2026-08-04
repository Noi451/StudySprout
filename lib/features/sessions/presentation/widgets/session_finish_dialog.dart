import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_press_button.dart';
import '../../../../core/widgets/status_pill.dart';
import '../../domain/finish_session_service.dart';
import '../session_format.dart';

/// Dialog สรุปผลตอนจบ Session การเรียน (Finish) — **presentation only**
///
/// Sprint 8: ใช้ theme ใหม่ (Midnight Greenhouse) แต่ไม่เปลี่ยน flow/business logic
/// อ่านค่าทั้งหมดจาก [FinishSessionResult] snapshot (commit ไปแล้ว)
class SessionFinishDialog extends StatelessWidget {
  const SessionFinishDialog({super.key, required this.result});

  final FinishSessionResult result;

  static Future<void> show(BuildContext context, FinishSessionResult result) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => SessionFinishDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final timeText = SessionFormat.duration(result.elapsedSeconds);
    final percent = SessionFormat.percent(result.elapsedSeconds, result.targetMinutes);

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.emerald, size: 28),
          const SizedBox(width: AppSpacing.sm),
          const Text('Study Complete'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Goal', style: AppTextStyles.label(context)),
            Text(result.goalTitle, style: AppTextStyles.cardTitle(context)),
            const SizedBox(height: AppSpacing.md),
            Text('Time Studied', style: AppTextStyles.label(context)),
            Text(timeText, style: AppTextStyles.metricValue(context)),
            const SizedBox(height: AppSpacing.md),
            Text('Goal Progress', style: AppTextStyles.label(context)),
            Text(
              '$percent%',
              style: AppTextStyles.metricValue(context)
                  .copyWith(color: AppColors.emerald),
            ),
            const Divider(height: AppSpacing.xxxl),
            Text('Reward', style: AppTextStyles.label(context)),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '+${result.xpGained} XP',
              style: AppTextStyles.metricValue(context)
                  .copyWith(color: AppColors.emerald),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text('Level ${result.resultingLevel}', style: AppTextStyles.cardTitle(context)),
            const SizedBox(height: AppSpacing.xs),
            StatusPill(
              label: result.resultingTreeStage.label,
              accent: AppColors.emerald,
              icon: Icons.park,
            ),
            if (result.didLevelUp) ...[
              const SizedBox(height: AppSpacing.sm),
              const StatusPill(
                label: 'Level Up!',
                accent: AppColors.amber,
                icon: Icons.celebration,
              ),
            ],
          ],
        ),
      ),
      actions: [
        AppPressButton(
          label: 'Done',
          onPressed: () => Navigator.of(context).pop(),
          isExpanded: false,
        ),
      ],
    );
  }
}
