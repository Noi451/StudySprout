import 'package:flutter/material.dart';

/// หน้าเป้าหมาย (Goals) — แท็บที่ 2
///
/// ใน milestone นี้เป็นแค่โครงหน้า (Scaffold + AppBar + ข้อความกึ่งกลาง)
/// ยังไม่มี business logic ใด ๆ ตามข้อกำหนด
class GoalsPage extends StatelessWidget {
  const GoalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      body: const Center(
        child: Text('Goals'),
      ),
    );
  }
}
