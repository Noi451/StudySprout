import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/goals/domain/goal_store.dart';
import 'features/goals/domain/goal_store_loader.dart';
import 'features/progress/domain/progress_store_loader.dart';
import 'features/sessions/domain/session_store_loader.dart';

/// จุดเริ่มต้นของแอป StudySprout
///
/// Sprint 3: ก่อน [runApp] เรากู้คืน Goal และ Active Goal จาก SharedPreferences
/// ผ่าน [GoalStoreLoader.load] แล้วส่ง [GoalStore] (พร้อมข้อมูล) เข้าสู่ widget tree
/// ทำให้เปิดแอปใหม่แล้วเป้าหมายที่เคยสร้าง/active กลับมาทันที
///
/// Sprint 4: กู้คืนประวัติ session จาก SharedPreferences ผ่าน [SessionStoreLoader.load]
/// ด้วย — เปิดแอปใหม่แล้วประวัติการเรียนกลับมาทันที (session ที่ active ตอนปิดแอป
/// ไม่ถูกกู้คืน — ถือว่ายกเลิก ตามขอบเขต Sprint นี้)
///
/// Sprint 5: กู้คืน XP/Level จาก SharedPreferences ผ่าน [ProgressStoreLoader.load]
/// ด้วย — เปิดแอปใหม่แล้วระดับ/ต้นไม้จากครั้งก่อนกลับมาทันที (Tree Stage derive จาก level)
Future<void> main() async {
  // จำเป็นเพราะเราเรียก async (SharedPreferences) ก่อน runApp
  WidgetsFlutterBinding.ensureInitialized();

  final goalStore = await GoalStoreLoader.load();
  final sessionStore = await SessionStoreLoader.load();
  final progressStore = await ProgressStoreLoader.load();

  runApp(
    StudySproutApp(
      goalStore: goalStore,
      sessionStore: sessionStore,
      progressStore: progressStore,
    ),
  );
}
