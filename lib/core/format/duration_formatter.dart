/// ตัวจัดรูปแบบระยะเวลา (Duration) กลาง — ใช้ร่วมข้ามทุก feature
///
/// เป็น formatter กลางตัวเดียวของแอป เพื่อให้การแสดงเวลาเป้าหมาย
/// (เช่นใน GoalCard บน Home/Goals และหน้า Timer) เป็นรูปแบบเดียวกัน
/// และแก้ที่เดียว — ห้ามเขียน logic การจัดรูปนาทีซ้ำในหลายไฟล์
///
/// รูปแบบ (input = นาที):
///  - 45  → "45 min"
///  - 60  → "1 hr"
///  - 90  → "1 hr 30 min"
///  - 120 → "2 hr"
///  - 125 → "2 hr 5 min"
class DurationFormatter {
  DurationFormatter._(); // ป้องกันการสร้าง instance

  /// แปลงจำนวนนาทีเป็นข้อความอ่านง่ายรูป `H hr M min` (ซ่อนส่วนที่เป็น 0)
  ///
  /// - ถ้า < 60 นาที → แสดงเฉพาะนาที เช่น "45 min"
  /// - ถ้าจำนวนนาทีลงตัวเป็นชั่วโมง → แสดงเฉพาะชั่วโมง เช่น "2 hr"
  /// - มีทั้งสองส่วน → "1 hr 30 min"
  /// - 0 หรือค่าติดลบ → "0 min" (กัน edge case)
  static String fromMinutes(int minutes) {
    if (minutes <= 0) return '0 min';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) return '$remainingMinutes min';
    if (remainingMinutes == 0) return '$hours hr';
    return '$hours hr $remainingMinutes min';
  }

  /// แปลงจำนวนวินาทีเป็นข้อความอ่านง่าย — ปัดเป็นนาทีแล้วใช้ [fromMinutes]
  ///
  /// ใช้กับสถิติสะสมในหน้า Progress (เช่น todaySeconds/totalSeconds) —
  /// **ไม่เขียน logic จัดรูปซ้ำ** แต่ส่งต่อให้ formatter กลางตัวเดิมจัดการ
  /// (เช่น 90 วินาที → ปัดเป็น 2 นาที → "2 min"; 5400 วินาที → 90 นาที → "1 hr 30 min")
  static String fromSeconds(int seconds) {
    final minutes = (seconds / 60).round();
    return fromMinutes(minutes);
  }
}
