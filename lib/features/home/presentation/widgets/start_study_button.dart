import 'package:flutter/material.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';

/// ปุ่ม "Start Study" ขนาดใหญ่ด้านล่างหน้า Home
///
/// ปุ่มสีเขียว มุมโค้ง ขนาดเต็มความกว้าง
/// ตอนนี้กดแล้วยังไม่ต้องทำอะไร — เป็น UI เพียงอย่างเดียว
class StartStudyButton extends StatelessWidget {
  const StartStudyButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        // ยังไม่ผูก action ใด ๆ — milestone นี้เน้น UI เท่านั้น
        onPressed: () {},
        style: FilledButton.styleFrom(
          // ปุ่มโค้งตาม Design System
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.button,
          ),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl - 8),
          backgroundColor: theme.colorScheme.primary,
        ),
        child: Text('Start Study', style: AppTextStyles.button(context)),
      ),
    );
  }
}
