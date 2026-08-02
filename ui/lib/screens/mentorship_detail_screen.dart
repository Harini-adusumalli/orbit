// lib/screens/mentorship_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:orbit/main.dart';
import 'package:orbit/screens/chat_screen.dart';
import 'package:orbit/screens/mentorship_board_screen.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class MentorshipDetailScreen extends StatelessWidget {
  final MentorshipOpportunity opportunity;

  const MentorshipDetailScreen({
    super.key,
    required this.opportunity,
  });

  @override
  Widget build(BuildContext context) {
    final isStudent = authManager.userRole == "student";

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
        ),
        title: Text(
          "Opportunity Details",
          style: AppTextStyles.title,
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      opportunity.title,
                      style: AppTextStyles.heading,
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [

                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary,
                          child: Text(
                            opportunity.mentorName[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),

                        const SizedBox(width: 15),

                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [

                            Text(
                              opportunity.mentorName,
                              style: AppTextStyles.title,
                            ),

                            const SizedBox(height: 4),

                            Text(
                              "Alumnus",
                              style:
                                  AppTextStyles.subtitle,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      "About this Opportunity",
                      style:
                          AppTextStyles.subHeading,
                    ),

                    const SizedBox(height: 15),

                    Text(
                      opportunity.description,
                      style: AppTextStyles.body.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Required Skills",
                      style:
                          AppTextStyles.subHeading,
                    ),

                    const SizedBox(height: 15),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: opportunity
                          .requiredSkills
                          .split(",")
                          .map(
                            (skill) => Chip(
                              label: Text(
                                skill.trim(),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,

      floatingActionButton: isStudent
          ? Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
              ),

              child: Row(
                children: [

                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {

                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Application submitted successfully!",
                            ),
                          ),
                        );
                      },

                      icon: const Icon(Icons.send),

                      label: const Text(
                        "Apply",
                      ),
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              recipientId:
                                  opportunity.id,
                              recipientName:
                                  opportunity
                                      .mentorName,
                            ),
                          ),
                        );
                      },

                      icon: const Icon(Icons.chat),

                      label: const Text(
                        "Message",
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}