import '../../sessions/domain/session_record.dart';

/// สถิติความคืบหน้าการเรียน ที่คำนวณจากประวัติ session (`List<SessionRecord>`)
///
/// เป็น immutable data class ล้วน ๆ — คำนวณที่เดียวผ่าน [ProgressStats.compute]
/// แล้วส่งให้ widget โชว์ผลลัพธ์ ไม่มี business logic ปะปนใน widget
///
/// Sprint 4: สร้างเพื่อแยก computation ออกจาก ProgressPage
///
/// ฟิลด์ทั้งหมด (ตามข้อกำหนด Sprint 4):
///  - [todaySeconds]   เวลาเรียนสะสมวันนี้ (วินาที)
///  - [weekSeconds]    เวลาเรียนสะสมสัปดาห์นี้ (จันทร์–อาทิตย์, ISO)
///  - [totalSeconds]   เวลาเรียนสะสมทั้งหมด
///  - [sessionCount]   จำนวน session ทั้งหมด
///  - [averageSeconds] ความยาวเฉลี่ยต่อ session (`total ~/ count`, 0 ถ้าไม่มี)
///  - [recent]         รายการ session 5 ล่าสุด (เรียงจากใหม่ไปเก่า)
class ProgressStats {
  const ProgressStats({
    required this.todaySeconds,
    required this.weekSeconds,
    required this.totalSeconds,
    required this.sessionCount,
    required this.averageSeconds,
    required this.recent,
  });

  final int todaySeconds;
  final int weekSeconds;
  final int totalSeconds;
  final int sessionCount;
  final int averageSeconds;
  final List<SessionRecord> recent;

  /// คำนวณสถิติจาก [history] ณ เวลา [now]
  ///
  /// รับ [now] เป็นพารามิเตอร์เพื่อให้ทดสอบได้ (ส่งเวลาตายตัวเข้ามา)
  /// ถ้า [history] ว่าง → คืนค่า 0 ทุกตัว + recent ว่าง
  static ProgressStats compute(List<SessionRecord> history, DateTime now) {
    if (history.isEmpty) {
      return const ProgressStats(
        todaySeconds: 0,
        weekSeconds: 0,
        totalSeconds: 0,
        sessionCount: 0,
        averageSeconds: 0,
        recent: [],
      );
    }

    final today = _dateOnly(now);
    final weekStart = _mondayOfWeek(now);

    var todaySeconds = 0;
    var weekSeconds = 0;
    var totalSeconds = 0;

    for (final record in history) {
      totalSeconds += record.elapsedSeconds;
      // เทียบเฉพาะวัน (ไม่สนเวลา) สำหรับ "วันนี้"
      if (_dateOnly(record.startedAt) == today) {
        todaySeconds += record.elapsedSeconds;
      }
      // เริ่มตั้งแต่วันจันทร์ 00:00 ของสัปดาห์ปัจจุบัน
      if (!record.startedAt.isBefore(weekStart)) {
        weekSeconds += record.elapsedSeconds;
      }
    }

    final sessionCount = history.length;
    final averageSeconds = totalSeconds ~/ sessionCount;

    // เรียงจากใหม่ไปเก่า แล้วเอา 5 อันดับแรก
    final sorted = [...history]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    final recent = sorted.take(5).toList();

    return ProgressStats(
      todaySeconds: todaySeconds,
      weekSeconds: weekSeconds,
      totalSeconds: totalSeconds,
      sessionCount: sessionCount,
      averageSeconds: averageSeconds,
      recent: recent,
    );
  }

  /// ตัดเวลาออก เหลือเฉพาะส่วนวัน (00:00 ของวันนั้น) — เทียบ "วันเดียวกัน" ได้แม่นยำ
  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// วันจันทร์ 00:00 ของสัปดาห์ที่ [dt] อยู่ (ISO week, จันทร์–อาทิตย์)
  ///
  /// `weekday` จันทร์=1 ... อาทิตย์=7 → ลบ (weekday - 1) วัน
  static DateTime _mondayOfWeek(DateTime dt) {
    final monday = dt.subtract(Duration(days: dt.weekday - 1));
    return _dateOnly(monday);
  }
}
