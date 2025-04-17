import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_spa/controller/user_profile_controller.dart';
import 'package:my_spa/services/api_service.dart';
import 'package:my_spa/view/pages/connection_test_page.dart';
import 'package:my_spa/view/pages/edit_profile_page.dart';
import 'package:my_spa/view/pages/change_password_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool isDarkMode = false;
  bool notificationsEnabled = true;
  late TextEditingController _serverIPController;
  bool _isTestingConnection = false;
  String _connectionStatus = "";
  final UserProfileController _profileController =
      Get.put(UserProfileController());

  @override
  void initState() {
    super.initState();
    _serverIPController = TextEditingController();
    _loadServerIP();
  }

  @override
  void dispose() {
    _serverIPController.dispose();
    super.dispose();
  }

  // Load the current server IP
  Future<void> _loadServerIP() async {
    final ip = await ApiService.serverIP;
    setState(() {
      _serverIPController.text = ip;
    });
  }

  // Save the new server IP
  Future<void> _saveServerIP() async {
    final newIP = _serverIPController.text.trim();
    if (newIP.isNotEmpty) {
      await ApiService.setServerIP(newIP);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Server IP updated successfully')),
      );

      // Test connection with new IP
      _testConnection();
    }
  }

  // Test connection to the server
  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionStatus = "Testing connection...";
    });

    final success = await ApiService().testConnection();

    setState(() {
      _isTestingConnection = false;
      _connectionStatus =
          success ? "✅ Connected successfully" : "❌ Connection failed";
    });
  }

  // Upload profile image
  Future<void> _uploadProfileImage() async {
    await _profileController.uploadProfileImage();
    if (_profileController.errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_profileController.errorMessage.value)),
      );
    } else if (_profileController.successMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_profileController.successMessage.value)),
      );
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
                                                      "assets/images/user/default_avatar.jpg")
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
                      trailing: Switch(
                        value: isDarkMode,
                        activeColor: const Color(0xFF2A6877),
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
                        activeColor: const Color(0xFF2A6877),
                        onChanged: (value) {
                          setState(() => notificationsEnabled = value);
                          // Apply notification settings here
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Server Configuration Section
              const Text(
                "SERVER CONFIGURATION",
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
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "If you've changed networks or the app can't connect to the server, update the IP address below:",
                        style: TextStyle(fontSize: 14, fontFamily: 'Urbanist'),
                      ),
                      const SizedBox(height: 15),
                      TextField(
                        controller: _serverIPController,
                        decoration: InputDecoration(
                          labelText: "Server IP Address",
                          labelStyle: const TextStyle(color: Color(0xFF2A6877)),
                          hintText: "e.g., 192.168.1.100",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide:
                                const BorderSide(color: Color(0xFF2A6877)),
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.save,
                                color: Color(0xFF2A6877)),
                            onPressed: _saveServerIP,
                            tooltip: "Save IP",
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed:
                                _isTestingConnection ? null : _testConnection,
                            icon: const Icon(Icons.wifi),
                            label: const Text("Test Connection"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2A6877),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _isTestingConnection
                                ? const Center(
                                    child: CircularProgressIndicator(
                                    color: Color(0xFF2A6877),
                                  ))
                                : Text(
                                    _connectionStatus,
                                    style: TextStyle(
                                      color: _connectionStatus.contains("✅")
                                          ? Colors.green
                                          : _connectionStatus.contains("❌")
                                              ? Colors.red
                                              : Colors.black,
                                      fontFamily: 'Urbanist',
                                    ),
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton.icon(
                          onPressed: () {
                            Get.to(() => const ConnectionTestPage());
                          },
                          icon: const Icon(Icons.bug_report),
                          label: const Text("Advanced Diagnostics"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.deepOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
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
