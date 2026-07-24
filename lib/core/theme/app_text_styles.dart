import 'package:flutter/material.dart';

/// ชุดสไตล์ตัวอักษร (text styles) ของ Design System StudySprout
///
/// เป็นชุดสไตล์ที่สอดคล้องกับ Material 3 typography แต่กำหนด weight/ความหนา
/// ให้ชัดเจนและสอดคล้องกันทั่วแอป แทนการเขียนซ้ำในแต่ละ widget
///
/// การใช้งาน: ส่งผ่าน `Theme.of(context)` เป็นฐาน แล้ว override ด้วยค่าจากที่นี่
/// ```
/// Text('StudySprout', style: AppTextStyles.brand(context))
/// ```
class AppTextStyles {
  AppTextStyles._(); // ป้องกันการสร้าง instance

  /// ชื่อแบรนด์ "StudySprout" — ตัวใหญ่ เด่น หนา
  static TextStyle brand(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
          fontWeight: FontWeight.bold,
        );
  }

  /// คำทักทาย (เช่น "Good Morning") — กลาง สีอ่อนกว่าปกติ
  static TextStyle greeting(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
  }

  /// ป้ายขนาดเล็กบนการ์ด (เช่น "Level 1", "Current Streak") — สีอ่อน
  static TextStyle label(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
  }

  /// ค่าตัวเลข/ข้อความสำคัญบนการ์ด (เช่น "XP 0 / 100", "0 Days") — หนา เด่น
  static TextStyle value(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
        );
  }

  /// หัวข้อการ์ด (เช่น "Today's Goal") — หนา
  static TextStyle cardTitle(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
        );
  }

  /// ข้อความบอกรายละเอียด/สถานะว่าง — สีอ่อน ขนาดปกติ
  static TextStyle body(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
  }

  /// ข้อความชวนสร้าง/คลิก (เช่น "Create your first goal") — สีหลัก หนา
  static TextStyle action(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.w600,
        );
  }

  /// ข้อความบนปุ่มใหญ่ (CTA) — ขนาดกลาง หนา สีตัดกับพื้นปุ่ม
  static TextStyle button(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        );
  }
}
