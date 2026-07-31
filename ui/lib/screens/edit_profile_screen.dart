import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _companyController;
  late final TextEditingController _designationController;
  late final TextEditingController _skillsController;
  late final TextEditingController _mentorshipAreaController;

  @override
  void initState() {
    super.initState();
    _companyController = TextEditingController(text: 'TechNova Systems');
    _designationController = TextEditingController(text: 'Senior Software Engineer');
    _skillsController = TextEditingController(text: 'Java, Python, Cloud');
    _mentorshipAreaController = TextEditingController(text: 'Career guidance, coding interviews');
  }

  @override
  void dispose() {
    _companyController.dispose();
    _designationController.dispose();
    _skillsController.dispose();
    _mentorshipAreaController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
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
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveProfile,
            tooltip: 'Save Changes',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextField(
                controller: _companyController,
                label: 'Current Company',
                icon: Icons.business,
              ),
              _buildTextField(
                controller: _designationController,
                label: 'Designation',
                icon: Icons.work_outline,
              ),
              _buildTextField(
                controller: _skillsController,
                label: 'Technical Skills (comma-separated)',
                icon: Icons.code,
              ),
               _buildTextField(
                controller: _mentorshipAreaController,
                label: 'Mentorship Areas (comma-separated)',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Changes'),
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
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
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

