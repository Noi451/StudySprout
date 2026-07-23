import 'package:flutter/material.dart';

/// หน้าโปรไฟล์ (Profile) — แท็บที่ 4
///
/// ใน milestone นี้เป็นแค่โครงหน้า (Scaffold + AppBar + ข้อความกึ่งกลาง)
/// ยังไม่มี business logic ใด ๆ ตามข้อกำหนด
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Text('Profile'),
      ),
    );
  }
}
