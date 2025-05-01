import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_spa/controller/signup_controller.dart';
import 'package:my_spa/view/widgets/my_button.dart';
import 'package:my_spa/view/widgets/my_text_field.dart';
import 'package:animated_background/animated_background.dart';

final SignupController signupController = Get.put(SignupController());

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> with SingleTickerProviderStateMixin {
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  // Add focus nodes for form traversal
  late FocusNode emailFocus;
  late FocusNode passwordFocus;
  late FocusNode confirmPasswordFocus;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    // Initialize focus nodes
    emailFocus = FocusNode();
    passwordFocus = FocusNode();
    confirmPasswordFocus = FocusNode();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    // Dispose focus nodes
    emailFocus.dispose();
    passwordFocus.dispose();
    confirmPasswordFocus.dispose();

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
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sign up to get started',
                    style: TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 40),
                  textField(
                    hint: "Username",
                    icon: Icons.person,
                    controller: usernameController,
                    onSubmitted: (_) => emailFocus.requestFocus(),
                  ),
                  const SizedBox(height: 16),
                  textField(
                    hint: "Email",
                    icon: Icons.email,
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: emailFocus,
                    onSubmitted: (_) => passwordFocus.requestFocus(),
                  ),
                  const SizedBox(height: 16),
                  textField(
                    hint: "Password",
                    icon: Icons.lock,
                    controller: passwordController,
                    obscureText: true,
                    isPassword: true,
                    focusNode: passwordFocus,
                    onSubmitted: (_) => confirmPasswordFocus.requestFocus(),
                  ),
                  const SizedBox(height: 16),
                  textField(
                    hint: "Confirm Password",
                    icon: Icons.lock,
                    controller: confirmPasswordController,
                    obscureText: true,
                    isPassword: true,
                    focusNode: confirmPasswordFocus,
                  ),
                  const SizedBox(height: 16),
                  Obx(() => signupController.errorMessage.value != ''
                      ? Text(
                          signupController.errorMessage.value,
                          style: const TextStyle(color: Colors.red),
                        )
                      : const SizedBox()),
                  const SizedBox(height: 16),
                  Obx(() => signupController.isLoading.value
                      ? const CircularProgressIndicator()
                      : myButton(
                          onPressed: () {
                            if (passwordController.text !=
                                confirmPasswordController.text) {
                              signupController.errorMessage.value =
                                  "Passwords do not match!";
                            } else {
                              signupController.signupUser(
                                usernameController.text.trim(),
                                emailController.text.trim(),
                                passwordController.text.trim(),
                              );
                            }
                          },
                          label: "Sign Up",
                          color: Colors.yellow,
                        )),
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
