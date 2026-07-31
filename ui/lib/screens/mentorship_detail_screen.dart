// lib/screens/mentorship_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:orbit/main.dart'; // To access authManager
import 'package:orbit/screens/mentorship_board_screen.dart'; // To access the model
import 'package:orbit/screens/chat_screen.dart';

class MentorshipDetailScreen extends StatelessWidget {
  final MentorshipOpportunity opportunity;

  const MentorshipDetailScreen({super.key, required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStudent = authManager.userRole == 'student';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunity Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header ---
            Text(
              opportunity.title,
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  // TODO: Use actual mentor image URL
                  backgroundImage: NetworkImage('https://placehold.co/100x100/7E57C2/FFFFFF?text=${opportunity.mentorName.substring(0,1)}'),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.mentorName,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Alumnus', // Role of the mentor
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 32),

            // --- Description ---
            _buildSectionHeader(context, 'About this Opportunity'),
            const SizedBox(height: 8),
            Text(
              opportunity.description,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.5, color: Colors.white70),
            ),
            const SizedBox(height: 24),

            // --- Required Skills ---
            _buildSectionHeader(context, 'Required Skills'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: opportunity.requiredSkills.split(',').map((skill) {
                return Chip(
                  label: Text(skill.trim()),
                  backgroundColor: theme.colorScheme.secondaryContainer.withOpacity(0.5),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      // --- Floating Action Button for Students ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Row(
          children: [
            Expanded(
              child: FloatingActionButton.extended(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Your application has been sent!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.send_outlined),
                label: const Text('Apply Now'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: FloatingActionButton.extended(
                onPressed: () {
                  // Open chat screen with mentor
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        recipientId: opportunity.id, // Replace with email/rollno if available
                        recipientName: opportunity.mentorName,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.message_outlined),
                label: const Text('Send Message'),
              ),
            ),
          ],
        ),
      ),
      // End of Scaffold
    );
  }
}

Widget _buildSectionHeader(BuildContext context, String title) {
  return Text(
    title,
    style: Theme.of(context).textTheme.headlineSmall,
  );
}
