import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// ปุ่ม CTA หลัก — Micro Interaction + a11y
///
/// สถานะ: enabled / disabled / hover / focus / pressed
/// ripple จาก InkWell, elevation (เงา) เพิ่มตอน press, scale เล็กน้อย
/// เคารพ reduceMotion (scale และ shadow ยังทำงานเพราะเป็น implicit สั้น แต่
/// ไม่รบกวน — หากต้องการปิดทั้งหมด widget เรียกจะส่ง disableAnimations ได้ภายหลัง)
///
/// [variant] = primary (emerald, เด่นสุด) / subtle (surface) / danger
class AppPressButton extends StatefulWidget {
  const AppPressButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isExpanded = true,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isExpanded;
  final AppButtonVariant variant;
  final IconData? icon;

  @override
  State<AppPressButton> createState() => _AppPressButtonState();
}

enum AppButtonVariant { primary, subtle, danger }

class _AppPressButtonState extends State<AppPressButton> {
  bool _pressed = false;

  bool get _disabled => widget.onPressed == null;

  void _setPressed(bool v) {
    if (_disabled) return;
    if (_pressed != v) setState(() => _pressed = v);
  }

  ({Color bg, Color fg, Color shadow}) _colors(BuildContext context) {
    switch (widget.variant) {
      case AppButtonVariant.primary:
        return (
          bg: _disabled ? AppColors.surfaceHigh : AppColors.emerald,
          fg: _disabled ? AppColors.textMuted : AppColors.onEmerald,
          shadow: AppColors.emerald,
        );
      case AppButtonVariant.subtle:
        return (
          bg: _disabled ? AppColors.surface : AppColors.surfaceHigh,
          fg: _disabled ? AppColors.textMuted : AppColors.textPrimary,
          shadow: AppColors.surfaceHighest,
        );
      case AppButtonVariant.danger:
        return (
          bg: _disabled ? AppColors.surfaceHigh : AppColors.danger,
          fg: _disabled ? AppColors.textMuted : AppColors.background,
          shadow: AppColors.danger,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _colors(context);
    final showShadow = _pressed && !_disabled && widget.variant == AppButtonVariant.primary;

    Widget button = AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: AppMotion.short,
      curve: AppMotion.easeInOutCubic,
      child: AnimatedContainer(
        duration: AppMotion.medium,
        curve: AppMotion.easeInOutCubic,
        decoration: BoxDecoration(
          color: c.bg,
          borderRadius: AppRadius.button,
          border: widget.variant == AppButtonVariant.subtle
              ? Border.all(color: AppColors.outlineSoft, width: 1)
              : null,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    color: c.shadow.withValues(alpha: 0.40),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: AppRadius.button,
            onTap: widget.onPressed,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xxl - 8,
                horizontal: AppSpacing.xxl,
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: c.fg, size: 20),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.label,
                          style: TextStyle(
                            color: c.fg,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.isExpanded) {
      button = SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
