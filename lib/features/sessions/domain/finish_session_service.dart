import '../../progress/domain/progress_store.dart';
import '../../progress/domain/tree_stage.dart';
import '../../progress/domain/tree_stage_calculator.dart';
import '../../progress/domain/xp_calculator.dart';
import 'session_store.dart';
import 'study_session.dart';

/// ผลลัพธ์หลัง commit session ที่จบ — immutable snapshot สำหรับแสดงใน Finish Dialog
///
/// Sprint 5.1: dialog เป็น "presentation only" → อ่านค่าจาก snapshot นี้เท่านั้น
/// ไม่อ่านจาก store ที่อาจเปลี่ยนภายหลัง ทำให้ค่าที่แสดงตรงกับที่ commit จริงเสมอ
///
/// ฟิลด์:
///  - [goalTitle]        ชื่อเป้าหมายของ session ที่จบ
///  - [elapsedSeconds]   เวลาที่เรียน (วินาที) — เอาไป format mm:ss
///  - [targetMinutes]    เป้าหมายเวลาของรอบนี้ — เอาไปคำนวณ %
///  - [xpGained]         XP ที่ได้จาก session นี้
///  - [resultingTotalXp] XP สะสมรวม *หลัง* รับ XP
///  - [resultingLevel]   Level *หลัง* รับ XP
///  - [resultingTreeStage] ระยะต้นไม้ *หลัง* รับ XP
///  - [didLevelUp]       ข้ามเลเวลหรือไม่ (`resultingLevel > previousLevel`)
class FinishSessionResult {
  const FinishSessionResult({
    required this.goalTitle,
    required this.elapsedSeconds,
    required this.targetMinutes,
    required this.xpGained,
    required this.resultingTotalXp,
    required this.resultingLevel,
    required this.resultingTreeStage,
    required this.didLevelUp,
  });

  final String goalTitle;
  final int elapsedSeconds;
  final int targetMinutes;
  final int xpGained;
  final int resultingTotalXp;
  final int resultingLevel;
  final TreeStage resultingTreeStage;
  final bool didLevelUp;
}

/// บริการจบ session — orchestrate การ commit (บันทึก history + แจก XP) exactly once
///
/// Sprint 5.1: แยก business logic ออกจาก [TimerPage] widget มาไว้ใน domain layer
/// (ตามข้อกำหนด "business logic อยู่ใน domain layer")
///
/// จุดสำคัญ — **commit ก่อนเปิด dialog**:
///  - อ่าน session ปัจจุบัน → คำนวณ XP → finish() + addXp() (synchronous, atomic)
///  - คืน snapshot ผลลัพธ์ให้ UI แสดง โดย dialog ไม่ใช่ trigger ของการบันทึก
///
/// ความปลอดภัย exactly-once:
///  - ถ้าไม่มี active session (`current == null`) → คืน null ไม่ commit อะไร
///  - การเรียกซ้ำ → `current` เป็น null หลัง commit แรก → คืน null ไม่มี reward ซ้ำ
///  - `ProgressStore.addXp` เองก็ guard `xp <= 0`
class FinishSessionService {
  const FinishSessionService();

  /// จบ session ปัจจุบัน — บันทึก history + แจก XP แล้วคืน snapshot ผลลัพธ์
  ///
  /// คืน `null` ถ้าไม่มี active session (ไม่ commit อะไร) — caller ควร pop กลับ
  /// การ commit เป็น synchronous → ทำเสร็จก่อน await ใด ๆ จึงปลอดภัยจาก re-entry
  FinishSessionResult? commit(SessionStore sessionStore, ProgressStore progressStore) {
    final StudySession? session = sessionStore.current;
    if (session == null) return null; // ไม่มี active session → nothing to commit

    // คำนวณ XP จากเวลาที่เรียนจริง (XpCalculator — 1 นาที = 1 XP)
    final xpGained = XpCalculator.fromSeconds(session.elapsedSeconds);

    // เก็บ previousLevel ก่อน addXp เพื่อคำนวณ didLevelUp
    final previousLevel = progressStore.level;

    // Commit (synchronous, atomic ใน event เดียว):
    //  1. บันทึก history (sessionStore.finish เก็บ _current ลง history ครั้งเดียว)
    //  2. แจก XP (progressStore.addXp ครั้งเดียว)
    sessionStore.finish();
    progressStore.addXp(xpGained);

    // Snapshot ผลลัพธ์หลัง commit — immutable ให้ dialog อ่าน
    final resultingLevel = progressStore.level;
    return FinishSessionResult(
      goalTitle: session.goalTitle,
      elapsedSeconds: session.elapsedSeconds,
      targetMinutes: session.targetMinutes,
      xpGained: xpGained,
      resultingTotalXp: progressStore.totalXp,
      resultingLevel: resultingLevel,
      resultingTreeStage: TreeStageCalculator.fromLevel(resultingLevel),
      didLevelUp: resultingLevel > previousLevel,
    );
  }
}
