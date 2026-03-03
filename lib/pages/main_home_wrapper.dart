import 'package:flutter/material.dart';
import 'package:projectone/services/auth_service.dart';
import 'package:projectone/pages/login_page.dart';
import 'package:projectone/pages/admin_dashboard_page.dart';
import 'package:projectone/pages/home_page.dart';

class MainHomeWrapper extends StatefulWidget {
  const MainHomeWrapper({super.key});

  @override
  State<MainHomeWrapper> createState() => _MainHomeWrapperState();
}

class _MainHomeWrapperState extends State<MainHomeWrapper> {
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = AuthService.getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Check if user is logged in
        if (!AuthService.isLoggedIn()) {
          return const LoginPage();
        }

        // Get user data
        final userData = AuthService.getUserData();
        final userRole = userData?['role'] ?? 'user';

        // Route to appropriate page based on role
        if (userRole == 'admin') {
          return const AdminDashboardPage();
        } else {
          return const HomePage();
        }
      },
    );
  }
}
