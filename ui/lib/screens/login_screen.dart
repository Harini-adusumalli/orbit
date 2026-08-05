import 'package:flutter/material.dart';
import 'package:orbit/main.dart';
import 'package:orbit/services/api_service.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _rollnoController =
      TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _rollnoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _apiService.login(
        _rollnoController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      if (response.containsKey("token")) {
        authManager.login(
          response["token"],
          response["role"],
          response["rollno"],
        );

        // MaterialApp rebuilds automatically.
        // Do NOT navigate manually.
        return;
      }

      setState(() {
        _errorMessage =
            response["error"] ?? "Login failed.";
      });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
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
                crossAxisAlignment:
                    CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    "assets/logo.png",
                    height: 110,
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Welcome to Orbit",
                    style: AppTextStyles.heading,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Connect • Mentor • Grow",
                    style: AppTextStyles.subtitle,
                  ),

                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _rollnoController,
                    decoration: const InputDecoration(
                      labelText: "Roll Number",
                      prefixIcon: Icon(Icons.badge),
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
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return "Enter your Password";
                      }
                      return null;
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
                            onPressed: _login,
                            child: const Text(
                              "Login",
                            ),
                          ),
                        ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        "/signup",
                      );
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style:
                          AppTextStyles.subtitle,
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