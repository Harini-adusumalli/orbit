import 'dart:io';

import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:orbit/auth_manager.dart';
import 'package:orbit/screens/login_screen.dart';
import 'package:orbit/screens/main_shell.dart';
import 'package:orbit/screens/signup_screen.dart';
import 'package:orbit/theme/app_theme.dart';

final AuthManager authManager = AuthManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb &&
      (Platform.isWindows ||
          Platform.isLinux ||
          Platform.isMacOS)) {
    await DesktopWindow.setMinWindowSize(
      const Size(400, 700),
    );

    await DesktopWindow.setWindowSize(
      const Size(450, 800),
    );
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authManager,
      builder: (context, _) {
        return MaterialApp(
          title: "Orbit",
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,

          routes: {
            "/login": (_) => const LoginScreen(),
            "/signup": (_) => const SignupScreen(),
          },

          home: authManager.isLoggedIn
              ? const MainShell()
              : const LoginScreen(),
        );
      },
    );
  }
}