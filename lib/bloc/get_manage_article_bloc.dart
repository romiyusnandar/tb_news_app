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

    final prefs = await SharedPreferences.getInstance();
    final myArticleIds = prefs.getStringList('my_article_ids') ?? [];

    if (myArticleIds.isEmpty) {
      _subject.sink.add(ArticleResponse(true, "Tidak ada artikel.", [], ''));
      return;
    }

    ArticleResponse allArticlesResponse = await _repository.getAllNews();

    if (allArticlesResponse.success) {
      final myArticles = allArticlesResponse.articles
          .where((article) => myArticleIds.contains(article.id))
          .toList();

      _subject.sink.add(ArticleResponse(true, "Berhasil", myArticles, ''));
    } else {
      _subject.sink.add(allArticlesResponse);
    }
  }

  dispose() => _subject.close();
  BehaviorSubject<ArticleResponse> get subject => _subject;
}

final getManagedArticlesBloc = GetManagedArticlesBloc();