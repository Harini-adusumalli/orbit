// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:orbit/screens/bot_chat_screen.dart';
import 'package:orbit/screens/mentorship_board_screen.dart';
import 'package:orbit/screens/search_results_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Search Section ---
            Text(
              "Find the right mentor",
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 8),
            Text(
              "Search by skill, industry, or company to connect with experienced alumni.",
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'e.g., "Alumni in fintech"',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFF96583E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (query) {
                if (query.trim().isNotEmpty) {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => SearchResultsScreen(query: query.trim()),
                  ));
                }
              },
            ),
            const SizedBox(height: 32),

            // --- Quick Actions Section ---
            _buildSectionHeader(context, "Explore Opportunities"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.school_outlined,
                    label: 'Mentorship Board',
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const MentorshipBoardScreen(),
                      ));
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    context,
                    icon: Icons.work_outline,
                    label: 'Internships',
                    onTap: () {
                      // TODO: Navigate to an internships screen
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

             // --- Featured Content Section ---
            _buildSectionHeader(context, "Featured"),
            const SizedBox(height: 16),
              Card(
                // FIX 1: Set the featured card background color
                color: const Color(0xFF96583E),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/workshops.jpg',
                      fit: BoxFit.cover,
                      height: 150,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox(
                          height: 150,
                          child: Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 48),
                        );
                      },
                    ),
                    ListTile(
                      // FIX 2: Changed text color for readability on dark background
                      title: Text("Workshop: AI in Modern Industry", style: theme.textTheme.titleLarge?.copyWith(color: Colors.white)),
                      subtitle: const Text("Join us for a deep dive into the world of AI.", style: TextStyle(color: Colors.white70)),
                      trailing: const Icon(Icons.arrow_forward, color: Colors.white),
                      onTap: (){
                        // TODO: Navigate to the specific event
                      },
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => const ChatBotScreen(),
          ));
        },
        label: const Text('AI Assistant'),
        icon: const Icon(Icons.smart_toy_outlined),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }

  Widget _buildActionCard(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
    final theme = Theme.of(context);
    return Card(
      // FIX 3: Set the action card background color
      color: const Color(0xFF96583E),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: theme.colorScheme.primary),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                // FIX 4: Changed text color for readability on dark background
                style: theme.textTheme.titleMedium?.copyWith(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}