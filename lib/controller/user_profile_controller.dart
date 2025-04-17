import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_spa/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileController extends GetxController {
  final ApiService _apiService = ApiService();

  // User data observables
  var userId = 0.obs;
  var username = ''.obs;
  var email = ''.obs;
  var phone = ''.obs;
  var bio = ''.obs;
  var profileImage = ''.obs;

  // Loading states
  var isLoading = false.obs;
  var isUpdating = false.obs;
  var isUploading = false.obs;
  var isChangingPassword = false.obs;

  // Error messages
  var errorMessage = ''.obs;

  // Success messages
  var successMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Only load the data from local storage, don't fetch from API automatically
    _loadFromPreferences();
    // Removed the automatic API call that was here before
  }

  // Load user data from SharedPreferences and then optionally fetch from API
  Future<void> loadUserData({bool fetchFromApi = false}) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // First try to load from SharedPreferences for instant display
      await _loadFromPreferences();

      // Then fetch fresh data from API if requested and we have a user ID
      if (fetchFromApi && userId.value > 0) {
        await fetchUserProfile();
      }
    } catch (e) {
      errorMessage.value = "Failed to load user data: $e";
    } finally {
      isLoading.value = false;
    }
  }

  // Load user data from SharedPreferences
  Future<void> _loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    userId.value = prefs.getInt('user_id') ?? 0;
    username.value = prefs.getString('username') ?? '';
    email.value = prefs.getString('email') ?? '';
    phone.value = prefs.getString('phone') ?? '';
    bio.value = prefs.getString('bio') ?? '';
    profileImage.value = prefs.getString('profile_image') ?? '';
  }

  // Save user data to SharedPreferences
  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('user_id', userId.value);
    await prefs.setString('username', username.value);
    await prefs.setString('email', email.value);
    await prefs.setString('phone', phone.value);
    await prefs.setString('bio', bio.value);
    await prefs.setString('profile_image', profileImage.value);
  }

  // Fetch user profile from API
  Future<void> fetchUserProfile() async {
    if (userId.value <= 0) {
      errorMessage.value = "No user ID found";
      return;
    }

    try {
      final result = await _apiService.getUserProfile(userId.value);

      if (result['success'] == true && result['data'] != null) {
        final userData = result['data'];

        username.value = userData['username'] ?? username.value;
        email.value = userData['email'] ?? email.value;
        phone.value = userData['phone'] ?? phone.value;
        bio.value = userData['bio'] ?? bio.value;

        if (userData['profile_image'] != null &&
            userData['profile_image'].isNotEmpty) {
          profileImage.value = userData['profile_image'];
        }

        // Save updated data locally
        await _saveToPreferences();
      } else {
        errorMessage.value = result['message'] ?? "Failed to fetch profile";
      }
    } catch (e) {
      errorMessage.value = "Error fetching profile: $e";
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? newUsername,
    String? newEmail,
    String? newPhone,
    String? newBio,
  }) async {
    if (userId.value <= 0) {
      errorMessage.value = "No user ID found";
      return false;
    }

    isUpdating.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final Map<String, dynamic> updateData = {
        'user_id': userId.value,
      };

      if (newUsername != null && newUsername.isNotEmpty) {
        updateData['username'] = newUsername;
      }

      if (newEmail != null && newEmail.isNotEmpty) {
        updateData['email'] = newEmail;
      }

      if (newPhone != null) {
        updateData['phone'] = newPhone;
      }

      if (newBio != null) {
        updateData['bio'] = newBio;
      }

      final result = await _apiService.updateUserProfile(updateData);

      if (result['success'] == true) {
        // Update local data
        if (newUsername != null && newUsername.isNotEmpty) {
          username.value = newUsername;
        }

        if (newEmail != null && newEmail.isNotEmpty) {
          email.value = newEmail;
        }

        if (newPhone != null) {
          phone.value = newPhone;
        }

        if (newBio != null) {
          bio.value = newBio;
        }

        // Save updated data locally
        await _saveToPreferences();

        successMessage.value = "Profile updated successfully";
        return true;
      } else {
        errorMessage.value = result['message'] ?? "Failed to update profile";
        return false;
      }
    } catch (e) {
      errorMessage.value = "Error updating profile: $e";
      return false;
    } finally {
      isUpdating.value = false;
    }
  }

  // Upload profile image
  Future<bool> uploadProfileImage() async {
    if (userId.value <= 0) {
      errorMessage.value = "No user ID found";
      return false;
    }

    final ImagePicker picker = ImagePicker();

    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image == null) {
        return false; // User canceled
      }

      isUploading.value = true;
      errorMessage.value = '';
      successMessage.value = '';

      final result =
          await _apiService.uploadProfileImage(userId.value, image.path);

      if (result['success'] == true && result['data'] != null) {
        profileImage.value = result['data']['profile_image'] ?? '';

        // Save updated image path locally
        await _saveToPreferences();

        successMessage.value = "Profile image updated successfully";
        return true;
      } else {
        errorMessage.value =
            result['message'] ?? "Failed to upload profile image";
        return false;
      }
    } catch (e) {
      errorMessage.value = "Error uploading profile image: $e";
      return false;
    } finally {
      isUploading.value = false;
    }
  }

  // Change password
  Future<bool> changePassword(String currentPassword, String newPassword,
      String confirmPassword) async {
    if (userId.value <= 0) {
      errorMessage.value = "No user ID found";
      return false;
    }

    // Validate password
    if (newPassword.isEmpty || currentPassword.isEmpty) {
      errorMessage.value = "Passwords cannot be empty";
      return false;
    }

    if (newPassword != confirmPassword) {
      errorMessage.value = "New passwords do not match";
      return false;
    }

    if (newPassword.length < 6) {
      errorMessage.value = "Password must be at least 6 characters long";
      return false;
    }

    isChangingPassword.value = true;
    errorMessage.value = '';
    successMessage.value = '';

    try {
      final result = await _apiService.changePassword(
          userId.value, currentPassword, newPassword);

      if (result['success'] == true) {
        successMessage.value = "Password changed successfully";
        return true;
      } else {
        errorMessage.value = result['message'] ?? "Failed to change password";
        return false;
      }
    } catch (e) {
      errorMessage.value = "Error changing password: $e";
      return false;
    } finally {
      isChangingPassword.value = false;
    }
  }

  // Save login data after successful login
  Future<void> saveLoginData(Map<String, dynamic> userData) async {
    // Parse the ID to ensure it's an integer
    userId.value = userData['id'] is String
        ? int.tryParse(userData['id']) ?? 0
        : userData['id'] ?? 0;
    username.value = userData['username'] ?? '';
    email.value = userData['email'] ?? '';
    phone.value = userData['phone'] ?? '';
    bio.value = userData['bio'] ?? '';
    profileImage.value = userData['profile_image'] ?? '';

    await _saveToPreferences();
  }

  // Clear user data on logout
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();

    userId.value = 0;
    username.value = '';
    email.value = '';
    phone.value = '';
    bio.value = '';
    profileImage.value = '';

    await prefs.remove('user_id');
    await prefs.remove('username');
    await prefs.remove('email');
    await prefs.remove('phone');
    await prefs.remove('bio');
    await prefs.remove('profile_image');
  }

  // Check if user is logged in
  bool get isLoggedIn => userId.value > 0;
}
