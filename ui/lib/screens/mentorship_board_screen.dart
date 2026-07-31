// lib/screens/mentorship_board_screen.dart
import 'package:flutter/material.dart';
import 'package:orbit/main.dart'; // To access authManager
import 'package:orbit/screens/mentorship_detail_screen.dart';
import 'package:orbit/screens/post_mentorship_screen.dart';

// TODO: Replace with a real MentorshipOpportunity model from your backend
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

  // TODO: Fetch real opportunities from your /api/mentorship/posts endpoint
  static final List<MentorshipOpportunity> _opportunities = [
    MentorshipOpportunity(
      id: '1',
      title: 'Resume Review for Aspiring Product Managers',
      description: 'I will personally review your resume and provide actionable feedback.',
      mentorName: 'Priya Kapoor',
      requiredSkills: 'Product Management, Communication',
    ),
    MentorshipOpportunity(
      id: '2',
      title: 'Mock Interviews for SWE Roles',
      description: 'Conducting realistic, FAANG-style technical interviews.',
      mentorName: 'Arjun Mehra',
      requiredSkills: 'Data Structures, Algorithms',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAlumnus = authManager.userRole == 'alumnus';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentorship Board'),
        actions: [
          // Conditionally show the 'Add' button only for alumni
          if (isAlumnus)
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Post an Opportunity',
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => const PostMentorshipScreen(),
                ));
              },
            ),
        ],
      ),
      body: _opportunities.isEmpty
          ? const Center(
              child: Text('No mentorship opportunities available right now.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _opportunities.length,
              itemBuilder: (context, index) {
                final opportunity = _opportunities[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      opportunity.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text('Posted by ${opportunity.mentorName}'),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => MentorshipDetailScreen(opportunity: opportunity),
                      ));
                    },
                  ),
                );
              },
            ),
    );
  }
}
