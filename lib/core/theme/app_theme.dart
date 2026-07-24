import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// จุดรวมธีม (theme) ของทั้งแอป StudySprout
///
/// แยกธีมออกมาเป็นไฟล์เดียว เวลาต้องการปรับสี/รัศมี/เงา แก้ที่นี่ที่เดียวพอ
/// ค่าพื้นฐานทั้งหมดดึงจาก Design System ใน `core/theme/` (app_colors, app_radius)
class AppTheme {
  AppTheme._(); // ป้อกันการสร้าง instance — ใช้แค่ static getter ด้านล่าง

  /// ธีมแสง (light theme) แบบ Material 3
  ///
  /// - [ColorScheme.fromSeed] สร้างชุดสีที่กลมกลืนกันจาก [AppColors.seed]
  /// - `useMaterial3: true` เปิดระบบดีไซน์ Material 3
  /// - ปรับ AppBar, Card, และเงา (shadow) ให้สะอาดตามสไตล์ calm/minimal
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(seedColor: AppColors.seed);

    return ThemeData.light(useMaterial3: true).copyWith(
      colorScheme: colorScheme,

      // พื้นหลังหลักของแอป — ขาวสะอาดตา (calm)
      scaffoldBackgroundColor: Colors.white,

      // AppBar ใส/โปร่งใสตามสไตล์ Material 3
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.white,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),

      // การ์ด: มุมโค้งตาม Design System, ไม่มี elevation (ใช้เงากำหนดเองแทน)
      cardTheme: CardThemeData(
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.card,
        ),
        // note: เงาจริงใส่ที่ DecoratedBox ของแต่ละการ์ดใน widget ย่อย
        // เพื่อควบคุมความนุ่มของเงาได้จากที่เดียว
      ),
    );
  }
}
