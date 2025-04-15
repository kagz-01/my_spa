import 'package:get/get.dart';
import 'package:my_spa/view/pages/dash.dart';
import 'package:my_spa/view/pages/first_page.dart';
import 'package:my_spa/view/pages/home_page.dart';
import 'package:my_spa/view/pages/login_page.dart';
import 'package:my_spa/view/pages/products_list.dart';
import 'package:my_spa/view/pages/products_page.dart';
import 'package:my_spa/view/pages/profile_page.dart';
import 'package:my_spa/view/pages/services_list.dart';
import 'package:my_spa/view/pages/services_page.dart';
import 'package:my_spa/view/pages/signup_page.dart';

List<GetPage> myroutes = [
  GetPage(name: "/", page: () => FirstPage()),
  GetPage(name: "/login", page: () => LoginPage()),
  GetPage(name: "/signup", page: () => const Signup()),
  GetPage(name: "/dash", page: () => const Dash()),
  GetPage(name: "/home", page: () => const HomePage()),
  GetPage(name: "/servicesList", page: () => ServiceDetailsPage()),
  GetPage(name: "/services", page: () => const ServicesPage()),
  GetPage(name: "/productsList", page: () => ProductDetailsPage()),
  GetPage(name: "/products", page: () => const ProductsPage()),
  GetPage(name: "/profile", page: () => const ProfilePage()),
];
