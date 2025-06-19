import 'package:flutter/material.dart';
import 'package:my_berita/bloc/login_bloc.dart';
import 'package:my_berita/screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _name = '';
  String _email = '';
  String _title = '';
  String _avatar = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('user_email') ?? 'Tidak ada email';
      _name = prefs.getString('user_name') ?? _email.split('@')[0];
      _title = prefs.getString('user_title') ?? 'Pengguna';
      _avatar = prefs.getString('user_avatar') ?? '';
    });
  }

  Future<void> _logout() async {
    print("LOGOUT: Tombol Logout Ditekan.");
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("LOGOUT: SharedPreferences berhasil dihapus.");

    loginBloc.drainStream();
    if (!mounted) return;

    print("LOGOUT: Melakukan navigasi ke LoginScreen...");
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2833),
      body: _email.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileContent(),
    );
  }

  Widget _buildProfileContent() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24.0).copyWith(top: 40, bottom: 30),
          decoration: const BoxDecoration(
              color: Color(0xFF1A1A2E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              )
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey.shade800,
                backgroundImage: _avatar.isNotEmpty ? NetworkImage(_avatar) : null,
                child: _avatar.isEmpty ? const Icon(Icons.person, size: 50, color: Colors.white70) : null,
              ),
              const SizedBox(height: 16),
              Text(_name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(_title, style: const TextStyle(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 4),
              Text(_email, style: const TextStyle(color: Colors.white54, fontSize: 14)),
            ],
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: ElevatedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text("Logout", style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                )
            ),
          ),
        ),
      ],
    );
  }
}
