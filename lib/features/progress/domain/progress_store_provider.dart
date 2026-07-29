import 'package:flutter/widgets.dart';

import 'progress_store.dart';

/// ส่ง [ProgressStore] ให้ widget ทั้งแอปผ่าน inheritance tree
///
/// ใช้ [InheritedNotifier] ที่รองรับการ rebuild อัตโนมัติเมื่อ [ProgressStore]
/// (ซึ่งเป็น [ChangeNotifier]) แจ้งว่ามีการเปลี่ยนแปลง — ทำให้ XpCard/TreeSection
/// บน Home ถูก rebuild เมื่อ XP/Level/TreeStage เปลี่ยน (หลัง Finish Session)
///
/// Sprint 5: ลอก pattern [GoalStoreProvider]/[SessionStoreProvider]
class ProgressStoreProvider extends InheritedNotifier<ProgressStore> {
  const ProgressStoreProvider({
    super.key,
    required ProgressStore notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// ดึง [ProgressStore] จาก context — rebuild อัตโนมัติเมื่อ store เปลี่ยน
  static ProgressStore of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<ProgressStoreProvider>();
    assert(provider != null, 'ProgressStoreProvider ไม่พบใน widget tree');
    return provider!.notifier!;
  }
}
