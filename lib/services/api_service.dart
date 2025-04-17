import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get_storage/get_storage.dart';

class ApiService {
  static final _box = GetStorage();
  static const _serverIPKey = 'server_ip';

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

  // Helper to detect if running on Android emulator

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

      // Print request details for debugging
      print("Making share photo request to: $url/share_photo.php");

      final imageFile = photoData['image'] as String?;

      // Create a copy of the data without the File object
      final data = {
        'username': photoData['username'] ?? 'Anonymous',
        'caption': photoData['caption'] ?? '',
        'rating': photoData['rating'] ?? 5.0,
        'image_name':
            imageFile != null ? imageFile.split('/').last : 'default_image.jpg',
        'date_time': photoData['date'] ?? DateTime.now().toString(),
      };

      print("With data: ${jsonEncode(data)}");

      final response = await http
          .post(
            Uri.parse('$url/share_photo.php'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(data),
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
      print("Error occurred: $e");
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

  // Get all bookings for a user
  Future<Map<String, dynamic>> getUserBookings(int userId) async {
    try {
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

  // Get cart items for a user
  Future<Map<String, dynamic>> getUserCart(int userId) async {
    try {
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

  // Process checkout for a user
  Future<Map<String, dynamic>> checkout(int userId) async {
    try {
      final url = await baseUrl;

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

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(int userId) async {
    try {
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

  // Upload profile image
  Future<Map<String, dynamic>> uploadProfileImage(
      int userId, String filePath) async {
    try {
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

  // Change password
  Future<Map<String, dynamic>> changePassword(
      int userId, String currentPassword, String newPassword) async {
    try {
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
}
