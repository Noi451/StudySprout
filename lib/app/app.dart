import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/goals/domain/goal_store.dart';
import '../features/goals/domain/goal_store_provider.dart';
import 'router.dart';

/// วิดเจ็ตราก (root widget) ของแอป StudySprout
///
/// ใช้ [MaterialApp.router] เพื่อเชื่อมกับ [AppRouter.router] (go_router)
/// และใช้ธีมแสง Material 3 จาก [AppTheme.light]
///
/// หุ้มด้วย [GoalStoreProvider] เพื่อส่ง [GoalStore] (รายการเป้าหมายใน memory)
/// ให้ทุกหน้าใช้ร่วมกัน — Home กับ Goals แสดงข้อมูลเดียวกันและอัปเดตพร้อมกัน
class StudySproutApp extends StatelessWidget {
  const StudySproutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GoalStoreProvider(
      notifier: GoalStore(),
      child: MaterialApp.router(
        title: 'StudySprout',
        debugShowCheckedModeBanner: false,

        // ธีมแสงที่สะอาดตา แบบ Material 3
        theme: AppTheme.light(),

        // ส่ง router ให้ MaterialApp จัดการเส้นทางทั้งหมด
        routerConfig: AppRouter.router,
      ),
    );
  }
}
