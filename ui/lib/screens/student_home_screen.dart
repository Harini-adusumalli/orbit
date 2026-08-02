import 'package:flutter/material.dart';
import 'package:orbit/main.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

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
              "Welcome 👋",
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
                      Icons.search,
                      size: 45,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Find Alumni",
                      style: AppTextStyles.title,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Search for alumni based on company, role, skills or graduation year.",
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
                      Icons.chat_bubble_outline,
                      size: 45,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Connect with Mentors",
                      style: AppTextStyles.title,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Send chat requests and build professional connections with alumni.",
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
                      Icons.school_outlined,
                      size: 45,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Mentorship Opportunities",
                      style: AppTextStyles.title,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Apply for mentorship programs, resume reviews and mock interviews.",
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
                      Icons.smart_toy_outlined,
                      size: 45,
                      color: AppColors.primary,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      "Orbit Guide",
                      style: AppTextStyles.title,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      "Need help using Orbit? Open Orbit Guide from the bottom navigation for step-by-step assistance.",
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