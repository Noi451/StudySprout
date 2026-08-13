import 'package:flutter/widgets.dart';

import 'evidence_verification_store.dart';

/// ส่ง [EvidenceVerificationStore] ให้ widget ใน subtree ผ่าน inheritance tree
///
/// Sprint 9A: เป็น feature แยก/ทดลอง — store สร้างเฉพาะหน้า ไม่ได้ส่งข้ามแท็บ
/// แต่ใช้ InheritedNotifier ตาม pattern โปรเจกต์ เพื่อให้ widget ย่อย rebuild
/// อัตโนมัติเมื่อสถานะเปลี่ยน (idle/verifying/passed/rejected/error)
class EvidenceVerificationStoreProvider
    extends InheritedNotifier<EvidenceVerificationStore> {
  const EvidenceVerificationStoreProvider({
    super.key,
    required EvidenceVerificationStore notifier,
    required super.child,
  }) : super(notifier: notifier);

  /// ดึง store จาก context — rebuild อัตโนมัติเมื่อ store เปลี่ยน
  static EvidenceVerificationStore of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<EvidenceVerificationStoreProvider>();
    assert(
      provider != null,
      'EvidenceVerificationStoreProvider ไม่พบใน widget tree',
    );
    return provider!.notifier!;
  }
}
