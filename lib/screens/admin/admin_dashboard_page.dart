import 'package:flutter/material.dart';
import 'user_list_page.dart';
import 'role_list_page.dart';

class AdminDashboardPage extends StatelessWidget {
  // 1. ACCEPT the permissions from the HomePage
  final bool canManageUsers;
  final bool canManageRoles;

  const AdminDashboardPage({
    super.key,
    required this.canManageUsers,
    required this.canManageRoles,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 2. CONDITIONALLY show the "Manage Users" card
          if (canManageUsers)
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.people, size: 40),
                title: const Text(
                  'Manage Users',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text(
                  'Create, edit, and delete users and their roles.',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const UserListPage(),
                    ),
                  );
                },
              ),
            ),

          // Add spacing only if both cards are visible
          if (canManageUsers && canManageRoles) const SizedBox(height: 16),

          // 3. CONDITIONALLY show the "Manage Roles" card
          if (canManageRoles)
            Card(
              elevation: 2,
              child: ListTile(
                leading: const Icon(Icons.policy, size: 40),
                title: const Text(
                  'Manage Roles & Permissions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Define roles and assign permissions.'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RoleListPage(),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
