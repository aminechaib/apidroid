import 'package:flutter/material.dart';
import '../../models/role.dart';
import '../../services/api_service.dart';
import '../../utils/app_theme.dart';

// A simple model to hold the combined data for this page
class RoleEditPageData {
  final List<Permission> allPermissions;
  final Set<int> assignedPermissionIds;

  RoleEditPageData({
    required this.allPermissions,
    required this.assignedPermissionIds,
  });
}

class RoleEditPage extends StatefulWidget {
  final Role role;
  const RoleEditPage({super.key, required this.role});

  @override
  State<RoleEditPage> createState() => _RoleEditPageState();
}

class _RoleEditPageState extends State<RoleEditPage> {
  final ApiService _apiService = ApiService();
  late Future<RoleEditPageData> _dataFuture;
  // A local set to track changes without waiting for API calls
  late Set<int> _currentPermissionIds;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
    // Initialize the local set with the role's current permissions
    _currentPermissionIds = widget.role.permissions.map((p) => p.id).toSet();
  }

  Future<RoleEditPageData> _loadData() async {
    // Fetch all available permissions from the API
    final permissionsData = await _apiService.getPermissions();
    final allPermissions = permissionsData.map((json) => Permission.fromJson(json)).toList();

    return RoleEditPageData(
      allPermissions: allPermissions,
      assignedPermissionIds: _currentPermissionIds,
    );
  }

  // This method is called when a checkbox is tapped
  void _onPermissionChanged(bool? value, Permission permission) {
    setState(() {
      if (value == true) {
        // If checked, add the permission and call the API
        _currentPermissionIds.add(permission.id);
        _apiService.assignPermissionToRole(widget.role.id, permission.id);
      } else {
        // If unchecked, remove the permission and call the API
        _currentPermissionIds.remove(permission.id);
        _apiService.revokePermissionFromRole(widget.role.id, permission.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Role: ${widget.role.name}'),
        // Add a "Done" button to go back
        actions: [
          IconButton(
            icon: const Icon(Icons.done),
            tooltip: 'Done',
            onPressed: () {
              // Pop the screen and return 'true' to signal a change was made
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
      body: FutureBuilder<RoleEditPageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data found.'));
          }

          final data = snapshot.data!;
          final allPermissions = data.allPermissions;

          return ListView.builder(
            itemCount: allPermissions.length,
            itemBuilder: (context, index) {
              final permission = allPermissions[index];
              // Check if the current permission is in our local set
              final bool isAssigned = _currentPermissionIds.contains(permission.id);

              return CheckboxListTile(
                title: Text(permission.name),
                subtitle: Text(permission.slug, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7))),
                value: isAssigned,
                onChanged: (bool? value) {
                  _onPermissionChanged(value, permission);
                },
              );
            },
          );
        },
      ),
    );
  }
}
