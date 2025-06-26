import 'package:my_berita/model/article_model.dart';
import 'package:my_berita/repository/repository.dart';
import 'package:rxdart/rxdart.dart';

enum FormSubmissionState { initial, loading, success, error }

class FormSubmissionResult {
  final FormSubmissionState state;
  final Article? article;
  final String? errorMessage;

  FormSubmissionResult(this.state, {this.article, this.errorMessage});
}

class CreateArticleBloc {
  final NewsRepository _repository = NewsRepository();
  final BehaviorSubject<FormSubmissionResult> _subject =
  BehaviorSubject<FormSubmissionResult>.seeded(FormSubmissionResult(FormSubmissionState.initial));

  Future<void> createArticle({
    required String title,
    required String summary,
    required String content,
    required String featuredImageUrl,
    required String category,
    required List<String> tags,
    required bool isPublished,
  }) async {
    _subject.sink.add(FormSubmissionResult(FormSubmissionState.loading));
    try {
      Article newArticle = await _repository.createArticle(
        title: title, summary: summary, content: content,
        featuredImageUrl: featuredImageUrl, category: category,
        tags: tags, isPublished: isPublished,
      );
      _subject.sink.add(FormSubmissionResult(FormSubmissionState.success, article: newArticle));
    } catch (e) {
      _subject.sink.add(FormSubmissionResult(FormSubmissionState.error, errorMessage: e.toString()));
    }
  }

  void reset() => _subject.sink.add(FormSubmissionResult(FormSubmissionState.initial));
  void dispose() => _subject.close();
  BehaviorSubject<FormSubmissionResult> get subject => _subject;
}

final createArticleBloc = CreateArticleBloc();
