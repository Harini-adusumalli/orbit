import 'package:flutter/material.dart';

class AlumniHomeScreen extends StatelessWidget {
  const AlumniHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alumni Home')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, Alumni!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Text('Share your expertise, post mentorships, and connect with students.'),
          ],
        ),
      ),
    );
  }
}
