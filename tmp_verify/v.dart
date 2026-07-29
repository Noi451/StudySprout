import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studysprout_app/app/app.dart';
import 'package:studysprout_app/features/goals/domain/goal_store.dart';
import 'package:studysprout_app/features/sessions/domain/session_store.dart';
import 'package:studysprout_app/features/progress/domain/progress_store.dart';

void main() {
  testWidgets('home no overflow at 800x600', (tester) async {
    final errors = <String>[];
    FlutterError.onError = (d) => errors.add(d.exception.toString());
    await tester.pumpWidget(StudySproutApp(goalStore: GoalStore(), sessionStore: SessionStore(), progressStore: ProgressStore()));
    await tester.pumpAndSettle();
    final overflow = errors.where((e) => e.contains('RenderFlex overflowed')).toList();
    print('OVERFLOW_COUNT: ${overflow.length}');
    for (final e in overflow) print('OVERFLOW: $e');
    print('EE_FOUND: ${tester.widgetList<Text>(find.byType(Text)).where((t) => (t.data ?? "") == "ee").length}');
  });
}
