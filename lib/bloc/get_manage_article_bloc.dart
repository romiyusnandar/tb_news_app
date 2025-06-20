import 'package:my_berita/model/article/article_model.dart';
import 'package:my_berita/model/article/article_response.dart';
import 'package:my_berita/repository/repository_second.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetManagedArticlesBloc {
  final NewsRepositorySecond _repository = NewsRepositorySecond();
  final BehaviorSubject<ArticleResponse> _subject =
  BehaviorSubject<ArticleResponse>();

  getManagedArticles() async {
    _subject.sink.add(ArticleResponse.withError("loading"));

    try {
      final prefs = await SharedPreferences.getInstance();
      final myArticleIds = prefs.getStringList('my_article_ids') ?? [];

      if (myArticleIds.isEmpty) {
        _subject.sink.add(ArticleResponse(true, "Anda belum membuat artikel.", [], ''));
        return;
      }

      // PERBAIKAN: Logika yang sama seperti di bookmark BLoC.
      final List<Future<Article?>> articleFutures = myArticleIds.map((id) {
        return _repository.getArticleById(id).catchError((error) {
          print("Gagal mengambil artikel terkelola dengan ID: $id. Menghapus dari daftar...");
          _removeInvalidManagedId(id);
          return null;
        });
      }).toList();

      final List<Article?> results = await Future.wait(articleFutures);
      final List<Article> validArticles = results.whereType<Article>().toList();

      _subject.sink.add(ArticleResponse(true, "Berhasil", validArticles, ''));

    } catch (e) {
      _subject.sink.add(ArticleResponse.withError("Gagal memuat artikel: ${e.toString()}"));
    }
  }

  Future<void> _removeInvalidManagedId(String articleId) async {
    final prefs = await SharedPreferences.getInstance();
    final myArticleIds = prefs.getStringList('my_article_ids') ?? [];
    myArticleIds.remove(articleId);
    await prefs.setStringList('my_article_ids', myArticleIds);
  }

  dispose() => _subject.close();
  BehaviorSubject<ArticleResponse> get subject => _subject;
}

final getManagedArticlesBloc = GetManagedArticlesBloc();