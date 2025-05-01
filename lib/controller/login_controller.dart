import 'package:get/get.dart';
import 'package:my_spa/services/api_service.dart';
import 'package:my_spa/controller/user_profile_controller.dart';
import 'package:my_spa/services/user_service.dart';
import 'dart:developer';

class LoginController extends GetxController {
  // API service instance
  final ApiService _apiService = ApiService();
  // User profile controller for managing user data
  final UserProfileController _profileController =
      Get.find<UserProfileController>();
  // User service for authentication
  final UserService _userService = UserService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> loginUser(String email, String password) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final data = await _apiService.loginUser(email, password);

      if (data["success"]) {
        // Save user data to profile controller
        await _profileController.saveLoginData(data["data"]);

        // IMPORTANT: Use user_id instead of id from the response
        final userId = data["data"]["user_id"] is String
            ? int.tryParse(data["data"]["user_id"]) ?? 0
            : data["data"]["user_id"] ?? 0;

        await _userService.saveUserData(
          userId: userId,
          username: data["data"]["username"] ?? "",
          email: data["data"]["email"] ?? "",
        );

        // Always navigate to welcome screen first, then to dashboard
        // This removes the previous login history check
        log('Always going to welcome page first');
        Get.offAllNamed('/welcome');
      } else {
        errorMessage.value = data["message"] ?? "Invalid email or password";
      }
    } catch (e) {
      errorMessage.value = "Something went wrong: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
