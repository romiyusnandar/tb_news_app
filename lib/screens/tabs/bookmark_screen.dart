import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_berita/bloc/get_bookmarked_articles_bloc.dart';
import 'package:my_berita/bloc/bookmark_bloc.dart';
import 'package:my_berita/model/article_model.dart';
import 'package:my_berita/screens/news_detail_screen.dart';
import 'package:my_berita/widgets/home_widgets/article_card.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  StreamSubscription? _bookmarkSubscription;

  @override
  void initState() {
    super.initState();
    _bookmarkSubscription = bookmarkBloc.stream.listen((_) {
      if (mounted) {
        getBookmarkedArticlesBloc.getBookmarkedArticles();
      }
    });
    getBookmarkedArticlesBloc.getBookmarkedArticles();
  }

  @override
  void dispose() {
    _bookmarkSubscription?.cancel();
    super.dispose();
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
    return StreamBuilder<ArticleResponse>(
      stream: getBookmarkedArticlesBloc.subject.stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data?.error == "loading") {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        if (snapshot.data!.error.isNotEmpty) {
          return Center(child: Text(snapshot.data!.error, style: const TextStyle(color: Colors.white70)));
        }
        final articles = snapshot.data!.articles;
        if (articles.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 80, color: Colors.white54),
                SizedBox(height: 16),
                Text("Belum Ada Bookmark", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text("Tandai artikel yang Anda suka untuk membacanya di sini.", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
              ],
            ),
          );
        }
        
        return StreamBuilder<List<String>>(
          stream: bookmarkBloc.stream,
          builder: (context, bookmarkSnapshot) {
            final bookmarkedIds = bookmarkSnapshot.data ?? [];
            return RefreshIndicator(
              onRefresh: () => getBookmarkedArticlesBloc.getBookmarkedArticles(),
              color: Colors.white,
              backgroundColor: Colors.blueAccent,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return ArticleCard(
                    article: article,
                    isBookmarked: bookmarkedIds.contains(article.id),
                    onBookmarkPressed: () => bookmarkBloc.toggleBookmark(article.id),
                    onTap: () => _navigateToDetail(article),
                  );
                },
              ),
            );
          }
        );
      },
    );
  }
}