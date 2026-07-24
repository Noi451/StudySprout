import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// ส่วนหัวของหน้า Home — ข้อความต้อนรับ
///
/// แสดงคำทักทาย (ตอนนี้เป็นข้อความคงที่ ยังไม่มี logic คำนวณเวลาจริง)
/// และชื่อแอป "StudySprout" เป็นตัวใหญ่ด้านล่าง
class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // คำทักทาย — เน้นนุ่มนวล สีอ่อนกว่าชื่อแอป
        Text('Good Morning', style: AppTextStyles.greeting(context)),
        const SizedBox(height: AppSpacing.xs),
        // ชื่อแอป — ตัวใหญ่ เด่น เป็นจุดศูนย์กลางของส่วนบน
        Text('StudySprout', style: AppTextStyles.brand(context)),
      ],
    );
  }
}
