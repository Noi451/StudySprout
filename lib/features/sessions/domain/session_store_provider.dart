import 'package:flutter/widgets.dart';

import 'session_store.dart';

/// ส่ง [SessionStore] ให้ widget ทั้งแอปผ่าน inheritance tree
///
/// ใช้ [InheritedNotifier] ที่รองรับการ rebuild อัตโนมัติเมื่อ [SessionStore]
/// (ซึ่งเป็น [ChangeNotifier]) แจ้งว่ามีการเปลี่ยนแปลง — ทำให้ widget ที่
/// ดึง store ผ่าน [SessionStoreProvider.of] ถูก rebuild เมื่อสถานะ session เปลี่ยน
/// (เช่น เวลาเดินทุกวินาที, กด Pause/Resume/Finish)
///
/// วิธีนี้ไม่ต้องใช้ state management library และไม่ต้องแก้ router —
/// เพียงหุ้ม MaterialApp.router ด้วย widget นี้
class SessionStoreProvider extends InheritedNotifier<SessionStore> {
  const SessionStoreProvider({
    super.key,
    required SessionStore notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// ดึง [SessionStore] จาก context — rebuild อัตโนมัติเมื่อ store เปลี่ยน
  static SessionStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<SessionStoreProvider>();
    assert(provider != null, 'SessionStoreProvider ไม่พบใน widget tree');
    return provider!.notifier!;
  }
}
