import 'package:flutter/material.dart';

import '../responsive/breakpoints.dart';
import '../theme/app_colors.dart';
import 'animated_bottom_nav.dart';

/// Shell นำทางแบบ responsive — หุ้มเนื้อหาแท็บ + ตัวนำทาง
///
/// Sprint 8 PART 2: ตัดสินใจ layout จาก available width เท่านั้น (ไม่เช็ก Platform)
///  - **Compact/Medium**: bottom navigation (AnimatedBottomNav) เหมือนเดิม
///  - **Expanded (≥1000)**: NavigationRail ทางซ้าย + เนื้อหา constrained ทางขวา
///
/// **เป็น Presentation เท่านั้น** — routing logic (paths/branches/goBranch/redirect)
/// อยู่ใน router.dart และไม่ถูกแตะ ตัวนี้รับ `currentIndex` + `onSelect` + `body` มาแสดง
class AppNavShell extends StatelessWidget {
  const AppNavShell({
    super.key,
    required this.currentIndex,
    required this.onSelect,
    required this.body,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final Widget body;

  /// รายการแท็บ (เหมือน AnimatedBottomNav.destinations)
  final List<AnimatedNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Expanded → NavigationRail ทางซ้าย
        if (AppBreakpoint.isExpanded(width)) {
          return _RailShell(
            currentIndex: currentIndex,
            onSelect: onSelect,
            body: body,
            destinations: destinations,
          );
        }

        // Compact/Medium → bottom nav
        return Scaffold(
          body: body,
          bottomNavigationBar: AnimatedBottomNav(
            currentIndex: currentIndex,
            onDestinationSelected: onSelect,
            destinations: destinations,
          ),
        );
      },
    );
  }
}

/// Shell แบบ NavigationRail (expanded)
class _RailShell extends StatelessWidget {
  const _RailShell({
    required this.currentIndex,
    required this.onSelect,
    required this.body,
    required this.destinations,
  });

  final int currentIndex;
  final ValueChanged<int> onSelect;
  final Widget body;
  final List<AnimatedNavDestination> destinations;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // แถบนำทางซ้าย — พื้นผิว backgroundSoft, มีขอบขวาบาง
          Container(
            decoration: const BoxDecoration(
              color: AppColors.backgroundSoft,
              border: Border(
                right: BorderSide(color: AppColors.outlineSoft, width: 1),
              ),
            ),
            child: SafeArea(
              right: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: onSelect,
                  extended: false,
                  minExtendedWidth: 200,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: _RailBrand(),
                  ),
                  destinations: [
                    for (final d in destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selectedIcon),
                        label: Text(d.label),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // เนื้อหาของแท็บ (ขวา)
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// โลโก้/แบรนด์เล็กบนยอด rail (expanded)
class _RailBrand extends StatelessWidget {
  const _RailBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.emerald,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.park, color: AppColors.onEmerald, size: 22),
        ),
      ],
    );
  }
}
