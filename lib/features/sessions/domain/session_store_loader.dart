import 'session_store.dart';

/// ตัวโหลดข้อมูลเริ่มต้นของ session — สร้าง [SessionStore] พร้อมกู้คืนจาก SharedPreferences
///
/// ลอก pattern [GoalStoreLoader] — แยก logic "สร้าง store + load" ออกจาก [main]
/// เพื่อให้ `main.dart` สะอาดและทดสอบการ load แยกจากการ render ได้
///
/// Sprint 4: กู้คืนประวัติ session (`List<SessionRecord>`) ก่อนเปิดแอป
///
/// การใช้งานใน `main.dart`:
/// ```
/// final goalStore = await GoalStoreLoader.load();
/// final sessionStore = await SessionStoreLoader.load();
/// runApp(StudySproutApp(goalStore: goalStore, sessionStore: sessionStore));
/// ```
class SessionStoreLoader {
  SessionStoreLoader._(); // ป้องกันการสร้าง instance

  /// สร้าง [SessionStore] ใหม่แล้วกู้คืนประวัติที่เคยบันทึกไว้จาก SharedPreferences
  /// ก่อนคืนให้ caller — เพื่อให้เปิดแอปมาแล้วมีประวัติการเรียนจากครั้งก่อนทันที
  static Future<SessionStore> load() async {
    final store = SessionStore();
    await store.load();
    return store;
  }
}
