import 'package:my_berita/model/article/article_response.dart';
import 'package:my_berita/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

class GetTopHeadlinesBloc {
  final NewsRepository _repository = NewsRepository();
  final BehaviorSubject<ArticleResponse> _subject = BehaviorSubject();

  getHeadlines() async {
    ArticleResponse response = await _repository.getTopHeadlines();
    _subject.sink.add(response);
  }

  dispose() {
    _subject.close();
  }

  BehaviorSubject<ArticleResponse> get subject => _subject;

}

final getTopHeadlinesBloc = GetTopHeadlinesBloc();