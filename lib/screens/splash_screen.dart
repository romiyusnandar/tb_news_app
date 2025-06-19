import 'package:flutter/material.dart';
import 'package:my_berita/screens/main_screen.dart';
import 'package:my_berita/screens/auth/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    print("SPLASH_SCREEN: Memeriksa status login...");

    await Future.delayed(const Duration(seconds: 2));

    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('auth_token');

    print(
        "SPLASH_SCREEN: Token yang ditemukan -> ${token ?? 'TIDAK ADA TOKEN'}");

    if (!mounted) return;

    if (token != null && token.isNotEmpty) {
      print("SPLASH_SCREEN: Token ditemukan, navigasi ke MainScreen.");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      print("SPLASH_SCREEN: Token KOSONG, navigasi ke LoginScreen.");
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A1A2E),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, color: Colors.white, size: 80),
            SizedBox(height: 20),
            Text(
              'MyBerita App',
              style: TextStyle(
                fontSize: 32,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 40),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}