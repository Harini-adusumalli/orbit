// lib/screens/events_screen.dart
import 'package:flutter/material.dart';

// TODO: Replace with a real Event model from your backend response
class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
  });
}

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  // TODO: Fetch real events from your /api/events GET endpoint
  static final List<Event> _events = [
    Event(
      id: '1',
      title: 'AI in Modern Industry',
      description: 'A deep dive into the practical applications of AI and machine learning.',
      // Using a specific date for consistency in the UI
      date: DateTime(2025, 10, 7),
      location: 'Virtual Event',
    ),
    Event(
      id: '2',
      title: 'Alumni Networking Mixer',
      description: 'Connect with fellow alumni and current students.',
      date: DateTime(2025, 10, 23),
      location: 'University Grand Hall',
    ),
    Event(
      id: '3',
      title: 'Workshop: Product Management 101',
      description: 'Learn the fundamentals of product management from an industry expert.',
      date: DateTime(2025, 11, 7),
      location: 'Online Webinar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_events.isEmpty) {
      return const Center(
        child: Text(
          'No upcoming events.',
          style: TextStyle(fontSize: 16, color: Colors.white60),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          // FIX 1: Set the card's background color
          color: const Color(0xFFc7b299),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Simple date formatting
                  '${event.date.day}/${event.date.month}/${event.date.year}',
                  style: theme.textTheme.labelLarge?.copyWith(
                    // FIX 2: Corrected the typo to a valid color
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  event.title,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 16, color: Colors.black87),
                    const SizedBox(width: 8),
                    Text(event.location, style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  event.description,
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black87),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}