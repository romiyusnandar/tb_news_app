import 'package:my_berita/model/article/article_model.dart';
import 'package:my_berita/model/article/article_response.dart';
import 'package:my_berita/repository/repository_second.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetBookmarkedArticlesBloc {
  final NewsRepositorySecond _repository = NewsRepositorySecond();
  final BehaviorSubject<ArticleResponse> _subject =
  BehaviorSubject<ArticleResponse>();

  getBookmarkedArticles() async {
    _subject.sink.add(ArticleResponse.withError("loading"));

    try {
      final prefs = await SharedPreferences.getInstance();
      final bookmarkedIds = prefs.getStringList('bookmarked_articles') ?? [];

      if (bookmarkedIds.isEmpty) {
        _subject.sink.add(ArticleResponse(true, "Belum ada artikel yang ditandai.", [], ''));
        return;
      }

      final List<Future<Article?>> articleFutures = bookmarkedIds.map((id) async {
        try {
          return await _repository.getArticleById(id);
        } catch (error) {
          print("Gagal mengambil bookmark dengan ID: $id. Menghapus dari daftar...");
          await _removeInvalidBookmark(id);
          return null;
        }
      }).toList();

      final List<Article?> results = await Future.wait(articleFutures);
      final List<Article> validArticles = results.whereType<Article>().toList();

      _subject.sink.add(ArticleResponse(true, "Berhasil", validArticles, ''));

    } catch (e) {
      _subject.sink.add(ArticleResponse.withError("Gagal memuat bookmark: ${e.toString()}"));
    }
  }

  Future<void> _removeInvalidBookmark(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarkedIds = prefs.getStringList('bookmarked_articles') ?? [];
    bookmarkedIds.remove(articleId);
    await prefs.setStringList('bookmarked_articles', bookmarkedIds);
  }

  dispose() => _subject.close();
  BehaviorSubject<ArticleResponse> get subject => _subject;
}

final getBookmarkedArticlesBloc = GetBookmarkedArticlesBloc();