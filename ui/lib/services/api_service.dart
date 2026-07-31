// lib/services/api_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:orbit/config.dart';
import 'package:orbit/main.dart';

// Centralized API routes for maintainability
class _ApiRoutes {
  static const String login = '$apiBaseUrl/login';
  static const String signup = '$apiBaseUrl/signup';
  static const String query = '$apiBaseUrl/query';
  static const String geminiChat = '$apiBaseUrl/chat';
  static const String sendChatRequest = '$apiBaseUrl/chat-requests/send';
  static const String getChats = '$apiBaseUrl/chats';
  static const String respondToChatRequest = '$apiBaseUrl/chat-requests';
  static const String getMessages = '$apiBaseUrl/chats'; // Base path for messages
  static const String getMyProfile = '$apiBaseUrl/profile';
  static const String createEvent = '$apiBaseUrl/events';
  static const String addAlumni = '$apiBaseUrl/admin/add_alumni';
  static const String addStudent = '$apiBaseUrl/admin/add_student';
}

class ApiService {
  // Helper for authenticated headers
  Map<String, String> get _headers {
    final token = authManager.token;
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'x-access-token': token,
    };
  }

  // Robust error handling
  dynamic _handleResponse(http.Response response) {
    final body = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw HttpException(body['error'] ?? 'An unknown error occurred.');
    }
  }

  // --- Authentication ---
  Future<Map<String, dynamic>> login(String rollno, String password) async {
    final response = await http.post(
      Uri.parse(_ApiRoutes.login),
      headers: _headers,
      body: jsonEncode({'rollno': rollno, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> signup(String rollno, String password, String role) async {
    final response = await http.post(
      Uri.parse(_ApiRoutes.signup),
      headers: _headers,
      body: jsonEncode({'rollno': rollno, 'password': password, 'role': role}),
    );
    return _handleResponse(response);
  }

  // --- Core Features ---
  Future<Map<String, dynamic>> semanticSearch(String query) async {
    final response = await http.post(
      Uri.parse(_ApiRoutes.query),
      headers: _headers,
      body: jsonEncode({'query': query}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postToGeminiChat(String query, {List<Map<String, dynamic>>? results}) async {
    final response = await http.post(
      Uri.parse(_ApiRoutes.geminiChat),
      headers: _headers,
      body: jsonEncode({'query': query, 'results': results ?? []}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await http.get(
      Uri.parse(_ApiRoutes.getMyProfile),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  // --- Chat ---
  Future<Map<String, dynamic>> createOrGetChatRoom(String alumniId) async {
    final response = await http.post(
      Uri.parse(_ApiRoutes.sendChatRequest),
      headers: _headers,
      body: jsonEncode({'alumni_id': alumniId}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> getChatRooms() async {
    final response = await http.get(
      Uri.parse(_ApiRoutes.getChats),
      headers: _headers,
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> respondToChatRequest(String requestId, String action) async {
    final response = await http.post(
      Uri.parse('${_ApiRoutes.respondToChatRequest}/$requestId/$action'),
      headers: _headers,
    );
    return _handleResponse(response);
  }

// In lib/services/api_service.dart

Future<Map<String, dynamic>> getMessages(String roomId) async {
  final response = await http.get(
    Uri.parse('${_ApiRoutes.getMessages}/$roomId/messages'),
    headers: _headers,
  );
  // Cast the dynamic response to the correct type
  return _handleResponse(response) as Map<String, dynamic>;
}

  // --- Admin ---
  Future<Map<String, dynamic>> createEvent(String title, String description, String date) async {
    final response = await http.post(
      Uri.parse(_ApiRoutes.createEvent),
      headers: _headers,
      body: jsonEncode({'title': title, 'description': description, 'event_date': date}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> addAlumni(String name, String email, String rollno, String password) async {
    final response = await http.post(
      Uri.parse(_ApiRoutes.addAlumni),
      headers: _headers,
      body: jsonEncode({'name': name, 'email': email, 'rollno': rollno, 'password': password}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> addStudent(String name, String email, String rollno, String password) async {
    final response = await http.post(
      Uri.parse(_ApiRoutes.addStudent),
      headers: _headers,
      body: jsonEncode({'name': name, 'email': email, 'rollno': rollno, 'password': password}),
    );
    return _handleResponse(response);
  }


}

