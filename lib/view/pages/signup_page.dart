import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_spa/controller/signup_controller.dart';
import 'package:my_spa/view/widgets/my_button.dart';
import 'package:my_spa/view/widgets/my_text_field.dart';
import 'package:animated_background/animated_background.dart';

SignupController signupController = SignupController();

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
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
                    'Create an Account',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sign up to get started',
                    style: TextStyle(
                      color: Colors.white70,
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
                    hint: "Email",
                    icon: Icons.email,
                    controller: emailController,
                  ),
                  const SizedBox(height: 16),
                  textField(
                    hint: "Enter Password",
                    icon: Icons.lock,
                    controller: passwordController,
                    obscureText: true,
                    isPassword: true,
                  ),
                  const SizedBox(height: 16),
                  textField(
                    hint: "Confirm Password",
                    icon: Icons.lock,
                    controller: passwordController,
                    obscureText: true,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  myButton(
                    onPressed: () {
                      Get.toNamed("/home");
                      signupController
                          .setErrorMessage('Cannot continue to signup!!');
                    },
                    label: "Sign Up",
                    color: Colors.yellow,
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed("/login");
                    },
                    child: const Text(
                      "Already have an account? Login",
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
