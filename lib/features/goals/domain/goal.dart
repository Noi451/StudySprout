/// Model ของ "เป้าหมาย" (Goal) ของแอป StudySprout
///
/// เป็น data class ล้วน ๆ — เก็บข้อมูลเป้าหมายที่ผู้ใช้สร้าง
/// ยังไม่มีการบันทึกลง Database/SharedPreferences เก็บไว้ใน memory เท่านั้น
///
/// ฟิลด์ทั้งหมดตามข้อกำหนด Milestone 4:
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
}
