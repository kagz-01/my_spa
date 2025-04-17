import 'package:get/get.dart';
import 'package:my_spa/services/api_service.dart';
import 'package:my_spa/controller/user_profile_controller.dart';

class LoginController extends GetxController {
  // API service instance
  final ApiService _apiService = ApiService();
  // User profile controller for managing user data
  final UserProfileController _profileController =
      Get.find<UserProfileController>();

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

        // Navigate to dashboard
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
