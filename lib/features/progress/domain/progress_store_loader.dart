import 'progress_store.dart';

/// ตัวโหลดข้อมูลเริ่มต้นของ progress — สร้าง [ProgressStore] พร้อมกู้คืนจาก SharedPreferences
///
/// ลอก pattern [GoalStoreLoader]/[SessionStoreLoader] — แยก logic "สร้าง store + load"
/// ออกจาก [main] เพื่อให้ `main.dart` สะอาดและทดสอบการ load แยกจากการ render ได้
///
/// Sprint 5: กู้คืน totalXp ก่อนเปิดแอป (level/treeStage derive จาก totalXp)
class ProgressStoreLoader {
  ProgressStoreLoader._(); // ป้องกันการสร้าง instance

  /// สร้าง [ProgressStore] ใหม่แล้วกู้คืน XP ที่เคยบันทึกไว้จาก SharedPreferences
  /// ก่อนคืนให้ caller — เพื่อให้เปิดแอปมาแล้ว XP/Level/TreeStage จากครั้งก่อนกลับมาทันที
  static Future<ProgressStore> load() async {
    final store = ProgressStore();
    await store.load();
    return store;
  }
}
