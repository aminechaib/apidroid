// A simple model for a Role
class Role {
  final int id;
  final String name;

  Role({required this.id, required this.name});

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
    );
  }
}

// The main User model
class User {
  final int id;
  final String name;
  final String email;
  final List<Role> roles;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Safely parse the list of roles
    var rolesList = json['roles'] as List? ?? [];
    List<Role> parsedRoles = rolesList.map((r) => Role.fromJson(r)).toList();

    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      roles: parsedRoles,
    );
  }
}
