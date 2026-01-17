import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import 'login_page.dart';
import 'task_list_page.dart';
import 'admin/admin_dashboard_page.dart';
import '../utils/app_theme.dart';

// 1. UPDATED: The data model now holds the list of permission slugs
class HomePageData {
  final Map<String, dynamic> user;
  final List<String> permissions; // <-- NEW
  final List<Project> projects;

  HomePageData({
    required this.user,
    required this.permissions, // <-- NEW
    required this.projects,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  late Future<HomePageData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  // 2. UPDATED: The load method now parses the new API response
  Future<HomePageData> _loadData() async {
    try {
      // We now only need to wait for two API calls
      final results = await Future.wait([
        _apiService.getCurrentUser(), // This now returns user AND permissions
        _apiService.getProjects(),
      ]);

      // Safely parse the user and permissions data
      final userData = results[0] as Map<String, dynamic>? ?? {};
      final user = userData['user'] as Map<String, dynamic>? ?? {};
      final permissions = List<String>.from(
        userData['permissions'] as List? ?? [],
      );

      // Safely parse the project data
      final projectData = results[1] as List<dynamic>? ?? [];
      final projects = projectData
          .map((json) => Project.fromJson(json))
          .toList();

      return HomePageData(
        user: user,
        permissions: permissions,
        projects: projects,
      );
    } catch (e) {
      print("Error loading home page data: $e");
      throw Exception('Failed to load data');
    }
  }

  void _handleLogout(BuildContext context) async {
    final storageService = StorageService();
    await storageService.deleteToken();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<HomePageData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(child: Text('An error occurred: ${snapshot.error}'));
          }

          final homeData = snapshot.data!;
          final projects = homeData.projects;
          // 3. NEW: Check for specific permissions
          final bool canManageUsers = homeData.permissions.contains(
            'manage-users',
          );
          final bool canManageRoles = homeData.permissions.contains(
            'manage-roles',
          );
          // The dashboard button is shown if the user has EITHER permission
          final bool showDashboardButton = canManageUsers || canManageRoles;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Projects'),
              actions: [
                // 4. UPDATED: The logic is now based on permissions
                if (showDashboardButton)
                  IconButton(
                    icon: const Icon(Icons.dashboard_customize),
                    tooltip: 'Admin Dashboard',
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          // Pass the permissions to the dashboard so it knows what to show
                          builder: (context) => AdminDashboardPage(
                            canManageUsers: canManageUsers,
                            canManageRoles: canManageRoles,
                          ),
                        ),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'Logout',
                  onPressed: () => _handleLogout(context),
                ),
              ],
            ),
            body: projects.isEmpty
                ? const Center(child: Text('No projects found.'))
                : ListView.builder(
                    itemCount: projects.length,
                    itemBuilder: (context, index) {
                      final project = projects[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: const Color(0xFF2C3A4A),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            project.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            'Created by: ${project.creatorName}',
                            style: TextStyle(
                              color: AppTheme.primaryText.withOpacity(0.7),
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_right,
                            color: AppTheme.primaryText,
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaskListPage(project: project),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}
