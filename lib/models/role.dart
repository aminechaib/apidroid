// A simple model for a Permission
class Permission {
  final int id;
  final String name;
  final String slug;

  Permission({required this.id, required this.name, required this.slug});

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }
}

// The main Role model
class Role {
  final int id;
  final String name;
  final String slug;
  final List<Permission> permissions;

  Role({
    required this.id,
    required this.name,
    required this.slug,
    required this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    var permissionsList = json['permissions'] as List? ?? [];
    List<Permission> parsedPermissions = permissionsList.map((p) => Permission.fromJson(p)).toList();

    return Role(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      permissions: parsedPermissions,
    );
  }
}
