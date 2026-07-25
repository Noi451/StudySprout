import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/goals/domain/goal_store.dart';
import 'features/goals/domain/goal_store_loader.dart';
import 'features/sessions/domain/session_store.dart';

/// จุดเริ่มต้นของแอป StudySprout
///
/// Sprint 3: ก่อน [runApp] เรากู้คืน Goal และ Active Goal จาก SharedPreferences
/// ผ่าน [GoalStoreLoader.load] แล้วส่ง [GoalStore] (พร้อมข้อมูล) เข้าสู่ widget tree
/// ทำให้เปิดแอปใหม่แล้วเป้าหมายที่เคยสร้าง/active กลับมาทันที
///
/// [SessionStore] ยังคงเป็น in-memory (ยังไม่ persist — ตามขอบเขต Sprint นี้)
Future<void> main() async {
  // จำเป็นเพราะเราเรียก async (SharedPreferences) ก่อน runApp
  WidgetsFlutterBinding.ensureInitialized();

  final goalStore = await GoalStoreLoader.load();

  runApp(
    StudySproutApp(
      goalStore: goalStore,
      sessionStore: SessionStore(),
    ),
  );
}
