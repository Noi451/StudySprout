/// ตัวสร้างรหัสเฉพาะ (id) สำหรับ [StudySession]
///
/// แยก logic การสร้าง id ออกจาก widget/store เพื่อให้โค้ดสะอาดและเปลี่ยนที่เดียวได้
/// ใช้ตัวนับอัตโนมัติ (ไม่พึ่งพา `DateTime.now` ซึ่งอาจไม่สามารถใช้ได้ในบาง context)
class SessionIdGenerator {
  SessionIdGenerator._(); // ป้องกันการสร้าง instance

  /// สร้าง id จากจำนวน session ที่มีอยู่ — คืน id ถัดไปที่ไม่ซ้ำ
  static String nextId(int currentCount) {
    return 'session_${currentCount + 1}';
  }
}
