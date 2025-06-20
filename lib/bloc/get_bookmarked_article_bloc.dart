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

      final List<Future<Article>> articleFutures = bookmarkedIds.map((id) {
        return _repository.getArticleById(id);
      }).toList();

      final List<Article> bookmarkedArticles = await Future.wait(articleFutures);

      _subject.sink.add(ArticleResponse(true, "Berhasil", bookmarkedArticles, ''));

    } catch (e) {
      _subject.sink.add(ArticleResponse.withError("Gagal memuat sebagian atau semua bookmark: ${e.toString()}"));
    }
  }

  dispose() => _subject.close();
  BehaviorSubject<ArticleResponse> get subject => _subject;
}

final getBookmarkedArticlesBloc = GetBookmarkedArticlesBloc();
