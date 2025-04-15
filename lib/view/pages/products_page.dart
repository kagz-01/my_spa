import 'package:flutter/material.dart';
import 'package:my_spa/view/widgets/my_button.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  late VideoPlayerController _controller;
  final TextEditingController _searchController = TextEditingController();

  // Product Categories
  List<Map<String, String>> products = [
    {"title": "Hair Care", "video": "assets/videos/hair_products.mp4"},
    {"title": "Skincare", "video": "assets/videos/skincare.mp4"},
    {"title": "Nail Care", "video": "assets/videos/nail_products.mp4"},
    {"title": "Beauty & Makeup", "video": "assets/videos/makeup.mp4"},
    {"title": "Fragrances", "video": "assets/videos/fragrance.mp4"},
    {"title": "Jewelry & Accessories", "video": "assets/videos/jewelry.mp4"},
    {"title": "Spa & Wellness", "video": "assets/videos/spa_products.mp4"},
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset("assets/videos/shopping_background.mp4")
          ..initialize().then((_) {
            _controller.setLooping(true);
            _controller.setVolume(0);
            _controller.play();
            setState(() {});
          });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: "Search products...",
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white),
          onChanged: (query) {
            setState(() {});
          },
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
      ),
      body: Stack(
        children: [
          // Background animation
          SizedBox.expand(
            child: Opacity(
              opacity: 0.2,
              child: _controller.value.isInitialized
                  ? VideoPlayer(_controller)
                  : Container(color: Colors.black),
            ),
          ),

          // Product Cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: products
                  .where((product) => product["title"]!
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                  .map((product) {
                return Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: VideoPlayer(
                              VideoPlayerController.asset(product["video"]!)
                                ..initialize().then((_) {
                                  setState(() {});
                                })),
                        ),
                      ),
                      ListTile(
                        title: Text(product["title"]!,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: myButton(
                            onPressed: () {
                              Get.toNamed("/productsList");
                            },
                            label: 'VIEW'),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
