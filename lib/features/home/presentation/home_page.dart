import 'package:flutter/material.dart';

/// หน้าหลัก (Home) — แท็บที่ 1
///
/// ใน milestone นี้เป็นแค่โครงหน้า (Scaffold + AppBar + ข้อความกึ่งกลาง)
/// ยังไม่มี business logic ใด ๆ ตามข้อกำหนด
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(
        child: Text('Home'),
      ),
    );
  }
}
