// Smoke test พื้นฐานว่าแอป StudySprout build ผ่านโดยไม่พัง
//
// รวมถึงการตรวจสอบเบื้องต้นของ Goal model และ GoalStore (domain layer)

import 'dart:ui' show Size;

import 'package:flutter_test/flutter_test.dart';

import 'package:studysprout_app/app/app.dart';
import 'package:studysprout_app/features/goals/domain/goal.dart';
import 'package:studysprout_app/features/goals/domain/goal_store.dart';
import 'package:studysprout_app/features/sessions/domain/session_status.dart';
import 'package:studysprout_app/features/sessions/domain/session_store.dart';
import 'package:studysprout_app/features/sessions/domain/study_session.dart';

void main() {
  testWidgets('StudySproutApp สร้างได้โดยไม่พัง', (WidgetTester tester) async {
    // แอป target windows/android/web ซึ่งมีความสูงจอมากกว่า test surface
    // เริ่มต้น (800x600) จึงตั้งขนาดจอให้ใกล้เคียงอุปกรณ์จริง เพื่อให้
    // layout ของหน้า Home (ที่มีเนื้อหายาว) ไม่ overflow ใน smoke test
    await tester.binding.setSurfaceSize(const Size(800, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const StudySproutApp());
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
  });

  group('GoalStore', () {
    test('เริ่มต้นว่าง — ไม่มีเป้าหมาย, latestGoal เป็น null', () {
      final store = GoalStore();

      expect(store.goals, isEmpty);
      expect(store.latestGoal, isNull);
    });

    test('add เพิ่มเป้าหมาย แล้ว latestGoal คือตัวล่าสุด', () {
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
      expect(store.latestGoal, latest);
    });

    test('createGoal สร้างเป้าหมายจาก title + targetMinutes', () {
      final store = GoalStore();

      store.createGoal(title: 'Math', targetMinutes: 45);

      expect(store.goals.length, 1);
      expect(store.goals.first.title, 'Math');
      expect(store.goals.first.targetMinutes, 45);
      expect(store.latestGoal, store.goals.first);
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

      expect(notifyCount, 1);
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

      // ตอนเริ่ม elapsedSeconds = 0 → progress = 0
      expect(store.progress, 0.0);
      // progress ต้องอยู่ในช่วง [0, 1] เสมอ (clamped ใน getter)
      expect(store.progress, inInclusiveRange(0.0, 1.0));
    });

    test('tick เพิ่มเวลาทีละ 1 และ progress เพิ่มขึ้น', () {
      final store = SessionStore();
      store.startSession(goal); // targetMinutes = 1 → 60 วินาที

      store.tick();
      store.tick();

      expect(store.elapsedSeconds, 2);
      // 2/60 ≈ 0.033
      expect(store.progress, closeTo(2 / 60, 0.001));
    });

    test('tick หลายครั้งเกินเป้าหมาย → progress clamp ที่ 1.0', () {
      final store = SessionStore();
      store.startSession(goal); // target 60 วินาที

      // tick 70 ครั้ง (เกิน 60)
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
