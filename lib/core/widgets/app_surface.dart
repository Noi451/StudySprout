import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// ระดับ "พื้นผิว" ของ component — แยกจาก background ด้วย surface level + border
/// (ไม่พึ่ง shadow หนัก) ตามหลัก Midnight Greenhouse: surface ไม่เกิน 3 ระดับ
enum AppSurfaceLevel {
  /// surface ธรรมดา (การ์ด/panel ทั่วไป)
  base,

  /// surfaceHigh (metric tile, supporting panel)
  high,

  /// surfaceHighest (dialog, องค์ประกอบเด่นบางส่วน)
  highest,
}

/// Container พื้นผิวมาตรฐาน — ใช้ทั่วแอปแทน DecoratedBox เปล่า ๆ
///
/// กำหนด color/border ตาม [level] เสมอ → ภาษาภาพเดียวกันทั้งแอป
/// ไม่มี shadow หนัก (เว้น [elevated] สำหรับ Hero/องค์ประกอบลอย)
class AppSurface extends StatelessWidget {
  const AppSurface({
    super.key,
    required this.child,
    this.level = AppSurfaceLevel.base,
    this.radius = AppRadius.card,
    this.elevated = false,
    this.padding,
    this.onTap,
    this.borderOverride,
  });

  final Widget child;
  final AppSurfaceLevel level;
  final BorderRadius radius;

  /// true = เพิ่มเงานุ่มเล็กน้อย (Hero/องค์ประกอบลอย) — ใช้จำกัด
  final bool elevated;

  final EdgeInsets? padding;
  final VoidCallback? onTap;

  /// บังคับสีขอบ (null = ใช้ default ตาม level)
  final Color? borderOverride;

  Color get _background => switch (level) {
        AppSurfaceLevel.base => AppColors.surface,
        AppSurfaceLevel.high => AppColors.surfaceHigh,
        AppSurfaceLevel.highest => AppColors.surfaceHighest,
      };

  Color get _border => borderOverride ?? switch (level) {
        AppSurfaceLevel.base => AppColors.outlineSoft,
        AppSurfaceLevel.high => AppColors.outlineSoft,
        AppSurfaceLevel.highest => AppColors.outline,
      };

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      color: _background,
      borderRadius: radius,
      border: Border.all(color: _border, width: 1),
      boxShadow: elevated
          ? const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 24,
                offset: Offset(0, 8),
              ),
            ]
          : null,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: DecoratedBox(
            decoration: decoration,
            child: padding == null ? child : Padding(padding: padding!, child: child),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: decoration,
      child: padding == null ? child : Padding(padding: padding!, child: child),
    );
  }
}
