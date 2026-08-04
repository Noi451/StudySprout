// Smoke test พื้นฐานว่าแอป StudySprout build ผ่านโดยไม่พัง
//
// รวมถึง unit test ของ domain layer:
//  - Goal model (+ JSON round-trip สำหรับ persistence — Sprint 3)
//  - GoalStore (CRUD + active goal + persistence — Sprint 3)
//  - StudySession model + SessionStore (Sprint 2) + Session History (Sprint 4)
//  - ProgressStats (Sprint 4)
//  - XP/Level/TreeStage calculators + ProgressStore (Sprint 5)

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:studysprout_app/app/app.dart';
import 'package:studysprout_app/core/format/duration_formatter.dart';
import 'package:studysprout_app/features/goals/domain/goal.dart';
import 'package:studysprout_app/features/goals/domain/goal_id_generator.dart';
import 'package:studysprout_app/features/goals/domain/goal_store.dart';
import 'package:studysprout_app/features/progress/domain/level_calculator.dart';
import 'package:studysprout_app/features/progress/domain/progress_stats.dart';
import 'package:studysprout_app/features/progress/domain/progress_store.dart';
import 'package:studysprout_app/features/progress/domain/tree_stage.dart';
import 'package:studysprout_app/features/progress/domain/tree_stage_calculator.dart';
import 'package:studysprout_app/features/progress/domain/xp_calculator.dart';
import 'package:studysprout_app/features/sessions/domain/finish_session_service.dart';
import 'package:studysprout_app/features/sessions/domain/session_record.dart';
import 'package:studysprout_app/features/sessions/domain/session_status.dart';
import 'package:studysprout_app/features/sessions/domain/session_store.dart';
import 'package:studysprout_app/features/sessions/domain/study_session.dart';
import 'package:studysprout_app/features/goals/domain/goal_store_provider.dart';
import 'package:studysprout_app/features/sessions/domain/session_store_provider.dart';
import 'package:studysprout_app/features/progress/domain/progress_store_provider.dart';
import 'package:studysprout_app/features/sessions/presentation/timer_page.dart';

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
        progressStore: ProgressStore(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudySproutApp), findsOneWidget);
  });

  // ---------------------------------------------------------------------------
  // Sprint 8 — Responsive smoke tests (ไม่ใช้ package)
  // ตรวจ layout ที่ 3 ขนาด + text scaling โดยไม่ RenderFlex overflow
  // ---------------------------------------------------------------------------
  Future<void> pumpApp(WidgetTester tester, Size size) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('Sprint 8: Compact 390x844 — Home build ไม่ overflow', (tester) async {
    await pumpApp(tester, const Size(390, 844));
    await tester.pumpWidget(
      StudySproutApp(
        goalStore: GoalStore(),
        sessionStore: SessionStore(),
        progressStore: ProgressStore(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StudySproutApp), findsOneWidget);
  });

  testWidgets('Sprint 8: Medium 768x1024 — Home build ไม่ overflow', (tester) async {
    await pumpApp(tester, const Size(768, 1024));
    await tester.pumpWidget(
      StudySproutApp(
        goalStore: GoalStore(),
        sessionStore: SessionStore(),
        progressStore: ProgressStore(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(StudySproutApp), findsOneWidget);
  });

  testWidgets('Sprint 8: Expanded 1440x900 — Home build + NavigationRail', (tester) async {
    await pumpApp(tester, const Size(1440, 900));
    await tester.pumpWidget(
      StudySproutApp(
        goalStore: GoalStore(),
        sessionStore: SessionStore(),
        progressStore: ProgressStore(),
      ),
    );
    await tester.pumpAndSettle();
    // Expanded → NavigationRail แทน bottom nav
    expect(find.byType(NavigationRail), findsOneWidget);
  });

  testWidgets('Sprint 8: text scale 1.6 — Home build ไม่ overflow', (tester) async {
    await pumpApp(tester, const Size(390, 1200));
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.6)),
        child: StudySproutApp(
          goalStore: GoalStore(),
          sessionStore: SessionStore(),
          progressStore: ProgressStore(),
        ),
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

    // ---------------------------------------------------------------------------
    // BUGFIX: Multiple Active Goals — invariant ต้องมี active goal ได้ทีละตัว
    // ---------------------------------------------------------------------------

    test('BUGFIX: setActiveGoal หลายครั้งติดต่อกัน — active เปลี่ยนไปตัวล่าสุดเสมอ',
        () {
      final store = GoalStore();
      store.createGoal(title: 'A', targetMinutes: 10); // → goal_1 (active)
      store.createGoal(title: 'B', targetMinutes: 20); // → goal_2
      store.createGoal(title: 'C', targetMinutes: 30); // → goal_3
      final aId = store.goals[0].id;
      final bId = store.goals[1].id;
      final cId = store.goals[2].id;

      // เปลี่ยน active หลายครั้งติดต่อกัน ไป-กลับ
      store.setActiveGoal(bId);
      expect(store.activeGoalId, bId);
      store.setActiveGoal(cId);
      expect(store.activeGoalId, cId);
      store.setActiveGoal(aId);
      expect(store.activeGoalId, aId);
      store.setActiveGoal(cId);
      expect(store.activeGoalId, cId);

      // invariant: มี active goal ได้เพียงตัวเดียวเสมอ
      final activeIds =
          store.goals.where((g) => g.id == store.activeGoalId).toList();
      expect(activeIds.length, 1);
      expect(store.activeGoal?.id, cId);
    });

    test('BUGFIX: setActiveGoal ตัวเดิมซ้ำ — ไม่ throw, ค่าไม่เปลี่ยน', () {
      final store = GoalStore();
      store.createGoal(title: 'A', targetMinutes: 10); // → active
      store.createGoal(title: 'B', targetMinutes: 20);
      final aId = store.goals[0].id;
      store.setActiveGoal(aId); // เป็น active อยู่แล้ว → no-op

      expect(store.activeGoalId, aId);
    });

    test('BUGFIX: load ข้อมูลที่มี id ซ้ำ (บัคเดิม) → เก็บตัวแรก, active ตัวเดียว',
        () async {
      // จำลองข้อมูลที่เคยเสีย: goal_1 ซ้ำ 2 ตัว, active_goal ชี้ goal_1
      SharedPreferences.setMockInitialValues({
        'goals': '[{"id":"goal_1","title":"A","targetMinutes":10,'
            '"createdAtMs":1753392000000},'
            '{"id":"goal_1","title":"A dup","targetMinutes":20,'
            '"createdAtMs":1753392000000}]',
        'active_goal': 'goal_1',
      });

      final store = GoalStore();
      await store.load();

      // ตัดซ้ำออก → เหลือ goal_1 ตัวเดียว
      expect(store.goals.length, 1);
      expect(store.goals.first.id, 'goal_1');
      expect(store.activeGoal?.id, 'goal_1');
    });

    test('BUGFIX: load ที่มี goals แต่ไม่มี active → ตั้งตัวแรกเป็น active',
        () async {
      SharedPreferences.setMockInitialValues({
        'goals': '[{"id":"goal_1","title":"A","targetMinutes":10,'
            '"createdAtMs":1753392000000},'
            '{"id":"goal_2","title":"B","targetMinutes":20,'
            '"createdAtMs":1753392000000}]',
        // ไม่มี 'active_goal'
      });

      final store = GoalStore();
      await store.load();

      expect(store.goals.length, 2);
      expect(store.activeGoalId, 'goal_1'); // ได้รับการแก้ให้ตั้งตัวแรก
    });

    test('BUGFIX: GoalIdGenerator ไม่ซ้ำหลังลบแล้วสร้างใหม่', () {
      final goals = <Goal>[
        Goal(
          id: 'goal_1',
          title: 'A',
          targetMinutes: 10,
          createdAt: DateTime(2026, 7, 24),
        ),
        Goal(
          id: 'goal_3',
          title: 'C',
          targetMinutes: 30,
          createdAt: DateTime(2026, 7, 24),
        ),
      ];
      // มี goal_1, goal_3 (ลบ goal_2 ไปแล้ว) → ตัวใหม่ต้องเป็น goal_4 ไม่ใช่ goal_3
      expect(GoalIdGenerator.nextIdFor(goals), 'goal_4');
    });

    test('BUGFIX: add ที่ id ซ้ำ → ไม่เพิ่ม (กัน duplicate)', () {
      final store = GoalStore();
      store.add(
        Goal(
          id: 'goal_1',
          title: 'A',
          targetMinutes: 10,
          createdAt: DateTime(2026, 7, 24),
        ),
      );

      // เพิ่ม goal id ซ้ำ → ต้องถูกปฏิเสธ
      store.add(
        Goal(
          id: 'goal_1',
          title: 'A dup',
          targetMinutes: 20,
          createdAt: DateTime(2026, 7, 24),
        ),
      );

      expect(store.goals.length, 1);
      expect(store.goals.first.title, 'A');
    });

    test('BUGFIX: มี goals หลายตัว → active ได้เพียงตัวเดียวเสมอ', () {
      final store = GoalStore();
      store.createGoal(title: 'A', targetMinutes: 10);
      store.createGoal(title: 'B', targetMinutes: 20);
      store.createGoal(title: 'C', targetMinutes: 30);

      // ตั้ง active เป็นตัวกลาง
      store.setActiveGoal(store.goals[1].id);

      // invariant: มี goal ตรง activeGoalId ได้ตัวเดียวเสมอ (ไม่มีทางซ้ำ id)
      final activeCount =
          store.goals.where((g) => g.id == store.activeGoalId).length;
      expect(activeCount, 1);
    });
  });

  group('DurationFormatter', () {
    test('< 60 นาที → "45 min"', () {
      expect(DurationFormatter.fromMinutes(45), '45 min');
    });

    test('60 นาที → "1 hr"', () {
      expect(DurationFormatter.fromMinutes(60), '1 hr');
    });

    test('90 นาที → "1 hr 30 min"', () {
      expect(DurationFormatter.fromMinutes(90), '1 hr 30 min');
    });

    test('120 นาที → "2 hr"', () {
      expect(DurationFormatter.fromMinutes(120), '2 hr');
    });

    test('125 นาที → "2 hr 5 min"', () {
      expect(DurationFormatter.fromMinutes(125), '2 hr 5 min');
    });

    test('0 หรือติดลบ → "0 min" (edge case)', () {
      expect(DurationFormatter.fromMinutes(0), '0 min');
      expect(DurationFormatter.fromMinutes(-5), '0 min');
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
      // Sprint 4: history เป็น SessionRecord (ไม่มี status) → เช็คข้อมูลที่บันทึก
      expect(store.history.first.goalId, goal.id);
      expect(store.history.first.goalTitle, goal.title);
      expect(store.history.first.elapsedSeconds, 0); // ยังไม่ tick
      // targetMinutes = 1 → ต้องเรียน 60 วินาทีถึง completed; 0 วินาที → ยังไม่ครบ
      expect(store.history.first.completed, isFalse);
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

    test('tick หลายครั้งจนถึงเป้า → progress clamp ที่ 1.0 และหยุดที่เป้า (Sprint 6)', () {
      final store = SessionStore();
      store.startSession(goal); // target 60 วินาที

      // tick จนครบเป้า — Sprint 6: tick หยุดที่ targetSeconds (ไม่เกิน)
      for (var i = 0; i < 60; i++) {
        store.tick();
      }

      expect(store.elapsedSeconds, 60); // หยุดที่เป้า ไม่เกิน
      expect(store.progress, 1.0); // clamp ที่ 1.0
      // หยุดเอง → status เป็น paused (รอกด Finish)
      expect(store.status, SessionStatus.paused);
      // tick ต่อหลังครบ → ไม่เพิ่ม (ticker หยุด + status != running)
      store.tick();
      expect(store.elapsedSeconds, 60);
    });

    test('tick ไม่เกิน targetSeconds (Sprint 6) — ต่อให้เรียก 70 ครั้งก็ติด 60', () {
      final store = SessionStore();
      store.startSession(goal); // target 60 วินาที

      for (var i = 0; i < 70; i++) {
        store.tick();
      }

      // Sprint 6: Timer หยุดเองที่เป้า → ไม่เกิน 60 วินาที
      expect(store.elapsedSeconds, 60);
      expect(store.progress, 1.0);
      expect(store.status, SessionStatus.paused);
    });

    test('isGoalReached false ขณะยังไม่ครบเป้า (Sprint 6)', () {
      final store = SessionStore();
      store.startSession(goal); // target 60 วินาที
      store.tick(); // 1 วินาที

      expect(store.isGoalReached, isFalse);
    });

    test('isGoalReached true เมื่อครบเป้า (Sprint 6)', () {
      final store = SessionStore();
      store.startSession(goal); // target 60 วินาที
      for (var i = 0; i < 60; i++) {
        store.tick();
      } // ครบ 60

      expect(store.isGoalReached, isTrue);
    });

    test('isGoalReached false เมื่อไม่มี session (Sprint 6)', () {
      final store = SessionStore(); // ว่าง

      expect(store.isGoalReached, isFalse);
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

    // ---------------------------------------------------------------------------
    // Sprint 4 — Session History & Persistence (SessionRecord)
    // ---------------------------------------------------------------------------

    test('finish ที่เรียนครบเป้า → completed true (Sprint 4)', () {
      final store = SessionStore();
      store.startSession(goal); // targetMinutes = 1 → 60 วินาที
      for (var i = 0; i < 60; i++) {
        store.tick();
      }
      expect(store.elapsedSeconds, 60);

      store.finish();

      expect(store.history.length, 1);
      expect(store.history.first.completed, isTrue);
      expect(store.history.first.elapsedSeconds, 60);
    });

    test('finish ที่ยังไม่ครบเป้า → completed false (Sprint 4)', () {
      final store = SessionStore();
      store.startSession(goal);
      store.tick(); // 1 วินาที

      store.finish();

      expect(store.history.first.completed, isFalse);
    });

    test('finish บันทึก startedAt/endedAt ของ session (Sprint 4)', () {
      final store = SessionStore();
      store.startSession(goal);
      final startedAt = store.current!.startedAt;

      store.finish();

      final record = store.history.first;
      expect(record.startedAt, startedAt);
      // endedAt ต้องไม่ก่อน startedAt (อย่างน้อยเท่ากัน)
      expect(record.endedAt.isAfter(record.startedAt) ||
          record.endedAt == record.startedAt, isTrue);
    });

    test('persist + load round-trip ข้าม instance (Sprint 4)', () async {
      final store = SessionStore();
      store.startSession(goal);
      for (var i = 0; i < 60; i++) {
        store.tick();
      }
      store.finish(); // completed session

      // รอ persist (async, fire-and-forget)
      await Future<void>.delayed(Duration.zero);

      // สร้าง store ใหม่ (เสมือนเปิดแอปใหม่) แล้ว load
      final restored = SessionStore();
      await restored.load();

      expect(restored.history.length, 1);
      expect(restored.history.first.goalId, goal.id);
      expect(restored.history.first.elapsedSeconds, 60);
      expect(restored.history.first.completed, isTrue);
    });

    test('load กู้คืนหลาย session ตามลำดับ (Sprint 4)', () async {
      SharedPreferences.setMockInitialValues({
        'session_history': '[{"goalId":"goal_1","goalTitle":"Math",'
            '"startedAtMs":1753392000000,"endedAtMs":1753392060000,'
            '"elapsedSeconds":60,"completed":true},'
            '{"goalId":"goal_2","goalTitle":"English",'
            '"startedAtMs":1753478400000,"endedAtMs":1753478520000,'
            '"elapsedSeconds":120,"completed":false}]',
      });

      final store = SessionStore();
      await store.load();

      expect(store.history.length, 2);
      expect(store.history[0].goalTitle, 'Math');
      expect(store.history[0].completed, isTrue);
      expect(store.history[1].goalTitle, 'English');
      expect(store.history[1].elapsedSeconds, 120);
      expect(store.history[1].completed, isFalse);
    });
  });

  group('SessionRecord', () {
    test('toJson / fromJson round-trip ไม่สูญเสียข้อมูล (Sprint 4)', () {
      final record = SessionRecord(
        goalId: 'goal_1',
        goalTitle: 'Math',
        startedAt: DateTime(2026, 7, 29, 9, 0),
        endedAt: DateTime(2026, 7, 29, 9, 30),
        elapsedSeconds: 1800,
        completed: true,
      );

      final restored = SessionRecord.fromJson(record.toJson());

      expect(restored.goalId, record.goalId);
      expect(restored.goalTitle, record.goalTitle);
      expect(restored.startedAt, record.startedAt);
      expect(restored.endedAt, record.endedAt);
      expect(restored.elapsedSeconds, record.elapsedSeconds);
      expect(restored.completed, record.completed);
    });
  });

  group('ProgressStats', () {
    // เวลาตายตัวเพื่อทดสอบ: พุธ 29 ก.ค. 2026, 10:00 (weekday = 3 → พุธ)
    final now = DateTime(2026, 7, 29, 10, 0);
    // วันจันทร์ของสัปดาห์นี้ = 27 ก.ค. 2026, 00:00
    final monday = DateTime(2026, 7, 27, 0, 0);

    SessionRecord record({
      required DateTime startedAt,
      int elapsedSeconds = 600,
    }) {
      return SessionRecord(
        goalId: 'goal_1',
        goalTitle: 'Math',
        startedAt: startedAt,
        endedAt: startedAt.add(Duration(seconds: elapsedSeconds)),
        elapsedSeconds: elapsedSeconds,
        completed: true,
      );
    }

    test('history ว่าง → ทุกค่าเป็น 0, recent ว่าง', () {
      final stats = ProgressStats.compute(const [], now);

      expect(stats.todaySeconds, 0);
      expect(stats.weekSeconds, 0);
      expect(stats.totalSeconds, 0);
      expect(stats.sessionCount, 0);
      expect(stats.averageSeconds, 0);
      expect(stats.recent, isEmpty);
    });

    test('total + count + average คำนวณถูก', () {
      final history = [
        record(startedAt: now, elapsedSeconds: 600),  // 10 นาที
        record(startedAt: now, elapsedSeconds: 1200), // 20 นาที
      ];

      final stats = ProgressStats.compute(history, now);

      expect(stats.totalSeconds, 1800);
      expect(stats.sessionCount, 2);
      expect(stats.averageSeconds, 900); // 1800 ~/ 2
    });

    test('todaySeconds นับเฉพาะ session ที่เริ่มวันเดียวกับ now', () {
      final history = [
        record(startedAt: now, elapsedSeconds: 600),                  // วันนี้
        record(startedAt: now.subtract(const Duration(days: 1)), elapsedSeconds: 600), // เมื่อวาน
      ];

      final stats = ProgressStats.compute(history, now);

      expect(stats.todaySeconds, 600); // เฉพาะตัววันนี้
    });

    test('weekSeconds นับตั้งแต่วันจันทร์ของสัปดาห์ปัจจุบัน (ISO)', () {
      final history = [
        record(startedAt: now, elapsedSeconds: 600),                          // พุธ วันนี้
        record(startedAt: monday, elapsedSeconds: 1200),                      // จันทร์ (ในสัปดาห์)
        record(startedAt: monday.subtract(const Duration(days: 1)), elapsedSeconds: 600), // อาทิตย์ก่อนหน้า (นอกสัปดาห์)
      ];

      final stats = ProgressStats.compute(history, now);

      // วันนี้ 600 + จันทร์ 1200 = 1800 (อาทิตย์ก่อนหน้าไม่นับ)
      expect(stats.weekSeconds, 1800);
    });

    test('recent เรียงจากใหม่ไปเก่า และเอาแค่ 5 อันดับแรก', () {
      // สร้าง 7 session ในวันต่าง ๆ (เก่า → ใหม่)
      final history = [
        for (var i = 6; i >= 0; i--)
          record(startedAt: now.subtract(Duration(days: i)), elapsedSeconds: 60),
      ];

      final stats = ProgressStats.compute(history, now);

      expect(stats.recent.length, 5);
      // ตัวแรกต้องเป็นใหม่สุด = วันนี้ (now)
      expect(stats.recent.first.startedAt, now);
    });
  });

  // ---------------------------------------------------------------------------
  // Sprint 5 — XP, Level & Tree System
  // ---------------------------------------------------------------------------

  group('XpCalculator', () {
    test('1 นาที = 1 XP (คำนวณจาก elapsedSeconds ปัดเป็นนาที)', () {
      // 10 min
      expect(XpCalculator.fromSeconds(600), 10);
      // 30 min
      expect(XpCalculator.fromSeconds(1800), 30);
      // 125 min
      expect(XpCalculator.fromSeconds(7500), 125);
    });

    test('ปัดวินาทีเศษ (90s → 2 XP เพราะ round)', () {
      // 90 วินาที = 1.5 นาที → round = 2
      expect(XpCalculator.fromSeconds(90), 2);
    });

    test('ค่าติดลบ/ศูนย์ → 0 XP', () {
      expect(XpCalculator.fromSeconds(0), 0);
      expect(XpCalculator.fromSeconds(-10), 0);
    });
  });

  group('LevelCalculator', () {
    test('100 XP ต่อ Level — Level derive จาก totalXp', () {
      expect(LevelCalculator.fromXp(0), 1);
      expect(LevelCalculator.fromXp(99), 1);
      expect(LevelCalculator.fromXp(100), 2);
      expect(LevelCalculator.fromXp(199), 2);
      expect(LevelCalculator.fromXp(200), 3);
      expect(LevelCalculator.fromXp(999), 10);
    });

    test('ค่าติดลบ → Level 1', () {
      expect(LevelCalculator.fromXp(-50), 1);
    });

    test('levelStartXp / levelEndXp', () {
      expect(LevelCalculator.levelStartXp(1), 0);
      expect(LevelCalculator.levelStartXp(2), 100);
      expect(LevelCalculator.levelStartXp(10), 900);
      expect(LevelCalculator.levelEndXp(1), 100);
      expect(LevelCalculator.levelEndXp(2), 200);
      expect(LevelCalculator.levelEndXp(10), 1000);
    });

    test('xpIntoCurrentLevel — XP ในเลเวลปัจจุบัน (reset ทุก 100)', () {
      // totalXp = 130, level = 2 → 30
      expect(LevelCalculator.xpIntoCurrentLevel(130), 30);
      // totalXp = 100, level = 2 → 0 (เพิ่งเลื่อนเลเวล)
      expect(LevelCalculator.xpIntoCurrentLevel(100), 0);
      // totalXp = 250, level = 3 → 50
      expect(LevelCalculator.xpIntoCurrentLevel(250), 50);
    });

    test('progressIntoCurrentLevel — สัดส่วน 0.0–1.0', () {
      // 30/100 = 0.30
      expect(LevelCalculator.progressIntoCurrentLevel(130), closeTo(0.30, 0.001));
      // 100 = เลื่อนเลเวล → 0.0
      expect(LevelCalculator.progressIntoCurrentLevel(100), closeTo(0.0, 0.001));
    });
  });

  group('TreeStageCalculator', () {
    test('Level 1 → Seed', () {
      expect(TreeStageCalculator.fromLevel(1), TreeStage.seed);
    });

    test('Level 2 → Sprout', () {
      expect(TreeStageCalculator.fromLevel(2), TreeStage.sprout);
    });

    test('Level 3 → Small Plant', () {
      expect(TreeStageCalculator.fromLevel(3), TreeStage.smallPlant);
    });

    test('Level 5 → Young Tree', () {
      expect(TreeStageCalculator.fromLevel(5), TreeStage.youngTree);
    });

    test('Level 8 → Tree', () {
      expect(TreeStageCalculator.fromLevel(8), TreeStage.tree);
    });

    test('Level 12 → Big Tree', () {
      expect(TreeStageCalculator.fromLevel(12), TreeStage.bigTree);
    });

    test('ค่าระหว่างช่วงใช้ระยะล่าสุดที่ผ่านเกณฑ์', () {
      // Level 4 → ยังไม่ถึง 5 → Small Plant
      expect(TreeStageCalculator.fromLevel(4), TreeStage.smallPlant);
      // Level 10 → ยังไม่ถึง 12 → Tree
      expect(TreeStageCalculator.fromLevel(10), TreeStage.tree);
      // Level 20 → เกิน 12 → Big Tree
      expect(TreeStageCalculator.fromLevel(20), TreeStage.bigTree);
    });

    test('TreeStage มี label + emoji', () {
      expect(TreeStage.seed.label, 'Seed');
      expect(TreeStage.seed.emoji, '🌱');
      expect(TreeStage.bigTree.label, 'Big Tree');
    });
  });

  group('ProgressStore', () {
    test('เริ่มต้น — totalXp 0, Level 1, TreeStage Seed', () {
      final store = ProgressStore();

      expect(store.totalXp, 0);
      expect(store.level, 1);
      expect(store.treeStage, TreeStage.seed);
      expect(store.currentLevelXp, 0);
    });

    test('addXp เพิ่ม XP และแจ้ง listener', () {
      final store = ProgressStore();
      var notifyCount = 0;
      store.addListener(() => notifyCount++);

      store.addXp(50);

      expect(store.totalXp, 50);
      expect(store.level, 1); // ยังไม่ถึง 100
      expect(notifyCount, greaterThanOrEqualTo(1));
    });

    test('addXp ทำให้เลื่อนเลเวล (Level Up)', () {
      final store = ProgressStore();
      store.addXp(100);

      expect(store.totalXp, 100);
      expect(store.level, 2);
      expect(store.treeStage, TreeStage.sprout); // Level 2 → Sprout
      expect(store.currentLevelXp, 0); // เพิ่งเลื่อน → 0
    });

    test('addXp หลายครั้ง → Multiple Level Up', () {
      final store = ProgressStore();
      // 300 XP → Level 4 (200-299 = L3, 300-399 = L4)
      store.addXp(300);

      expect(store.totalXp, 300);
      expect(store.level, 4);
      expect(store.treeStage, TreeStage.smallPlant); // Level 4 → Small Plant
      expect(store.currentLevelXp, 0); // 300 = ตรงขอบเลเวล 4 → 0
    });

    test('addXp ค่าติดลบ/ศูนย์ → ไม่เปลี่ยน', () {
      final store = ProgressStore();
      store.addXp(50);
      store.addXp(0);
      store.addXp(-10);

      expect(store.totalXp, 50);
    });

    test('persistence — load กู้คืน totalXp แล้ว derive level/treeStage ถูก', () async {
      SharedPreferences.setMockInitialValues({
        'progress_total_xp': 230,
      });

      final store = ProgressStore();
      await store.load();

      expect(store.totalXp, 230);
      expect(store.level, 3); // 200-299 = Level 3
      expect(store.treeStage, TreeStage.smallPlant); // Level 3 → Small Plant
      expect(store.currentLevelXp, 30); // 230 - 200
    });

    test('persistence round-trip ข้าม instance (addXp → สร้างใหม่ → load)', () async {
      final store = ProgressStore();
      store.addXp(150); // Level 2, currentLevelXp = 50

      // รอ persist (async, fire-and-forget)
      await Future<void>.delayed(Duration.zero);

      // สร้าง store ใหม่ (เสมือนเปิดแอปใหม่) แล้ว load
      final restored = ProgressStore();
      await restored.load();

      expect(restored.totalXp, 150);
      expect(restored.level, 2);
      expect(restored.treeStage, TreeStage.sprout);
    });

    test('XP calculation integration — finish session 30 min → +30 XP', () {
      // จำลอง flow: XpCalculator คำนวณจาก elapsedSeconds แล้วส่งให้ addXp
      final store = ProgressStore();
      final xpGain = XpCalculator.fromSeconds(1800); // 30 min

      store.addXp(xpGain);

      expect(xpGain, 30);
      expect(store.totalXp, 30);
      expect(store.level, 1); // ยังไม่ถึง 100
    });
  });

  // ---------------------------------------------------------------------------
  // Sprint 5.1 — Finish Flow Hardening (FinishSessionService, exactly-once)
  // ---------------------------------------------------------------------------

  group('FinishSessionService', () {
    final goal = Goal(
      id: 'goal_1',
      title: 'Math',
      targetMinutes: 60, // 60 นาที = 3600 วินาที
      createdAt: DateTime(2026, 7, 25),
    );

    test('commit บันทึก history และ XP อย่างละ 1 ครั้ง', () {
      final sessionStore = SessionStore();
      final progressStore = ProgressStore();
      sessionStore.startSession(goal);
      // เรียน 30 นาที = 1800 วินาที = 30 XP
      for (var i = 0; i < 1800; i++) {
        sessionStore.tick();
      }

      final result = const FinishSessionService().commit(
        sessionStore,
        progressStore,
      );

      expect(result, isNotNull);
      expect(sessionStore.history.length, 1); // history 1 ครั้ง
      expect(progressStore.totalXp, 30); // XP 1 ครั้ง = 30
      expect(result!.xpGained, 30);
    });

    test('commit ซ้ำครั้งที่ 2 → คืน null, ไม่มี reward ซ้ำ (exactly once)', () {
      final sessionStore = SessionStore();
      final progressStore = ProgressStore();
      sessionStore.startSession(goal);
      for (var i = 0; i < 1800; i++) {
        sessionStore.tick();
      }

      const service = FinishSessionService();
      service.commit(sessionStore, progressStore);
      // ครั้งที่ 2 — current เป็น null แล้ว
      final result2 = service.commit(sessionStore, progressStore);

      expect(result2, isNull);
      expect(sessionStore.history.length, 1); // ไม่เพิ่ม
      expect(progressStore.totalXp, 30); // ไม่เพิ่ม
    });

    test('ไม่มี active session → commit คืน null และไม่เพิ่ม XP', () {
      final sessionStore = SessionStore(); // ว่าง
      final progressStore = ProgressStore();

      final result = const FinishSessionService().commit(
        sessionStore,
        progressStore,
      );

      expect(result, isNull);
      expect(progressStore.totalXp, 0);
      expect(sessionStore.history, isEmpty);
    });

    test('didLevelUp false เมื่อ XP ยังไม่ข้าม level (+30 ที่ total 0)', () {
      final sessionStore = SessionStore();
      final progressStore = ProgressStore();
      sessionStore.startSession(goal);
      for (var i = 0; i < 1800; i++) {
        sessionStore.tick();
      } // 30 XP → total 30 → ยัง Level 1

      final result = const FinishSessionService().commit(
        sessionStore,
        progressStore,
      )!;

      expect(result.didLevelUp, isFalse);
      expect(result.resultingLevel, 1);
    });

    test('didLevelUp true เมื่อข้าม level (previous 90 + เรียน 60 นาที)', () {
      final sessionStore = SessionStore();
      final progressStore = ProgressStore();
      // ตั้ง previous total = 90 (Level 1) — เพิ่ม XP ทีละนิดจนได้ 90
      progressStore.addXp(90);
      expect(progressStore.level, 1);

      // สร้าง session ที่เรียน 60 นาที = 3600 วินาที = 60 XP → total 150 → Level 2
      sessionStore.startSession(goal);
      for (var i = 0; i < 3600; i++) {
        sessionStore.tick();
      }

      final result = const FinishSessionService().commit(
        sessionStore,
        progressStore,
      )!;

      expect(result.didLevelUp, isTrue);
      expect(result.resultingLevel, 2);
      expect(result.resultingTotalXp, 150);
    });

    test('reward snapshot แสดง resulting level/tree stage ถูกต้อง', () {
      final sessionStore = SessionStore();
      final progressStore = ProgressStore();
      // previous = 100 → Level 2, เรียน 60 นาที = 60 XP → total 160 → Level 2 (ยัง)
      progressStore.addXp(100);
      sessionStore.startSession(goal);
      for (var i = 0; i < 3600; i++) {
        sessionStore.tick();
      }

      final result = const FinishSessionService().commit(
        sessionStore,
        progressStore,
      )!;

      // snapshot ต้องตรง store หลัง commit
      expect(result.resultingTotalXp, progressStore.totalXp);
      expect(result.resultingLevel, progressStore.level);
      expect(result.resultingTreeStage, progressStore.treeStage);
      // Level 2 → Sprout
      expect(result.resultingTreeStage, TreeStage.sprout);
      expect(result.didLevelUp, isFalse); // 100→160 ยัง Level 2
    });

    test('snapshot เป็น immutable — แม้ store เปลี่ยนภายหลังค่าใน snapshot ไม่เปลี่ยน', () {
      final sessionStore = SessionStore();
      final progressStore = ProgressStore();
      sessionStore.startSession(goal);
      for (var i = 0; i < 1800; i++) {
        sessionStore.tick();
      }

      final result = const FinishSessionService().commit(
        sessionStore,
        progressStore,
      )!;
      final snapshotLevel = result.resultingLevel;
      final snapshotTotalXp = result.resultingTotalXp;

      // จำลอง store เปลี่ยนภายหลัง (เช่น session ใหม่)
      progressStore.addXp(500);

      // snapshot ยังเดิม
      expect(result.resultingLevel, snapshotLevel);
      expect(result.resultingTotalXp, snapshotTotalXp);
    });

    test('commit เซสชัน 0 วินาที → xpGained 0, didLevelUp false', () {
      final sessionStore = SessionStore();
      final progressStore = ProgressStore();
      sessionStore.startSession(goal);
      // ไม่ tick (0 วินาที)

      final result = const FinishSessionService().commit(
        sessionStore,
        progressStore,
      )!;

      expect(result.xpGained, 0);
      expect(result.resultingTotalXp, 0);
      expect(result.didLevelUp, isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // Sprint 6 — Early Finish confirmation (TimerPage flow)
  // ---------------------------------------------------------------------------

  group('TimerPage — Early Finish (Sprint 6)', () {
    final goal = Goal(
      id: 'goal_1',
      title: 'Math',
      targetMinutes: 1, // 60 วินาที
      createdAt: DateTime(2026, 7, 29),
    );

    /// สร้าง widget tree ที่มี Provider ครบเหมือนในแอป + เปิด TimerPage เป็น home
    Widget buildHarness(SessionStore sessionStore, ProgressStore progressStore) {
      return GoalStoreProvider(
        notifier: GoalStore(),
        child: SessionStoreProvider(
          notifier: sessionStore,
          child: ProgressStoreProvider(
            notifier: progressStore,
            child: MaterialApp(
              home: TimerPage(key: Key('timer_page')),
            ),
          ),
        ),
      );
    }

    testWidgets('ยังไม่ครบเป้า → กด Finish ขึ้น EarlyFinishDialog', (tester) async {
      final sessionStore = SessionStore();
      final progressStore = ProgressStore();
      // startSession เริ่ม Timer.periodic จริง → ต้อง dispose ปิด ticker ภายใน test
      // (dispose ใน body ไม่ใช่ addTearDown เพราะ binding ตรวจ "Timer pending" ก่อน tearDown)
      sessionStore.startSession(goal);
      sessionStore.tick(); // 1 วินาที (ยังไม่ครบ 60)

      await tester.pumpWidget(buildHarness(sessionStore, progressStore));
      await tester.pumpAndSettle();

      // กด Finish
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // ต้องขึ้น dialog ยืนยัน (ไม่ใช่ dialog สรุปผล)
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text("You haven't reached your study goal yet."), findsOneWidget);
      expect(find.text('Continue Studying'), findsOneWidget);
      expect(find.text('Finish Anyway'), findsOneWidget);
      // ยังไม่ commit → ไม่มี history, ไม่มี XP
      expect(sessionStore.history, isEmpty);
      expect(progressStore.totalXp, 0);

      sessionStore.dispose(); // ปิด ticker ก่อนตรวจ pending timer
    });

    testWidgets('เลือก Continue Studying → ปิด dialog, session ยัง active, ไม่ commit',
        (tester) async {
      final sessionStore = SessionStore();
      final progressStore = ProgressStore();
      sessionStore.startSession(goal);
      sessionStore.tick();

      await tester.pumpWidget(buildHarness(sessionStore, progressStore));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // Continue Studying
      await tester.tap(find.text('Continue Studying'));
      await tester.pumpAndSettle();

      // dialog ยืนยันปิดแล้ว และไม่มี dialog สรุปผล
      expect(find.text('Are you sure?'), findsNothing);
      expect(find.text('Study Complete'), findsNothing);
      // session ยัง active — ไม่ได้ commit
      expect(sessionStore.isActive, isTrue);
      expect(sessionStore.history, isEmpty);
      expect(progressStore.totalXp, 0);

      sessionStore.dispose();
    });

    testWidgets('เลือก Finish Anyway → commit + ขึ้น dialog สรุปผล', (tester) async {
      final sessionStore = SessionStore();
      final progressStore = ProgressStore();
      sessionStore.startSession(goal);
      sessionStore.tick(); // 1 วินาที = 1 XP (round จาก 1s → 0 นาที... ดู XpCalculator)

      await tester.pumpWidget(buildHarness(sessionStore, progressStore));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // Finish Anyway → commit
      await tester.tap(find.text('Finish Anyway'));
      await tester.pumpAndSettle();

      // ขึ้น dialog สรุปผล
      expect(find.text('Study Complete'), findsOneWidget);
      // commit แล้ว → history 1, current เป็น null
      expect(sessionStore.history.length, 1);
      expect(sessionStore.isActive, isFalse);

      sessionStore.dispose();
    });

    testWidgets('ครบเป้าแล้ว → กด Finish ไม่ถาม ขึ้น dialog สรุปผลเลย', (tester) async {
      final sessionStore = SessionStore();
      final progressStore = ProgressStore();
      sessionStore.startSession(goal);
      for (var i = 0; i < 60; i++) {
        sessionStore.tick();
      } // ครบ 60 วินาที (เป้า) → isGoalReached = true
      expect(sessionStore.isGoalReached, isTrue);

      await tester.pumpWidget(buildHarness(sessionStore, progressStore));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // ห้ามถามยืนยัน — ขึ้น dialog สรุปผลโดยตรง
      expect(find.text('Are you sure?'), findsNothing);
      expect(find.text('Study Complete'), findsOneWidget);
      expect(sessionStore.history.length, 1);

      sessionStore.dispose();
    });
  });

  group('DurationFormatter.fromSeconds', () {
    test('0 วินาที → "0 min"', () {
      expect(DurationFormatter.fromSeconds(0), '0 min');
    });

    test('< 60 วินาที → ปัดเป็นนาที (90s → "2 min")', () {
      expect(DurationFormatter.fromSeconds(90), '2 min');
    });

    test('3600 วินาที → "1 hr"', () {
      expect(DurationFormatter.fromSeconds(3600), '1 hr');
    });

    test('5400 วินาที → "1 hr 30 min"', () {
      expect(DurationFormatter.fromSeconds(5400), '1 hr 30 min');
    });
  });
}
