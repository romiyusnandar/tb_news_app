import 'package:my_berita/model/article/article_response.dart';
import 'package:my_berita/repository/repository_second.dart';
import 'package:rxdart/rxdart.dart';

class GetTrendingNewsBloc {
  final NewsRepositorySecond _repository = NewsRepositorySecond();
  final BehaviorSubject<ArticleResponse> _subject =
  BehaviorSubject<ArticleResponse>();

  getTrendingNews() async {
    _subject.sink.add(ArticleResponse.withError("loading"));

    ArticleResponse response = await _repository.getTrendingNews();
    if (!_subject.isClosed) {
      _subject.sink.add(response);
    }
  }

  dispose() {
    _subject.close();
  }

  BehaviorSubject<ArticleResponse> get subject => _subject;
}

final getTrendingNewsBloc = GetTrendingNewsBloc();
