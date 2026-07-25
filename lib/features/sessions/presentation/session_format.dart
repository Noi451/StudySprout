/// ตัวช่วยจัดรูปแบบเวลา (format) สำหรับ Session การเรียน
///
/// แยก logic การจัดรูป "วินาที → mm:ss" ออกจาก widget เพื่อใช้ซ้ำ
/// ทั้งในหน้า Timer, การ์ด Active Session บน Home และ Finish Dialog
class SessionFormat {
  SessionFormat._(); // ป้องกันการสร้าง instance

  /// แปลงวินาทีเป็นข้อความรูป `mm:ss` (เช่น 65 → "01:05")
  static String duration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  /// คำนวณเปอร์เซ็นต์ความคืบหน้าของ session เทียบกับเป้าหมาย (clamped ที่ 100)
  ///
  /// ถ้าเกิน 100 จะคืน 100 (ไม่แสดงค่าเกิน เพื่อความเรียบง่าย)
  static int percent(int elapsedSeconds, int targetMinutes) {
    if (targetMinutes <= 0) return 0;
    final targetSeconds = targetMinutes * 60;
    final p = (elapsedSeconds / targetSeconds * 100).round();
    return p.clamp(0, 100);
  }
}
