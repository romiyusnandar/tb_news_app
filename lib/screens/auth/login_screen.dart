import 'package:flutter/material.dart';
import 'package:my_berita/bloc/login_bloc.dart';
import 'package:my_berita/model/auth/login_response.dart';
import 'package:my_berita/screens/auth/register_screen.dart';
import 'package:my_berita/screens/main_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    loginBloc.subject.stream.listen((LoginResponse response) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }

      // Kondisi ini sekarang akan terpenuhi jika API merespons dengan benar.
      if (response.success && response.token != null && response.userProfile != null) {
        _saveDataAndNavigate(response);
      } else if (response.error.isNotEmpty) {
        _showErrorDialog(response.error);
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog("Email dan password tidak boleh kosong.");
      return;
    }
    setState(() => _isLoading = true);
    loginBloc.login(_emailController.text, _passwordController.text);
  }

  /// PERUBAHAN UTAMA: Menyimpan semua data pengguna ke SharedPreferences.
  Future<void> _saveDataAndNavigate(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    final user = response.userProfile!;

    // Simpan semua data pengguna yang diterima dari API.
    await prefs.setString('auth_token', response.token!);
    await prefs.setString('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_title', user.title);
    await prefs.setString('user_avatar', user.avatar);

    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainScreen()),
          (Route<dynamic> route) => false,
    );
  }

  void _showErrorDialog(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI tidak berubah, jadi saya singkat.
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 80.0),
              const Text('Selamat Datang Kembali', textAlign: TextAlign.center, style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8.0),
              Text('Masuk untuk melanjutkan', textAlign: TextAlign.center, style: TextStyle(fontSize: 16.0, color: Colors.grey[600])),
              const SizedBox(height: 48.0),
              TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: InputDecoration(labelText: 'Email', prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)))),
              const SizedBox(height: 16.0),
              TextField(controller: _passwordController, obscureText: !_isPasswordVisible, decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)), suffixIcon: IconButton(icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible)))),
              const SizedBox(height: 24.0),
              _isLoading ? const Center(child: CircularProgressIndicator()) : ElevatedButton(onPressed: _login, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)), backgroundColor: Colors.blueAccent), child: const Text('Masuk', style: TextStyle(fontSize: 16, color: Colors.white))),
              const SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Belum punya akun?", style: TextStyle(color: Colors.grey[600])),
                  TextButton(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterScreen())), child: const Text('Daftar di sini', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
