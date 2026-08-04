import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type hierarchy ของ StudySprout (Midnight Greenhouse)
///
/// Sprint 8: สร้าง ladder ที่ชัด — แต่ละระดับต่างกันที่ size/weight/color
/// หลีกเลี่ยงตัวหนาทุกบรรทัด / font size ใกล้กัน / สีขาวเท่ากันทุกระดับ
///
/// Ladder (สูง → ต่ำ):
///  - [display]      Hero/Display (StudySprout, Growth Hero) — ใหญ่สุด
///  - [brand]        ชื่อแบรนด์ (เดิมเก็กไว้) ≈ display เล็กกว่าเล็กน้อย
///  - [pageTitle]    หัวข้อหน้า (AppBar)
///  - [sectionTitle] หัวข้อ section
///  - [cardTitle]    หัวข้อการ์ด
///  - [metricValue]  ตัวเลข metric — เด่น ตัวเลข
///  - [metricLabel]  ป้าย metric — สั้น สีอ่อน
///  - [greeting]     คำทักทาย — textSecondary
///  - [body]         ข้อความปกติ — textSecondary
///  - [bodyStrong]   ข้อความสำคัญ — textPrimary หนา
///  - [label]        ป้ายบนการ์ด — textSecondary
///  - [action]       ข้อความชวนกระทำ — emerald
///  - [caption]      metadata จาง ๆ — textMuted
///  - [value]        (compat) ค่าตัวเลขบนการ์ด ≈ metricValue
///  - [button]       ข้อความปุ่ม — onPrimary หนา
///
/// ทุก style กำหนดสีตรง ๆ จาก [AppColors] (ไม่พึ่ง textTheme color) เพื่อ contrast
/// ที่ควบคุมได้ และรองรับ text scaling โดยไม่ overflow (ไม่กำหนดความสูงตายตัว)
class AppTextStyles {
  AppTextStyles._();

  static TextStyle display(BuildContext context) =>
      Theme.of(context).textTheme.displayMedium!.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            height: 1.1,
            letterSpacing: -0.5,
          );

  static TextStyle brand(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          );

  static TextStyle pageTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          );

  static TextStyle sectionTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          );

  static TextStyle cardTitle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          );

  static TextStyle metricValue(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          );

  static TextStyle metricLabel(BuildContext context) =>
      Theme.of(context).textTheme.labelMedium!.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          );

  static TextStyle greeting(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.textMuted,
          );

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.textSecondary,
          );

  static TextStyle bodyStrong(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          );

  static TextStyle label(BuildContext context) =>
      Theme.of(context).textTheme.labelLarge!.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          );

  static TextStyle action(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
            color: AppColors.emerald,
            fontWeight: FontWeight.w700,
          );

  static TextStyle caption(BuildContext context) =>
      Theme.of(context).textTheme.bodySmall!.copyWith(
            color: AppColors.textMuted,
        );

  /// (compat) ค่าตัวเลขบนการ์ดเดิม — ใช้ metricValue
  static TextStyle value(BuildContext context) => metricValue(context);

  /// ข้อความปุ่ม — onPrimary หนา
  static TextStyle button(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onEmerald,
          );
}
