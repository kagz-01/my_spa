// filepath: /home/kagz03/VS Code Projects /Flutter_work/my_spa/lib/services/user_service.dart
import 'package:get_storage/get_storage.dart';

class UserService {
  static final _box = GetStorage();
  static const _userIdKey = 'user_id';
  static const _userNameKey = 'user_name';
  static const _userEmailKey = 'user_email';
  static const _isLoggedInKey = 'is_logged_in';

  // Singleton pattern for user service
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  // Get current user ID (returns null if not logged in)
  int? getCurrentUserId() {
    if (!isLoggedIn()) {
      return null;
    }
    return _box.read(_userIdKey);
  }

  // Get current user ID safely (for API calls)
  // If not logged in, this will throw an error to prevent unauthorized access
  int getAuthenticatedUserId() {
    if (!isLoggedIn()) {
      throw Exception("User not authenticated");
    }
    final userId = _box.read(_userIdKey);
    if (userId == null) {
      throw Exception("User ID not found");
    }
    return userId;
  }

  // Set current user ID
  Future<void> setCurrentUserId(int id) async {
    await _box.write(_userIdKey, id);
  }

  // Get current username
  String? getCurrentUsername() {
    return _box.read(_userNameKey);
  }

  // Set current username
  Future<void> setCurrentUsername(String username) async {
    await _box.write(_userNameKey, username);
  }

  // Get current user email
  String? getCurrentUserEmail() {
    return _box.read(_userEmailKey);
  }

  // Set current user email
  Future<void> setCurrentUserEmail(String email) async {
    await _box.write(_userEmailKey, email);
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return _box.read(_isLoggedInKey) ?? false;
  }

  // Set login status
  Future<void> setLoggedIn(bool status) async {
    await _box.write(_isLoggedInKey, status);
  }

  // Save all user data at once (useful after login/registration)
  Future<void> saveUserData({
    required int userId,
    required String username,
    required String email,
  }) async {
    await _box.write(_userIdKey, userId);
    await _box.write(_userNameKey, username);
    await _box.write(_userEmailKey, email);
    await _box.write(_isLoggedInKey, true);
  }

  // Clear all user data (for logout)
  Future<void> clearUserData() async {
    await _box.remove(_userIdKey);
    await _box.remove(_userNameKey);
    await _box.remove(_userEmailKey);
    await _box.write(_isLoggedInKey, false);
  }
}
