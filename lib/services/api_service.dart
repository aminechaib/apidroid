import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'storage_service.dart';

// A helper class to hold the result of an API call
class ApiResponse {
  final bool success;
  final String? message;
  ApiResponse({required this.success, this.message});
}

class ApiService {
  // --- Base URL Configuration ---
  static String get _host {
    if (kIsWeb) {
      return 'http://localhost:8000';
    } else {
      return 'http://10.0.2.2:8000';
    }
  }

  static String get baseUrl => '$_host/api/v1';
  static String get loginUrl => '$_host/api/login';

  // --- Helper for Authenticated Headers ---
  Future<Map<String, String>?> _getAuthHeaders({bool isPost = false}) async {
    final storage = StorageService();
    final token = await storage.readToken();
    if (token == null) {
      print('Authentication token not found.');
      return null;
    }
    final headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    if (isPost) {
      headers['Content-Type'] = 'application/json';
    }
    return headers;
  }

  // --- Login Method ---
  Future<String?> login(String email, String password) async {
    final url = Uri.parse(loginUrl);
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        print('Login failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('An error occurred during login: $e');
      return null;
    }
  }

  // UPDATED: Get Current User
  Future<Map<String, dynamic>?> getCurrentUser() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return null;

    final url = Uri.parse('$baseUrl/user');
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        // The API now returns a more complex object.
        // We just return the whole thing, and the UI will parse it.
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('An error occurred while fetching user: $e');
      return null;
    }
  }

  // --- Get Projects Method ---
  Future<List<dynamic>> getProjects() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return [];
    final url = Uri.parse('$baseUrl/projects');
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body)['data'];
      print('Failed to fetch projects: ${response.statusCode}');
      return [];
    } catch (e) {
      print('An error occurred while fetching projects: $e');
      return [];
    }
  }

  // --- Get Tasks Method ---
  Future<List<dynamic>> getTasks() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return [];
    final url = Uri.parse('$baseUrl/tasks');
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body)['data'];
      print('Failed to fetch tasks: ${response.statusCode}');
      return [];
    } catch (e) {
      print('An error occurred while fetching tasks: $e');
      return [];
    }
  }

  // --- Get Simple Users List (for dropdowns) ---
  Future<List<dynamic>> getUsersList() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return [];
    final url = Uri.parse('$baseUrl/users-list');
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
      print('Failed to fetch users list: ${response.statusCode}');
      return [];
    } catch (e) {
      print('An error occurred while fetching users list: $e');
      return [];
    }
  }

  // --- Get All Users (for admin list) ---
  Future<List<dynamic>> getUsers() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return [];
    final url = Uri.parse('$baseUrl/users');
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body)['data'];
      print('Failed to fetch users: ${response.statusCode}');
      return [];
    } catch (e) {
      print('An error occurred while fetching users: $e');
      return [];
    }
  }

  // --- Create a Task ---
  Future<bool> createTask(Map<String, dynamic> taskData) async {
    final headers = await _getAuthHeaders(isPost: true);
    if (headers == null) return false;
    final url = Uri.parse('$baseUrl/tasks');
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(taskData),
      );
      if (response.statusCode == 201) return true;
      print('Failed to create task: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    } catch (e) {
      print('An error occurred while creating task: $e');
      return false;
    }
  }

  // --- Get All Roles ---
  Future<List<dynamic>> getRoles() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return [];
    final url = Uri.parse('$baseUrl/roles');
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
      print('Failed to fetch roles: ${response.statusCode}');
      return [];
    } catch (e) {
      print('An error occurred while fetching roles: $e');
      return [];
    }
  }

  // --- Update a User ---
  Future<bool> updateUser(int userId, Map<String, dynamic> userData) async {
    final headers = await _getAuthHeaders(isPost: true);
    if (headers == null) return false;
    final url = Uri.parse('$baseUrl/users/$userId');
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(userData),
      );
      if (response.statusCode == 200) return true;
      print('Failed to update user: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    } catch (e) {
      print('An error occurred while updating user: $e');
      return false;
    }
  }

  // --- Create a User ---
  Future<bool> createUser(Map<String, dynamic> userData) async {
    final headers = await _getAuthHeaders(isPost: true);
    if (headers == null) return false;
    final url = Uri.parse('$baseUrl/users');
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(userData),
      );
      if (response.statusCode == 201) return true;
      print('Failed to create user: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    } catch (e) {
      print('An error occurred while creating user: $e');
      return false;
    }
  }

  // --- Delete a User ---
  Future<ApiResponse> deleteUser(int userId) async {
    final headers = await _getAuthHeaders();
    if (headers == null)
      return ApiResponse(success: false, message: 'Not authenticated.');
    final url = Uri.parse('$baseUrl/users/$userId');
    try {
      final response = await http.delete(url, headers: headers);
      if (response.statusCode == 204) {
        return ApiResponse(success: true);
      } else {
        final data = jsonDecode(response.body);
        final message = data['error'] ?? 'An unknown error occurred.';
        return ApiResponse(success: false, message: message);
      }
    } catch (e) {
      return ApiResponse(success: false, message: 'A network error occurred.');
    }
  }

  // --- NEW: Get All Permissions ---
  Future<List<dynamic>> getPermissions() async {
    final headers = await _getAuthHeaders();
    if (headers == null) return [];
    final url = Uri.parse('$baseUrl/permissions');
    try {
      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
      print('Failed to fetch permissions: ${response.statusCode}');
      return [];
    } catch (e) {
      print('An error occurred while fetching permissions: $e');
      return [];
    }
  }

  // --- NEW: Assign a Permission to a Role ---
  Future<bool> assignPermissionToRole(int roleId, int permissionId) async {
    final headers = await _getAuthHeaders(isPost: true);
    if (headers == null) return false;
    final url = Uri.parse('$baseUrl/roles/assign-permission');
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'role_id': roleId, 'permission_id': permissionId}),
      );
      if (response.statusCode == 200) return true;
      print('Failed to assign permission: ${response.statusCode}');
      return false;
    } catch (e) {
      print('An error occurred while assigning permission: $e');
      return false;
    }
  }

  // --- NEW: Revoke a Permission from a Role ---
  Future<bool> revokePermissionFromRole(int roleId, int permissionId) async {
    final headers = await _getAuthHeaders(isPost: true);
    if (headers == null) return false;
    final url = Uri.parse('$baseUrl/roles/revoke-permission');
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'role_id': roleId, 'permission_id': permissionId}),
      );
      if (response.statusCode == 200) return true;
      print('Failed to revoke permission: ${response.statusCode}');
      return false;
    } catch (e) {
      print('An error occurred while revoking permission: $e');
      return false;
    }
  }
}
