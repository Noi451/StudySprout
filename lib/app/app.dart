import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/goals/domain/goal_store.dart';
import '../features/goals/domain/goal_store_provider.dart';
import '../features/sessions/domain/session_store.dart';
import '../features/sessions/domain/session_store_provider.dart';
import 'router.dart';

/// วิดเจ็ตราก (root widget) ของแอป StudySprout
///
/// ใช้ [MaterialApp.router] เพื่อเชื่อมกับ [AppRouter.router] (go_router)
/// และใช้ธีมแสง Material 3 จาก [AppTheme.light]
///
/// หุ้มด้วย [GoalStoreProvider] (รายการเป้าหมาย + active goal) และ [SessionStoreProvider]
/// (สถานะ session การเรียน) เรียงกัน — ให้ทุกหน้าใช้ร่วมกันและอัปเดตพร้อมกัน
///
/// Sprint 3: [GoalStore] ถูกสร้างและกู้คืนจาก SharedPreferences ที่ [main] แล้ว
/// ส่งเข้ามาที่นี่เพื่อใช้ instance เดียวกันทั้งแอป (ไม่สร้างใหม่ใน widget tree)
class StudySproutApp extends StatelessWidget {
  const StudySproutApp({
    super.key,
    required this.goalStore,
    required this.sessionStore,
  });

  /// store ของเป้าหมาย — มาจาก [GoalStoreLoader.load] (พร้อมข้อมูลที่กู้คืนแล้ว)
  final GoalStore goalStore;

  /// store ของ session การเรียน (in-memory)
  final SessionStore sessionStore;

  @override
  Widget build(BuildContext context) {
    return GoalStoreProvider(
      notifier: goalStore,
      child: SessionStoreProvider(
        notifier: sessionStore,
        child: MaterialApp.router(
          title: 'StudySprout',
          debugShowCheckedModeBanner: false,

          // ธีมแสงที่สะอาดตา แบบ Material 3
          theme: AppTheme.light(),

          // ส่ง router ให้ MaterialApp จัดการเส้นทางทั้งหมด
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
