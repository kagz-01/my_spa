import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final _key = 'isDarkMode';

  // Observable for the theme mode
  final Rx<ThemeMode> _themeMode = ThemeMode.light.obs;

  // Getter for the current theme mode
  ThemeMode get themeMode => _themeMode.value;

  // Observable for dark mode status
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeFromStorage();
  }

  // Load the theme setting from local storage
  _loadThemeFromStorage() {
    isDarkMode.value = _box.read(_key) ?? false;
    _themeMode.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
  }

  // Toggle the theme between dark and light
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _themeMode.value = isDarkMode.value ? ThemeMode.dark : ThemeMode.light;
    _saveThemeToStorage();
    Get.changeThemeMode(_themeMode.value);
  }

  // Set specific theme (true for dark, false for light)
  void setTheme(bool darkMode) {
    isDarkMode.value = darkMode;
    _themeMode.value = darkMode ? ThemeMode.dark : ThemeMode.light;
    _saveThemeToStorage();
    Get.changeThemeMode(_themeMode.value);
  }

  // Save the theme setting to local storage
  _saveThemeToStorage() {
    _box.write(_key, isDarkMode.value);
  }
}
