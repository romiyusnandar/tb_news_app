import 'dart:async';
import 'package:flutter/material.dart';
import 'package:my_berita/bloc/get_bookmaked_article_bloc.dart';
import 'package:my_berita/bloc/bookmark_bloc.dart';
import 'package:my_berita/model/article_model.dart';
import 'package:my_berita/screens/news_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

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
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border_rounded, size: 80, color: Colors.white54),
                  SizedBox(height: 16),
                  Text("Bookmark Kosong", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text("Tandai artikel yang Anda suka untuk membacanya di sini nanti.", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        }

        return StreamBuilder<List<String>>(
            stream: bookmarkBloc.stream,
            builder: (context, bookmarkSnapshot) {
              final bookmarkedSlugs = bookmarkSnapshot.data ?? [];
              return RefreshIndicator(
                onRefresh: () => getBookmarkedArticlesBloc.getBookmarkedArticles(),
                color: Colors.white,
                backgroundColor: Colors.blueAccent,
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: articles.length,
                  itemBuilder: (context, index) {
                    final article = articles[index];
                    return _BookmarkArticleCard(
                      article: article,
                      isBookmarked: bookmarkedSlugs.contains(article.slug),
                      onBookmarkPressed: () => bookmarkBloc.toggleBookmark(article.slug),
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

class _BookmarkArticleCard extends StatelessWidget {
  final Article article;
  final bool isBookmarked;
  final VoidCallback onBookmarkPressed;
  final VoidCallback onTap;

  const _BookmarkArticleCard({
    required this.article,
    required this.isBookmarked,
    required this.onBookmarkPressed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E50),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: FadeInImage.assetNetwork(
                placeholder: 'assets/images/placeholder.png',
                image: article.featuredImageUrl ?? '',
                height: 100,
                width: 120,
                fit: BoxFit.cover,
                imageErrorBuilder: (c, o, s) => Container(
                  height: 100,
                  width: 120,
                  color: Colors.grey[800],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
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
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15.0),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article.authorName,
                                style: const TextStyle(color: Colors.white70, fontSize: 12.0, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                timeago.format(article.publishedAt, locale: 'id'),
                                style: const TextStyle(color: Colors.white54, fontSize: 11.0),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                            color: isBookmarked ? Colors.amber : Colors.white70,
                          ),
                          onPressed: onBookmarkPressed,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}