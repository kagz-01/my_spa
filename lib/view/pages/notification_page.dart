import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_spa/services/api_service.dart';
import 'dart:async'; // Adding missing Timer import

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  _NotificationPageState createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final ApiService _apiService = ApiService();

  // Data for bookings and cart
  List<Map<String, dynamic>> _bookings = [];
  Map<String, dynamic> _cartData = {};

  bool _isLoadingBookings = true;
  bool _isLoadingCart = true;
  String _bookingsError = '';
  String _cartError = '';

  @override
  void initState() {
    super.initState();
    _loadBookings();
    _loadCart();

    // Add listener for when the page is focused again (becomes visible)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Add observer to detect when this screen becomes active again
      if (Get.routing.current == '/notification') {
        // Setup a periodic refresh when the page is active
        _startPeriodicRefresh();
      }
    });
  }

  Timer? _refreshTimer;

  void _startPeriodicRefresh() {
    // Cancel any existing timer
    _refreshTimer?.cancel();

    // Create a new timer that refreshes data every 5 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        print("Auto-refreshing notification data");
        _loadBookings();
        _loadCart();
      } else {
        // If widget is no longer mounted, cancel the timer
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    // Cancel the refresh timer when the page is disposed
    _refreshTimer?.cancel();
    super.dispose();
  }

  // Load user bookings
  Future<void> _loadBookings() async {
    try {
      final result = await _apiService.getUserBookings();

      if (mounted) {
        setState(() {
          _isLoadingBookings = false;
          if (result['success'] == true && result['data'] != null) {
            _bookings = List<Map<String, dynamic>>.from(result['data']);
          } else {
            _bookingsError = result['message'] ?? 'Failed to load bookings';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBookings = false;
          _bookingsError = 'Error: $e';
        });
      }
    }
  }

  // Delete a booking notification
  Future<void> _deleteBookingNotification(int index) async {
    // Since we're just hiding the notification in the UI and not from the database
    // we'll remove it from the local list only
    setState(() {
      _bookings.removeAt(index);
    });

    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Notification removed'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // Reload all bookings as we don't store the deleted item
            _loadBookings();
          },
        ),
      ),
    );
  }

  // Delete a cart notification
  Future<void> _deleteCartNotification(int index) async {
    // Get the items list
    final cartItems = _cartData['items'] as List<dynamic>? ?? [];

    // We'll remove it from the local list only
    if (cartItems.isNotEmpty && index < cartItems.length) {
      // Store count and total before removing
      final oldCount = cartItems.length;
      final oldTotal = _cartData['total_amount'] ?? 0.0;

      // Calculate the price of the item being removed
      final item = cartItems[index];
      final price = (item['price'] ?? 0) * (item['quantity'] ?? 1);

      // Remove the item
      setState(() {
        cartItems.removeAt(index);
        _cartData['count'] = oldCount - 1;
        _cartData['total_amount'] = oldTotal - price;
      });

      // Show confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification removed'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              // Reload all cart items
              _loadCart();
            },
          ),
        ),
      );
    }
  }

  // Load user cart
  Future<void> _loadCart() async {
    try {
      final result = await _apiService.getUserCart();

      if (mounted) {
        setState(() {
          _isLoadingCart = false;
          if (result['success'] == true && result['data'] != null) {
            _cartData = Map<String, dynamic>.from(result['data']);
          } else {
            _cartError = result['message'] ?? 'Failed to load cart';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCart = false;
          _cartError = 'Error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadBookings();
          await _loadCart();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bookings section
              _buildSectionTitle('Your Bookings', Icons.calendar_today),
              const SizedBox(height: 10),
              _buildBookingsSection(),

              const SizedBox(height: 24),
              // Cart items section
              _buildSectionTitle('Your Cart', Icons.shopping_bag),
              const SizedBox(height: 10),
              _buildCartSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Section title widget
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey.shade700),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: 'Urbanist',
          ),
        ),
      ],
    );
  }

  // Bookings section
  Widget _buildBookingsSection() {
    if (_isLoadingBookings) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_bookingsError.isNotEmpty) {
      return Center(child: Text(_bookingsError));
    }

    if (_bookings.isEmpty) {
      return _buildEmptyState(
        'No bookings yet',
        'Book a service to see your appointments here',
        Icons.calendar_today_outlined,
        () => Get.toNamed('/category'),
        'Browse Services',
      );
    }

    return Column(
      children: List.generate(_bookings.length, (index) {
        return _buildBookingCard(_bookings[index], index);
      }),
    );
  }

  // Cart section
  Widget _buildCartSection() {
    if (_isLoadingCart) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_cartError.isNotEmpty) {
      return Center(child: Text(_cartError));
    }

    final cartItems = _cartData['items'] as List<dynamic>? ?? [];
    if (cartItems.isEmpty) {
      return _buildEmptyState(
        'Your cart is empty',
        'Add products to your cart to see them here',
        Icons.shopping_cart_outlined,
        () => Get.toNamed('/products'),
        'Browse Products',
      );
    }

    return Column(
      children: [
        ...List.generate(cartItems.length, (index) {
          return _buildCartItemCard(cartItems[index], index);
        }),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total: \$${_cartData['total_amount']?.toStringAsFixed(2) ?? '0.00'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
              ),
            ),
            ElevatedButton(
              onPressed: () =>
                  Get.toNamed('/bookings', parameters: {'tab': '1'}),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey.shade700,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('View Cart'),
            ),
          ],
        ),
      ],
    );
  }

  // Booking card
  Widget _buildBookingCard(Map<String, dynamic> booking, int index) {
    String statusColor;
    switch (booking['status']) {
      case 'confirmed':
        statusColor = '#4CAF50'; // Green
        break;
      case 'pending':
        statusColor = '#FF9800'; // Orange
        break;
      case 'canceled':
        statusColor = '#F44336'; // Red
        break;
      default:
        statusColor = '#9E9E9E'; // Grey
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    booking['service_name'] ?? 'Unknown Service',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(
                        int.parse(statusColor.substring(1, 7), radix: 16) +
                            0xFF000000),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    booking['status']?.toString().toUpperCase() ?? 'UNKNOWN',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  "${booking['appointment_time']} (${booking['duration']} min)",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  booking['formatted_date'] ??
                      booking['appointment_date'] ??
                      'Unknown date',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${booking['price']?.toString() ?? '0'}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade700,
                    fontFamily: 'Urbanist',
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/bookings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade700,
                    textStyle: const TextStyle(fontSize: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('View Details'),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteBookingNotification(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Cart item card
  Widget _buildCartItemCard(Map<String, dynamic> item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product image or icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.blueGrey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: item['image_path'] != null && item['image_path'].isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _buildProductImage(item['image_path']),
                    )
                  : const Icon(
                      Icons.spa,
                      color: Colors.white,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 12),
            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['product_name'] ?? 'Unknown Product',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Urbanist',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete,
                            color: Colors.red, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _deleteCartNotification(index),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['product_category'] ?? 'Spa Product',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${(item['price'] ?? 0).toString()} × ${_parseQuantity(item['quantity'])}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade700,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      Text(
                        '\$${(_parsePrice(item['price']) * _parseQuantity(item['quantity'])).toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey.shade700,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to parse quantity properly - handles both int and String types
  int _parseQuantity(dynamic quantity) {
    if (quantity is int) return quantity;
    if (quantity is String) {
      return int.tryParse(quantity) ?? 1;
    }
    return 1;
  }

  // Helper method to parse price properly - handles both double and String types
  double _parsePrice(dynamic price) {
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      return double.tryParse(price) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to determine if path is asset or network and build appropriate image widget
  Widget _buildProductImage(String imagePath) {
    // Check if the image path is a local asset path
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.spa,
          color: Colors.white,
          size: 30,
        ),
      );
    } else {
      // This is a network image
      return Image.network(
        imagePath.startsWith('http')
            ? imagePath
            : 'http://${ApiService.serverIP}/$imagePath',
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const Icon(
          Icons.spa,
          color: Colors.white,
          size: 30,
        ),
      );
    }
  }

  // Empty state widget
  Widget _buildEmptyState(String title, String message, IconData icon,
      VoidCallback onAction, String actionText) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 70,
            color: Colors.blueGrey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey.shade700,
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontFamily: 'Urbanist',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }
}
