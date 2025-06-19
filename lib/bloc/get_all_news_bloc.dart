import 'package:my_berita/model/article/article_response.dart';
import 'package:my_berita/repository/repository_second.dart';
import 'package:rxdart/rxdart.dart';

class GetAllNewsBloc {
  final NewsRepositorySecond _repository = NewsRepositorySecond();
  final BehaviorSubject<ArticleResponse> _subject =
  BehaviorSubject<ArticleResponse>();

  getAllNews({int page = 1}) async {
    if (page == 1) {
      _subject.sink.add(ArticleResponse.withError("loading"));
    }

    ArticleResponse response = await _repository.getAllNews(page: page);
    if (!_subject.isClosed) {
      _subject.sink.add(response);
    }
  }

  dispose() {
    _subject.close();
  }

  BehaviorSubject<ArticleResponse> get subject => _subject;
}

final getAllNewsBloc = GetAllNewsBloc();