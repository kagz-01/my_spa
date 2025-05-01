import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_spa/services/user_service.dart';

class AuthMiddleware extends GetMiddleware {
  final UserService _userService = UserService();

  @override
  RouteSettings? redirect(String? route) {
    // If user is not logged in, redirect to login page
    if (!_userService.isLoggedIn()) {
      return const RouteSettings(name: '/login');
    }
    return null;
  }
}
