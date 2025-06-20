import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:my_berita/bloc/register_bloc.dart';
import 'package:my_berita/model/auth/register_response.dart';
import 'package:my_berita/screens/auth/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _titleController = TextEditingController();
  final _avatarController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    registerBloc.subject.stream.listen((RegisterResponse response) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      if (response.success) {
        _showSuccessDialog(response.message);
      } else if (response.error.isNotEmpty) {
        _showErrorSnackbar(response.error);
      }
    });
  }

  void _register() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      registerBloc.register(
        _emailController.text,
        _passwordController.text,
        _nameController.text,
        _titleController.text,
        _avatarController.text.isNotEmpty
            ? _avatarController.text
            : "https://i.pravatar.cc/150",
      );
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: HexColor("1C2833"),
        title: const Text("Registrasi Berhasil", style: TextStyle(color: Colors.white)),
        content: Text("$message Silakan masuk untuk melanjutkan.", style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: const Text("OK", style: TextStyle(color: Colors.lightBlueAccent)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _titleController.dispose();
    _avatarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C2833),
      appBar: AppBar(
        title: const Text("Buat Akun Baru", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Header Teks
            const Text(
              "Mulai Perjalanan Anda",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Lengkapi data di bawah untuk membuat akun anda.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),

            // Input Fields
            _buildTextField(_nameController, "Nama Lengkap", icon: Icons.person_outline),
            _buildTextField(_emailController, "Alamat Email", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
            _buildPasswordField(),
            _buildTextField(_titleController, "Jabatan (e.g., Jurnalis)", icon: Icons.work_outline),
            _buildTextField(_avatarController, "URL Gambar Avatar (Opsional)", icon: Icons.image_outlined),

            const SizedBox(height: 32),
            _buildSubmitButton(),

            const SizedBox(height: 16),
            _buildLoginLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {IconData? icon, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
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
        validator: (value) {
          if (controller == _avatarController) return null;
          if (value == null || value.isEmpty) return '$hintText tidak boleh kosong';
          if (controller == _emailController && !value.contains('@')) return 'Masukkan format email yang valid';
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          TextFormField(
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
            validator: (value) => (value != null && value.length < 6) ? 'Password minimal 6 karakter' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: !_isPasswordVisible,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Konfirmasi Password",
              hintStyle: const TextStyle(color: Colors.white54),
              prefixIcon: const Icon(Icons.lock_person_outlined, color: Colors.white70, size: 20),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: Colors.blueAccent, width: 1.5)),
            ),
            validator: (value) => value != _passwordController.text ? 'Password tidak cocok' : null,
          ),
        ],
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
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
        child: const Text("Daftar Sekarang", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Sudah punya akun?", style: TextStyle(color: Colors.white70)),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Masuk di sini", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.lightBlueAccent)),
        ),
      ],
    );
  }
}