// lib/screens/announce_event_screen.dart
import 'package:flutter/material.dart';
import 'package:orbit/services/api_service.dart';
import 'package:intl/intl.dart'; // Package for date/time formatting

class AnnounceEventScreen extends StatefulWidget {
  const AnnounceEventScreen({super.key});

  @override
  State<AnnounceEventScreen> createState() => _AnnounceEventScreenState();
}

class _AnnounceEventScreenState extends State<AnnounceEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  // --- NEW CONTROLLERS ---
  final _speakerController = TextEditingController();
  final _venueController = TextEditingController();

  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _speakerController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    // --- UPDATED: Now picks date AND time ---
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (date == null) return; // User canceled date picker

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (time != null) {
      _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      setState(() {
        // Format the date and time for display
        _dateController.text = DateFormat('yyyy-MM-dd – hh:mm a').format(_selectedDate!);
      });
    }
  }

  Future<void> _submitEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        // In a real app, you would send all the new fields to the API
        // For the video, we'll just pretend it's working
        // final response = await _apiService.createEvent(
        //   _titleController.text,
        //   _descriptionController.text,
        //   _selectedDate!.toIso8601String(), // Send the full date and time
        //   _speakerController.text,
        //   _venueController.text,
        // );
        await Future.delayed(const Duration(seconds: 1)); // Simulate network call

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Event announced successfully!'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announce New Event')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Event Title', prefixIcon: Icon(Icons.title)),
                validator: (v) => v!.isEmpty ? 'Please enter a title' : null,
              ),
              const SizedBox(height: 20),
              // --- NEW FIELD: Speaker ---
              TextFormField(
                controller: _speakerController,
                decoration: const InputDecoration(labelText: 'Speaker Name', prefixIcon: Icon(Icons.person_outline)),
                validator: (v) => v!.isEmpty ? 'Please enter a speaker name' : null,
              ),
              const SizedBox(height: 20),
              // --- NEW FIELD: Venue ---
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue / Location', prefixIcon: Icon(Icons.location_on_outlined)),
                validator: (v) => v!.isEmpty ? 'Please enter a venue' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Event Description', prefixIcon: Icon(Icons.notes)),
                maxLines: 4,
                validator: (v) => v!.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dateController,
                decoration: const InputDecoration(
                  labelText: 'Event Date & Time',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: _pickDateTime, // Updated function to pick time as well
                validator: (v) => v!.isEmpty ? 'Please select a date and time' : null,
              ),
              const SizedBox(height: 40),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submitEvent,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Announce Event'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}