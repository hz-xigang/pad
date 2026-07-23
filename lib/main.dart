import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app_routes.dart';
import 'entity/login_user.dart';
import 'entity/production_order.dart';
import 'pages/home/home_page.dart';
import 'pages/login/login_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  // 隐藏系统状态栏，并在状态栏被系统唤起时自动重新隐藏
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
    if (systemOverlaysAreVisible) {
      await Future.delayed(const Duration(milliseconds: 300));
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  });

  await Hive.initFlutter();
  Hive.registerAdapter(LoginUserAdapter());
  Hive.registerAdapter(ProductionOrderAdapter());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HZ XG Pad',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D63F0)),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (context) => const LoginPage(),
        AppRoutes.home: (context) => const HomePage(),
      },
      builder: EasyLoading.init(),
    );
  }
}
