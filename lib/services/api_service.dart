import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';
import 'package:my_spa/services/user_service.dart';

class ApiService {
  static final _box = GetStorage();
  static const _serverIPKey = 'server_ip';
  final UserService _userService = UserService();

  static const _defaultIP = '127.0.0.1';

  static Future<String> get serverIP async {
    return _box.read(_serverIPKey) ?? _defaultIP;
  }

  static Future<void> setServerIP(String ip) async {
    await _box.write(_serverIPKey, ip);
  }

  // Get base URL
  Future<String> get baseUrl async {
    final ip = await serverIP;
    return 'http://$ip/my_spa';
  }

  // Get authenticated user ID - returns 0 if not authenticated (instead of throwing)
  int getUserIdForApi() {
    try {
      return _userService.getAuthenticatedUserId();
    } catch (e) {
      print("Authentication error: $e");
      return 0; // Return 0 instead of throwing
    }
  }

  // Check if a user is currently authenticated
  bool isAuthenticated() {
    return _userService.isLoggedIn();
  }

  // Require authentication for API calls
  void requireAuthentication() {
    if (!isAuthenticated()) {
      throw Exception("Authentication required");
    }
  }

  // Singleton pattern for API service
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Login user
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final url = await baseUrl;
      final response = await http.post(
        Uri.parse('$url/login.php'),
        body: {
          'email': email,
          'password': password,
        },
      );

      // Check if response has content before parsing
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Register new user
  Future<Map<String, dynamic>> registerUser(
      String username, String email, String password) async {
    try {
      final url = await baseUrl;

      // Print request details for debugging
      print("Making signup request to: $url/signup.php");
      print(
          "With data: {'username': '$username', 'email': '$email', 'password': '****'}");

      final response = await http.post(
        Uri.parse('$url/signup.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Check if response has content before parsing
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      print("Error occurred: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Testing connection to server
  Future<bool> testConnection() async {
    try {
      final url = await baseUrl;
      final response = await http
          .get(Uri.parse('$url/connect.php'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      print("Connection test failed: $e");
      return false;
    }
  }

  // Share photo data
  Future<Map<String, dynamic>> sharePhoto(
      Map<String, dynamic> photoData) async {
    try {
      final url = await baseUrl;
      final uploadUrl = '$url/share_photo.php';

      print("Making share photo request to: $uploadUrl");

      // Make sure we have a user ID
      if (!photoData.containsKey('user_id') && isAuthenticated()) {
        // Add the authenticated user's ID
        photoData['user_id'] = getUserIdForApi();
      }

      final imageFilePath = photoData['image'] as String?;

      if (imageFilePath == null) {
        return {
          'success': false,
          'message': 'No image file provided',
        };
      }

      // Create JSON data with the correct field name mapping
      final jsonData = {
        'username': photoData['username'] ?? 'Anonymous',
        'caption': photoData['caption'] ?? '',
        'rating': photoData['rating'] ?? 5.0,
        'user_id': photoData['user_id'] ?? getUserIdForApi(),
        'image_name':
            imageFilePath.split('/').last, // Convert path to just filename
      };

      print("Sending data: ${jsonEncode(jsonData)}");

      final response = await http
          .post(
            Uri.parse(uploadUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(jsonData),
          )
          .timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      // Check if response has content before parsing
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      print("Error occurred while sharing photo: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get photos from database
  Future<Map<String, dynamic>> getPhotos() async {
    try {
      final url = await baseUrl;

      print("Making get photos request to: $url/get_photos.php");

      final response = await http.get(
        Uri.parse('$url/get_photos.php'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");

      // Check if response has content before parsing
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }
    } catch (e) {
      print("Error occurred: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': [],
      };
    }
  }

  // Book an appointment
  Future<Map<String, dynamic>> bookAppointment(
      Map<String, dynamic> appointmentData) async {
    try {
      final url = await baseUrl;

      print("Making booking request to: $url/booking.php");
      print("With data: ${jsonEncode(appointmentData)}");

      final response = await http
          .post(
            Uri.parse('$url/booking.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(appointmentData),
          )
          .timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      print("Error booking appointment: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get all bookings for the authenticated user
  Future<Map<String, dynamic>> getUserBookings() async {
    try {
      // Check if user is authenticated
      if (!isAuthenticated()) {
        return {
          'success': false,
          'message': 'Authentication required',
          'data': [],
          'requireLogin': true
        };
      }

      // Get authenticated user ID
      final userId = getUserIdForApi();
      final url = await baseUrl;

      print("Fetching bookings from: $url/booking.php?user_id=$userId");

      final response = await http.get(
        Uri.parse('$url/booking.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");

      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': [],
        };
      }
    } catch (e) {
      print("Error fetching bookings: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': [],
      };
    }
  }

  // Legacy method for backward compatibility
  @Deprecated("Use getUserBookings() without parameters instead")
  Future<Map<String, dynamic>> getUserBookingsWithUserId(int userId) async {
    // Validate that the provided userId matches the authenticated user
    final authenticatedUserId = getUserIdForApi();
    if (userId != authenticatedUserId) {
      return {
        'success': false,
        'message': 'Unauthorized access attempt',
        'data': [],
      };
    }

    return getUserBookings();
  }

  // Update booking status (e.g. cancel a booking)
  Future<Map<String, dynamic>> updateBookingStatus(int bookingId, String status,
      {String? notes}) async {
    try {
      final url = await baseUrl;

      print("Updating booking status at: $url/booking.php");
      final data = {
        'id': bookingId,
        'status': status,
      };

      if (notes != null) {
        data['notes'] = notes;
      }

      print("With data: ${jsonEncode(data)}");

      final response = await http
          .put(
            Uri.parse('$url/booking.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      print("Error updating booking: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Cancel a booking (convenience method)
  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    return updateBookingStatus(bookingId, 'canceled');
  }

  // Add item to cart
  Future<Map<String, dynamic>> addToCart(Map<String, dynamic> cartData) async {
    try {
      final url = await baseUrl;

      // Make sure we have a user ID
      if (!cartData.containsKey('user_id') && isAuthenticated()) {
        // Add the authenticated user's ID
        cartData['user_id'] = getUserIdForApi();
      }

      print("Adding to cart: $url/cart.php");
      print("With data: ${jsonEncode(cartData)}");

      final response = await http
          .post(
            Uri.parse('$url/cart.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(cartData),
          )
          .timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      print("Error adding to cart: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Get cart items for the authenticated user
  Future<Map<String, dynamic>> getUserCart() async {
    try {
      // Check if user is authenticated
      if (!isAuthenticated()) {
        return {
          'success': false,
          'message': 'Authentication required',
          'data': {'items': [], 'count': 0, 'total_amount': 0},
          'requireLogin': true
        };
      }

      // Get authenticated user ID
      final userId = getUserIdForApi();
      final url = await baseUrl;

      print("Fetching cart from: $url/cart.php?user_id=$userId");

      final response = await http.get(
        Uri.parse('$url/cart.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
          'data': {'items': [], 'count': 0, 'total_amount': 0},
        };
      }
    } catch (e) {
      print("Error fetching cart: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
        'data': {'items': [], 'count': 0, 'total_amount': 0},
      };
    }
  }

  // Legacy method for backward compatibility
  @Deprecated("Use getUserCart() without parameters instead")
  Future<Map<String, dynamic>> getUserCartWithUserId(int userId) async {
    // Validate that the provided userId matches the authenticated user
    final authenticatedUserId = getUserIdForApi();
    if (userId != authenticatedUserId) {
      return {
        'success': false,
        'message': 'Unauthorized access attempt',
        'data': {'items': [], 'count': 0, 'total_amount': 0},
      };
    }

    return getUserCart();
  }

  // Remove item from cart
  Future<Map<String, dynamic>> removeFromCart(int itemId) async {
    try {
      final url = await baseUrl;

      print("Removing from cart: $url/cart.php?id=$itemId");

      final response = await http.delete(
        Uri.parse('$url/cart.php?id=$itemId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      print("Error removing from cart: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Process checkout for the authenticated user
  Future<Map<String, dynamic>> checkout() async {
    try {
      final url = await baseUrl;

      // Get the authenticated user's ID
      final userId = getUserIdForApi();

      print("Processing checkout: $url/cart.php?checkout&user_id=$userId");

      final response = await http.get(
        Uri.parse('$url/cart.php?checkout&user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      print("Error processing checkout: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Legacy method for backward compatibility
  @Deprecated("Use checkout() without parameters instead")
  Future<Map<String, dynamic>> checkoutWithUserId(int userId) async {
    // Validate that the provided userId matches the authenticated user
    final authenticatedUserId = getUserIdForApi();
    if (userId != authenticatedUserId) {
      return {
        'success': false,
        'message': 'Unauthorized access attempt',
      };
    }

    return checkout();
  }

  // Get current user's profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      // Check if user is authenticated
      if (!isAuthenticated()) {
        return {
          'success': false,
          'message': 'Authentication required',
          'requireLogin': true
        };
      }

      // Get authenticated user ID
      final userId = getUserIdForApi();
      final url = await baseUrl;

      print("Fetching user profile: $url/user_profile.php?user_id=$userId");

      final response = await http.get(
        Uri.parse('$url/user_profile.php?user_id=$userId'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      print("Error fetching user profile: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Legacy method for backward compatibility
  @Deprecated("Use getUserProfile() without parameters instead")
  Future<Map<String, dynamic>> getUserProfileWithUserId(int userId) async {
    // Validate that the provided userId matches the authenticated user
    final authenticatedUserId = getUserIdForApi();
    if (userId != authenticatedUserId) {
      return {
        'success': false,
        'message': 'Unauthorized access attempt',
      };
    }

    return getUserProfile();
  }

  // Update user profile
  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> profileData) async {
    try {
      final url = await baseUrl;

      print("Updating user profile: $url/user_profile.php");
      print("With data: ${jsonEncode(profileData)}");

      final response = await http
          .put(
            Uri.parse('$url/user_profile.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(profileData),
          )
          .timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      print("Error updating user profile: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Upload profile image for authenticated user
  Future<Map<String, dynamic>> uploadProfileImage(String filePath) async {
    try {
      // Get authenticated user ID
      final userId = getUserIdForApi();
      final url = await baseUrl;
      final uploadUrl = '$url/user_profile.php?upload_image';

      print("Uploading profile image to: $uploadUrl");

      var request = http.MultipartRequest('POST', Uri.parse(uploadUrl));
      request.fields['user_id'] = userId.toString();
      request.files.add(await http.MultipartFile.fromPath('image', filePath));

      var streamedResponse =
          await request.send().timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      print("Error uploading profile image: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> uploadProfileImageWithUserId(
      int userId, String filePath) async {
    // Validate that the provided userId matches the authenticated user
    final authenticatedUserId = getUserIdForApi();
    if (userId != authenticatedUserId) {
      return {
        'success': false,
        'message': 'Unauthorized access attempt',
      };
    }

    return uploadProfileImage(filePath);
  }

  // Change password for authenticated user
  Future<Map<String, dynamic>> changePassword(
      String currentPassword, String newPassword) async {
    try {
      // Get authenticated user ID
      final userId = getUserIdForApi();
      final url = await baseUrl;

      print("Changing password: $url/user_profile.php?change_password");

      final data = {
        'user_id': userId,
        'current_password': currentPassword,
        'new_password': newPassword,
      };

      final response = await http
          .post(
            Uri.parse('$url/user_profile.php?change_password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      print("Response status: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.body.isNotEmpty) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Empty response from server',
        };
      }
    } catch (e) {
      print("Error changing password: $e");
      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // Legacy method for backward compatibility
  @Deprecated(
      "Use changePassword(String currentPassword, String newPassword) instead")
  Future<Map<String, dynamic>> changePasswordWithUserId(
      int userId, String currentPassword, String newPassword) async {
    // Validate that the provided userId matches the authenticated user
    final authenticatedUserId = getUserIdForApi();
    if (userId != authenticatedUserId) {
      return {
        'success': false,
        'message': 'Unauthorized access attempt',
      };
    }

    return changePassword(currentPassword, newPassword);
  }
}
