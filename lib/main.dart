import 'package:flutter/material.dart';
import 'package:projectone/pages/login_page_new.dart';
import 'package:projectone/pages/home_page.dart';
import 'package:projectone/services/auth_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  await AuthService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistem Absensi Siswa',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: AuthService.isLoggedIn() ? const HomePage() : const LoginPageNew(),
      debugShowCheckedModeBanner: false,
    );
  }
}


