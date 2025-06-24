import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_berita/bloc/get_all_news_bloc.dart';
import 'package:my_berita/model/article_model.dart';
import 'package:my_berita/screens/news_detail_screen.dart';
import 'package:my_berita/widgets/home_widgets/article_card.dart';
import 'package:my_berita/widgets/home_widgets/news_slider.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  void _initializeScreen() {
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
    await getAllNewsBloc.getAllNews(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: Colors.white,
      backgroundColor: Colors.blueAccent,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 12.0),
            child: Text("Berita Teratas", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          TrendingSliderWidget(
            articles: _articles,
            isLoading: _articles.isEmpty && _currentError == 'loading',
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 16.0, bottom: 12.0),
            child: Text("Semua Berita", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          _buildAllNewsSection(),
        ],
      ),
    );
  }

  Widget _buildAllNewsSection() {
    if (_articles.isEmpty && _currentError == 'loading') {
      return _buildShimmerList();
    }
    if (_currentError.isNotEmpty && _currentError != 'loading') {
      return Container(height: 200, child: Center(child: Text(_currentError, style: TextStyle(color: Colors.white70))));
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
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => NewsDetailScreen(),
                ));
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
      height: 124,
      decoration: BoxDecoration(
        color: const Color(0xFF2C3E50),
        borderRadius: BorderRadius.circular(12.0),
      ),
    );
  }
}