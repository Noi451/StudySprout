import 'package:flutter/material.dart';

/// หน้าความคืบหน้า (Progress) — แท็บที่ 3
///
/// ใน milestone นี้เป็นแค่โครงหน้า (Scaffold + AppBar + ข้อความกึ่งกลาง)
/// ยังไม่มี business logic ใด ๆ ตามข้อกำหนด
class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Progress')),
      body: const Center(
        child: Text('Progress'),
      ),
    );
  }
}
