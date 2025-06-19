import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_berita/bloc/get_all_news_bloc.dart';
import 'package:my_berita/model/article/article_model.dart';
import 'package:my_berita/model/article/article_response.dart';
import 'package:my_berita/widgets/home_widgets/article_card.dart';
import 'package:my_berita/widgets/home_widgets/trending_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<ArticleResponse>? _newsSubscription;

  final List<Article> _articles = [];
  int _currentPage = 1;
  bool _isLoadingMore = false;
  bool _hasReachedMax = false;
  String _currentError = '';

  List<String> _bookmarkedIds = [];

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() {
    _loadBookmarks();
    _scrollController.addListener(_onScroll);
    _newsSubscription = getAllNewsBloc.subject.stream.listen((response) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
        if (response.error.isNotEmpty && response.error != "loading") {
          _currentError = response.error;
        } else if (response.success) {
          _currentError = '';
          if (response.articles.isEmpty) {
            _hasReachedMax = true;
          } else {
            _articles.addAll(response.articles);
          }
        }
      });
    });
    getAllNewsBloc.getAllNews();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _newsSubscription?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 300 &&
        !_isLoadingMore &&
        !_hasReachedMax) {
      setState(() {
        _isLoadingMore = true;
      });
      _currentPage++;
      getAllNewsBloc.getAllNews();
    }
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _bookmarkedIds = prefs.getStringList('bookmarked_articles') ?? [];
    });
  }

  Future<void> _toggleBookmark(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final updatedBookmarks = List<String>.from(_bookmarkedIds);
    if (updatedBookmarks.contains(articleId)) {
      updatedBookmarks.remove(articleId);
    } else {
      updatedBookmarks.add(articleId);
    }
    await prefs.setStringList('bookmarked_articles', updatedBookmarks);
    setState(() {
      _bookmarkedIds = updatedBookmarks;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0, bottom: 12.0),
          child: Text("Trending Saat Ini", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const TrendingSliderWidget(),
        const SizedBox(height: 24),
        _buildActionButtons(),
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.only(left: 16.0, bottom: 12.0),
          child: Text("Berita Terbaru", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        _buildAllNewsSection(),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildActionButton(icon: Icons.add_circle_outline, label: 'Tambah', color: Colors.blueAccent, onPressed: () => _showSnackbar('Navigasi ke halaman tambah berita...'))),
          const SizedBox(width: 16),
          Expanded(child: _buildActionButton(icon: Icons.edit_note, label: 'Manage', color: Colors.green, onPressed: () => _showSnackbar('Navigasi ke halaman kelola berita...'))),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14.0),
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildAllNewsSection() {
    if (_articles.isEmpty && _isLoadingMore) {
      return const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)));
    }
    if (_currentError.isNotEmpty) {
      return Center(child: Text("Gagal memuat berita: $_currentError", style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center));
    }
    return Column(
      children: [
        ListView.builder(
          itemCount: _articles.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final article = _articles[index];
            return ArticleCard(
              article: article,
              isBookmarked: _bookmarkedIds.contains(article.id),
              onBookmarkPressed: () => _toggleBookmark(article.id),
              onTap: () {
                // Navigate to article detail page
                _showSnackbar('Navigasi ke halaman detail berita: ${article.title}');
              },
            );
          },
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))),
          ),
      ],
    );
  }
}