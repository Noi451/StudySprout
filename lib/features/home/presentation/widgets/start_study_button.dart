import 'package:flutter/material.dart';

/// ปุ่ม "Start Study" ขนาดใหญ่ด้านล่างหน้า Home
///
/// ปุ่มสีเขียว มุมโค้ง ขนาดเต็มความกว้าง
/// ตอนนี้กดแล้วยังไม่ต้องทำอะไร — เป็น UI เพียงอย่างเดียว
/// (onPressed เป็น null ในเฟสนี้ เพื่อให้ชัดว่ายังไม่มี action)
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
          // ปุ่มโค้งเล็กน้อย ดูนุ่มนวลตามสไตล์ calm/minimal
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: theme.colorScheme.primary,
        ),
        child: Text(
          'Start Study',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
