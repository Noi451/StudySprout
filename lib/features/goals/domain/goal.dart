/// Model ของ "เป้าหมาย" (Goal) ของแอป StudySprout
///
/// เป็น data class ล้วน ๆ — เก็บข้อมูลเป้าหมายที่ผู้ใช้สร้าง
/// ฟิลด์ทั้งหมด immutable (final) เพื่อให้จัดการ state ง่ายและปลอดภัย
///
/// Sprint 3: เพิ่มความสามารถบันทึก/กู้คืนจาก SharedPreferences
/// ผ่าน [toJson] และ [Goal.fromJson] — model เองยังไม่รู้จัก "active"
/// (สถานะ active ถูกจัดการแยกที่ [GoalStore] เพราะ active ได้ทีละตัว)
///
/// ฟิลด์ทั้งหมด:
///  - [id]            รหัสเฉพาะของเป้าหมาย
///  - [title]         ชื่อเป้าหมาย
///  - [targetMinutes] เป้าหมายเวลาเรียน (นาที)
///  - [createdAt]     วันเวลาที่สร้าง
class Goal {
  const Goal({
    required this.id,
    required this.title,
    required this.targetMinutes,
    required this.createdAt,
  });

  final String id;
  final String title;
  final int targetMinutes;
  final DateTime createdAt;

  /// แปลง Goal เป็น Map เพื่อบันทึกลง SharedPreferences (เป็น JSON string)
  Map<String, Object?> toJson() => {
        'id': id,
        'title': title,
        'targetMinutes': targetMinutes,
        // เก็บ createdAt เป็นมิลลิวินาที (ISO ก็ได้ แต่ int เล็ก/เร็วกว่า)
        'createdAtMs': createdAt.millisecondsSinceEpoch,
      };

  /// สร้าง Goal จาก Map ที่อ่านได้จาก SharedPreferences
  /// ใช้ใน [GoalStore.load] ตอนกู้คืนข้อมูลเมื่อเปิดแอปใหม่
  static Goal fromJson(Map<String, Object?> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      targetMinutes: json['targetMinutes'] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAtMs'] as int,
      ),
    );
  }
}
