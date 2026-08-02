// lib/screens/events_screen.dart

import 'package:flutter/material.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

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

  // TODO: Fetch real events from backend
  static final List<Event> _events = [
    Event(
      id: '1',
      title: 'AI in Modern Industry',
      description:
          'A deep dive into the practical applications of AI and Machine Learning.',
      date: DateTime(2025, 10, 7),
      location: 'Virtual Event',
    ),
    Event(
      id: '2',
      title: 'Alumni Networking Mixer',
      description:
          'Connect with fellow alumni and current students through networking sessions.',
      date: DateTime(2025, 10, 23),
      location: 'University Grand Hall',
    ),
    Event(
      id: '3',
      title: 'Workshop: Product Management 101',
      description:
          'Learn the fundamentals of Product Management from industry experts.',
      date: DateTime(2025, 11, 7),
      location: 'Online Webinar',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    if (_events.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.event_busy,
                size: 70,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              Text(
                "No Upcoming Events",
                style: AppTextStyles.heading,
              ),
              const SizedBox(height: 8),
              Text(
                "Check back later for new events.",
                style: AppTextStyles.subtitle,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 18),
            elevation: 2,
            color: AppColors.card,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// Date Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${event.date.day}/${event.date.month}/${event.date.year}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    event.title,
                    style: AppTextStyles.title,
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [

                      const Icon(
                        Icons.location_on,
                        color: AppColors.primary,
                        size: 18,
                      ),

                      const SizedBox(width: 8),

                      Expanded(
                        child: Text(
                          event.location,
                          style: AppTextStyles.subtitle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Text(
                    event.description,
                    style: AppTextStyles.body,
                  ),

                  const SizedBox(height: 22),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.success,
                            content: Text(
                              "You're interested in ${event.title}",
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.event_available),
                      label: const Text("I'm Interested"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}