import 'package:flutter/material.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class PostMentorshipScreen extends StatefulWidget {
  const PostMentorshipScreen({super.key});

  @override
  State<PostMentorshipScreen> createState() =>
      _PostMentorshipScreenState();
}

class _PostMentorshipScreenState
    extends State<PostMentorshipScreen> {
  final _formKey =
      GlobalKey<FormState>();

  final _titleController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  final _skillsController =
      TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  void _submitOpportunity() {
    if (_formKey.currentState!
        .validate()) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Mentorship opportunity posted successfully!",
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
    required String hint,
    required IconData icon,
    bool multiLine = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 18,
      ),
      child: TextFormField(
        controller: controller,
        maxLines:
            multiLine ? 5 : 1,
        minLines:
            multiLine ? 3 : 1,
        decoration:
            InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color:
                AppColors.primary,
          ),
          alignLabelWithHint: true,
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
          "Post Mentorship",
        ),
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
                    "Create Mentorship Opportunity",
                    style:
                        AppTextStyles
                            .heading,
                    textAlign:
                        TextAlign.center,
                  ),

                  const SizedBox(
                      height: 10),

                  Text(
                    "Share your expertise and help students grow.",
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
                        _titleController,
                    label: "Title",
                    hint:
                        "Resume Review for SWE",
                    icon:
                        Icons.title,
                  ),

                  _buildField(
                    controller:
                        _descriptionController,
                    label:
                        "Description",
                    hint:
                        "Describe what you are offering...",
                    icon:
                        Icons.description,
                    multiLine: true,
                  ),

                  _buildField(
                    controller:
                        _skillsController,
                    label:
                        "Required Skills",
                    hint:
                        "Java, Python, Flutter",
                    icon:
                        Icons.code,
                  ),

                  const SizedBox(
                      height: 30),

                  SizedBox(
                    height: 52,
                    child:
                        FilledButton.icon(
                      onPressed:
                          _submitOpportunity,
                      icon: const Icon(
                        Icons.school,
                      ),
                      label: const Text(
                        "Post Opportunity",
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