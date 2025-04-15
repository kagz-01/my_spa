import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_spa/view/widgets/my_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.tealAccent, Colors.teal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.spa, size: 100, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                "Welcome to Kagz Spa",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
                "Relax, Refresh, and Rejuvenate.",
                style: TextStyle(fontSize: 16, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Mission & Vision Card
              Card(
                color: Colors.white.withOpacity(0.9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "🌍 Our Mission",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "To provide world-class spa services and self-care products that enhance well-being and beauty.",
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        "🎯 Our Vision",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "To be a leading spa and wellness destination, offering relaxation and rejuvenation for all.",
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  myButton(
                    onPressed: () {
                      Get.toNamed('/services');
                    },
                    label: 'View Services',
                    icon: Icons.spa,
                    color: Colors.teal,
                  ),
                  const SizedBox(width: 10),
                  myButton(
                    onPressed: () {
                      Get.toNamed('/products');
                    },
                    label: 'Shop Products',
                    icon: Icons.shopping_cart,
                    color: Colors.deepPurple,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              myButton(
                onPressed: () {
                  Get.toNamed('/dash');
                },
                label: 'Continue to Kagz Spa',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
