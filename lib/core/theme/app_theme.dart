import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radius.dart';

/// จุดรวมธีมของทั้งแอป StudySprout — "Midnight Greenhouse" (Dark-first)
///
/// Sprint 8: เปลี่ยนจาก Light theme เป็น Dark-first Product Design
/// สร้าง [ColorScheme.dark] ที่มี semantic meaning ครบ แล้ว map token ของ
/// [AppColors] เข้ากับ ColorScheme roles → widget ทั่วแอปใช้ `Theme.of` ได้ตามปกติ
/// ส่วน token เฉพาะ (surface levels, text roles, accent) ใช้ [AppColors] ตรง ๆ
class AppTheme {
  AppTheme._();

  /// ColorScheme หลัก — semantic roles ครบ
  static const ColorScheme _colorScheme = ColorScheme.dark(
    primary: AppColors.emerald,
    onPrimary: AppColors.onEmerald,
    primaryContainer: AppColors.emeraldContainer,
    onPrimaryContainer: AppColors.textPrimary,
    secondary: AppColors.sky,
    onSecondary: AppColors.background,
    secondaryContainer: AppColors.skyContainer,
    onSecondaryContainer: AppColors.textPrimary,
    tertiary: AppColors.amber,
    onTertiary: AppColors.background,
    tertiaryContainer: AppColors.amberContainer,
    onTertiaryContainer: AppColors.textPrimary,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.surface,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.surfaceHigh,
    surfaceContainerHighest: AppColors.surfaceHighest,
    onSurfaceVariant: AppColors.textSecondary,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineSoft,
    error: AppColors.danger,
    onError: AppColors.background,
    scrim: Color(0xFF000000),
  );

  /// Dark-first theme ของแอป
  static ThemeData dark() {
    final cs = _colorScheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      // พื้นหลังหลัก — midnight navy (ไม่ใช่ดำสนิท)
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,

      // ตัวอักษรหลัก — กำหนดสีตรง ๆ จาก text roles เพื่อ contrast ที่ควบคุมได้
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: AppColors.textPrimary),
        displayMedium: TextStyle(color: AppColors.textPrimary),
        displaySmall: TextStyle(color: AppColors.textPrimary),
        headlineLarge: TextStyle(color: AppColors.textPrimary),
        headlineMedium: TextStyle(color: AppColors.textPrimary),
        headlineSmall: TextStyle(color: AppColors.textPrimary),
        titleLarge: TextStyle(color: AppColors.textPrimary),
        titleMedium: TextStyle(color: AppColors.textPrimary),
        titleSmall: TextStyle(color: AppColors.textSecondary),
        bodyLarge: TextStyle(color: AppColors.textPrimary),
        bodyMedium: TextStyle(color: AppColors.textSecondary),
        bodySmall: TextStyle(color: AppColors.textMuted),
        labelLarge: TextStyle(color: AppColors.textSecondary),
        labelMedium: TextStyle(color: AppColors.textMuted),
        labelSmall: TextStyle(color: AppColors.textMuted),
      ),

      // AppBar — โปร่งใสกลมกลืนพื้นหลัง ไม่มี elevation
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card — ไม่มี elevation (ใช้ surface level + border แยกจาก background)
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: AppColors.outlineSoft, width: 1),
        ),
      ),

      // Divider — บาง โทน outline
      dividerTheme: const DividerThemeData(
        color: AppColors.outlineSoft,
        thickness: 1,
        space: 1,
      ),

      // ปุ่ม — โค้งตาม Design System
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          backgroundColor: AppColors.emerald,
          foregroundColor: AppColors.onEmerald,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.outline),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.emerald),
      ),

      // Progress indicator — emerald
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.emerald,
        linearTrackColor: AppColors.emeraldContainer,
        circularTrackColor: AppColors.surfaceHighest,
      ),

      // Icon theme default
      iconTheme: const IconThemeData(color: AppColors.textSecondary),

      // NavigationBar (ใช้ใน compact/medium shell)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.background,
        indicatorColor: AppColors.emeraldContainer,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? AppColors.emerald : AppColors.textMuted,
            size: 24,
          );
        }),
      ),

      // NavigationRail (ใช้ใน expanded shell)
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: AppColors.backgroundSoft,
        selectedIconTheme: const IconThemeData(color: AppColors.emerald, size: 26),
        unselectedIconTheme: const IconThemeData(color: AppColors.textMuted, size: 24),
        selectedLabelTextStyle: const TextStyle(
          color: AppColors.emerald,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelTextStyle: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
        ),
        indicatorColor: AppColors.emeraldContainer,
      ),

      // Dialog — surfaceHighest (สูงสุด เพื่อเด่นบนพื้น)
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceHighest,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: AppColors.outlineSoft, width: 1),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        contentTextStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),

      // SnackBar / tooltip
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.surfaceHighest,
        contentTextStyle: TextStyle(color: AppColors.textPrimary),
        behavior: SnackBarBehavior.floating,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceHighest,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: TextStyle(color: AppColors.textPrimary, fontSize: 12),
      ),

      // ColorScheme สำหรับ widget ที่อ่านจาก Theme.of
      // (วางท้ายเพราะ copyWith ของบาง field อาจ override — เราใช้ ColorScheme ตรง ๆ)
    ).copyWith(colorScheme: cs);
  }
}
