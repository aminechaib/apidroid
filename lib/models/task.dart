// lib/models/task.dart

// A generic model for nested objects like status, priority, user, etc.
class TaskAttribute {
  final int id;
  final String name;
  final String? color; // Optional color property

  TaskAttribute({required this.id, required this.name, this.color});

  factory TaskAttribute.fromJson(Map<String, dynamic> json) {
    return TaskAttribute(
      id: json['id'],
      name: json['name'] ?? 'N/A',
      color: json['color'],
    );
  }
}

class TaskUser {
  final int id;
  final String name;
  final String? email;

  TaskUser({required this.id, required this.name, this.email});

  factory TaskUser.fromJson(Map<String, dynamic> json) {
    return TaskUser(
      id: json['id'],
      name: json['name'] ?? 'Unnamed',
      email: json['email'],
    );
  }
}

class Task {
  final int id;
  final String title; // Renamed from 'name' for clarity
  final String? description;
  final String? dueDate;

  // Detailed properties for detail view
  final TaskAttribute status;
  final TaskAttribute priority;
  final TaskUser? assignee;
  final TaskUser? creator;

  // Simplified properties for list view
  final List<String> assignedUserNames;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.status,
    required this.priority,
    this.assignee,
    this.creator,
    this.assignedUserNames = const [],
  });

  // Your existing helper function
  static int colorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  /// Constructor for the Task List (matches your original FromJson)
  factory Task.fromListJson(Map<String, dynamic> json) {
    List<String> users = [];
    if (json['assigned_users'] != null && json['assigned_users'] is List) {
      users = (json['assigned_users'] as List)
          .map((user) => user['name'] as String)
          .toList();
    }

    return Task(
      id: json['id'],
      title: json['name'], // Your list uses 'name'
      description: json['description'],
      status: TaskAttribute.fromJson(
        json['status'] ?? {'id': 0, 'name': 'Unknown'},
      ),
      priority: TaskAttribute.fromJson(
        json['priority'] ?? {'id': 0, 'name': 'Unknown'},
      ),
      assignedUserNames: users,
    );
  }

  /// Constructor for the Task Detail page
  factory Task.fromDetailJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      dueDate: json['due_date'],
      status: TaskAttribute.fromJson(json['status']),
      priority: TaskAttribute.fromJson(json['priority']),
      assignee: json['assignee'] != null
          ? TaskUser.fromJson(json['assignee'])
          : null,
      creator: json['creator'] != null
          ? TaskUser.fromJson(json['creator'])
          : null,
    );
  }
}
