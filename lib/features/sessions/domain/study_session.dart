import 'session_status.dart';

/// Model ของ "Session การเรียน" หนึ่งรอบของแอป StudySprout
///
/// เป็น data class ล้วน ๆ — เก็บข้อมูลของการเรียนรอบหนึ่งที่ผูกกับ [Goal] ใด [Goal] หนึ่ง
/// ยังไม่มีการบันทึกลง Database/SharedPreferences เก็บไว้ใน memory เท่านั้น
///
/// ฟิลด์ทั้งหมดตามข้อกำหนด Sprint 2:
///  - [id]            รหัสเฉพาะของ session
///  - [goalId]        รหัสของเป้าหมายที่ผูกกับ session นี้
///  - [goalTitle]     ชื่อเป้าหมาย (snapshot ตอนเริ่ม — เผื่อ goal ถูกลบ/เปลี่ยนในภายหลัง)
///  - [targetMinutes] เป้าหมายเวลาเรียน (นาที) ของ goal ตอนเริ่ม session
///  - [startedAt]     วันเวลาที่เริ่ม session
///  - [elapsedSeconds] เวลาที่เรียนสะสม (วินาที) — เพิ่มขึ้นทีละ 1 ทุก tick ขณะ running
///  - [status]        สถานะปัจจุบันของ session ([SessionStatus])
class StudySession {
  const StudySession({
    required this.id,
    required this.goalId,
    required this.goalTitle,
    required this.targetMinutes,
    required this.startedAt,
    required this.elapsedSeconds,
    required this.status,
  });

  final String id;
  final String goalId;
  final String goalTitle;
  final int targetMinutes;
  final DateTime startedAt;
  final int elapsedSeconds;
  final SessionStatus status;

  /// สำเนา session พร้อมเขียนทับบางฟิลด์ — ใช้ใน [SessionStore] เวลาอัปเดต
  /// `elapsedSeconds` หรือ `status` (เนื่องจาก model เป็น immutable)
  StudySession copyWith({int? elapsedSeconds, SessionStatus? status}) {
    return StudySession(
      id: id,
      goalId: goalId,
      goalTitle: goalTitle,
      targetMinutes: targetMinutes,
      startedAt: startedAt,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      status: status ?? this.status,
    );
  }
}
