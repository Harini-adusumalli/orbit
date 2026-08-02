// lib/screens/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:orbit/screens/login_screen.dart';
import 'package:orbit/services/api_service.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _rollnoController = TextEditingController();
  final _passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;

  String _selectedRole = "student";

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.signup(
        _rollnoController.text.trim(),
        _passwordController.text,
        _selectedRole,
      );

      if (response.containsKey("message")) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppColors.success,
              content: Text(response["message"]),
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const LoginScreen(),
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage =
              response["error"] ?? "Signup failed.";
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            "Could not connect to the server.";
      });
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Create Account",
          style: AppTextStyles.title,
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                children: [

                  Text(
                    "Join Orbit",
                    style: AppTextStyles.heading,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Create your account to start connecting.",
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 35),

                  TextFormField(
                    controller: _rollnoController,
                    decoration: const InputDecoration(
                      labelText: "Roll Number / ID",
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return "Enter your Roll Number";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return "Enter a Password";
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  DropdownButtonFormField<String>(
                    value: _selectedRole,

                    decoration: const InputDecoration(
                      labelText: "I am a",
                      prefixIcon: Icon(Icons.person_outline),
                    ),

                    items: const [

                      DropdownMenuItem(
                        value: "student",
                        child: Text("Student"),
                      ),

                      DropdownMenuItem(
                        value: "alumnus",
                        child: Text("Alumnus"),
                      ),

                      DropdownMenuItem(
                        value: "admin",
                        child: Text("Admin"),
                      ),
                    ],

                    onChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        _selectedRole = value;
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 15,
                      ),

                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: AppColors.error,
                        ),
                      ),
                    ),

                  _isLoading
                      ? const CircularProgressIndicator(
                          color: AppColors.primary,
                        )
                      : SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: _signup,
                            child: const Text(
                              "Sign Up",
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const LoginScreen(),
                        ),
                      );
                    },

                    child: Text(
                      "Already have an account? Login",
                      style: AppTextStyles.subtitle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}