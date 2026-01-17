import 'package:flutter/material.dart';
import '../../models/role.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import 'role_edit_page.dart'; // 1. IMPORT THE NEW EDIT PAGE

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

  // 2. NEW: Method to handle navigation and refreshing
  void _navigateToEditPage(Role role) async {
    // Use `await` to wait for the edit page to be closed
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => RoleEditPage(role: role)),
    );

    // If the edit page returned 'true' (meaning a change was made),
    // refresh the role list.
    if (result == true) {
      setState(() {
        _rolesFuture = _loadRoles();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Roles')),
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
                  // 3. UPDATE the onTap to call our new method
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
