// lib/screens/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:orbit/screens/announce_event_screen.dart'; // <-- Import the new screen

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Welcome, Admin!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Manage users, review activities, and oversee platform operations.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // --- ADD THIS BUTTON ---
              ElevatedButton.icon(
                icon: const Icon(Icons.campaign_outlined),
                label: const Text('Announce New Event'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const AnnounceEventScreen(),
                  ));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}