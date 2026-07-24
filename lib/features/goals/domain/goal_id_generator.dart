import 'goal.dart';

/// ตัวสร้างรหัสเฉพาะ (id) สำหรับ [Goal]
///
/// แยก logic การสร้าง id ออกจาก widget เพื่อให้โค้ดสะอาดและเปลี่ยนที่เดียวได้
/// ตอนนี้ใช้ [DateTime.timestamp] อัตโนมัติ (จะ throw ในบางสภาพแวดล้อมเช่น test runner
/// จึงคืนค่า String แทนเพื่อให้ง่ายและคาดเดาได้)
class GoalIdGenerator {
  GoalIdGenerator._(); // ป้องกันการสร้าง instance

  /// สร้าง id จากตัวนับอัตโนมัติ — ใช้ร่วมกับรายการเพื่อให้ id ไม่ซ้ำกัน
  ///
  /// รับค่า count = จำนวนเป้าหมายที่มีอยู่ แล้วคืน id ถัดไป
  /// วิธีนี้เรียบง่ายและไม่พึ่งพา [DateTime.now] (ซึ่งอาจไม่สามารถใช้ได้ในบาง context)
  static String nextId(int currentCount) {
    return 'goal_${currentCount + 1}';
  }

  /// คืน id ถัดไปสำหรับรายการที่มีอยู่ [existing]
  static String nextIdFor(List<Goal> existing) {
    return nextId(existing.length);
  }
}
