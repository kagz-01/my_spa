import 'package:flutter/material.dart';
import 'package:my_spa/view/pages/products_page.dart';
import 'package:my_spa/view/pages/status_page.dart';
import 'package:my_spa/view/pages/services_page.dart';
import 'package:my_spa/view/pages/profile_page.dart';

class Dash extends StatefulWidget {
  const Dash({super.key});

  @override
  State<Dash> createState() => _DashState();
}

class _DashState extends State<Dash> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ProductsPage(),
    const ServicesPage(),
    const StatusPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          ".....KAGZ SPA.....",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500), // Animation duration
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0), // Slide in from right
              end: Offset.zero, // End at original position
            ).animate(animation),
            child: FadeTransition(
              opacity: animation, // Fade effect
              child: child,
            ),
          );
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.spa), label: 'Services'),
          BottomNavigationBarItem(
              icon: Icon(Icons.track_changes), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        backgroundColor: Colors.indigo,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey.shade400,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("You Don't have any services booked and no products in cart.");
        },
        backgroundColor: Colors.yellow,
        child: const Icon(Icons.calendar_today, color: Colors.black),
      ),
    );
  }
}
