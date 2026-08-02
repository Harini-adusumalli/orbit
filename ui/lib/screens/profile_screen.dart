import 'package:flutter/material.dart';
import 'package:orbit/main.dart';
import 'package:orbit/screens/edit_profile_screen.dart';
import 'package:orbit/services/api_service.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

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

    setState(() {
      _isLoading = true;
      _error = null;
    });

    if (authManager.userRole == "alumnus") {
      try {
        final data = await _apiService.getMyProfile();

        if (mounted) {
          setState(() {
            _profileData = data;
          });
        }
      } catch (e) {
        if (mounted) {
          _error = "Unable to load profile.";
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _logout() {
    authManager.logout();
  }

  Future<void> _navigateToEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    final role = authManager.userRole;

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Profile",
          style: AppTextStyles.title,
        ),
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            )
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: AppTextStyles.body,
                  ),
                )
              : _buildProfileBody(role),
    );
  }

  Widget _buildProfileBody(String? role) {
    final rollNo = authManager.rollNumber;

    if (role == "admin") {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [

          Text(
            "Admin Settings",
            style: AppTextStyles.heading,
          ),

          const SizedBox(height: 8),

          Text(
            "Logged in as $rollNo",
            style: AppTextStyles.subtitle,
          ),

          const SizedBox(height: 25),

          Card(
            child: Column(
              children: [

                _buildSettingsTile(
                  Icons.settings,
                  "Platform Settings",
                  "Configure Orbit",
                ),

                const Divider(),

                _buildSettingsTile(
                  Icons.security,
                  "Security",
                  "Manage permissions",
                ),

                const Divider(),

                _buildSettingsTile(
                  Icons.history,
                  "Audit Logs",
                  "View activity",
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          FilledButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        ],
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          if (role == "alumnus")
            Align(
              alignment: Alignment.topRight,
              child: FilledButton.icon(
                onPressed: _navigateToEditProfile,
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
              ),
            ),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    _profileData?["Full_Name"] ??
                        rollNo ??
                        "",
                    style: AppTextStyles.heading,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    role?.capitalize() ?? "",
                    style: AppTextStyles.subtitle,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          if (role == "alumnus" &&
              _profileData != null)
            ..._buildAlumniDetails(),

          if (role == "student")
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Welcome, $rollNo!",
                  style: AppTextStyles.body,
                ),
              ),
            ),

          const SizedBox(height: 30),

          FilledButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            label: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      IconData icon,
      String title,
      String subtitle) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.title,
      ),
      subtitle: Text(
        subtitle,
        style: AppTextStyles.subtitle,
      ),
    );
  }
    List<Widget> _buildAlumniDetails() {
    return [

      Card(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              _buildInfoRow(
                "Company",
                _profileData?["Current_Company"],
              ),

              const Divider(),

              _buildInfoRow(
                "Designation",
                _profileData?["Designation"],
              ),

              const Divider(),

              _buildInfoRow(
                "Industry",
                _profileData?["Industry"],
              ),

              const Divider(),

              _buildInfoRow(
                "Mentorship Area",
                _profileData?["Mentorship_Area"],
              ),
            ],
          ),
        ),
      ),
    ];
  }

  Widget _buildInfoRow(
    String title,
    String? value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style: AppTextStyles.title,
          ),

          const SizedBox(height: 6),

          Text(
            value ?? "Not Provided",
            style: AppTextStyles.subtitle,
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