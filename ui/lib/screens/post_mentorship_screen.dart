// lib/screens/post_mentorship_screen.dart
import 'package:flutter/material.dart';

class PostMentorshipScreen extends StatefulWidget {
  const PostMentorshipScreen({super.key});

  @override
  State<PostMentorshipScreen> createState() => _PostMentorshipScreenState();
}

class _PostMentorshipScreenState extends State<PostMentorshipScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _skillsController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _submitOpportunity() {
    if (_formKey.currentState!.validate()) {
      // Form is valid
      // TODO: Implement API call to POST /api/mentorship/posts
      // final newOpportunity = {
      //   "title": _titleController.text,
      //   "description": _descriptionController.text,
      //   "required_skills": _skillsController.text,
      // };

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mentorship opportunity posted successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post an Opportunity'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _titleController,
                label: 'Title',
                hint: 'e.g., Resume Review for SWE',
                icon: Icons.title,
              ),
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Provide details about what you are offering...',
                icon: Icons.description_outlined,
                isMultiLine: true,
              ),
              _buildTextField(
                controller: _skillsController,
                label: 'Required Skills (comma-separated)',
                hint: 'e.g., Java, Python, Public Speaking',
                icon: Icons.code,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitOpportunity,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Submit Opportunity'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        maxLines: isMultiLine ? 5 : 1,
        minLines: isMultiLine ? 3 : 1,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          alignLabelWithHint: true,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field cannot be empty';
          }
          return null;
        },
      ),
    );
  }
}
