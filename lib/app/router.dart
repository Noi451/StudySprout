import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/app_nav_shell.dart';
import '../core/widgets/animated_bottom_nav.dart';
import '../features/goals/presentation/goals_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/progress/presentation/progress_page.dart';

/// จุดรวมเส้นทาง (routing) ของทั้งแอป
///
/// ไฟล์นี้สร้าง [GoRouter] ซึ่งเป็นตัวจัดการ navigation แบบ declarative
/// เราใช้รูปแบบ **StatefulShellRoute.indexedStack** เพื่อทำ Bottom Navigation 4 แท็บ
/// โดยแต่ละแท็บจะเก็บ state ของตัวเองแยกกัน (เปลี่ยนแท็บไปกลับแล้วหน้าไม่รีเซ็ต)
class AppRouter {
  AppRouter._(); // ป้องกันการสร้าง instance — ใช้แค่ static getter ด้านล่าง

  /// รายชื่อเส้นทางของแต่ละแท็บ เก็บไว้ที่เดียวเพื่อให้แก้ง่าย
  static const String home = '/home';
  static const String goals = '/goals';
  static const String progress = '/progress';
  static const String profile = '/profile';

  /// ตัว router หลักที่ส่งให้ [MaterialApp.router]
  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // navigationShell คือตัวที่คุมการสลับแท็บ
          // เราหุ้มด้วย Scaffold + NavigationBar (Bottom Navigation แบบ Material 3)
          return AppNavShell(
            currentIndex: navigationShell.currentIndex,
            onSelect: (index) {
              // สลับไปแท็บที่เลือก พร้อมเก็บ state ของแท็บเดิมไว้
              // (routing logic: paths/branches/goBranch ไม่ถูกแตะเลย)
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            body: navigationShell,
            destinations: const [
              AnimatedNavDestination(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
              ),
              AnimatedNavDestination(
                icon: Icons.flag_outlined,
                selectedIcon: Icons.flag,
                label: 'Goals',
              ),
              AnimatedNavDestination(
                icon: Icons.trending_up_outlined,
                selectedIcon: Icons.trending_up,
                label: 'Progress',
              ),
              AnimatedNavDestination(
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: 'Profile',
              ),
            ],
          );
        },
        branches: [
          // แท็บที่ 1 — Home
          StatefulShellBranch(
            routes: [
              GoRoute(path: home, builder: (context, state) => const HomePage()),
            ],
          ),
          // แท็บที่ 2 — Goals
          StatefulShellBranch(
            routes: [
              GoRoute(path: goals, builder: (context, state) => const GoalsPage()),
            ],
          ),
          // แท็บที่ 3 — Progress
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: progress,
                builder: (context, state) => const ProgressPage(),
              ),
            ],
          ),
          // แท็บที่ 4 — Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                builder: (context, state) => const ProfilePage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
