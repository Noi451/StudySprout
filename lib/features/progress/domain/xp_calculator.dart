/// ตัวคำนวณ XP (ค่าประสบการณ์) — pure function ที่ทำหน้าที่คำนวณอย่างเดียว
///
/// แยกออกจาก [ProgressStore] เพื่อให้กฎการให้ XP เปลี่ยนได้ที่เดียว
/// โดยไม่ต้องแตะ Store หรือ UI — เช่นอนาคตอาจเพิ่มโบนัส session ที่ completed,
/// weekend 2x, โบนัส goal ยาก ฯลฯ แก้แค่ไฟล์นี้
///
/// กฎเริ่มต้น (Sprint 5): **1 นาทีที่เรียน = 1 XP**
/// - คำนวณจาก `elapsedSeconds` (เวลาที่เรียนจริง) ปัดเป็นนาที
/// - ห้ามคำนวณจาก targetMinutes — XP ต้องมาจากเวลาที่เรียนจริงเท่านั้น
class XpCalculator {
  XpCalculator._(); // ป้องกันการสร้าง instance

  /// คำนวณ XP ที่ได้จาก session ที่เรียนไป `elapsedSeconds` วินาที
  ///
  /// ปัดเป็นนาที (round) แล้วนับ 1 นาที = 1 XP
  /// - ตัวอย่าง: 600s (10 min) → 10 XP, 1800s (30 min) → 30 XP,
  ///   7500s (125 min) → 125 XP
  /// - ค่าติดลบ/ศูนย์ → 0 XP (กัน edge case)
  static int fromSeconds(int elapsedSeconds) {
    if (elapsedSeconds <= 0) return 0;
    return (elapsedSeconds / 60).round();
  }
}
