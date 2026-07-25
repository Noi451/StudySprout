import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../session_format.dart';
import '../../domain/study_session.dart';

/// Dialog สรุปผลตอนจบ Session การเรียน (Finish)
///
/// แสดงสรุป: ชื่อ Goal, เวลาที่เรียน (mm:ss), เปอร์เซ็นต์ความคืบหน้าเทียบเป้าหมาย
/// ปุ่ม: Cancel (กลับไปหน้า Timer) / Done (ยืนยันจบ)
///
/// เป็น widget ล้วน ๆ — ไม่มี form ไม่มี controller จึงใช้ StatelessWidget ได้
class SessionFinishDialog extends StatelessWidget {
  const SessionFinishDialog({super.key, required this.session});

  /// snapshot ของ session ตอนจบ (เพื่อแสดงสรุปผล)
  final StudySession session;

  /// เปิด dialog สรุปผล คืน true ถ้ากด Done, false/null ถ้ายกเลิก
  static Future<bool> show(BuildContext context, StudySession session) {
    return showDialog<bool>(
      context: context,
      builder: (context) => SessionFinishDialog(session: session),
    ).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final timeText = SessionFormat.duration(session.elapsedSeconds);
    final percent = SessionFormat.percent(
      session.elapsedSeconds,
      session.targetMinutes,
    );

    return AlertDialog(
      title: const Text('Study Complete'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ชื่อ Goal
          Text('Goal', style: theme.textTheme.labelLarge),
          Text(
            session.goalTitle,
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
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
