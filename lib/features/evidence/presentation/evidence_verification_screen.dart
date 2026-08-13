import 'package:flutter/material.dart';

import '../domain/evidence_verification_store.dart';
import '../domain/evidence_verification_store_provider.dart';
import '../domain/evidence_verifier.dart';
import 'evidence_verification_page.dart';

/// หน้าจอ Evidence Verification แบบครบ — สร้าง store เฉพาะ + หุ้ม Provider + Page
///
/// Sprint 9A: เป็นจุดเข้าเดียวสำหรับเปิดหน้าทดลอง — caller ส่ง verifier (test ใช้
/// FakeEvidenceVerifier) + goalTitle + onChooseEvidence (Sprint 9B เสียบ picker)
///
/// ตัวอย่างการเปิด (ใน test):
/// ```
/// Navigator.push(MaterialPageRoute(
///   builder: (_) => EvidenceVerificationScreen(
///     verifier: fakeVerifier,
///     goalTitle: 'Practice Python',
///     onChooseEvidence: () => /* set bytes */,
///   ),
/// ));
/// ```
class EvidenceVerificationScreen extends StatefulWidget {
  const EvidenceVerificationScreen({
    super.key,
    required this.verifier,
    required this.goalTitle,
    required this.onChooseEvidence,
  });

  final EvidenceVerifier verifier;
  final String goalTitle;
  final VoidCallback onChooseEvidence;

  @override
  State<EvidenceVerificationScreen> createState() =>
      _EvidenceVerificationScreenState();
}

class _EvidenceVerificationScreenState extends State<EvidenceVerificationScreen> {
  late final EvidenceVerificationStore _store;

  @override
  void initState() {
    super.initState();
    _store = EvidenceVerificationStore(verifier: widget.verifier);
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EvidenceVerificationStoreProvider(
      notifier: _store,
      child: EvidenceVerificationPage(
        goalTitle: widget.goalTitle,
        onChooseEvidence: widget.onChooseEvidence,
      ),
    );
  }
}
