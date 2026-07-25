import 'goal_store.dart';

/// ตัวโหลดข้อมูลเริ่มต้นของแอป — สร้าง [GoalStore] พร้อมกู้คืนจาก SharedPreferences
///
/// แยก logic "สร้าง store + load" ออกจาก [main] เพื่อให้ `main.dart` สะอาด
/// และให้ทดสอบการ load แยกจากการ render ได้
///
/// การใช้งานใน `main.dart`:
/// ```
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   final store = await GoalStoreLoader.load();
///   runApp(StudySproutApp(goalStore: store));
/// }
/// ```
class GoalStoreLoader {
  GoalStoreLoader._(); // ป้องกันการสร้าง instance

  /// สร้าง [GoalStore] ใหม่แล้วกู้คืนข้อมูลที่เคยบันทึกไว้จาก SharedPreferences
  /// ก่อนคืนให้ caller — เพื่อให้เปิดแอปมาแล้วมีเป้าหมาย/active จากครั้งก่อนทันที
  static Future<GoalStore> load() async {
    final store = GoalStore();
    await store.load();
    return store;
  }
}
