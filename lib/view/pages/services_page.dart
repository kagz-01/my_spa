import 'package:flutter/material.dart';
import 'package:my_spa/view/widgets/my_button.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  late VideoPlayerController _controller;
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> services = [
    {"title": "Massages", "video": "assets/videos/massage.mp4"},
    {"title": "Facials & Skincare", "video": "assets/videos/facial.mp4"},
    {"title": "Nail Care", "video": "assets/videos/nailcare.mp4"},
    {"title": "Sauna & Steam", "video": "assets/videos/sauna.mp4"},
    {"title": "Hair & Salon", "video": "assets/videos/hair.mp4"},
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        VideoPlayerController.asset("assets/videos/spa_background.mp4")
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
            hintText: "Search services...",
            border: InputBorder.none,
          ),
          style: TextStyle(color: Colors.white),
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

          // Service cards
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: services
                  .where((service) => service["title"]!
                      .toLowerCase()
                      .contains(_searchController.text.toLowerCase()))
                  .map((service) {
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
                              VideoPlayerController.asset(service["video"]!)
                                ..initialize().then((_) {
                                  setState(() {});
                                })),
                        ),
                      ),
                      ListTile(
                        title: Text(service["title"]!,
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: myButton(
                            onPressed: () {
                              Get.toNamed('/servicesList');
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
