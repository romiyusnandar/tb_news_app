import 'package:my_berita/model/article_model.dart';
import 'package:my_berita/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

class GetAuthorNewsBloc {
  final NewsRepository _repository = NewsRepository();
  final BehaviorSubject<ArticleResponse> _subject =
  BehaviorSubject<ArticleResponse>();

  getAuthorNews() async {
    _subject.sink.add(ArticleResponse.withError("loading"));
    ArticleResponse response = await _repository.getAuthorNews();
    if (!_subject.isClosed) {
      _subject.sink.add(response);
    }
  }

  dispose() {
    _subject.close();
  }

  BehaviorSubject<ArticleResponse> get subject => _subject;
}

final getAuthorNewsBloc = GetAuthorNewsBloc();
