import 'package:flutter/material.dart';
import 'package:my_berita/bloc/get_author_news_bloc.dart';
import 'package:my_berita/bloc/login_bloc.dart';
import 'package:my_berita/model/article_model.dart';
import 'package:my_berita/screens/auth/login_screen.dart';
import 'package:my_berita/screens/crud/create_news_screen.dart';
import 'package:my_berita/screens/manage_news_screen.dart';
import 'package:my_berita/screens/news_detail_screen.dart';
import 'package:my_berita/screens/splash_screen.dart';
import 'package:my_berita/widgets/home_widgets/article_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoggedIn = false;
  bool _isLoading = true;
  String _name = '', _email = '', _avatar = '';

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (mounted) {
      setState(() {
        _isLoggedIn = (token != null && token.isNotEmpty);
        if (_isLoggedIn) {
          _name = prefs.getString('user_name') ?? 'Pengguna';
          _email = prefs.getString('user_email') ?? '';
          _avatar = prefs.getString('user_avatar') ?? '';
          getAuthorNewsBloc.getAuthorNews();
        }
        _isLoading = false;
      });
    }
  }

  void _navigateToLogin() async {
    final result = await Navigator.of(context, rootNavigator: true).push<bool>(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      _checkLoginStatus();
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    loginBloc.drainStream();
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const SplashScreen()),
          (route) => false,
    );
  }

  Future<void> _onRefresh() async {
    await getAuthorNewsBloc.getAuthorNews();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _isLoggedIn ? _buildLoggedInView() : _buildLoggedOutView();
  }

  Widget _buildLoggedOutView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white54, size: 80),
            const SizedBox(height: 24),
            const Text(
              "Anda Belum Masuk",
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              "Silakan masuk terlebih dahulu untuk membuat, mengelola, dan melihat artikel Anda.",
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _navigateToLogin,
              icon: const Icon(Icons.login),
              label: const Text("Masuk Sekarang"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoggedInView() {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Colors.white,
      backgroundColor: Colors.blueAccent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          _buildProfileHeader(),
          _buildActionButtons(),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text("Artikel Anda", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          _buildMyArticlesList(),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundImage: _avatar.isNotEmpty ? NetworkImage(_avatar) : null,
            child: _avatar.isEmpty ? const Icon(Icons.person, size: 35) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(_email, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            tooltip: 'Logout',
          )
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      child: Row(
        children: [
          Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => const CreateNewsScreen())), icon: const Icon(Icons.add, color: Colors.white), label: const Text("Buat", style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, padding: const EdgeInsets.symmetric(vertical: 12)))),
          const SizedBox(width: 16),
          Expanded(child: ElevatedButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (c) => const ManageNewsScreen())), icon: const Icon(Icons.edit_note, color: Colors.white), label: const Text("Manage", style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 12)))),
        ],
      ),
    );
  }

  Widget _buildMyArticlesList() {
    return StreamBuilder<ArticleResponse>(
      stream: getAuthorNewsBloc.subject.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.error == "loading") {
          return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: CircularProgressIndicator()));
        }
        if (snapshot.data!.error.isNotEmpty) {
          return Center(child: Text(snapshot.data!.error, style: const TextStyle(color: Colors.white70)));
        }
        final articles = snapshot.data!.articles;
        if (articles.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Anda belum menerbitkan artikel.", style: TextStyle(color: Colors.white70))));
        }
        return ListView.builder(
          itemCount: articles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return ArticleCard(
              article: articles[index],
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NewsDetailScreen(article: articles[index]),
                ));
              },
            );
          },
        );
      },
    );
  }
}