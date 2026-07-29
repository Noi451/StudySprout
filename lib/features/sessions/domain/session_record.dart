/// Model ของ "ประวัติ Session การเรียน" หนึ่งรอบที่จบแล้ว
///
/// แยกจาก [StudySession] (ซึ่งเป็น state ตอนกำลังเรียน) เพราะ Requirement กำหนด
/// รูปทรงของ history เป็นคนละแบบ — มี `endedAt` และ `completed` แต่ไม่มี `id`/
/// `targetMinutes`/`status` เก็บเฉพาะข้อมูลที่จำเป็นสำหรับสถิติและรายการย้อนหลัง
///
/// Sprint 4: เป็น data class ล้วน ๆ — immutable ทุกฟิลด์ และบันทึก/กู้คืนจาก
/// SharedPreferences ผ่าน [toJson] และ [SessionRecord.fromJson]
///
/// ฟิลด์ทั้งหมด (ตามข้อกำหนด Sprint 4):
///  - [goalId]         รหัสเป้าหมายที่ผูกกับ session นี้
///  - [goalTitle]      ชื่อเป้าหมาย (snapshot ตอนเริ่ม — เผื่อ goal ถูกลบ/เปลี่ยน)
///  - [startedAt]      วันเวลาที่เริ่ม session
///  - [endedAt]        วันเวลาที่จบ session (กด Finish)
///  - [elapsedSeconds] เวลาที่เรียนสะสม (วินาที)
///  - [completed]      เรียนครบเป้าหมายรอบนั้นหรือไม่
///                     (elapsedSeconds >= targetMinutes * 60 ตอน Finish)
class SessionRecord {
  const SessionRecord({
    required this.goalId,
    required this.goalTitle,
    required this.startedAt,
    required this.endedAt,
    required this.elapsedSeconds,
    required this.completed,
  });

  final String goalId;
  final String goalTitle;
  final DateTime startedAt;
  final DateTime endedAt;
  final int elapsedSeconds;
  final bool completed;

  /// แปลง SessionRecord เป็น Map เพื่อบันทึกลง SharedPreferences (เป็น JSON string)
  ///
  /// เก็บ `startedAt`/`endedAt` เป็นมิลลิวินาทีเหมือน [Goal.toJson] (int เล็ก/เร็วกว่า ISO)
  Map<String, Object?> toJson() => {
        'goalId': goalId,
        'goalTitle': goalTitle,
        'startedAtMs': startedAt.millisecondsSinceEpoch,
        'endedAtMs': endedAt.millisecondsSinceEpoch,
        'elapsedSeconds': elapsedSeconds,
        'completed': completed,
      };

  /// สร้าง SessionRecord จาก Map ที่อ่านได้จาก SharedPreferences
  /// ใช้ใน [SessionStore.load] ตอนกู้คืนประวัติเมื่อเปิดแอปใหม่
  static SessionRecord fromJson(Map<String, Object?> json) {
    return SessionRecord(
      goalId: json['goalId'] as String,
      goalTitle: json['goalTitle'] as String,
      startedAt:
          DateTime.fromMillisecondsSinceEpoch(json['startedAtMs'] as int),
      endedAt: DateTime.fromMillisecondsSinceEpoch(json['endedAtMs'] as int),
      elapsedSeconds: json['elapsedSeconds'] as int,
      completed: json['completed'] as bool,
    );
  }
}
