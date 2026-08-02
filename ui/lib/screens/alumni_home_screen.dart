// lib/screens/alumni_home_screen.dart

import 'package:flutter/material.dart';
import 'package:orbit/main.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class AlumniHomeScreen extends StatelessWidget {
  const AlumniHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Text(
              "Welcome Back 👋",
              style: AppTextStyles.heading,
            ),

            const SizedBox(height: 6),

            Text(
              authManager.rollNumber ?? "",
              style: AppTextStyles.subtitle,
            ),

            const SizedBox(height: 30),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const Icon(
                      Icons.people_alt_rounded,
                      size: 45,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Connect with Students",
                      style: AppTextStyles.title,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Help students by mentoring, answering questions and sharing your experience.",
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const Icon(
                      Icons.event,
                      size: 45,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Upcoming Events",
                      style: AppTextStyles.title,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Participate in alumni meets, webinars and networking sessions.",
                      style: AppTextStyles.body,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    const Icon(
                      Icons.volunteer_activism,
                      size: 45,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Support the Community",
                      style: AppTextStyles.title,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Contribute through mentorship, donations and career guidance.",
                      style: AppTextStyles.body,
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