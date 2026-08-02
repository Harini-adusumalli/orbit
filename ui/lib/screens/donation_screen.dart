// lib/screens/donation_screen.dart

import 'package:flutter/material.dart';
import 'package:orbit/theme/app_colors.dart';
import 'package:orbit/theme/app_text_styles.dart';

// TODO: Replace with real Donation model
class Donation {
  final String id;
  final double amount;
  final DateTime date;
  final String campaign;

  Donation({
    required this.id,
    required this.amount,
    required this.date,
    required this.campaign,
  });
}

class DonationScreen extends StatelessWidget {
  const DonationScreen({super.key});

  static final List<Donation> _donations = [
    Donation(
      id: '1',
      amount: 50,
      date: DateTime.now().subtract(
        const Duration(days: 30),
      ),
      campaign: 'Annual Fund 2024',
    ),
    Donation(
      id: '2',
      amount: 100,
      date: DateTime.now().subtract(
        const Duration(days: 120),
      ),
      campaign: 'Scholarship Drive',
    ),
  ];

  void _showDonationDialog(
      BuildContext context) {
    final controller =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor:
            AppColors.card,
        title: Text(
          "Make a Donation",
          style: AppTextStyles.title,
        ),
        content: TextField(
          controller: controller,
          keyboardType:
              const TextInputType
                  .numberWithOptions(
            decimal: true,
          ),
          decoration:
              const InputDecoration(
            labelText: "Amount",
            prefixIcon:
                Icon(Icons.currency_rupee),
          ),
        ),
        actions: [

          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text(
              "Cancel",
            ),
          ),

          FilledButton(
            onPressed: () {
              Navigator.pop(context);

              ScaffoldMessenger.of(
                      context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    "Thank you for your donation!",
                  ),
                  backgroundColor:
                      AppColors.success,
                ),
              );
            },
            child: const Text(
              "Donate",
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          AppColors.background,

      appBar: AppBar(
        title: const Text(
          "Donations",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .stretch,

          children: [

            Card(
              color: AppColors.card,
              elevation: 2,

              child: Padding(
                padding:
                    const EdgeInsets
                        .all(20),

                child: Column(
                  children: [

                    const Icon(
                      Icons
                          .volunteer_activism,
                      color:
                          AppColors.primary,
                      size: 50,
                    ),

                    const SizedBox(
                        height: 16),

                    Text(
                      "Support Our Institution",
                      style:
                          AppTextStyles
                              .heading,
                      textAlign:
                          TextAlign
                              .center,
                    ),

                    const SizedBox(
                        height: 10),

                    Text(
                      "Your contribution helps fund scholarships, campus improvements and student activities.",
                      style:
                          AppTextStyles
                              .body,
                      textAlign:
                          TextAlign
                              .center,
                    ),

                    const SizedBox(
                        height: 20),

                    FilledButton.icon(
                      icon: const Icon(
                        Icons
                            .currency_rupee,
                      ),
                      label: const Text(
                        "Donate Now",
                      ),
                      onPressed: () =>
                          _showDonationDialog(
                              context),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              "Donation History",
              style:
                  AppTextStyles
                      .subHeading,
            ),

            const SizedBox(height: 15),

            Expanded(
              child: ListView.builder(
                itemCount:
                    _donations.length,

                itemBuilder:
                    (_, index) {

                  final donation =
                      _donations[
                          index];

                  return Card(
                    color:
                        AppColors
                            .card,
                    margin:
                        const EdgeInsets
                            .only(
                      bottom: 14,
                    ),

                    child: ListTile(

                      leading:
                          CircleAvatar(
                        backgroundColor:
                            AppColors
                                .primary,

                        child:
                            const Icon(
                          Icons.favorite,
                          color: Colors
                              .white,
                        ),
                      ),

                      title: Text(
                        "₹${donation.amount.toStringAsFixed(0)}",
                        style:
                            AppTextStyles
                                .title,
                      ),

                      subtitle: Text(
                        donation
                            .campaign,
                        style:
                            AppTextStyles
                                .body,
                      ),

                      trailing: Text(
                        "${donation.date.day}/${donation.date.month}/${donation.date.year}",
                        style:
                            AppTextStyles
                                .subtitle,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}