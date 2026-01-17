import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';
import 'user_edit_page.dart';
import 'add_user_form.dart';

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final ApiService _apiService = ApiService();
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = _loadUsers();
  }

  Future<List<User>> _loadUsers() async {
    final usersData = await _apiService.getUsers();
    return usersData.map((json) => User.fromJson(json)).toList();
  }

  void _navigateToEditPage(User user) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => UserEditPage(user: user)),
    );
    if (result == true) {
      _refreshUsers();
    }
  }

  void _refreshUsers() {
    setState(() {
      _usersFuture = _loadUsers();
    });
  }

  void _showAddUserForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddUserForm(onUserAdded: _refreshUsers),
    );
  }

// UPDATED: Method to handle user deletion
Future<void> _handleDelete(User user) async {
  final bool? confirmed = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Deletion'),
      content: Text('Are you sure you want to delete the user "${user.name}"? This action cannot be undone.'),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );

  if (confirmed != true) return;

  // The API call now returns our new ApiResponse object
  final response = await _apiService.deleteUser(user.id);

  if (!mounted) return; // Check if the widget is still in the tree

  if (response.success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User "${user.name}" deleted.'), backgroundColor: Colors.green),
    );
    _refreshUsers();
  } else {
    // If the deletion failed, show the specific error from the API
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletion Failed'),
        // Use the message from the ApiResponse
        content: Text(response.message ?? 'An unknown error occurred.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK')),
        ],
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Users')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddUserForm,
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
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
            return const Center(child: Text('No users found.'));
          }

          final users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final rolesString = user.roles
                  .map((role) => role.name)
                  .join(', ');

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryColor,
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email),
                      const SizedBox(height: 4),
                      if (rolesString.isNotEmpty)
                        Text(
                          'Roles: $rolesString',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                    ],
                  ),
                  // 2. UPDATE the trailing property to include a delete button
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        tooltip: 'Delete User',
                        onPressed: () => _handleDelete(user),
                      ),
                      const Icon(
                        Icons.chevron_right,
                      ), // Keep the navigation chevron
                    ],
                  ),
                  onTap: () => _navigateToEditPage(user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
