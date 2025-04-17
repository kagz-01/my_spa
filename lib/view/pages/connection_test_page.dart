import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:my_spa/services/api_service.dart';

class ConnectionTestPage extends StatefulWidget {
  const ConnectionTestPage({Key? key}) : super(key: key);

  @override
  State<ConnectionTestPage> createState() => _ConnectionTestPageState();
}

class _ConnectionTestPageState extends State<ConnectionTestPage> {
  final TextEditingController _serverIPController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _connectionStatus = "Not tested yet";
  String _loginStatus = "Not attempted";
  bool _isLoading = false;
  String _currentIP = "";

  @override
  void initState() {
    super.initState();
    _loadServerIP();
  }

  @override
  void dispose() {
    _serverIPController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadServerIP() async {
    setState(() => _isLoading = true);

    final ip = await ApiService.serverIP;
    setState(() {
      _currentIP = ip;
      _serverIPController.text = ip;
      _isLoading = false;
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = "Testing connection...";
    });

    try {
      // Test connection to server
      final ip = _serverIPController.text.trim();
      final url = "http://$ip/my_spa/connect.php";

      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      setState(() {
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          _connectionStatus =
              "✅ Connected: ${jsonResponse['message']} at ${jsonResponse['timestamp']}";
          // Save the IP if connection successful
          ApiService.setServerIP(ip);
          _currentIP = ip;
        } else {
          _connectionStatus =
              "❌ Connection failed: Status ${response.statusCode}";
        }
      });
    } catch (e) {
      setState(() {
        _connectionStatus = "❌ Connection error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _loginStatus = "❌ Email and password are required";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _loginStatus = "Attempting login...";
    });

    try {
      // Test login to server
      final ip = _currentIP;
      final url = "http://$ip/my_spa/login.php";

      final response = await http.post(
        Uri.parse(url),
        body: {
          'email': _emailController.text.trim(),
          'password': _passwordController.text.trim(),
        },
      ).timeout(const Duration(seconds: 10));

      setState(() {
        _loginStatus = "Response (${response.statusCode}): ${response.body}";
      });
    } catch (e) {
      setState(() {
        _loginStatus = "❌ Login error: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Diagnostic'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Server connection test
            const Text(
              'Server Connection Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _serverIPController,
              decoration: const InputDecoration(
                labelText: 'Server IP',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testConnection,
                  child: const Text('Test Connection'),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _connectionStatus,
                    style: TextStyle(
                      color: _connectionStatus.contains('✅')
                          ? Colors.green
                          : _connectionStatus.contains('❌')
                              ? Colors.red
                              : Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 40),

            // Login test
            const Text(
              'Login Test',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _testLogin,
                  child: const Text('Test Login'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Current server IP: $_currentIP',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Login Status:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(_loginStatus),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                ),
                child: const Text('Back to Settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
