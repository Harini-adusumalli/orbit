// lib/screens/admin_home_screen.dart

import 'package:flutter/material.dart';
import 'package:orbit/screens/add_alumni_screen.dart';
import 'package:orbit/screens/add_student_screen.dart';
import 'package:orbit/screens/announce_event_screen.dart';

import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text("Admin Dashboard"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              "Welcome, Admin 👋",
              style: AppTextStyles.heading,
            ),

            const SizedBox(height: 8),

            Text(
              "Manage students, alumni and events from one place.",
              style: AppTextStyles.subtitle,
            ),

            const SizedBox(height: 30),

            _buildCard(
              context,
              title: "Add Alumni",
              subtitle:
                  "Register a new alumnus into the Orbit platform.",
              icon: Icons.people_alt_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AddAlumniScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            _buildCard(
              context,
              title: "Add Student",
              subtitle:
                  "Create a new student account.",
              icon: Icons.school_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AddStudentScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 18),

            _buildCard(
              context,
              title: "Announce Event",
              subtitle:
                  "Publish workshops, seminars and alumni meetups.",
              icon: Icons.campaign_outlined,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const AnnounceEventScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Card(
        color: AppColors.card,
        elevation: 2,

        child: Padding(
          padding: const EdgeInsets.all(18),

          child: Row(
            children: [

              CircleAvatar(
                radius: 28,
                backgroundColor:
                    AppColors.primary.withOpacity(.12),

                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 28,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [

                    Text(
                      title,
                      style: AppTextStyles.title,
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtitle,
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}