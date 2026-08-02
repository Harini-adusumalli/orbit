import 'package:flutter/material.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() =>
      _EditProfileScreenState();
}

class _EditProfileScreenState
    extends State<EditProfileScreen> {
  final _formKey =
      GlobalKey<FormState>();

  late final TextEditingController
      _companyController;
  late final TextEditingController
      _designationController;
  late final TextEditingController
      _skillsController;
  late final TextEditingController
      _mentorshipAreaController;

  @override
  void initState() {
    super.initState();

    _companyController =
        TextEditingController(
      text: 'TechNova Systems',
    );

    _designationController =
        TextEditingController(
      text:
          'Senior Software Engineer',
    );

    _skillsController =
        TextEditingController(
      text:
          'Java, Python, Cloud',
    );

    _mentorshipAreaController =
        TextEditingController(
      text:
          'Career guidance, Coding interviews',
    );
  }

  @override
  void dispose() {
    _companyController.dispose();
    _designationController.dispose();
    _skillsController.dispose();
    _mentorshipAreaController
        .dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!
        .validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Profile updated successfully!",
          ),
          backgroundColor:
              AppColors.success,
        ),
      );

      Navigator.pop(context);
    }
  }

  Widget _buildField({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 18,
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration:
            InputDecoration(
          labelText: label,
          prefixIcon: Icon(
            icon,
            color:
                AppColors.primary,
          ),
        ),
        validator: (value) {
          if (value == null ||
              value.trim().isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          "Edit Profile",
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.check),
            tooltip: "Save",
            onPressed: _saveProfile,
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(
                20),

        child: Card(
          color: AppColors.card,
          elevation: 2,

          child: Padding(
            padding:
                const EdgeInsets.all(
                    20),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .stretch,

                children: [

                  Text(
                    "Update Your Profile",
                    style:
                        AppTextStyles
                            .heading,
                    textAlign:
                        TextAlign.center,
                  ),

                  const SizedBox(
                      height: 10),

                  Text(
                    "Keep your professional information up to date.",
                    style:
                        AppTextStyles
                            .subtitle,
                    textAlign:
                        TextAlign.center,
                  ),

                  const SizedBox(
                      height: 30),

                  _buildField(
                    controller:
                        _companyController,
                    label:
                        "Current Company",
                    icon:
                        Icons.business,
                  ),

                  _buildField(
                    controller:
                        _designationController,
                    label:
                        "Designation",
                    icon: Icons.work,
                  ),

                  _buildField(
                    controller:
                        _skillsController,
                    label:
                        "Technical Skills",
                    icon: Icons.code,
                    maxLines: 2,
                  ),

                  _buildField(
                    controller:
                        _mentorshipAreaController,
                    label:
                        "Mentorship Areas",
                    icon: Icons.school,
                    maxLines: 2,
                  ),

                  const SizedBox(
                      height: 30),

                  SizedBox(
                    height: 52,
                    child:
                        FilledButton.icon(
                      onPressed:
                          _saveProfile,
                      icon: const Icon(
                        Icons.save,
                      ),
                      label: const Text(
                        "Save Changes",
                      ),
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