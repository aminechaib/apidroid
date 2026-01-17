import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

class UserEditPage extends StatefulWidget {
  final User user;

  const UserEditPage({super.key, required this.user});

  @override
  State<UserEditPage> createState() => _UserEditPageState();
}

class _UserEditPageState extends State<UserEditPage> {
  final _apiService = ApiService();
  
  // State variables
  late Future<List<dynamic>> _rolesFuture;
  late Set<int> _selectedRoleIds;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Fetch all available roles from the API
    _rolesFuture = _apiService.getRoles();
    // Initialize the selected roles based on the user's current roles
    _selectedRoleIds = widget.user.roles.map((role) => role.id).toSet();
  }

  Future<void> _submitChanges() async {
    setState(() => _isSubmitting = true);

    final userData = {
      'name': widget.user.name, // We are not editing the name here, but it's required
      'email': widget.user.email, // Same for email
      'roles': _selectedRoleIds.toList(), // Send the updated list of role IDs
    };

    final success = await _apiService.updateUser(widget.user.id, userData);

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User updated successfully!'), backgroundColor: Colors.green),
      );
      // Pop the screen to go back to the user list
      Navigator.of(context).pop(true); // Pass back 'true' to indicate success
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update user.'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit ${widget.user.name}'),
        actions: [
          // Add a save button to the app bar
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Save Changes',
            onPressed: _isSubmitting ? null : _submitChanges,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _rolesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Failed to load roles.'));
          }

          final allRoles = snapshot.data!;

          return _isSubmitting
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text('Assign Roles', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    // Use a Card for better visual separation
                    Card(
                      child: Column(
                        children: allRoles.map((role) {
                          final roleId = role['id'] as int;
                          final bool isSelected = _selectedRoleIds.contains(roleId);

                          return CheckboxListTile(
                            title: Text(role['name']),
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedRoleIds.add(roleId);
                                } else {
                                  _selectedRoleIds.remove(roleId);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                );
        },
      ),
    );
  }
}
