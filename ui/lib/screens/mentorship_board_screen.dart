// lib/screens/mentorship_board_screen.dart

import 'package:flutter/material.dart';
import 'package:orbit/main.dart';
import 'package:orbit/screens/mentorship_detail_screen.dart';
import 'package:orbit/screens/post_mentorship_screen.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class MentorshipOpportunity {
  final String id;
  final String title;
  final String description;
  final String mentorName;
  final String requiredSkills;

  MentorshipOpportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.mentorName,
    required this.requiredSkills,
  });
}

class MentorshipBoardScreen extends StatelessWidget {
  const MentorshipBoardScreen({super.key});

  static final List<MentorshipOpportunity> _opportunities = [
    MentorshipOpportunity(
      id: '1',
      title: 'Resume Review for Aspiring Product Managers',
      description:
          'I will personally review your resume and provide actionable feedback.',
      mentorName: 'Priya Kapoor',
      requiredSkills: 'Product Management, Communication',
    ),
    MentorshipOpportunity(
      id: '2',
      title: 'Mock Interviews for SWE Roles',
      description:
          'Conducting realistic, FAANG-style technical interviews.',
      mentorName: 'Arjun Mehra',
      requiredSkills: 'Data Structures, Algorithms',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isAlumnus = authManager.userRole == 'alumnus';

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Mentorship Board",
          style: AppTextStyles.title,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
        actions: [
          if (isAlumnus)
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.primary,
              ),
              tooltip: "Post Opportunity",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PostMentorshipScreen(),
                  ),
                );
              },
            ),
        ],
      ),

      body: _opportunities.isEmpty
          ? Center(
              child: Text(
                "No mentorship opportunities available.",
                style: AppTextStyles.subtitle,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _opportunities.length,
              itemBuilder: (context, index) {
                final opportunity = _opportunities[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(18),

                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Text(
                        opportunity.mentorName[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    title: Text(
                      opportunity.title,
                      style: AppTextStyles.title,
                    ),

                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        "Posted by ${opportunity.mentorName}",
                        style: AppTextStyles.subtitle,
                      ),
                    ),

                    trailing: const Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => MentorshipDetailScreen(
                            opportunity: opportunity,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

      floatingActionButton: isAlumnus
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PostMentorshipScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}