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

  Future<void> _saveDataAndNavigate(LoginResponse response) async {
    final prefs = await SharedPreferences.getInstance();
    final user = response.userProfile!;

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
    return Scaffold(
      backgroundColor: const Color(0xFF1C2833),
      body: SafeArea(
        child: Stack(
          children: [
            _buildForm(),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header
            const Icon(Icons.article_outlined, color: Colors.blueAccent, size: 60),
            const SizedBox(height: 24),
            const Text(
              'Selamat Datang Kembali',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            const Text(
              'Masuk untuk membaca dan membuat berita.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0, color: Colors.white70),
            ),
            const SizedBox(height: 48.0),

            // Form Email
            _buildTextField(_emailController, "Alamat Email", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16.0),

            // Form Password
            _buildPasswordField(),
            const SizedBox(height: 32.0),

            // Tombol Login
            _buildSubmitButton(),
            const SizedBox(height: 24.0),

            _buildRegisterLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {IconData? icon, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white70, size: 20) : null,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
      ),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Password",
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70, size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
        suffixIcon: IconButton(
          icon: Icon(_isPasswordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.white70),
          onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        gradient: const LinearGradient(
          colors: [Colors.blueAccent, Colors.lightBlueAccent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        child: const Text("Masuk", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum punya akun?", style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterScreen())),
          child: const Text("Daftar di sini", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlueAccent)),
        ),
      ],
    );
  }
}