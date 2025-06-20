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
        _subject.sink.add(ArticleResponse(true, "Tidak ada artikel.", [], ''));
        return;
      }

      final List<Future<Article>> articleFutures = myArticleIds.map((id) {
        return _repository.getArticleById(id);
      }).toList();

      final List<Article> myArticles = await Future.wait(articleFutures);

      _subject.sink.add(ArticleResponse(true, "Berhasil", myArticles, ''));

    } catch (e) {
      _subject.sink.add(ArticleResponse.withError("Gagal memuat sebagian atau semua artikel: ${e.toString()}"));
    }
  }

  dispose() => _subject.close();
  BehaviorSubject<ArticleResponse> get subject => _subject;
}

final getManagedArticlesBloc = GetManagedArticlesBloc();