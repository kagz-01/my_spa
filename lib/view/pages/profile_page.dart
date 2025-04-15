import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile page
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Picture & User Details
              Center(
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage(
                          "assets/images/user_avatar.png"), // Replace with actual user image
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "kenny kagz",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const Text("kenkagz@example.com",
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Booking History Section
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("📅 Booking History",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      bookingTile(
                          "Deep Tissue Massage", "April 5, 2025", "2:00 PM"),
                      bookingTile(
                          "Facial Treatment", "March 28, 2025", "4:30 PM"),
                      bookingTile(
                          "Manicure & Pedicure", "March 15, 2025", "11:00 AM"),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Account Settings
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    settingsTile(
                      icon: Icons.lock,
                      title: "Change Password",
                      onTap: () {
                        // Navigate to password change page
                      },
                    ),
                    settingsTile(
                      icon: Icons.brightness_6,
                      title: "Dark Mode",
                      trailing: Switch(
                        value: isDarkMode,
                        onChanged: (value) {
                          setState(() => isDarkMode = value);
                          // Apply theme change logic here
                        },
                      ),
                    ),
                    settingsTile(
                      icon: Icons.notifications,
                      title: "Notifications",
                      trailing: Switch(
                        value: notificationsEnabled,
                        onChanged: (value) {
                          setState(() => notificationsEnabled = value);
                          // Apply notification settings here
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Logout Button
              ElevatedButton.icon(
                onPressed: () {
                  Get.toNamed("/FirstPage");
                },
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Booking History Tile Widget
  Widget bookingTile(String service, String date, String time) {
    return ListTile(
      leading: const Icon(Icons.spa, color: Colors.teal),
      title: Text(service, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("$date at $time"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Navigate to booking details
      },
    );
  }

  // Settings Tile Widget
  Widget settingsTile(
      {required IconData icon,
      required String title,
      Widget? trailing,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
