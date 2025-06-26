import 'package:my_berita/model/article_model.dart';
import 'package:my_berita/repository/repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetBookmarkedArticlesBloc {
  final NewsRepository _repository = NewsRepository();
  final BehaviorSubject<ArticleResponse> _subject = BehaviorSubject<ArticleResponse>();

  getBookmarkedArticles() async {
    _subject.sink.add(ArticleResponse.withError("loading"));

    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedSlugs = prefs.getStringList('bookmarked_article_slugs') ?? [];

      if (bookmarkedSlugs.isEmpty) {
        _subject.sink.add(ArticleResponse(success: true, articles: [], message: "Belum ada artikel yang ditandai."));
        return;
      }

      final List<Future<Article?>> articleFutures = bookmarkedSlugs.map((slug) async {
        try {
          return await _repository.getArticleBySlug(slug);
        } catch (error) {
          print("Gagal mengambil bookmark dengan SLUG: $slug. Menghapus dari daftar...");
          await _removeInvalidBookmark(slug);
          return null;
        }
      }).toList();

      final List<Article?> results = await Future.wait(articleFutures);
      final List<Article> validArticles = results.whereType<Article>().toList();

      _subject.sink.add(ArticleResponse(success: true, articles: validArticles, message: "Berhasil"));

    } catch (e) {
      _subject.sink.add(ArticleResponse.withError("Gagal memuat bookmark: ${e.toString()}"));
    }
  }

  Future<void> _removeInvalidBookmark(String articleSlug) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedSlugs = prefs.getStringList('bookmarked_article_slugs') ?? [];
    bookmarkedSlugs.remove(articleSlug);
    await prefs.setStringList('bookmarked_article_slugs', bookmarkedSlugs);
  }

  dispose() => _subject.close();
  BehaviorSubject<ArticleResponse> get subject => _subject;
}

final getBookmarkedArticlesBloc = GetBookmarkedArticlesBloc();