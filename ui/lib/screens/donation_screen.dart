// lib/screens/donation_screen.dart
import 'package:flutter/material.dart';

// TODO: Replace with a real Donation model from your backend response
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

  // TODO: Fetch real donation history from your /api/donations endpoint
  static final List<Donation> _donations = [
    Donation(id: '1', amount: 50.00, date: DateTime.now().subtract(const Duration(days: 30)), campaign: 'Annual Fund 2024'),
    Donation(id: '2', amount: 100.00, date: DateTime.now().subtract(const Duration(days: 120)), campaign: 'Scholarship Drive'),
  ];

  void _showMakeDonationDialog(BuildContext context) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Make a Donation'),
          content: TextField(
            controller: amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Amount (\$)',
              prefixIcon: Icon(Icons.attach_money),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // TODO: Implement API call to POST /api/donations
                // final amount = double.tryParse(amountController.text);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your generous donation!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Donate'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Donations'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Make a Donation Card ---
            Card(
              elevation: 4,
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Text(
                      'Support Our Institution',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your contributions help fund scholarships and campus development.',
                       style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer.withOpacity(0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => _showMakeDonationDialog(context),
                      child: const Text('Make a Donation'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Donation History',
              style: theme.textTheme.headlineSmall,
            ),
            const Divider(height: 24),

            // --- Donation History List ---
            Expanded(
              child: _donations.isEmpty
                  ? const Center(child: Text('You have not made any donations yet.'))
                  : ListView.builder(
                      itemCount: _donations.length,
                      itemBuilder: (context, index) {
                        final donation = _donations[index];
                        return ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.favorite)),
                          title: Text(
                            '\$${donation.amount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(donation.campaign),
                          trailing: Text(
                             '${donation.date.day}/${donation.date.month}/${donation.date.year}',
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
