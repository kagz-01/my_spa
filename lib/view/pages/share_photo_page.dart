import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../widgets/my_button.dart';
import '../widgets/my_text_field.dart';
import 'package:my_spa/services/api_service.dart';

class SharePhotoPage extends StatefulWidget {
  const SharePhotoPage({Key? key}) : super(key: key);

  @override
  State<SharePhotoPage> createState() => _SharePhotoPageState();
}

class _SharePhotoPageState extends State<SharePhotoPage> {
  // Controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _captionController = TextEditingController();

  // State variables
  File? _selectedImage;
  double _rating = 5.0;
  final DateTime _currentDate = DateTime.now();
  bool _isUploading = false;
  String _errorMessage = "";

  // API service
  final ApiService _apiService = ApiService();

  @override
  void dispose() {
    _usernameController.dispose();
    _captionController.dispose();
    super.dispose();
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error selecting image. Please try again.'),
        ),
      );
    }
  }

  // Validate and share photo
  Future<void> _sharePhoto() async {
    // Reset error message
    setState(() {
      _errorMessage = "";
    });

    // Validate all fields
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = "Please select an image";
      });
      return;
    }

    if (_usernameController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please enter your username";
      });
      return;
    }

    if (_captionController.text.isEmpty) {
      setState(() {
        _errorMessage = "Please add a caption";
      });
      return;
    }

    // Format the date to display
    String formattedDate =
        DateFormat('MMM d, yyyy · h:mm a').format(_currentDate);

    try {
      // Set uploading state
      setState(() {
        _isUploading = true;
      });

      // Create photo data to pass to API
      final photoData = {
        'username': _usernameController.text,
        'caption': _captionController.text,
        'rating': _rating,
        'likes': 0,
        'timeAgo': 'Just now',
        'date': formattedDate,
        'image': _selectedImage!.path, // Local file path
      };

      // Send data to server
      final result = await _apiService.sharePhoto(photoData);

      if (result['success'] == true) {
        // Return data to previous screen
        Get.back(result: photoData);
      } else {
        // Show error
        setState(() {
          _isUploading = false;
          _errorMessage = result['message'] ?? "Failed to upload photo";
        });
      }
    } catch (e) {
      // Handle exceptions
      setState(() {
        _isUploading = false;
        _errorMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Share Your Experience',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo upload section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.blueGrey.shade200),
                    ),
                    child: _selectedImage == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                size: 60,
                                color: Colors.blueGrey.shade300,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tap to select a photo',
                                style: TextStyle(
                                  color: Colors.blueGrey.shade600,
                                  fontFamily: 'Urbanist',
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _selectedImage!,
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Username field
              const Text(
                'Your Name',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueGrey.shade200),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),

              const SizedBox(height: 20),

              // Rating section
              const Text(
                'Rate Your Experience',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_rating.toStringAsFixed(1)} / 5.0',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueGrey.shade700,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      final starValue = index + 1.0;
                      return IconButton(
                        onPressed: () {
                          setState(() {
                            _rating = starValue;
                          });
                        },
                        icon: Icon(
                          starValue <= _rating
                              ? Icons.star
                              : starValue - 0.5 <= _rating
                                  ? Icons.star_half
                                  : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Caption field
              const Text(
                'Caption',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _captionController,
                decoration: InputDecoration(
                  hintText: 'Share your experience...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueGrey.shade200),
                  ),
                  prefixIcon: const Icon(Icons.comment_outlined),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 20),

              // Date field (read-only)
              const Text(
                'Date',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText:
                      DateFormat('MMM d, yyyy · h:mm a').format(_currentDate),
                  hintStyle: const TextStyle(color: Colors.black),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.blueGrey.shade200),
                  ),
                  prefixIcon: const Icon(Icons.calendar_today),
                ),
              ),

              // Error message display
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: 30),

              // Share button
              _isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : myButton(
                      onPressed: _sharePhoto,
                      label: 'Share Your Experience',
                      color: Colors.blueGrey.shade700,
                      fontSize: 16,
                      minWidth: double.infinity,
                      padding: 16,
                      borderRadius: 12,
                      icon: Icons.share,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
