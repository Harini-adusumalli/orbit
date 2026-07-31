// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:orbit/main.dart';
import 'package:orbit/screens/edit_profile_screen.dart';
import 'package:orbit/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;
    setState(() { _isLoading = true; _error = null; });

    if (authManager.userRole == 'alumnus') {
      try {
        final data = await _apiService.getMyProfile();
        if (mounted) {
          setState(() { _profileData = data; });
        }
      } catch (e) {
        if (mounted) {
          setState(() { _error = "Could not load alumni profile."; });
        }
      }
    }
    if (mounted) {
      setState(() { _isLoading = false; });
    }
  }

  void _logout() {
    authManager.logout();
  }

  Future<void> _navigateToEditProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserRole = authManager.userRole;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _buildProfileBody(context), // Use a helper to build the body
    );
  }

  // --- WIDGET BUILDER LOGIC ---
  Widget _buildProfileBody(BuildContext context) {
    final theme = Theme.of(context);
    final currentRollNumber = authManager.rollNumber;
    final currentUserRole = authManager.userRole;

    // --- NEW: ADMIN-SPECIFIC UI ---
    if (currentUserRole == 'admin') {
      return ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Text('Admin Settings', style: theme.textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Logged in as: ${currentRollNumber ?? 'N/A'}',
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.black54),
          ),
          const Divider(height: 40),
          _buildSettingsTile(
            context,
            icon: Icons.settings_outlined,
            title: 'Platform Settings',
            subtitle: 'Configure platform-wide options',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Platform settings placeholder.')),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.security_outlined,
            title: 'Security',
            subtitle: 'Manage roles and permissions',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Security settings placeholder.')),
              );
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.history,
            title: 'View Audit Logs',
            subtitle: 'Track admin and user activity',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Audit logs placeholder.')),
              );
            },
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.red.withOpacity(0.8),
            ),
          ),
        ],
      );
    }
    
    // --- EXISTING UI for ALUMNI and STUDENTS ---
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentUserRole == 'alumnus')
            Align(
              alignment: Alignment.topRight,
              child: TextButton.icon(
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Profile'),
                onPressed: _navigateToEditProfile,
              ),
            ),
          Text(
            _profileData?['Full_Name'] ?? currentRollNumber ?? 'Name Not Available',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Role: ${currentUserRole?.capitalize() ?? 'N/A'}',
            style: theme.textTheme.headlineSmall?.copyWith(color: Colors.black54),
          ),
          const Divider(height: 40),
          if (currentUserRole == 'alumnus' && _profileData != null)
            ..._buildAlumniDetails(theme),
          if (currentUserRole == 'student')
            Text(
              'Welcome, $currentRollNumber!',
              style: theme.textTheme.bodyLarge,
            ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text('Log Out'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.red.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER for Admin Settings List ---
  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, size: 28),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }

  // --- HELPER for Alumni Details ---
  List<Widget> _buildAlumniDetails(ThemeData theme) {
    return [
      _buildInfoRow(theme, 'Company', _profileData?['Current_Company']),
      _buildInfoRow(theme, 'Designation', _profileData?['Designation']),
      _buildInfoRow(theme, 'Industry', _profileData?['Industry']),
      _buildInfoRow(theme, 'Mentorship Area', _profileData?['Mentorship_Area']),
      const SizedBox(height: 16),
    ];
  }

  Widget _buildInfoRow(ThemeData theme, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            value ?? 'Not Provided',
            style: theme.textTheme.bodyLarge?.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}