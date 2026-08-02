// lib/screens/alumni_management_screen.dart

import 'package:flutter/material.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class AlumniManagementScreen extends StatelessWidget {
  const AlumniManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "User Management",
              style: AppTextStyles.heading,
            ),

            const SizedBox(height: 8),

            Text(
              "Manage alumni and student accounts.",
              style: AppTextStyles.subtitle,
            ),

            const SizedBox(height: 30),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.school,
                    color: Colors.white,
                  ),
                ),

                title: Text(
                  "Add Alumni",
                  style: AppTextStyles.title,
                ),

                subtitle: Text(
                  "Register a new alumni account",
                  style: AppTextStyles.subtitle,
                ),

                trailing: const Icon(Icons.chevron_right),

                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/addAlumni",
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),

                title: Text(
                  "Add Student",
                  style: AppTextStyles.title,
                ),

                subtitle: Text(
                  "Register a new student account",
                  style: AppTextStyles.subtitle,
                ),

                trailing: const Icon(Icons.chevron_right),

                onTap: () {
                  Navigator.pushNamed(
                    context,
                    "/addStudent",
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Row(
                  children: [

                    const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        "Admins can add new users and manage the Orbit platform.",
                        style: AppTextStyles.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}