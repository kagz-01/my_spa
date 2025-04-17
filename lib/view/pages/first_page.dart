import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animated_background/animated_background.dart';
import 'package:my_spa/view/widgets/my_button.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override

  // ignore: library_private_types_in_public_api
  _FirstPageState createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage>
    with SingleTickerProviderStateMixin {
  final List<String> imagePaths = [
    'assets/images/pages/page1.jpg',
    'assets/images/pages/page2.jpg',
    'assets/images/pages/page3.jpg',
    'assets/images/pages/page4.jpg',
    'assets/images/pages/page5.png',
  ];

  int _currentIndex = 0;
  late PageController _pageController;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_currentIndex < imagePaths.length - 1) {
        _currentIndex++;
      } else {
        _currentIndex = 0;
      }
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          AnimatedBackground(
            behaviour: RandomParticleBehaviour(),
            vsync: this,
            child: PageView.builder(
              controller: _pageController,
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return Image.asset(
                  imagePaths[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                );
              },
            ),
          ),
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((0.7 * 255).toInt()),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an account? ",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed("/login");
                          Get.snackbar(
                            "HELLOOO!!!",
                            "Welcome back to My Spa!!",
                            colorText: Colors.lightBlue,
                            backgroundColor: Colors.black,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: const Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  myButton(
                    onPressed: () {
                      Get.toNamed("/signup");
                      Get.snackbar(
                        "WELCOME",
                        "Welcome to My Spa!!",
                        colorText: Colors.lightBlue,
                        backgroundColor: Colors.black,
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                    label: 'CREATE AN ACCOUNT',
                    color: Colors.yellow,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
