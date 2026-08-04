import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Breakpoints และ responsive helpers ของ StudySprout
///
/// ตัดสินใจ layout จาก **available width** เท่านั้น (ไม่เช็ก Platform)
/// ตามข้อกำหนด Sprint 8 PART 2
///
/// Compact : < 600  (mobile-first, single column, bottom nav)
/// Medium  : 600–999 (จำกัดความกว้าง, 2-column เฉพาะจุด)
/// Expanded: ≥ 1000  (จำกัด content ~1100–1200, supporting pane)
class AppBreakpoint {
  AppBreakpoint._();

  static const double compactMax = 600;
  static const double mediumMax = 1000;

  static bool isCompact(double width) => width < compactMax;
  static bool isMedium(double width) => width >= compactMax && width < mediumMax;
  static bool isExpanded(double width) => width >= mediumMax;
}

/// ระดับความกว้าง (enum ใช้ switch ได้)
enum AppViewport { compact, medium, expanded }

extension AppViewportX on double {
  AppViewport get viewport => this < AppBreakpoint.compactMax
      ? AppViewport.compact
      : this < AppBreakpoint.mediumMax
          ? AppViewport.medium
          : AppViewport.expanded;
}

/// จัด padding/maxWidth ตาม available width — กัน Web/Desktop ยืดเต็มจอ
class ResponsivePageFrame extends StatelessWidget {
  const ResponsivePageFrame({
    required this.child,
    super.key,
    this.expandedMaxWidth = 1180,
    this.topAlign = true,
  });

  final Widget child;

  /// ความกว้างสูงสุดเมื่อ expanded
  final double expandedMaxWidth;

  /// true = ชิดบน (เนื้อหาไม่กลางจอในแนวตั้ง)
  final bool topAlign;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final vp = width.viewport;

        final horizontalPadding = switch (vp) {
          AppViewport.compact => AppSpacing.lg,
          AppViewport.medium => AppSpacing.xxl,
          AppViewport.expanded => AppSpacing.xxxl,
        };

        final maxWidth = switch (vp) {
          AppViewport.compact => double.infinity,
          AppViewport.medium => 760.0,
          AppViewport.expanded => expandedMaxWidth,
        };

        return Align(
          alignment: topAlign ? Alignment.topCenter : Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
