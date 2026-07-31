import 'package:flutter/material.dart';
import 'package:orbit/services/api_service.dart';

class AddAlumniScreen extends StatefulWidget {
  const AddAlumniScreen({super.key});

  @override
  State<AddAlumniScreen> createState() => _AddAlumniScreenState();
}

class _AddAlumniScreenState extends State<AddAlumniScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _rollnoController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rollnoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  final ApiService _apiService = ApiService();

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final response = await _apiService.addAlumni(
        _nameController.text,
        _emailController.text,
        _rollnoController.text,
        _passwordController.text,
      );
      if (response['message'] != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message']), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error'] ?? 'Failed to add alumni'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Alumni')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _rollnoController,
                decoration: const InputDecoration(labelText: 'Roll Number'),
                validator: (v) => v == null || v.isEmpty ? 'Enter roll number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Add Alumni'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
