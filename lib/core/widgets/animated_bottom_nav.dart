import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';

/// Bottom Navigation แบบกำหนดเอง — มีแอนิเมชันเมื่อสลับแท็บ (PART 4)
///
/// Sprint 7 (PART 4): เมื่อเปลี่ยนแท็บ ให้
///  - **Icon**: scale 1.00 → 1.10 → 1.00 (เด้งเล็กน้อยตอนเลือก) ผ่าน [AnimatedScale]
///    + cross-fade ระหว่าง icon ธรรมดา ↔ selectedIcon ผ่าน [AnimatedSwitcher]
///  - **Label**: fade + เปลี่ยนสไตล์ (สี/น้ำหนัก) ผ่าน [AnimatedOpacity] +
///    [AnimatedDefaultTextStyle]
///
/// ใช้ implicit animations เท่านั้น — ไม่ใช้ AnimationController และไม่ใช้ package
///
/// เป็น "วิดเจ็ตแสดงผล" ล้วน ๆ — รับ `currentIndex` + `onDestinationSelected`
/// ไม่มี routing logic ใด ๆ ภายใน (caller ใน router เป็นคนเรียก `goBranch` ผ่าน callback)
class AnimatedBottomNav extends StatelessWidget {
  const AnimatedBottomNav({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  /// ดัชนีแท็บที่กำลังเลือกอยู่
  final int currentIndex;

  /// callback เมื่อแตะแท็บ — caller (router) เป็นคนเรียก `goBranch(index)` ผ่านนี่
  final ValueChanged<int> onDestinationSelected;

  /// รายการแท็บ — แต่ละตัวเก็บ icon/selectedIcon/label
  final List<AnimatedNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        // เส้นบาก ๆ ด้านบนแยกจากเนื้อหา
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                Expanded(
                  child: _NavTab(
                    destination: destinations[i],
                    selected: i == currentIndex,
                    onTap: () => onDestinationSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ข้อมูลของแท็บหนึ่งใน [AnimatedBottomNav]
class AnimatedNavDestination {
  const AnimatedNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  /// ไอคอนปกติ (ยังไม่ถูกเลือก)
  final IconData icon;

  /// ไอคอนเมื่อถูกเลือก
  final IconData selectedIcon;

  /// ป้ายข้อความของแท็บ
  final String label;
}

/// แท็บหนึ่งใน bottom nav — icon scale + label fade (PART 4)
class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.destination,
    required this.selected,
    required this.onTap,
  });

  final AnimatedNavDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: AppRadius.button,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // PART 4 — Icon: AnimatedScale (เด้ง 1.00 → 1.10 → 1.00 ด้วย easeOutBack)
            // + AnimatedSwitcher cross-fade ระหว่าง icon ธรรมดา ↔ selectedIcon
            AnimatedScale(
              scale: selected ? 1.10 : 1.00,
              duration: AppMotion.short,
              // easeOutBack มี overshoot → ได้เอฟเฟกต์ "เด้ง" คล้าย 1.10 แล้วกลับ
              curve: AppMotion.bounceOut,
              child: AnimatedSwitcher(
                duration: AppMotion.short,
                switchInCurve: AppMotion.easeOutCubic,
                switchOutCurve: AppMotion.easeOutCubic,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Icon(
                  selected ? destination.selectedIcon : destination.icon,
                  key: ValueKey(selected),
                  size: 24,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            // PART 4 — Label: fade (AnimatedOpacity) + เปลี่ยนสไตล์ (AnimatedDefaultTextStyle)
            AnimatedOpacity(
              opacity: selected ? 1.0 : 0.7,
              duration: AppMotion.short,
              curve: AppMotion.easeOutCubic,
              child: AnimatedDefaultTextStyle(
                duration: AppMotion.short,
                curve: AppMotion.easeOutCubic,
                style: selected
                    ? theme.textTheme.labelSmall!.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      )
                    : theme.textTheme.labelSmall!.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                child: Text(destination.label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
