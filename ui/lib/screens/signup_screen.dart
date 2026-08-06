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

  final TextEditingController _rollnoController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  bool get _hasMinLength =>
    _passwordController.text.length >= 8;

  bool get _hasUppercase =>
    RegExp(r'[A-Z]').hasMatch(_passwordController.text);

  bool get _hasLowercase =>
    RegExp(r'[a-z]').hasMatch(_passwordController.text);

  bool get _hasNumber =>
    RegExp(r'[0-9]').hasMatch(_passwordController.text);

  bool get _hasSpecial =>
    RegExp(r'[!@#$%^&*(),.?":{}|<>]')
        .hasMatch(_passwordController.text);
  String _selectedRole = "student";
  @override
  void initState() {
    super.initState();

    _passwordController.addListener(() {
      setState(() {});
    });
  }
  @override
  void dispose() {
    _rollnoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          content: Text(response["message"]),
        ),
      );

      // Remove signup screen completely
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            e.toString().replaceFirst(
              "HttpException: ",
              "",
            );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  Widget _passwordRequirement(bool valid, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            valid ? Icons.check_circle : Icons.radio_button_unchecked,
            color: valid ? Colors.green : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: valid ? Colors.green : Colors.grey,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
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
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 450,
                  ),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column( 
                        mainAxisSize: MainAxisSize.min,
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
                                prefixIcon:
                                    Icon(Icons.badge_outlined),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return "Enter your Roll Number";
                                }
                                return null;
                              },
                            ),

                  const SizedBox(height: 18),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Enter a Password";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Password Requirements",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        _passwordRequirement(
                          _hasMinLength,
                          "Minimum 8 characters",
                        ),

                        _passwordRequirement(
                          _hasUppercase,
                          "One uppercase letter",
                        ),

                        _passwordRequirement(
                          _hasLowercase,
                          "One lowercase letter",
                        ),

                        _passwordRequirement(
                          _hasNumber,
                          "One number",
                        ),

                        _passwordRequirement(
                          _hasSpecial,
                          "One special character",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: const InputDecoration(
                      labelText: "I am a",
                      prefixIcon:
                          Icon(Icons.person_outline),
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
                      padding:
                          const EdgeInsets.only(
                        bottom: 15,
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color:
                              AppColors.error,
                        ),
                      ),
                    ),

                  _isLoading
                      ? const CircularProgressIndicator(
                          color:
                              AppColors.primary,
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
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Already have an account? Login",
                      style:
                          AppTextStyles.subtitle,
                    ),
                  ),
                ],
              ), // Column
            ), // Padding
          ), // Card
        ), // ConstrainedBox
      ), // Center
    ), // Form
  ), // SingleChildScrollView
), // SafeArea
),
);
}
}