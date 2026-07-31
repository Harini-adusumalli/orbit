import 'package:flutter/material.dart';
import 'package:orbit/screens/add_alumni_screen.dart';

// Simple model for our hardcoded user data
class ManagedUser {
  final String id;
  String name;
  final String role;

  ManagedUser({required this.id, required this.name, required this.role});
}

class AlumniManagementScreen extends StatefulWidget {
  const AlumniManagementScreen({super.key});

  @override
  State<AlumniManagementScreen> createState() => _AlumniManagementScreenState();
}

class _AlumniManagementScreenState extends State<AlumniManagementScreen> {
  // --- HARDCODED DATA FOR THE PROTOTYPE VIDEO ---
  final List<ManagedUser> _users = [
    ManagedUser(id: '1', name: 'Arjun Mehra', role: 'Alumnus'),
    ManagedUser(id: '2', name: 'Priya Kapoor', role: 'Alumnus'),
    ManagedUser(id: '3', name: 'Zoha Khan', role: 'Student'),
    ManagedUser(id: '4', name: 'John Doe', role: 'Student'),
  ];

  void _deleteUser(String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Are you sure?'),
        content: const Text('Do you want to remove this user from the platform?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('No')),
          TextButton(
            onPressed: () {
              setState(() {
                _users.removeWhere((user) => user.id == id);
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _navigateToAddAlumni() {
     Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const AddAlumniScreen(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            // FIX 1: Set the card background color to match the events page
            color: const Color(0xFFc7b299),
            child: ListTile(
              leading: CircleAvatar(
                // FIX 2: Updated avatar style to complement the new card color
                backgroundColor: Colors.brown.shade700,
                child: Icon(
                  user.role == 'Alumnus' ? Icons.school_outlined : Icons.person_outline,
                  color: Colors.white,
                ),
              ),
              // FIX 3: Changed text colors to be dark and readable
              title: Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              subtitle: Text(
                user.role,
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    // FIX 4: Updated icon color to be dark
                    icon: const Icon(Icons.edit_outlined, color: Colors.black54),
                    tooltip: 'Edit User',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edit functionality placeholder')),
                      );
                    },
                  ),
                  IconButton(
                    // FIX 5: Updated icon color for better contrast
                    icon: Icon(Icons.delete_outline, color: Colors.red.shade800),
                    tooltip: 'Delete User',
                    onPressed: () => _deleteUser(user.id),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add User',
        onPressed: _navigateToAddAlumni,
        child: const Icon(Icons.add),
      ),
    );
  }
}