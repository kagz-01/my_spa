import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_spa/services/api_service.dart';
import 'package:my_spa/services/user_service.dart';
import 'package:my_spa/controller/user_profile_controller.dart';

class SignupController extends GetxController {
  // API service instance
  final ApiService _apiService = ApiService();
  final UserService _userService = UserService();

  // Get the user profile controller
  final UserProfileController _profileController =
      Get.find<UserProfileController>();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> signupUser(
      String username, String email, String password) async {
    // Input validation
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = "All fields must be filled!";
      return;
    }

    if (!email.contains('@') || !email.contains('.')) {
      errorMessage.value = "Enter a valid email address!";
      return;
    }

    isLoading.value = true;
    errorMessage.value = "";

    try {
      final result = await _apiService.registerUser(username, email, password);

      if (result['success']) {
        // Show success message
        Get.snackbar(
          "Account Created Successfully",
          "Please log in with your new account details",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Always direct to login page after successful signup
        Get.offAllNamed('/login');
      } else {
        errorMessage.value = result['message'];
        Get.snackbar("Signup Failed", result['message'],
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      errorMessage.value = "Something went wrong: $e";
      Get.snackbar("Network Error", errorMessage.value,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
}
