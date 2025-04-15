import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:my_spa/config/app_routes.dart';
import 'package:my_spa/config/colors.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
      ),
      title: 'Flutter Demo',
      initialRoute: "/",
      getPages: myroutes,
      debugShowCheckedModeBanner: false,
    );
  }
}
