import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_berita/bloc/get_all_news_bloc.dart';
import 'package:my_berita/bloc/get_trending_news.dart';
import 'package:my_berita/model/article/article_model.dart';
import 'package:my_berita/model/article/article_response.dart';
import 'package:my_berita/screens/crud/create_news_screen.dart';
import 'package:my_berita/screens/crud/manage_news_screen.dart';
import 'package:my_berita/screens/news_detail_screen.dart';
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
            var newArticles = response.articles.where((article) => !_articles.any((a) => a.id == article.id));
            _articles.addAll(newArticles);
          }
        } else if (response.error == "loading") {
          _currentError = "loading";
        }
      });
    });
    _onRefresh();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _newsSubscription?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 300 && !_isLoadingMore && !_hasReachedMax) {
      setState(() => _isLoadingMore = true);
      _currentPage++;
      getAllNewsBloc.getAllNews(page: _currentPage);
    }
  }

  Future<void> _onRefresh() async {
    setState(() {
      _articles.clear();
      _currentPage = 1;
      _hasReachedMax = false;
      _currentError = '';
      _isLoadingMore = false;
    });
    await Future.wait<void>([
      getAllNewsBloc.getAllNews(page: _currentPage),
      getTrendingNewsBloc.getTrendingNews(),
    ]);
  }

  Future<void> _loadBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
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

  void _navigateAndDisplayAddScreen() async {
    final newArticle = await Navigator.of(context).push<Article>(
      MaterialPageRoute(builder: (context) => const CreateNewsScreen()),
    );

    if (newArticle != null && mounted) {
      setState(() {
        _articles.insert(0, newArticle);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Artikel berhasil dipublikasikan!"), backgroundColor: Colors.green),
      );
    }
  }

  void _navigateToDetail(Article article) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => NewsDetailScreen(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Colors.white,
      backgroundColor: Colors.blueAccent,
      child: ListView(
        physics: AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(child: _buildActionButton(icon: Icons.add_circle_outline, label: 'Tambah', color: Colors.blueAccent, onPressed: _navigateAndDisplayAddScreen)),
          const SizedBox(width: 16),
          Expanded(child: _buildActionButton(icon: Icons.edit_note, label: 'Manage', color: Colors.green, onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ManageNewsScreen())))),
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

  Widget _buildAllNewsSection() {
    if (_articles.isEmpty && _currentError == 'loading') {
      return _buildShimmerList();
    }
    if (_currentError.isNotEmpty && _currentError != 'loading') {
      return _buildFullPageError(_currentError);
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
              onTap: () => _navigateToDetail(article),
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

  Widget _buildFullPageError(String error) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, color: Colors.white54, size: 60),
            const SizedBox(height: 16),
            Text(
              error,
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const Text(
              "Tarik layar ke bawah untuk mencoba lagi",
              style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      itemCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const _ShimmerArticleCard(),
    );
  }
}

class _ShimmerArticleCard extends StatelessWidget {
  const _ShimmerArticleCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 100,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: SizedBox(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 16, width: double.infinity, color: Colors.black.withOpacity(0.2)),
                  Container(height: 16, width: MediaQuery.of(context).size.width * 0.4, color: Colors.black.withOpacity(0.2)),
                  const Spacer(),
                  Container(height: 10, width: MediaQuery.of(context).size.width * 0.3, color: Colors.black.withOpacity(0.2)),
                  const SizedBox(height: 6),
                  Container(height: 10, width: double.infinity, color: Colors.black.withOpacity(0.2)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}