import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_spa/controller/login_controller.dart';
import 'package:my_spa/view/widgets/my_button.dart';
import 'package:my_spa/view/widgets/my_text_field.dart';
import 'package:animated_background/animated_background.dart';

LoginController loginController = Get.put(LoginController());

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
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
                    'Welcome Back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Login to your account',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  textField(
                    hint: "Email",
                    icon: Icons.email,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    onSubmitted: (_) => passwordController.text.isNotEmpty
                        ? loginController.loginUser(
                            emailController.text.trim(),
                            passwordController.text.trim(),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  textField(
                    hint: "Password",
                    icon: Icons.lock,
                    controller: passwordController,
                    obscureText: true,
                    isPassword: true,
                    onSubmitted: (_) => loginController.loginUser(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(() => loginController.errorMessage.value != ''
                      ? Text(
                          loginController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        )
                      : const SizedBox()),
                  const SizedBox(height: 16),
                  Obx(() => loginController.isLoading.value
                      ? const CircularProgressIndicator()
                      : myButton(
                          onPressed: () {
                            loginController.loginUser(
                              emailController.text.trim(),
                              passwordController.text.trim(),
                            );
                          },
                          label: "Login",
                          color: Colors.yellow,
                        )),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed("/signup");
                    },
                    child: const Text(
                      "Don't have an account? Sign up",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
