import 'package:flutter/widgets.dart';

import 'goal_store.dart';

/// ส่ง [GoalStore] ให้ widget ทั้งแอปผ่าน inheritance tree
///
/// ใช้ [InheritedNotifier] ที่รองรับการ rebuild อัตโนมัติเมื่อ [GoalStore]
/// (ซึ่งเป็น [ChangeNotifier]) แจ้งว่ามีการเปลี่ยนแปลง — ทำให้ widget ที่
/// ดึง store ผ่าน [GoalStoreProvider.of] ถูก rebuild เมื่อรายการเป้าหมายเปลี่ยน
///
/// วิธีนี้ไม่ต้องใช้ state management library (Provider/Riverpod/Bloc)
/// และไม่ต้องแก้ router — เพียงหุ้ม MaterialApp.router ด้วย widget นี้
class GoalStoreProvider extends InheritedNotifier<GoalStore> {
  const GoalStoreProvider({
    super.key,
    required GoalStore notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// ดึง [GoalStore] จาก context — rebuild อัตโนมัติเมื่อ store เปลี่ยน
  static GoalStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<GoalStoreProvider>();
    assert(provider != null, 'GoalStoreProvider ไม่พบใน widget tree');
    return provider!.notifier!;
  }
}
