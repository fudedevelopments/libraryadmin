import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/auth_controller.dart';
import 'controllers/book_controller.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();


  await SharedPreferences.getInstance();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEC Library Admin',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.grey.shade50,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          binding: BindingsBuilder(() {
            Get.put(AuthController());
          }),
        ),
        GetPage(
          name: '/dashboard',
          page: () => DashboardPage(),
          binding: BindingsBuilder(() {
            Get.find<AuthController>();
            Get.put(BookController());
          }),
        ),
      ],
    );
  }
}
