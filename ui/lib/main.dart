import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orbit/auth_manager.dart';
import 'package:orbit/screens/login_screen.dart';
import 'dart:io';
import 'package:desktop_window/desktop_window.dart';
import 'package:orbit/screens/main_shell.dart';

final AuthManager authManager = AuthManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    await DesktopWindow.setMinWindowSize(const Size(400, 700));
    await DesktopWindow.setWindowSize(const Size(450, 800));
  }
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
  ));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: authManager,
      builder: (context, child) {
        return MaterialApp(
          title: 'Orbit',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: const Color(0xFF03DAC6),
            scaffoldBackgroundColor: const Color(0xFFFDFBD4), // Main app background color
            cardColor: const Color(0xFF1E1E1E),
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF03DAC6),
              secondary: Color(0xFFBB86FC),
              surface: Color(0xFF1E1E1E),
              onPrimary: Colors.black,
            ),
            textSelectionTheme: const TextSelectionThemeData(
              cursorColor: Colors.black,
            ),
          ),
          home: authManager.isLoggedIn ? const MainShell() : const LoginScreen(),
        );
      },
    );
  }
}