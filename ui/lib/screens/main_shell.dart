// lib/screens/main_shell.dart

import 'package:flutter/material.dart';
import 'package:orbit/main.dart';

import 'package:orbit/screens/admin_home_screen.dart';
import 'package:orbit/screens/alumni_management_screen.dart';
import 'package:orbit/screens/bot_chat_screen.dart';
import 'package:orbit/screens/chat_list_screen.dart';
import 'package:orbit/screens/donation_screen.dart';
import 'package:orbit/screens/events_screen.dart';
import 'package:orbit/screens/home_screen.dart';
import 'package:orbit/screens/profile_screen.dart';

import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  List<Widget> get _widgetOptions {
    switch (authManager.userRole) {
      case "alumnus":
        return const [
          HomeScreen(),
          EventsScreen(),
          ChatListScreen(),
          DonationScreen(),
          ProfileScreen(),
          ChatBotScreen(),
        ];

      case "student":
        return const [
          HomeScreen(),
          EventsScreen(),
          ChatListScreen(),
          ProfileScreen(),
          ChatBotScreen(),
        ];

      case "admin":
        return const [
          AdminHomeScreen(),
          AlumniManagementScreen(),
          EventsScreen(),
          ChatListScreen(),
          ProfileScreen(),
        ];

      default:
        return const [
          HomeScreen(),
        ];
    }
  }

  List<String> get _titles {
    switch (authManager.userRole) {
      case "alumnus":
        return [
          "Orbit",
          "Events",
          "Chats",
          "Donations",
          "Profile",
          "Orbit Guide",
        ];

      case "student":
        return [
          "Orbit",
          "Events",
          "Chats",
          "Profile",
          "Orbit Guide",
        ];

      case "admin":
        return [
          "Dashboard",
          "User Management",
          "Events",
          "Chats",
          "Profile",
        ];

      default:
        return [
          "Orbit",
        ];
    }
  }

  void _onTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<BottomNavigationBarItem> _items() {
    switch (authManager.userRole) {
      case "alumnus":
        return const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: "Events",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat),
            label: "Chats",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite),
            label: "Donate",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy),
            label: "Guide",
          ),
        ];

      case "student":
        return const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: "Events",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat),
            label: "Chats",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy),
            label: "Guide",
          ),
        ];

      case "admin":
        return const [

          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.manage_accounts_outlined),
            activeIcon: Icon(Icons.manage_accounts),
            label: "Users",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: "Events",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat),
            label: "Chats",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ];

      default:
        return const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
        ];
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
          _titles[_selectedIndex],
          style: AppTextStyles.title,
        ),
      ),

      body: _widgetOptions[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,

        type: BottomNavigationBarType.fixed,

        backgroundColor: AppColors.card,

        selectedItemColor: AppColors.primary,

        unselectedItemColor:
            AppColors.textSecondary,

        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),

        items: _items(),
      ),
    );
  }
}