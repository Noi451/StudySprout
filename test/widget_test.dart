// Smoke test พื้นฐานว่าแอป StudySprout build ผ่านโดยไม่พัง
//
// รวมถึงการตรวจสอบเบื้องต้นของ Goal model และ GoalStore (domain layer)

import 'package:flutter_test/flutter_test.dart';

import 'package:studysprout_app/app/app.dart';
import 'package:studysprout_app/features/goals/domain/goal.dart';
import 'package:studysprout_app/features/goals/domain/goal_store.dart';

void main() {
  testWidgets('StudySproutApp สร้างได้โดยไม่พัง', (WidgetTester tester) async {
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
}
