
// lib/screens/task_detail_page.dart
import 'package:flutter/material.dart';

class TaskDetailPage extends StatelessWidget {
  final int taskId;
  final List<String> permissions;
  const TaskDetailPage({super.key, required this.taskId, required this.permissions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task #$taskId')),
      body: const Center(child: Text('Detail page coming soon!')),
    );
  }
}
