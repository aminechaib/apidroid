// lib/screens/task_detail_page.dart
// FINAL VERSION

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

class TaskDetailPage extends StatefulWidget {
  final int taskId;
  final List<String> permissions;

  const TaskDetailPage({
    super.key,
    required this.taskId,
    required this.permissions,
  });

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final ApiService _apiService = ApiService();
  late Future<Task> _taskFuture;

  @override
  void initState() {
    super.initState();
    _taskFuture = _apiService.getTaskById(widget.taskId);
  }

  @override
  Widget build(BuildContext context) {
    // Check for permissions
    final bool canManageTasks = widget.permissions.contains('manage-tasks');
    final bool canAssignTasks = widget.permissions.contains('assign-tasks');
    final bool showEditButton = canManageTasks || canAssignTasks;

    return Scaffold(
      appBar: AppBar(
        title: Text('Task #${widget.taskId}'),
        actions: [
          if (showEditButton)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit Task',
              onPressed: () {
                // TODO: Implement navigation to an Edit Task screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit functionality coming soon!'),
                  ),
                );
              },
            ),
        ],
      ),
      body: FutureBuilder<Task>(
        future: _taskFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text('Error: ${snapshot.error ?? 'Could not load task.'}'),
            );
          }

          final task = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Task Title ---
                Text(
                  task.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // --- Metadata Row (Status & Priority) ---
                Row(
                  children: [
                    _buildInfoChip(
                      label: task.status.name,
                      color: Color(
                        Task.colorFromHex(task.status.color ?? '#cccccc'),
                      ),
                      icon: Icons.sync_alt,
                    ),
                    const SizedBox(width: 12),
                    _buildInfoChip(
                      label: task.priority.name,
                      color: Color(
                        Task.colorFromHex(task.priority.color ?? '#cccccc'),
                      ),
                      icon: Icons.priority_high,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- Description ---
                _buildDetailSection(
                  title: 'Description',
                  child: Text(
                    task.description ?? 'No description provided.',
                    style: TextStyle(
                      color: AppTheme.primaryText.withOpacity(0.9),
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Assignee & Creator ---
                _buildDetailSection(
                  title: 'People',
                  child: Column(
                    children: [
                      _buildUserRow(
                        role: 'Assigned To',
                        userName: task.assignee?.name,
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildUserRow(
                        role: 'Created By',
                        userName: task.creator?.name,
                        icon: Icons.person_add_alt_1_outlined,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- Dates ---
                if (task.dueDate != null)
                  _buildDetailSection(
                    title: 'Dates',
                    child: _buildUserRow(
                      role: 'Due Date',
                      userName: task.dueDate,
                      icon: Icons.calendar_today_outlined,
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Helper widget for building styled info chips (Status, Priority)
  Widget _buildInfoChip({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Helper widget for building consistent section layouts
  Widget _buildDetailSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: TextStyle(
            color: AppTheme.primaryText.withOpacity(0.6),
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  // Helper widget for displaying user information
  Widget _buildUserRow({
    required String role,
    String? userName,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryText.withOpacity(0.7), size: 20),
        const SizedBox(width: 16),
        Text(
          '$role:',
          style: TextStyle(color: AppTheme.primaryText.withOpacity(0.7)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            userName ?? 'Unassigned',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
