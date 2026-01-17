import 'package:flutter/material.dart';
import '../../models/role.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import 'role_edit_page.dart';

class RoleListPage extends StatefulWidget {
  const RoleListPage({super.key});

  @override
  State<RoleListPage> createState() => _RoleListPageState();
}

class _RoleListPageState extends State<RoleListPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Role>> _rolesFuture;

  @override
  void initState() {
    super.initState();
    _rolesFuture = _loadRoles();
  }

  Future<List<Role>> _loadRoles() async {
    final rolesData = await _apiService.getRoles();
    return rolesData.map((json) => Role.fromJson(json)).toList();
  }

  void _refreshRoles() {
    setState(() {
      _rolesFuture = _loadRoles();
    });
  }

  void _navigateToEditPage(Role role) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => RoleEditPage(role: role)),
    );
    if (result == true) {
      _refreshRoles();
    }
  }

  // 1. NEW: Method to show the create role dialog
  void _showCreateRoleDialog() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Role'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Role Name'),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a role name.';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final success = await _apiService.createRole(
                    nameController.text.trim(),
                  );
                  if (mounted) {
                    Navigator.of(context).pop(); // Close the dialog
                    if (success) {
                      _refreshRoles(); // Refresh the list to show the new role
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Role created successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Failed to create role. The name might already exist.',
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Roles')),
      // 2. NEW: Add the Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRoleDialog,
        tooltip: 'Create Role',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Role>>(
        future: _rolesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No roles found.'));
          }

          final roles = snapshot.data!;

          return ListView.builder(
            itemCount: roles.length,
            itemBuilder: (context, index) {
              final role = roles[index];
              final permissionsPreview = role.permissions
                  .map((p) => p.name)
                  .take(3)
                  .join(', ');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Text(
                    role.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Permissions: $permissionsPreview...',
                    style: TextStyle(
                      color: Theme.of(
                        context,
                      ).textTheme.bodySmall?.color?.withOpacity(0.7),
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _navigateToEditPage(role),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
