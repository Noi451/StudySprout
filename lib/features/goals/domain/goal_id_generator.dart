import 'goal.dart';

/// ตัวสร้างรหัสเฉพาะ (id) สำหรับ [Goal]
///
/// แยก logic การสร้าง id ออกจาก widget เพื่อให้โค้ดสะอาดและเปลี่ยนที่เดียวได้
///
/// ⚠️ ใช้ค่าสูงสุดของเลข id ที่มีอยู่ + 1 (ไม่ใช่จำนวน goal) เพื่อให้ **id ไม่มีทางซ้ำกัน**
/// แม้จะลบ goal ไปแล้วสร้างใหม่ — เช่น มี goal_1, goal_3 อยู่ ตัวใหม่จะเป็น goal_4
/// (วิธีเดิมนับจากจำนวน → ลบแล้วสร้างใหม่ทำให้ id ซ้ำ → เป็นสาเหตุของบัค
/// "active goal สองตัว" เพราะมี goal 2 ตัว id เดียวกันใน list)
class GoalIdGenerator {
  GoalIdGenerator._(); // ป้องกันการสร้าง instance

  /// สร้าง id จากเลข id ที่สูงที่สุดใน [existing] บวก 1
  ///
  /// ไม่ใช้ [DateTime.now] เพื่อให้ id คาดเดาได้และทดสอบง่าย
  /// ถ้ายังไม่มี goal เลย → คืน `goal_1`
  static String nextIdFor(List<Goal> existing) {
    var max = 0;
    for (final goal in existing) {
      final n = _parseNumber(goal.id);
      if (n > max) max = n;
    }
    return 'goal_${max + 1}';
  }

  /// แยกตัวเลขต่อท้าย id ออกมา — `goal_7` → 7, `goal_1` → 1, อื่น ๆ → 0
  /// ใช้เพื่อหาค่าสูงสุด ไม่ใช่เพื่อตรวจรูปแบบ จึงหละโลยเมื่อ parse ไม่ได้
  static int _parseNumber(String id) {
    final match = _idPattern.firstMatch(id);
    if (match == null) return 0;
    return int.tryParse(match.group(1)!) ?? 0;
  }

  static final _idPattern = RegExp(r'goal_(\d+)$');
}
