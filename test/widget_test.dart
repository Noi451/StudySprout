// Smoke test พื้นฐานว่าแอป StudySprout build ผ่านโดยไม่พัง
//
// รวมถึง unit test ของ domain layer:
//  - Goal model (+ JSON round-trip สำหรับ persistence — Sprint 3)
//  - GoalStore (CRUD + active goal + persistence — Sprint 3)
//  - StudySession model + SessionStore (Sprint 2)

import 'dart:ui' show Size;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studysprout_app/app/app.dart';
import 'package:studysprout_app/features/goals/domain/goal.dart';
import 'package:studysprout_app/features/goals/domain/goal_store.dart';
import 'package:studysprout_app/features/sessions/domain/session_status.dart';
import 'package:studysprout_app/features/sessions/domain/session_store.dart';
import 'package:studysprout_app/features/sessions/domain/study_session.dart';

void main() {
  // SharedPreferences เป็น plugin — ต้อง mock ก่อนใช้ใน unit test
  // (ตั้งค่าเริ่มต้นเป็น empty map ก่อนแต่ละ test ที่ใช้ GoalStore)
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('StudySproutApp สร้างได้โดยไม่พัง', (WidgetTester tester) async {
    // แอป target windows/android/web ซึ่งมีความสูงจอมากกว่า test surface
    // เริ่มต้น (800x600) จึงตั้งขนาดจอให้ใกล้เคียงอุปกรณ์จริง เพื่อให้
    // layout ของหน้า Home (ที่มีเนื้อหายาว) ไม่ overflow ใน smoke test
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      StudySproutApp(
        goalStore: GoalStore(),
        sessionStore: SessionStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudySproutApp), findsOneWidget);
  });

  group('Goal', () {
    test('สร้าง Goal พร้อมฟิลด์ครบถ้วน', () {
      final goal = Goal(
        id: 'goal_1',
        title: 'Read a book',
        targetMinutes: 30,
        createdAt: DateTime(2026, 7, 24),
      );

      expect(goal.id, 'goal_1');
      expect(goal.title, 'Read a book');
      expect(goal.targetMinutes, 30);
      expect(goal.createdAt, DateTime(2026, 7, 24));
    });

    test('toJson / fromJson round-trip ไม่สูญเสียข้อมูล (Sprint 3)', () {
      final goal = Goal(
        id: 'goal_1',
        title: 'Read a book',
        targetMinutes: 45,
        createdAt: DateTime(2026, 7, 24, 9, 30),
      );

      final restored = Goal.fromJson(goal.toJson());

      expect(restored.id, goal.id);
      expect(restored.title, goal.title);
      expect(restored.targetMinutes, goal.targetMinutes);
      expect(restored.createdAt, goal.createdAt);
    });
  });

  group('GoalStore', () {
    test('เริ่มต้นว่าง — ไม่มีเป้าหมาย, activeGoal เป็น null', () {
      final store = GoalStore();

      expect(store.goals, isEmpty);
      expect(store.activeGoal, isNull);
      expect(store.hasActiveGoal, isFalse);
    });

    test('add เพิ่มเป้าหมาย', () {
      final store = GoalStore();
      final first = Goal(
        id: 'goal_1',
        title: 'A',
        targetMinutes: 10,
        createdAt: DateTime(2026, 7, 24, 9),
      );
      final latest = Goal(
        id: 'goal_2',
        title: 'B',
        targetMinutes: 20,
        createdAt: DateTime(2026, 7, 24, 10),
      );

      store.add(first);
      store.add(latest);

      expect(store.goals.length, 2);
    });

    test('createGoal สร้างเป้าหมาย และตั้งเป็น active อัตโนมัติเมื่อเป็นตัวแรก', () {
      final store = GoalStore();

      store.createGoal(title: 'Math', targetMinutes: 45);

      expect(store.goals.length, 1);
      expect(store.goals.first.title, 'Math');
      expect(store.goals.first.targetMinutes, 45);
      // เป้าหมายแรก → active อัตโนมัติ
      expect(store.activeGoal, store.goals.first);
      expect(store.hasActiveGoal, isTrue);
    });

    test('createGoal ตัวที่สองไม่แย่ง active', () {
      final store = GoalStore();
      store.createGoal(title: 'Math', targetMinutes: 45);
      final firstActive = store.activeGoal;

      store.createGoal(title: 'English', targetMinutes: 30);

      expect(store.goals.length, 2);
      expect(store.activeGoal, firstActive); // ยังเป็นตัวแรก
    });

    test('updateGoal แก้ไข title/targetMinutes คง id และ createdAt', () {
      final store = GoalStore();
      store.createGoal(title: 'Math', targetMinutes: 45);
      final id = store.goals.first.id;
      final createdAt = store.goals.first.createdAt;

      final ok = store.updateGoal(
        id: id,
        title: 'Math 2',
        targetMinutes: 60,
      );

      expect(ok, isTrue);
      expect(store.goals.first.title, 'Math 2');
      expect(store.goals.first.targetMinutes, 60);
      expect(store.goals.first.id, id);
      expect(store.goals.first.createdAt, createdAt);
    });

    test('updateGoal คืน false เมื่อ id ไม่มี', () {
      final store = GoalStore();

      expect(
        store.updateGoal(id: 'nope', title: 'X', targetMinutes: 1),
        isFalse,
      );
    });

    test('setActiveGoal เปลี่ยน active goal', () {
      final store = GoalStore();
      store.createGoal(title: 'A', targetMinutes: 10);
      store.createGoal(title: 'B', targetMinutes: 20);
      final bId = store.goals.last.id;

      store.setActiveGoal(bId);

      expect(store.activeGoal?.id, bId);
    });

    test('setActiveGoal ไม่ทำอะไรเมื่อ id ไม่มีใน list', () {
      final store = GoalStore();
      store.createGoal(title: 'A', targetMinutes: 10);
      final before = store.activeGoalId;

      store.setActiveGoal('not_exist');

      expect(store.activeGoalId, before);
    });

    test('deleteGoal ลบและย้าย active ไปตัวแรกที่เหลือ', () {
      final store = GoalStore();
      store.createGoal(title: 'A', targetMinutes: 10); // → active
      store.createGoal(title: 'B', targetMinutes: 20);
      final aId = store.goals.first.id;
      final bId = store.goals.last.id;

      store.deleteGoal(aId); // ลบตัว active

      expect(store.goals.length, 1);
      expect(store.activeGoal?.id, bId); // active ย้ายไป B
    });

    test('deleteGoal ตัวสุดท้าย → active เป็น null', () {
      final store = GoalStore();
      store.createGoal(title: 'A', targetMinutes: 10);
      final aId = store.goals.first.id;

      store.deleteGoal(aId);

      expect(store.goals, isEmpty);
      expect(store.activeGoal, isNull);
    });

    test('notifyListeners ถูกเรียกเมื่อ add', () {
      final store = GoalStore();
      var notifyCount = 0;
      store.addListener(() => notifyCount++);

      store.add(
        Goal(
          id: 'goal_1',
          title: 'A',
          targetMinutes: 10,
          createdAt: DateTime(2026, 7, 24),
        ),
      );

      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('load กู้คืน goals และ active จาก SharedPreferences (Sprint 3)', () async {
      // เตรียมข้อมูลใน mock SharedPreferences เสมือนเคยบันทึกไว้
      SharedPreferences.setMockInitialValues({
        'goals': '[{"id":"goal_1","title":"Math","targetMinutes":45,'
            '"createdAtMs":1753392000000}]',
        'active_goal': 'goal_1',
      });

      final store = GoalStore();
      await store.load();

      expect(store.goals.length, 1);
      expect(store.goals.first.title, 'Math');
      expect(store.activeGoal?.id, 'goal_1');
    });

    test('persist + load round-trip ข้าน instance (Sprint 3)', () async {
      final store = GoalStore();
      store.createGoal(title: 'Math', targetMinutes: 45);
      store.createGoal(title: 'English', targetMinutes: 30);
      final mathId = store.goals.first.id;
      store.setActiveGoal(mathId);

      // รอให้การ persist (async) เสร็จสมบูรณ์ก่อนสร้าง store ใหม่
      // (GoalStore เรียก _persist() แบบ fire-and-forget จาก CRUD methods)
      await Future<void>.delayed(Duration.zero);

      // สร้าง store ใหม่ (เสมือนเปิดแอปใหม่) แล้ว load
      final restored = GoalStore();
      await restored.load();

      expect(restored.goals.length, 2);
      expect(restored.goals.first.title, 'Math');
      expect(restored.activeGoal?.id, mathId);
    });
  });

  group('StudySession', () {
    test('สร้าง StudySession พร้อมฟิลด์ครบถ้วน', () {
      final session = StudySession(
        id: 'session_1',
        goalId: 'goal_1',
        goalTitle: 'Read a book',
        targetMinutes: 30,
        startedAt: DateTime(2026, 7, 25, 9),
        elapsedSeconds: 120,
        status: SessionStatus.running,
      );

      expect(session.id, 'session_1');
      expect(session.goalId, 'goal_1');
      expect(session.goalTitle, 'Read a book');
      expect(session.targetMinutes, 30);
      expect(session.elapsedSeconds, 120);
      expect(session.status, SessionStatus.running);
    });
  });

  group('SessionStore', () {
    final goal = Goal(
      id: 'goal_1',
      title: 'Math',
      targetMinutes: 1,
      createdAt: DateTime(2026, 7, 25),
    );

    test('เริ่มต้นว่าง — current เป็น null, history ว่าง, isActive false', () {
      final store = SessionStore();

      expect(store.current, isNull);
      expect(store.history, isEmpty);
      expect(store.isActive, isFalse);
      expect(store.elapsedSeconds, 0);
    });

    test('startSession สร้าง session running และผูกกับ goal', () {
      final store = SessionStore();

      store.startSession(goal);

      expect(store.current, isNotNull);
      expect(store.isActive, isTrue);
      expect(store.status, SessionStatus.running);
      expect(store.current!.goalId, goal.id);
      expect(store.current!.goalTitle, goal.title);
      expect(store.current!.targetMinutes, goal.targetMinutes);
      expect(store.elapsedSeconds, 0);
    });

    test('pause → paused, resume → running', () {
      final store = SessionStore();
      store.startSession(goal);

      store.pause();
      expect(store.status, SessionStatus.paused);

      store.resume();
      expect(store.status, SessionStatus.running);
    });

    test('finish → completed, current เป็น null, history เพิ่ม 1', () {
      final store = SessionStore();
      store.startSession(goal);

      store.finish();

      expect(store.current, isNull);
      expect(store.isActive, isFalse);
      expect(store.history.length, 1);
      expect(store.history.first.status, SessionStatus.completed);
    });

    test('notifyListeners ถูกเรียกเมื่อ startSession', () {
      final store = SessionStore();
      var notifyCount = 0;
      store.addListener(() => notifyCount++);

      store.startSession(goal);

      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('progress เริ่มที่ 0 และอยู่ใน [0, 1]', () {
      final store = SessionStore();
      store.startSession(goal);

      expect(store.progress, 0.0);
      expect(store.progress, inInclusiveRange(0.0, 1.0));
    });

    test('tick เพิ่มเวลาทีละ 1 และ progress เพิ่มขึ้น', () {
      final store = SessionStore();
      store.startSession(goal); // targetMinutes = 1 → 60 วินาที

      store.tick();
      store.tick();

      expect(store.elapsedSeconds, 2);
      expect(store.progress, closeTo(2 / 60, 0.001));
    });

    test('tick หลายครั้งเกินเป้าหมาย → progress clamp ที่ 1.0', () {
      final store = SessionStore();
      store.startSession(goal); // target 60 วินาที

      for (var i = 0; i < 70; i++) {
        store.tick();
      }

      expect(store.elapsedSeconds, 70);
      expect(store.progress, 1.0); // clamp ไม่เกิน 1.0
    });

    test('pause แล้ว tick ไม่เพิ่มเวลา', () {
      final store = SessionStore();
      store.startSession(goal);
      store.tick();
      expect(store.elapsedSeconds, 1);

      store.pause();
      store.tick(); // paused → ไม่ควรเพิ่ม

      expect(store.elapsedSeconds, 1);
    });
  });
}
