// lib/screens/announce_event_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbit/services/api_service.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

class AnnounceEventScreen extends StatefulWidget {
  const AnnounceEventScreen({super.key});

  @override
  State<AnnounceEventScreen> createState() =>
      _AnnounceEventScreenState();
}

class _AnnounceEventScreenState
    extends State<AnnounceEventScreen> {

  final _formKey =
      GlobalKey<FormState>();

  final _titleController =
      TextEditingController();

  final _descriptionController =
      TextEditingController();

  final _dateController =
      TextEditingController();

  final _speakerController =
      TextEditingController();

  final _venueController =
      TextEditingController();

  final ApiService _apiService =
      ApiService();

  bool _isLoading = false;

  DateTime? _selectedDate;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _speakerController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    DateTime? date =
        await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (date == null) return;

    TimeOfDay? time =
        await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay.now(),
    );

    if (time != null) {
      _selectedDate =
          DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );

      setState(() {
        _dateController.text =
            DateFormat(
          'dd MMM yyyy • hh:mm a',
        ).format(
          _selectedDate!,
        );
      });
    }
  }

  Future<void> _submitEvent() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO:
      // await _apiService.createEvent(...);

      await Future.delayed(
        const Duration(
          seconds: 1,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Event announced successfully!",
          ),
          backgroundColor:
              AppColors.success,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
          backgroundColor:
              AppColors.error,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildField({
    required TextEditingController
        controller,
    required String label,
    required IconData icon,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 18,
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
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
          "Announce Event",
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
                    "Create New Event",
                    style:
                        AppTextStyles
                            .heading,
                    textAlign:
                        TextAlign.center,
                  ),

                  const SizedBox(
                      height: 10),

                  Text(
                    "Publish a workshop, seminar or alumni event.",
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
                    label:
                        "Event Title",
                    icon:
                        Icons.title,
                  ),

                  _buildField(
                    controller:
                        _speakerController,
                    label:
                        "Speaker",
                    icon: Icons.person,
                  ),

                  _buildField(
                    controller:
                        _venueController,
                    label:
                        "Venue",
                    icon: Icons.location_on,
                  ),

                  _buildField(
                    controller:
                        _descriptionController,
                    label:
                        "Description",
                    icon:
                        Icons.notes,
                    maxLines: 4,
                  ),

                  _buildField(
                    controller:
                        _dateController,
                    label:
                        "Date & Time",
                    icon:
                        Icons.event,
                    readOnly: true,
                    onTap:
                        _pickDateTime,
                  ),

                  const SizedBox(
                      height: 30),

                  SizedBox(
                    height: 52,
                    child:
                        FilledButton.icon(
                      onPressed:
                          _isLoading
                              ? null
                              : _submitEvent,

                      icon: _isLoading
                          ? const SizedBox(
                              width:
                                  18,
                              height:
                                  18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth:
                                    2,
                                color: Colors
                                    .white,
                              ),
                            )
                          : const Icon(
                              Icons
                                  .campaign,
                            ),

                      label: Text(
                        _isLoading
                            ? "Publishing..."
                            : "Announce Event",
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