import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:my_spa/controller/login_controller.dart';
import 'package:my_spa/view/widgets/my_button.dart';
import 'package:my_spa/view/widgets/my_text_field.dart';
import 'package:animated_background/animated_background.dart';

var store = GetStorage();
LoginController loginController = LoginController();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController usernameController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();

    // Load stored username
    String username = store.read("username") ?? "";
    usernameController.text = username;
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(),
        vsync: this,
        child: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Hello, Welcome USER!!!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Login to continue',
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 40),
                  textField(
                    hint: "Username",
                    icon: Icons.person,
                    controller: usernameController,
                  ),
                  const SizedBox(height: 16),
                  textField(
                    hint: "Password",
                    icon: Icons.lock,
                    controller: passwordController,
                    obscureText: true,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  myButton(
                    onPressed: () {
                      Get.toNamed("/home");
                    },
                    label: "Continue",
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 20),
                  myButton(
                    onPressed: () {
                      Get.toNamed("/Signup");
                    },
                    label: "Sign Up",
                    color: Colors.yellow,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (val) {
                          // Handle remember me logic
                        },
                      ),
                      const Text("Remember me",
                          style: TextStyle(color: Colors.white)),
                      const Spacer(),
                      GestureDetector(
                        child: const Text(
                          "Forgot Password?",
                          style: TextStyle(
                            color: Colors.blueAccent,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                        onTap: () {
                          print("password recovery");
                        },
                      ),
                    ],
                  ),
                  Obx(() => Text(
                        loginController.error_message.value,
                        style: TextStyle(color: Colors.red),
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
