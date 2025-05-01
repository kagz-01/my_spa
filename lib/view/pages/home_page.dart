import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import '../widgets/my_button.dart';
import 'package:my_spa/services/api_service.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  // Controllers
  late TabController _tabController; // This is actually used in initState
  final TextEditingController _searchController = TextEditingController();

  // State variables
  int _currentCarouselIndex = 0;
  bool _isLoadingPhotos = false;
  String _photoErrorMessage = "";

  // Services
  final ApiService _apiService = ApiService();

  // Sample data for popular packages
  final List<Map<String, dynamic>> popularPackages = [
    {
      'name': 'Full Body Massage',
      'price': 150,
      'image': 'assets/images/services/massage.jpg',
      'rating': 4.8,
      'ratingCount': 120,
      'description': 'Relaxing full body massage for 60 minutes'
    },
    {
      'name': 'Facial Treatment',
      'price': 120,
      'image': 'assets/images/services/facial.jpg',
      'rating': 4.7,
      'ratingCount': 95,
      'description': 'Revitalizing facial treatment'
    },
    {
      'name': 'Spa Day Package',
      'price': 250,
      'image': 'assets/images/services/spa.jpg',
      'rating': 4.9,
      'ratingCount': 210,
      'description': 'Complete spa day with multiple treatments'
    },
    {
      'name': 'Manicure & Pedicure',
      'price': 80,
      'image': 'assets/images/services/pedi.jpg',
      'rating': 4.6,
      'ratingCount': 88,
      'description': 'Luxury hand and foot treatment'
    },
  ];

  // Special offers data
  final List<Map<String, dynamic>> specialOffers = [
    {
      'title': 'Weekend Special',
      'discount': '20% OFF',
      'code': 'WEEKEND20',
      'validUntil': 'Valid until Apr 30',
      'image': 'assets/images/services/massage.jpg',
    },
    {
      'title': 'Couple Package',
      'discount': '15% OFF',
      'code': 'COUPLE15',
      'validUntil': 'Valid until May 15',
      'image': 'assets/images/services/spa.jpg',
    },
    {
      'title': 'First Time Offer',
      'discount': '25% OFF',
      'code': 'WELCOME25',
      'validUntil': 'Valid for new customers',
      'image': 'assets/images/services/facial.jpg',
    },
  ];

  // User photos - now will be loaded from API
  List<Map<String, dynamic>> userPhotos = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Load photos from database when page initializes
    _loadPhotos();

    // Setup periodic refresh for notification count
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startNotificationRefresh();
    });
  }

  // Timer for periodic refresh of notification count
  Timer? _notificationRefreshTimer;

  void _startNotificationRefresh() {
    // Cancel any existing timer
    _notificationRefreshTimer?.cancel();

    // Create a new timer that refreshes notification count every 3 seconds
    _notificationRefreshTimer =
        Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        // Force rebuild of the notification badge
        setState(() {
          // This empty setState forces the FutureBuilder to rebuild
          print("Refreshing notification count...");
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _notificationRefreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Load photos from database
  Future<void> _loadPhotos() async {
    if (mounted) {
      setState(() {
        _isLoadingPhotos = true;
        _photoErrorMessage = "";
        // Clear existing photos to prevent duplicates
        userPhotos = [];
      });
    }

    try {
      print("Fetching photos from server...");
      final result = await _apiService.getPhotos();
      print("Photos API response: $result");

      if (mounted) {
        setState(() {
          _isLoadingPhotos = false;

          if (result['success'] == true && result['data'] != null) {
            // Convert the API response to the format our UI expects
            userPhotos =
                List<Map<String, dynamic>>.from(result['data'].map((photo) {
              print("Processing photo: ${photo['id']} - ${photo['image']}");
              return {
                'id': photo['id'],
                'username': photo['username'],
                'caption': photo['caption'],
                'rating': photo['rating'] ?? 5.0,
                'likes': photo['likes'] ?? 0,
                'timeAgo': photo['timeAgo'] ?? 'Recently',
                'image': photo['image'], // Use the image path from the server
                'isNetworkImage':
                    true, // Flag to indicate this is a network image
              };
            }));
            print("Loaded ${userPhotos.length} photos");
          } else {
            _photoErrorMessage = result['message'] ?? "Failed to load photos";
            print("Error loading photos: $_photoErrorMessage");
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingPhotos = false;
          _photoErrorMessage = "Error loading photos: $e";
        });
      }
      print("Exception when loading photos: $e");
    }
  }

  // Navigate to share photo page
  Future<void> _navigateToSharePhoto() async {
    print("Navigating to share photo page");
    try {
      // Make sure we're using the correct route name that matches app_routes.dart
      final result = await Get.toNamed('/share_photo');

      // If we got data back from the share photo page
      if (result != null && result is Map<String, dynamic>) {
        print("Returned from share photo page with result: $result");

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Experience shared successfully!'),
            duration: Duration(seconds: 2),
          ),
        );

        // Explicitly refresh the photos list with a small delay to allow server processing
        await Future.delayed(const Duration(milliseconds: 1000));
        print("Refreshing photos list...");
        await _loadPhotos();
      }
    } catch (e) {
      print("Error navigating to share photo page: $e");
      // Show error to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open share photo page: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Get notification count (bookings + cart items)
  Future<int> _getNotificationCount() async {
    try {
      int count = 0;

      // Fetch bookings using the secure API method
      final bookingsResult = await _apiService.getUserBookings();
      if (bookingsResult['success'] == true && bookingsResult['data'] != null) {
        List<dynamic> bookings = bookingsResult['data'];
        // Only count active bookings (confirmed or pending)
        count += bookings
            .where((booking) =>
                booking['status'] == 'confirmed' ||
                booking['status'] == 'pending')
            .length;
      }

      // Fetch cart items using the secure API method
      final cartResult = await _apiService.getUserCart();
      if (cartResult['success'] == true && cartResult['data'] != null) {
        Map<String, dynamic> cartData = cartResult['data'];
        count += cartData['count'] as int? ?? 0;
      }

      return count;
    } catch (e) {
      print('Error fetching notification count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAppBar(),
              _buildMainContent(),
            ],
          ),
        ),
      ),
    );
  }

  // App bar with search
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search for services...',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    fontFamily: 'Urbanist',
                  ),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications_none_rounded,
                      color: Colors.blueGrey.shade700),
                  onPressed: () {
                    Get.toNamed("/notification");
                  },
                ),
                // Notification badge for cart/booking count
                FutureBuilder(
                  future: _getNotificationCount(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data! > 0) {
                      return Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            snapshot.data! > 9 ? '9+' : '${snapshot.data}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Main content area
  Widget _buildMainContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPopularPackages(),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              _buildSpecialOffers(),
              const SizedBox(height: 30),
              _buildCustomerPhotos(),
            ],
          ),
        ),
      ],
    );
  }

  // Popular packages section with carousel
  Widget _buildPopularPackages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with See All button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: const Text(
                  'Most Popular Packages',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
              myButton(
                onPressed: () {
                  Get.toNamed("/category");
                },
                label: "see all",
                minWidth: 100,
                color: Colors.blueGrey,
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        CarouselSlider.builder(
          itemCount: popularPackages.length,
          options: CarouselOptions(
            height: 280,
            enlargeCenterPage: false, // Changed from true to false
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayCurve: Curves.fastOutSlowIn,
            enableInfiniteScroll: true,
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            viewportFraction: 0.85, // Fixed value instead of conditional
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          itemBuilder: (BuildContext context, int index, int realIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: _buildPackageCard(popularPackages[index]),
            );
          },
        ),

        const SizedBox(height: 12),

        // Carousel indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: popularPackages.asMap().entries.map((entry) {
            return Container(
              width: 8.0,
              height: 8.0,
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentCarouselIndex == entry.key
                    ? Colors.blueGrey.shade700
                    : Colors.grey.shade300,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPackageCard(Map<String, dynamic> package) {
    double cardWidth = MediaQuery.of(context).size.width * 0.8;

    return Container(
      width: cardWidth,
      margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with rating badge
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  child: SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Image.asset(
                      package['image'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 140,
                          color: Colors.grey.shade300,
                          child: const Center(child: Icon(Icons.error)),
                        );
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${package['rating']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Package details
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Urbanist',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${package['price']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueGrey.shade700,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      Text(
                        '${package['ratingCount']} reviews',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    package['description'],
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      fontFamily: 'Urbanist',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Special offers section
  Widget _buildSpecialOffers() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Special Offers',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Urbanist',
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: specialOffers.length,
            itemBuilder: (context, index) {
              return _buildSpecialOfferCard(specialOffers[index]);
            },
          ),
        ),
      ],
    );
  }

  // Special offer card
  Widget _buildSpecialOfferCard(Map<String, dynamic> offer) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Offer image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            child: Image.asset(
              offer['image'],
              width: double.infinity,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 100,
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.error)),
                );
              },
            ),
          ),

          // Offer details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offer['title'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Urbanist',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          offer['discount'],
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            fontFamily: 'Urbanist',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    color: Colors.blueGrey.shade700,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Customer photos section
  Widget _buildCustomerPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer Photos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Urbanist',
              ),
            ),
            TextButton(
              onPressed: _navigateToSharePhoto,
              child: Text(
                'Share Yours',
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontFamily: 'Urbanist',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),

        // Display user photos or upload prompt
        _isLoadingPhotos
            ? const Center(child: CircularProgressIndicator())
            : _photoErrorMessage.isNotEmpty
                ? Center(child: Text(_photoErrorMessage))
                : userPhotos.isNotEmpty
                    ? ConstrainedBox(
                        constraints: BoxConstraints(
                          // Set a maximum height to prevent overflow
                          maxHeight: MediaQuery.of(context).size.height * 0.6,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          // Use scroll physics to make it scrollable within the limited height
                          physics: const ClampingScrollPhysics(),
                          itemCount: userPhotos.length,
                          itemBuilder: (context, index) {
                            return _buildUserPhotoCard(userPhotos[index]);
                          },
                        ),
                      )
                    : _buildUploadPhotoSection(),
      ],
    );
  }

  // Upload photo section
  Widget _buildUploadPhotoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade50,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate,
            size: 60,
            color: Colors.blueGrey.shade300,
          ),
          const SizedBox(height: 15),
          const Text(
            'Share Your Experience',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Urbanist',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Upload photos of your spa experience and inspire others',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontFamily: 'Urbanist',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          myButton(
            onPressed: _navigateToSharePhoto,
            label: 'Upload a Photo',
            color: Colors.blueGrey.shade700,
            fontSize: 16,
            minWidth: double.infinity,
            padding: 16,
            borderRadius: 12,
          ),
        ],
      ),
    );
  }

  // User photo card
  Widget _buildUserPhotoCard(Map<String, dynamic> photo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User info
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.blueGrey.shade100,
                  child:
                      photo['username'] != null && photo['username'].isNotEmpty
                          ? Text(
                              photo['username'].substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: Colors.blueGrey.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      photo['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                    Text(
                      photo['timeAgo'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'Urbanist',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Photo - Use network image if isNetworkImage is true
          ClipRRect(
            child: photo['isNetworkImage'] == true
                ? Image.network(
                    // Create the full URL for the network image
                    'http://${ApiService.serverIP}/${photo['image']}',
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.blueGrey.shade200,
                        child: const Center(
                          child: Icon(Icons.broken_image,
                              size: 40, color: Colors.white),
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.blueGrey.shade100,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  )
                : Image.asset(
                    photo['image'],
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 180,
                        color: Colors.blueGrey.shade200,
                        child: const Center(
                          child:
                              Icon(Icons.photo, size: 40, color: Colors.white),
                        ),
                      );
                    },
                  ),
          ),

          // Caption and likes
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  photo['caption'],
                  style: const TextStyle(fontFamily: 'Urbanist'),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        setState(() {
                          photo['likes'] = photo['likes'] + 1;
                        });
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 18,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${photo['likes']}',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
