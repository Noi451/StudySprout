// Smoke test พื้นฐานว่าแอป StudySprout build ผ่านโดยไม่พัง
//
// Milestone 2 เป็นเพียง UI ของหน้า Home (ยังไม่มี business logic)
// จึงตรวจแค่ว่า root widget [StudySproutApp] สร้างได้ โดยไม่ผูกกับข้อความใด ๆ
// ใน UI (เพราะข้อความอาจเปลี่ยนได้ตามการออกแบบ)

import 'package:flutter_test/flutter_test.dart';

import 'package:studysprout_app/app/app.dart';

void main() {
  testWidgets('StudySproutApp สร้างได้โดยไม่พัง', (WidgetTester tester) async {
    // สร้าง root widget แล้วรอจน build เสร็จ — ถ้ามี exception จะ fail ทันที
    await tester.pumpWidget(const StudySproutApp());
    await tester.pumpAndSettle();

    expect(find.byType(StudySproutApp), findsOneWidget);
  });
}
