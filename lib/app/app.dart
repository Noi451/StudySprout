import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'router.dart';

/// วิดเจ็ตราก (root widget) ของแอป StudySprout
///
/// ใช้ [MaterialApp.router] เพื่อเชื่อมกับ [AppRouter.router] (go_router)
/// และใช้ธีมแสง Material 3 จาก [AppTheme.light]
/// ไม่ใช่ [MaterialApp] ธรรมดา เพราะ go_router เป็นตัวจัดการเส้นทางแทน
class StudySproutApp extends StatelessWidget {
  const StudySproutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'StudySprout',
      debugShowCheckedModeBanner: false,

      // ธีมแสงที่สะอาดตา แบบ Material 3
      theme: AppTheme.light(),

      // ส่ง router ให้ MaterialApp จัดการเส้นทางทั้งหมด
      routerConfig: AppRouter.router,
    );
  }
}
