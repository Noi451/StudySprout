import 'package:flutter/material.dart';

/// จุดรวมธีม (theme) ของทั้งแอป StudySprout
///
/// แยกธีมออกมาเป็นไฟล์เดียวเพื่อให้ [StudySproutApp] ใน `app/app.dart`
/// ดูสะอาดและอ่านง่าย เวลาต้องการปรับสี/ฟอนต์ แก้ที่นี่ที่เดียวพอ
class AppTheme {
  AppTheme._(); // ป้องกันการสร้าง instance — ใช้แค่ static getter ด้านล่าง

  /// ธีมแสง (light theme) แบบ Material 3
  ///
  /// - [ColorScheme.fromSeed] สร้างชุดสีที่กลมกลืนกันโดยอัตโนมัติจาก "สีเมล็ดพันธุ์" (seedColor)
  ///   ที่เรากำหนด ที่นี่เลือกสีเขียวเข้ม เพื่อให้รู้สึก "การเติบโต/การเรียนรู้"
  /// - `useMaterial3: true` เปิดระบบดีไซน์ Material 3 (ค่าเริ่มต้นของ Flutter รุ่นใหม่อยู่แล้ว
  ///   แต่เขียนไว้ชัดเจนเพื่อให้ผู้เริ่มต้นเข้าใจ)
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
    );

    return ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: colorScheme,

      // ให้ AppBar ใส่/โปร่งใสตามสไตล์ Material 3 (ไม่มีสีพื้นหลังแยก)
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      // ปรับความกลมของมุมการ์ด/ส่วนโค้งต่าง ๆ ให้นุ่มนวลขึ้นเล็กน้อย
      cardTheme: const CardThemeData(elevation: 0),
    );
  }
}
