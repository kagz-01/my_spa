import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:my_spa/services/api_service.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  bool isLoading = true;
  bool isError = false;
  String errorMessage = '';

  // Dummy user ID (in a real app, get from authentication)
  final int userId = 1;

  // Data containers
  List<dynamic> upcomingBookings = [];
  List<dynamic> completedBookings = [];
  List<dynamic> cartItems = [];
  double cartTotalAmount = 0.0;

  // Tab controller
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Load both booking and cart data
  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      // Load bookings
      await _loadBookings();
      // Load cart
      await _loadCart();
    } catch (e) {
      setState(() {
        isError = true;
        errorMessage = 'Failed to load data: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Load bookings from the API
  Future<void> _loadBookings() async {
    final result = await _apiService.getUserBookings(userId);

    if (result['success']) {
      final bookings = result['data'] as List<dynamic>;

      setState(() {
        // Filter bookings by status
        upcomingBookings = bookings
            .where((booking) => booking['status'] == 'confirmed')
            .toList();
        completedBookings = bookings
            .where((booking) => booking['status'] == 'completed')
            .toList();
      });
    } else {
      throw Exception(result['message']);
    }
  }

  // Load cart from the API
  Future<void> _loadCart() async {
    final result = await _apiService.getUserCart(userId);

    if (result['success']) {
      setState(() {
        cartItems = result['data']['items'] as List<dynamic>;
        cartTotalAmount =
            double.parse(result['data']['total_amount'].toString());
      });
    } else {
      throw Exception(result['message']);
    }
  }

  // Cancel booking
  Future<void> _cancelBooking(int bookingId) async {
    try {
      final result = await _apiService.cancelBooking(bookingId);

      if (result['success']) {
        Get.snackbar(
          'Success',
          'Appointment canceled successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Reload bookings data
        await _loadBookings();
      } else {
        Get.snackbar(
          'Error',
          'Failed to cancel appointment: ${result['message']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to cancel appointment: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Remove item from cart
  Future<void> _removeFromCart(int itemId) async {
    try {
      final result = await _apiService.removeFromCart(itemId);

      if (result['success']) {
        Get.snackbar(
          'Success',
          'Item removed from cart',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Reload cart data
        await _loadCart();
      } else {
        Get.snackbar(
          'Error',
          'Failed to remove item: ${result['message']}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove item: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Booking", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {
              // Navigate to notifications page
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? Center(
                  child: Text(errorMessage,
                      style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    // Profile section at top
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: AssetImage(
                                'assets/images/user/default_avatar.jpg'),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Agalya S A',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                              Text(
                                'Premium',
                                style: TextStyle(
                                  color: Colors.brown[600],
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined),
                            onPressed: () {
                              // Handle notification button
                            },
                          ),
                        ],
                      ),
                    ),

                    // Tab bar for Appointments and Cart
                    TabBar(
                      controller: _tabController,
                      labelColor: Colors.brown[600],
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.brown[600],
                      indicatorSize: TabBarIndicatorSize.label,
                      tabs: const [
                        Tab(text: 'Appointments'),
                        Tab(text: 'Cart'),
                      ],
                    ),

                    // Tab content
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Appointments tab
                          _buildAppointmentsTab(),

                          // Cart tab
                          _buildCartTab(),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  // Appointments tab content
  Widget _buildAppointmentsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upcoming Schedule
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Schedule',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all upcoming
                },
                child: Text(
                  'see all',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ],
          ),

          // Upcoming appointments list
          upcomingBookings.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      'No upcoming appointments',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              : Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: upcomingBookings.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final booking = upcomingBookings[index];
                      return buildUpcomingEvent(booking);
                    },
                  ),
                ),

          // Completed appointments
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Completed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                ),
              ),
              TextButton(
                onPressed: () {
                  // View all completed
                },
                child: Text(
                  'see all',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ],
          ),

          // Completed appointments list
          completedBookings.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: Text(
                      'No completed appointments',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              : Expanded(
                  flex: 1,
                  child: ListView.builder(
                    itemCount: completedBookings.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final booking = completedBookings[index];
                      return buildCompletedEvent(booking);
                    },
                  ),
                ),
        ],
      ),
    );
  }

  // Cart tab content
  Widget _buildCartTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cart Items',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 16),

          // Cart items list
          cartItems.isEmpty
              ? Expanded(
                  child: Center(
                    child: Text(
                      'Your cart is empty',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return buildCartItem(item);
                    },
                  ),
                ),

          // Total and checkout button (only show if cart has items)
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 0,
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      Text(
                        '\$${cartTotalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final result = await _apiService.checkout(userId);

                        if (result['success']) {
                          Get.snackbar(
                            'Success',
                            'Checkout completed successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                          // Reload cart after checkout
                          await _loadCart();
                        } else {
                          Get.snackbar(
                            'Error',
                            'Checkout failed: ${result['message']}',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      } catch (e) {
                        Get.snackbar(
                          'Error',
                          'Checkout failed: $e',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D6E63),
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget buildUpcomingEvent(Map<String, dynamic> booking) {
    // Extract data
    String serviceName = booking['service_name'];
    String dateStr = booking['formatted_date'] ?? 'Unknown date';
    String timeStr = booking['appointment_time'] ?? 'Unknown time';
    int bookingId = int.parse(booking['id'].toString());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Service image or icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.brown[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.spa, color: Colors.brown[800]),
            ),
            const SizedBox(width: 12),

            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    serviceName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const Text('Premium', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),

                  // Date and time row
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        getFormattedDate(dateStr),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.access_time,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Call button
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.green),
              onPressed: () {
                // Implement call functionality
              },
            ),

            // Cancel button
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Cancel Appointment'),
                      content: const Text(
                          'Are you sure you want to cancel this appointment?'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            _cancelBooking(bookingId);
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCompletedEvent(Map<String, dynamic> booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service image or icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.spa, color: Colors.brown[800]),
            ),
            const SizedBox(width: 12),

            // Service details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    booking['service_name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  const Text('Premium', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 8),

                  // Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${booking['formatted_date']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Write review button
            TextButton.icon(
              icon: const Icon(Icons.edit, size: 16),
              label: const Text('Write review'),
              onPressed: () {
                // Implement write review functionality
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[700],
                textStyle: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCartItem(Map<String, dynamic> item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: item['image_path'] != null &&
                        item['image_path'].toString().isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(item['image_path']),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: Colors.grey[200],
              ),
              child: item['image_path'] == null ||
                      item['image_path'].toString().isEmpty
                  ? Icon(Icons.shopping_bag, color: Colors.brown[600])
                  : null,
            ),
            const SizedBox(width: 12),

            // Product details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['product_name'] ?? 'Unknown Product',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  Text(
                    item['product_category'] ?? 'Unknown Category',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '\$${(double.parse(item['price'].toString()) * int.parse(item['quantity'].toString())).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Qty: ${item['quantity']}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Remove button
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                final itemId = int.parse(item['id'].toString());
                _removeFromCart(itemId);
              },
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format date in a more human-readable way
  String getFormattedDate(String dateStr) {
    try {
      // If it's already in the format we want, just return it
      if (dateStr.contains('Thursday') || dateStr.contains('Monday')) {
        return dateStr.split(',')[0] + ',' + dateStr.split(',')[1];
      }

      // Otherwise, try to parse and reformat
      DateTime date;
      if (dateStr.contains('/')) {
        final parts = dateStr.split('/');
        date = DateTime(
            int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
      } else {
        date = DateTime.parse(dateStr);
      }

      return DateFormat('EEEE, dd MMM').format(date);
    } catch (e) {
      return dateStr;
    }
  }
}
