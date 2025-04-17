import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_spa/services/api_service.dart';

class SignupController extends GetxController {
  // API service instance
  final ApiService _apiService = ApiService();

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
        Get.snackbar("Success", result['message'],
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.toNamed('/login');
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
