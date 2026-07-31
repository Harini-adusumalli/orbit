import 'package:flutter/foundation.dart';

class AuthManager extends ChangeNotifier {
  String? _token;
  String? _userRole;
  String? _rollNumber;

  String? get token => _token;
  String? get userRole => _userRole;
  String? get rollNumber => _rollNumber;

  bool get isLoggedIn => _token != null;

  void login(String token, String role, String rollNumber) {
    _token = token;
    _userRole = role;
    _rollNumber = rollNumber;
    notifyListeners();
  }

  void logout() {
    _token = null;
    _userRole = null;
    _rollNumber = null;
    notifyListeners();
  }
}