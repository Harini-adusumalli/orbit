import 'package:flutter/material.dart';
import 'package:orbit/screens/chat_list_screen.dart';
import 'package:orbit/screens/events_screen.dart';
import 'package:orbit/screens/home_screen.dart';
import 'package:orbit/screens/profile_screen.dart';
import 'package:orbit/main.dart'; // Import authManager
import 'package:orbit/screens/donation_screen.dart';
import 'package:orbit/screens/bot_chat_screen.dart';
import 'package:orbit/screens/admin_home_screen.dart';
import 'package:orbit/screens/alumni_management_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  List<Widget> get _widgetOptions {
    switch (authManager.userRole) {
      case 'alumnus':
        return [
          const HomeScreen(),
          const EventsScreen(),
          const ChatListScreen(),
          const DonationScreen(),
          const ProfileScreen(),
          const ChatBotScreen(),
        ];
      case 'student':
        return [
          const HomeScreen(),
          const EventsScreen(),
          const ChatListScreen(),
          const ProfileScreen(),
          const ChatBotScreen(),
        ];
      case 'admin':
        return [
          const AdminHomeScreen(),
          const AlumniManagementScreen(),
          const EventsScreen(),
          const ChatListScreen(),
          const ProfileScreen(),
        ];
      default:
        return [const HomeScreen()];
    }
  }

  List<String> get _widgetTitles {
    switch (authManager.userRole) {
      case 'alumnus':
        return ['Orbit Home', 'Events', 'Chats', 'Donations', 'Profile', 'AI Assistant'];
      case 'student':
        return ['Orbit Home', 'Events', 'Chats', 'Profile', 'AI Assistant'];
      case 'admin':
        return ['Admin Dashboard', 'Alumni Management', 'Events', 'Chats', 'Profile'];
      default:
        return ['Orbit Home'];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<BottomNavigationBarItem> navItems;
    switch (authManager.userRole) {
      case 'alumnus':
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), label: 'Donations'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'AI Assistant'),
        ];
        break;
      case 'student':
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.smart_toy_outlined), label: 'AI Assistant'),
        ];
        break;
      case 'admin':
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts_outlined), label: 'Alumni Mgmt'),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined), label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ];
        break;
      default:
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        ];
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_widgetTitles.elementAt(_selectedIndex)),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Blend AppBar with background
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: navItems,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}