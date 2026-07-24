import 'package:flutter/material.dart';

/// ส่วนหัวของหน้า Home — ข้อความต้อนรับ
///
/// แสดงคำทักทายตามช่วงเวลา (ตอนนี้เป็นข้อความคงที่ ยังไม่มี logic คำนวณเวลาจริง)
/// และชื่อแอป "StudySprout" เป็นตัวใหญ่ด้านล่าง
class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // คำทักทาย — เน้นนุ่มนวล สีอ่อนกว่าชื่อแอป
        Text(
          'Good Morning',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        // ชื่อแอป — ตัวใหญ่ เด่น เป็นจุดศูนย์กลางของส่วนบน
        Text(
          'StudySprout',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
