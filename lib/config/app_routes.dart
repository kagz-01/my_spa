import 'package:get/get.dart';
import 'package:my_spa/view/pages/booking_page.dart';
import 'package:my_spa/view/pages/category_page.dart';
import 'package:my_spa/view/pages/category_detail_page.dart';
import 'package:my_spa/view/pages/dash.dart';
import 'package:my_spa/view/pages/first_page.dart';
import 'package:my_spa/view/pages/home_page.dart';
import 'package:my_spa/view/pages/notification_page.dart';
import 'package:my_spa/view/pages/setting_page.dart';
import 'package:my_spa/view/pages/welcome_page.dart';
import 'package:my_spa/view/pages/login_page.dart';
import 'package:my_spa/view/pages/signup_page.dart';
import 'package:my_spa/view/pages/share_photo_page.dart';

List<GetPage> myroutes = [
  GetPage(name: "/", page: () => FirstPage()),
  GetPage(name: "/login", page: () => LoginPage()),
  GetPage(name: "/signup", page: () => const Signup()),
  GetPage(name: "/dash", page: () => const Dash()),
  GetPage(name: "/home", page: () => const HomePage()),
  GetPage(name: "/notification", page: () => const NotificationPage()),
  GetPage(name: "/welcome", page: () => const WelcomePage()),
  GetPage(name: "/category", page: () => CategoryPage()),
  GetPage(name: "/category-detail", page: () => const CategoryDetailPage()),
  GetPage(name: "/settings", page: () => SettingsPage()),
  GetPage(name: "/bookings", page: () => const BookingPage()),
  GetPage(name: "/share_photo", page: () => const SharePhotoPage()),
];
