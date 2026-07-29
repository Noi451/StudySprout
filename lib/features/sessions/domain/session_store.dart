import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../goals/domain/goal.dart';
import 'session_id_generator.dart';
import 'session_record.dart';
import 'session_status.dart';
import 'study_session.dart';

/// ที่เก็บสถานะ "Session การเรียน" ของทั้งแอป
///
/// เป็น [ChangeNotifier] เพื่อให้ widget ที่ฟัง rebuild อัตโนมัติเมื่อสถานะเปลี่ยน
/// (เช่น เวลาที่เพิ่มขึ้นทุกวินาที, กด Pause/Resume/Finish)
///
/// โครงสร้างภายใน:
///  - [_current]  session ที่กำลัง active (running/paused) — null เมื่อไม่มี session ค้างอยู่
///  - [_history]  รายการ [SessionRecord] ของ session ที่จบแล้ว (บันทึกถาวร)
///  - [_ticker]   [Timer.periodic] ที่ tick ทุก 1 วินาทีขณะ running
///
/// Sprint 4 เพิ่ม:
///  - **Session History**: เมื่อ Finish สร้าง [SessionRecord] (มี `endedAt`/`completed`)
///    แยกจาก [StudySession] ที่เป็น state ตอน active
///  - **Persistence**: บันทึก/กู้คืน `_history` จาก SharedPreferences — เปิดแอปใหม่กลับมาพร้อมประวัติ
///    (session ที่กำลัง active ยังเป็น in-memory ตามขอบเขต — ปิดแอปกลางคันถือว่ายกเลิก)
///
/// Storage key (SharedPreferences):
///  - `session_history`  JSON string ของ `[SessionRecord.toJson(), ...]`
class SessionStore extends ChangeNotifier {
  SessionStore();

  StudySession? _current;
  final List<SessionRecord> _history = [];
  Timer? _ticker;

  /// session ที่กำลัง active (running/paused) — null ถ้าไม่มี
  StudySession? get current => _current;

  /// รายการประวัติ session ที่จบแล้ว (อ่านได้อย่างเดียวจากภายนอก)
  List<SessionRecord> get history => List.unmodifiable(_history);

  /// มี session ค้างอยู่หรือไม่ (running หรือ paused)
  bool get isActive =>
      _current != null && _current!.status != SessionStatus.completed;

  /// สถานะของ session ปัจจุบัน — null ถ้าไม่มี session active
  SessionStatus? get status => _current?.status;

  /// เวลาที่เรียนสะสม (วินาที) ของ session ปัจจุบัน — 0 ถ้าไม่มี session
  int get elapsedSeconds => _current?.elapsedSeconds ?? 0;

  /// ความคืบหน้าไปยังเป้าหมาย (0.0–1.0) ของ session ปัจจุบัน
  ///
  /// คำนวณจาก `elapsedSeconds / (targetMinutes * 60)` แล้ว clamp ไม่ให้เกิน 1.0
  /// ถ้าไม่มี session หรือ targetMinutes เป็น 0 → คืน 0.0
  double get progress {
    if (_current == null || _current!.targetMinutes <= 0) return 0.0;
    final targetSeconds = _current!.targetMinutes * 60;
    final ratio = _current!.elapsedSeconds / targetSeconds;
    return ratio.clamp(0.0, 1.0);
  }

  /// เริ่ม session การเรียนใหม่จาก [goal]
  ///
  /// สร้าง [StudySession] สถานะ [SessionStatus.running], `elapsedSeconds = 0`,
  /// snapshot ชื่อ/เป้าหมายจาก goal แล้วเริ่ม ticker นับขึ้นทุกวินาที
  void startSession(Goal goal) {
    // ถ้ามี session ค้างอยู่อยู่แล้ว ไม่เริ่มทับ (ปล่อยให้เปิดหน้า timer เดิมต่อ)
    if (isActive) return;

    _ticker?.cancel();
    _current = StudySession(
      id: SessionIdGenerator.nextId(_history.length),
      goalId: goal.id,
      goalTitle: goal.title,
      targetMinutes: goal.targetMinutes,
      startedAt: DateTime.now(),
      elapsedSeconds: 0,
      status: SessionStatus.running,
    );
    _startTicker();
    notifyListeners();
  }

  /// พัก session ชั่วคราว — หยุด ticker เปลี่ยนสถานะเป็น [SessionStatus.paused]
  void pause() {
    if (_current == null || _current!.status != SessionStatus.running) return;
    _ticker?.cancel();
    _ticker = null;
    _current = _current!.copyWith(status: SessionStatus.paused);
    notifyListeners();
  }

  /// ทำต่อหลังพัก — เริ่ม ticker ใหม่ เปลี่ยนสถานะเป็น [SessionStatus.running]
  void resume() {
    if (_current == null || _current!.status != SessionStatus.paused) return;
    _current = _current!.copyWith(status: SessionStatus.running);
    _startTicker();
    notifyListeners();
  }

  /// จบ session ปัจจุบัน — ยกเลิก ticker, สร้าง [SessionRecord] บันทึกลง [_history],
  /// บันทึกถาวร แล้วล้าง [_current]
  ///
  /// `completed` = เรียนครบเป้าหมายรอบนั้น (`elapsedSeconds >= targetMinutes * 60`)
  /// ไม่ใช่ "กด Finish แล้วนับเสมอ" เพราะ Finish ทำได้ทุกกรณี → ใช้การถึงเป้าเป็นเกณฑ์
  void finish() {
    if (_current == null) return;
    _ticker?.cancel();
    _ticker = null;
    final session = _current!;
    final completed = session.elapsedSeconds >= session.targetMinutes * 60;
    _history.add(
      SessionRecord(
        goalId: session.goalId,
        goalTitle: session.goalTitle,
        startedAt: session.startedAt,
        endedAt: DateTime.now(),
        elapsedSeconds: session.elapsedSeconds,
        completed: completed,
      ),
    );
    _current = null;
    _persistHistory();
    notifyListeners();
  }

  /// เริ่ม ticker ที่ tick ทุก 1 วินาที — เรียกเฉพาะเมื่อ status == running
  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  /// ถูกเรียกทุก tick — เพิ่ม elapsedSeconds ทีละ 1 แล้วแจ้ง listener rebuild
  ///
  /// Sprint 6: เมื่อถึงเป้าหมาย (`targetMinutes * 60`) จะ **หยุดเอง** —
  /// ปัด elapsedSeconds เป็น targetSeconds (ไม่เกิน), เปลี่ยนสถานะเป็น
  /// [SessionStatus.paused] ("หยุดเพราะครบ รอผู้ใช้ Finish") และยกเลิก ticker
  /// **ไม่ auto commit** — ผู้ใช้ยังต้องกด Finish เอง (ตามข้อกำหนด)
  ///
  /// เปิดเผยเป็น `@visibleForTesting` เพื่อให้ unit test เรียกจำลอง tick ได้
  /// (ทดสอบการเพิ่มเวลา/หยุดที่เป้า โดยไม่ต้องรอ Timer จริง)
  @visibleForTesting
  void tick() {
    if (_current == null || _current!.status != SessionStatus.running) return;
    final next = _current!.elapsedSeconds + 1;
    final targetSeconds = _current!.targetMinutes * 60;
    if (next >= targetSeconds) {
      // ถึงเป้า → ปัดเป็น targetSeconds (ไม่เกิน) + paused + หยุด ticker
      _current = _current!.copyWith(
        elapsedSeconds: targetSeconds,
        status: SessionStatus.paused,
      );
      _ticker?.cancel();
      _ticker = null;
    } else {
      _current = _current!.copyWith(elapsedSeconds: next);
    }
    notifyListeners();
  }

  void _tick() => tick();

  // ---------------------------------------------------------------------------
  // Persistence (SharedPreferences)
  // ---------------------------------------------------------------------------

  /// คีย์ SharedPreferences สำหรับเก็บประวัติ session
  static const String historyKey = 'session_history';

  /// กู้คืนประวัติ session จาก SharedPreferences — เรียกตอนเปิดแอป (ก่อน runApp)
  ///
  /// อ่าน `List<SessionRecord>` กลับมาใน memory; ถ้ายังไม่เคยบันทึกจะเป็น empty
  /// (session ที่ active อยู่ตอนปิดแอปไม่ถูกกู้คืน — ถือว่ายกเลิก ตามขอบเขต Sprint นี้)
  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(historyKey);
    if (json != null) {
      final list = jsonDecode(json) as List;
      _history
        ..clear()
        ..addAll(
          list.map((e) => SessionRecord.fromJson(e as Map<String, Object?>)),
        );
    }
    notifyListeners();
  }

  /// บันทึก `_history` ลง SharedPreferences (เรียกทุกครั้งที่ [finish])
  /// fire-and-forget เหมือน GoalStore — ไม่ await ใน CRUD
  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(_history.map((r) => r.toJson()).toList());
    await prefs.setString(historyKey, json);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _ticker = null;
    super.dispose();
  }
}
