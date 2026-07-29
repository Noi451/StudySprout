import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../domain/finish_session_service.dart';
import '../session_format.dart';

/// Dialog สรุปผลตอนจบ Session การเรียน (Finish) — **presentation only**
///
/// Sprint 5.1: เปลี่ยนเป็น "แสดงผลเท่านั้น" — อ่านค่าทั้งหมดจาก [FinishSessionResult]
/// snapshot ที่ commit ไปแล้ว (history + XP บันทึกก่อนเปิด dialog)
///
/// แสดง: ชื่อ Goal, เวลาที่เรียน (mm:ss), % ความคืบหน้า, รางวัล (+XP, Level, Tree Stage,
/// และป้าย "Level Up!" เมื่อ [FinishSessionResult.didLevelUp])
///
/// ปุ่ม: **Done** เท่านั้น (ลบ Cancel — commit ไปแล้ว ยกเลิกไม่มีความหมาย)
/// ปิดได้ทุกวิธีอย่างปลอดภัย: Done / Back / Escape / กดนอก (barrierDismissible)
/// เพราะข้อมูล commit ไปแล้ว ไม่ขึ้นกับวิธีปิด dialog
///
/// เป็น widget ล้วน ๆ — ไม่มี form/controller, ไม่จับต้อง store เลย
class SessionFinishDialog extends StatelessWidget {
  const SessionFinishDialog({super.key, required this.result});

  /// snapshot ผลลัพธ์หลัง commit (immutable) — ค่าที่แสดงทั้งหมดมาจากนี่
  final FinishSessionResult result;

  /// เปิด dialog สรุปผล — presentation only (ไม่คืนค่ามา trigger อะไร)
  static Future<void> show(BuildContext context, FinishSessionResult result) {
    return showDialog<void>(
      context: context,
      // ปิดได้ทุกวิธีปลอดภัย (commit ไปแล้ว) → กดนอก/Back/Escape ปิดได้
      barrierDismissible: true,
      builder: (context) => SessionFinishDialog(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeText = SessionFormat.duration(result.elapsedSeconds);
    final percent = SessionFormat.percent(
      result.elapsedSeconds,
      result.targetMinutes,
    );

    return AlertDialog(
      title: const Text('Study Complete'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ชื่อ Goal
            Text('Goal', style: theme.textTheme.labelLarge),
            Text(
              result.goalTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // เวลาที่เรียน
            Text('Time Studied', style: theme.textTheme.labelLarge),
            Text(
              timeText,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // เปอร์เซ็นต์ความคืบหน้า
            Text('Goal Progress', style: theme.textTheme.labelLarge),
            Text(
              '$percent%',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const Divider(height: AppSpacing.xxxl),
            // รางวัล — XP ที่ได้
            Text('Reward', style: theme.textTheme.labelLarge),
            Text(
              '+${result.xpGained} XP',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            // Level หลังรับ XP
            Text('Level ${result.resultingLevel}', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            // ระยะต้นไม้ หลังรับ XP
            Row(
              children: [
                Text(
                  result.resultingTreeStage.emoji,
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  result.resultingTreeStage.label,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
            // ป้าย Level Up! เมื่อข้ามเลเวล
            if (result.didLevelUp) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Level Up!',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
      // เหลือ Done อย่างเดียว — ปิด dialog (ไม่ใช่ trigger commit)
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
