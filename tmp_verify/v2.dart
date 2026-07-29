import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studysprout_app/app/app.dart';
import 'package:studysprout_app/features/goals/domain/goal_store.dart';
import 'package:studysprout_app/features/sessions/domain/session_store.dart';
import 'package:studysprout_app/features/progress/domain/progress_store.dart';

void main() {
  testWidgets('measure heights', (tester) async {
    await tester.pumpWidget(StudySproutApp(goalStore: GoalStore(), sessionStore: SessionStore(), progressStore: ProgressStore()));
    await tester.pumpAndSettle();
    final size = tester.getSize(find.byType(Scaffold).first);
    print('SCAFFOLD: ' + size.toString());
  });
}
