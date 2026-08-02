import 'package:flutter/material.dart';
import 'package:orbit/screens/bot_chat_screen.dart';
import 'package:orbit/screens/mentorship_board_screen.dart';
import 'package:orbit/screens/search_results_screen.dart';

import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              "Find the right mentor",
              style: AppTextStyles.heading,
            ),

            const SizedBox(height: 8),

            Text(
              "Search by skill, industry, company or graduation year to connect with experienced alumni.",
              style: AppTextStyles.subtitle,
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                hintText: 'e.g. "Java Developer at Microsoft"',
                hintStyle: AppTextStyles.subtitle,

                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primary,
                ),

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),

              onSubmitted: (query) {
                if (query.trim().isEmpty) return;

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        SearchResultsScreen(
                      query: query.trim(),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            _buildSectionHeader(
              context,
              "Explore Opportunities",
            ),

            const SizedBox(height: 16),

            Row(
              children: [

                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.school_outlined,
                    label: "Mentorship Board",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MentorshipBoardScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.work_outline,
                    label: "Internships",
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 35),

            _buildSectionHeader(
              context,
              "Featured",
            ),

            const SizedBox(height: 16),

            Card(
              color: AppColors.card,

              clipBehavior: Clip.antiAlias,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Image.asset(
                    "assets/workshops.jpg",

                    height: 170,
                    width: double.infinity,

                    fit: BoxFit.cover,

                    errorBuilder:
                        (_, __, ___) =>
                            const SizedBox(
                      height: 170,

                      child: Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 60,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding:
                        const EdgeInsets.all(18),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: [

                        Text(
                          "Workshop: AI in Modern Industry",
                          style: AppTextStyles.title,
                        ),

                        const SizedBox(height: 8),

                        Text(
                          "Join industry experts for an exciting workshop on AI applications, careers and future trends.",
                          style:
                              AppTextStyles.body,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
                        const SizedBox(height: 40),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.smart_toy_outlined),
        label: const Text("Orbit Guide"),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ChatBotScreen(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
  ) {
    return Text(
      title,
      style: AppTextStyles.subHeading,
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 28,
            horizontal: 16,
          ),
          child: Column(
            children: [

              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary.withOpacity(0.12),
                child: Icon(
                  icon,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyles.title,
              ),
            ],
          ),
        ),
      ),
    );
  }
}