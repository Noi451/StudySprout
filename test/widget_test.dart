// สมมติฐานพื้นฐานว่าแอป StudySprout สร้างได้โดยไม่พัง
//
// milestone นี้ยังไม่มี business logic จึงมีแค่ smoke test ว่า
// root widget [StudySproutApp] build ผ่าน

import 'package:flutter_test/flutter_test.dart';

import 'package:studysprout_app/app/app.dart';

void main() {
  testWidgets('StudySproutApp สร้างได้โดยไม่พัง', (WidgetTester tester) async {
    await tester.pumpWidget(const StudySproutApp());

    // แท็บแรก (Home) ควรมีข้อความ "Home" แสดงอยู่
    expect(find.text('Home'), findsWidgets);
  });
}
