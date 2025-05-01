import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_spa/controller/user_profile_controller.dart';
import 'package:my_spa/controller/theme_controller.dart';
import 'package:my_spa/services/api_service.dart';
import 'package:my_spa/view/pages/edit_profile_page.dart';
import 'package:my_spa/view/pages/change_password_page.dart';
import 'package:get_storage/get_storage.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Controllers
  final UserProfileController _profileController =
      Get.find<UserProfileController>();
  final ThemeController _themeController = Get.find<ThemeController>();

  // Storage for notification preference
  final _box = GetStorage();
  final _notificationKey = 'notifications_enabled';
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreference();
    // Refresh user profile data when entering settings
    _profileController.loadUserData(fetchFromApi: true);
  }

  // Load the notification preference
  void _loadNotificationPreference() {
    setState(() {
      notificationsEnabled = _box.read(_notificationKey) ?? true;
    });
  }

  // Save the notification preference
  Future<void> _saveNotificationPreference(bool value) async {
    await _box.write(_notificationKey, value);
    setState(() {
      notificationsEnabled = value;
    });

    // Show confirmation to user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(value ? 'Notifications enabled' : 'Notifications disabled'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Upload profile image
  Future<void> _uploadProfileImage() async {
    await _profileController.uploadProfileImage();
    if (_profileController.errorMessage.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_profileController.errorMessage.value)),
        );
      }
    } else if (_profileController.successMessage.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_profileController.successMessage.value)),
        );
      }
    }
  }

  // Logout user
  Future<void> _logout() async {
    await _profileController.clearUserData();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(
              _profileController.username.isEmpty
                  ? "Settings"
                  : "Hello, ${_profileController.username}",
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Urbanist',
                fontWeight: FontWeight.bold,
              ),
            )),
        backgroundColor: const Color(0xFF2A6877),
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture & User Details
              Center(
                child: Column(
                  children: [
                    Obx(() {
                      final profileImage =
                          _profileController.profileImage.value;
                      return Stack(
                        children: [
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF2A6877),
                                width: 2,
                              ),
                              image: profileImage.isNotEmpty
                                  ? DecorationImage(
                                      fit: BoxFit.cover,
                                      image: profileImage.startsWith('http')
                                          ? NetworkImage(profileImage)
                                          : profileImage.startsWith('uploads/')
                                              ? NetworkImage(
                                                  'http://${ApiService.serverIP}/$profileImage')
                                              : const AssetImage(
                                                      "assets/images/user/Logo.png")
                                                  as ImageProvider,
                                    )
                                  : null,
                            ),
                            child: profileImage.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.grey.shade400,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _uploadProfileImage,
                              child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2A6877),
                                  border: Border.all(
                                    width: 2,
                                    color: Colors.white,
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 10),
                    Obx(() => Text(
                          _profileController.username.value.isEmpty
                              ? "Guest User"
                              : _profileController.username.value,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Urbanist',
                          ),
                        )),
                    Obx(() => Text(
                          _profileController.email.value.isEmpty
                              ? "No email available"
                              : _profileController.email.value,
                          style: TextStyle(
                            color: Colors.grey,
                            fontFamily: 'Urbanist',
                          ),
                        )),
                    if (_profileController.phone.value.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Obx(() => Text(
                              _profileController.phone.value,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontFamily: 'Urbanist',
                              ),
                            )),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Account Settings
              const Text(
                "ACCOUNT",
                style: TextStyle(
                  color: Color(0xFF2A6877),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 10),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    settingsTile(
                      icon: Icons.person,
                      title: "Edit Profile",
                      onTap: () {
                        Get.to(() => const EditProfilePage());
                      },
                    ),
                    settingsTile(
                      icon: Icons.lock,
                      title: "Change Password",
                      onTap: () {
                        Get.to(() => const ChangePasswordPage());
                      },
                    ),
                    settingsTile(
                      icon: Icons.brightness_6,
                      title: "Dark Mode",
                      trailing: Obx(() => Switch(
                            value: _themeController.isDarkMode.value,
                            activeColor: const Color(0xFF2A6877),
                            onChanged: (value) {
                              _themeController.setTheme(value);
                            },
                          )),
                    ),
                    settingsTile(
                      icon: Icons.notifications,
                      title: "Notifications",
                      trailing: Switch(
                        value: notificationsEnabled,
                        activeColor: const Color(0xFF2A6877),
                        onChanged: (value) {
                          _saveNotificationPreference(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),

              const SizedBox(height: 20),
              // App Version
              Center(
                child: Text(
                  'App version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontFamily: 'Urbanist',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Settings Tile Widget
  Widget settingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF2A6877)),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Urbanist',
        ),
      ),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
