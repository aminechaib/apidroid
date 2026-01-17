// lib/screens/task_list_page.dart

import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import 'task_detail_page.dart'; // CHANGED: Import the (soon to be created) detail page
import 'widgets/add_task_form.dart';

class TaskListPage extends StatefulWidget {
  final Project project;
  // CHANGED: We now need permissions to pass them to the detail page
  final List<String> permissions;

  const TaskListPage({
    super.key,
    required this.project,
    required this.permissions, // CHANGED: Add to constructor
  });

  @override
  State<TaskListPage> createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  final ApiService _apiService = ApiService();
  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _tasksFuture = _loadTasks();
  }

  Future<List<Task>> _loadTasks() async {
    final allTasksData = await _apiService.getTasks();
    final filteredTasks = allTasksData
        .where((taskJson) => taskJson['project']['id'] == widget.project.id)
        // CHANGED: Use the new named constructor
        .map((taskJson) => Task.fromListJson(taskJson))
        .toList();
    return filteredTasks;
  }

  void _refreshTasks() {
    setState(() {
      _tasksFuture = _loadTasks();
    });
  }

  void _showAddTaskForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.primaryBackground,
      builder: (context) {
        return AddTaskForm(
          projectId: widget.project.id,
          onTaskAdded: _refreshTasks,
        );
      },
    );
  }

  // CHANGED: Add navigation method
  void _navigateToTaskDetail(Task task) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (context) => TaskDetailPage(
              taskId: task.id,
              permissions: widget.permissions, // Pass permissions along
            ),
          ),
        )
        .then((_) => _refreshTasks()); // Refresh list when returning
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.project.name)),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskForm,
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
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
            return const Center(
              child: Text('No tasks found for this project.'),
            );
          }
          final tasks = snapshot.data!;
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              // CHANGED: Wrap Card with InkWell for tap functionality
              return InkWell(
                onTap: () => _navigateToTaskDetail(task),
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: const Color(0xFF2C3A4A),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                // CHANGED: Use 'title' instead of 'name'
                                task.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (task.assignedUserNames.isNotEmpty)
                              _buildUserAvatars(task.assignedUserNames),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                // CHANGED: Get color from the priority object
                                color: Color(
                                  Task.colorFromHex(
                                    task.priority.color ?? '#cccccc',
                                  ),
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              // CHANGED: Get name from the priority object
                              task.priority.name,
                              style: TextStyle(
                                color: AppTheme.primaryText.withOpacity(0.7),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                // CHANGED: Get color from the status object
                                color: Color(
                                  Task.colorFromHex(
                                    task.status.color ?? '#cccccc',
                                  ),
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                // CHANGED: Get name from the status object
                                task.status.name,
                                style: TextStyle(
                                  // CHANGED: Get color from the status object
                                  color: Color(
                                    Task.colorFromHex(
                                      task.status.color ?? '#cccccc',
                                    ),
                                  ),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserAvatars(List<String> userNames) {
    // ... (This widget remains unchanged)
    final displayUsers = userNames.length > 3
        ? userNames.sublist(0, 3)
        : userNames;
    return SizedBox(
      width: (displayUsers.length * 24.0) + 10,
      height: 34,
      child: Stack(
        children: List.generate(displayUsers.length, (index) {
          final userName = displayUsers[index];
          return Positioned(
            left: index * 24.0,
            child: CircleAvatar(
              radius: 17,
              backgroundColor: AppTheme.primaryBackground,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
