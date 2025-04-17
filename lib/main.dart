import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_spa/config/app_routes.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import 'package:my_spa/controller/user_profile_controller.dart';

// Spa theme colors
const Color primaryColor = Color(0xFF2A6877); // Teal blue - primary brand color
const Color secondaryAccentColor =
    Color(0xFF8D6E63); // Warm brown - secondary accent
const Color backgroundColor = Color(0xFFF5F5F5); // Light gray background
const Color surfaceColor = Color(0xFFFFFFFF); // White surface
const Color accentColor = Color(0xFFBB8FCE); // Soft lavender accent
const Color goldAccent = Color(0xFFD4AF37); // Gold for luxury accents
const Color textPrimaryColor = Color(0xFF424242); // Dark gray for primary text
const Color textSecondaryColor =
    Color(0xFF757575); // Medium gray for secondary text

void main() async {
  await GetStorage.init();
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: surfaceColor,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Initialize controllers - we still need this for dependency injection
  // but our modified controller won't make API calls on init
  Get.put(UserProfileController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Kagz Spa',
      initialRoute: "/", // Reverted back to normal login flow
      getPages: myroutes,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Color scheme
        primaryColor: primaryColor,
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: secondaryAccentColor,
          surface: surfaceColor,
          error: Colors.redAccent,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: textPrimaryColor,
          onError: Colors.white,
          brightness: Brightness.light,
        ),

        // Text theme
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Urbanist',
            color: textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Urbanist',
            color: textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
          displaySmall: TextStyle(
            fontFamily: 'Urbanist',
            color: textPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Urbanist',
            color: textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Urbanist',
            color: textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Urbanist',
            color: textPrimaryColor,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Urbanist',
            color: textPrimaryColor,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Urbanist',
            color: textSecondaryColor,
          ),
        ),

        // Other theme elements
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: surfaceColor,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: primaryColor),
          titleTextStyle: TextStyle(
            fontFamily: 'Urbanist',
            color: primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surfaceColor,
          selectedItemColor: primaryColor,
          unselectedItemColor: textSecondaryColor,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          showSelectedLabels: true,
          showUnselectedLabels: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: const BorderSide(color: primaryColor, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
            textStyle: const TextStyle(
              fontFamily: 'Urbanist',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: surfaceColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryColor, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 1),
          ),
          hintStyle: TextStyle(
            fontFamily: 'Urbanist',
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            fontFamily: 'Urbanist',
            color: textSecondaryColor,
            fontSize: 14,
          ),
        ),
        cardTheme: CardTheme(
          color: surfaceColor,
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        dividerTheme: DividerThemeData(
          color: Colors.grey.shade300,
          thickness: 1,
          space: 24,
        ),
        useMaterial3: true,
      ),
    );
  }
}
