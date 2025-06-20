import 'package:my_berita/model/article/article_model.dart';
import 'package:my_berita/repository/repository_second.dart';
import 'package:rxdart/rxdart.dart';

// Enum untuk merepresentasikan state
enum CreateArticleState { initial, loading, success, error }

// Kelas untuk membawa data hasil
class CreateArticleResult {
  final CreateArticleState state;
  final Article? article;
  final String? errorMessage;

  CreateArticleResult(this.state, {this.article, this.errorMessage});
}

class CreateArticleBloc {
  final NewsRepositorySecond _repository = NewsRepositorySecond();
  final BehaviorSubject<CreateArticleResult> _subject =
  BehaviorSubject<CreateArticleResult>();

  /// Memulai proses pembuatan artikel baru.
  Future<void> createArticle({
    required String title,
    required String category,
    required String readTime,
    required String imageUrl,
    required String content,
    required List<String> tags, // PERUBAHAN: Dibuat menjadi wajib (required)
  }) async {
    _subject.sink.add(CreateArticleResult(CreateArticleState.loading));
    try {
      Article newArticle = await _repository.createArticle(
        title: title,
        category: category,
        readTime: readTime,
        imageUrl: imageUrl,
        content: content,
        tags: tags, // PERUBAHAN: Mengirimkan list tags yang sudah wajib
      );
      _subject.sink.add(CreateArticleResult(CreateArticleState.success, article: newArticle));
    } catch (e) {
      _subject.sink.add(CreateArticleResult(CreateArticleState.error, errorMessage: e.toString()));
    }
  }

  void reset() {
    _subject.sink.add(CreateArticleResult(CreateArticleState.initial));
  }

  dispose() {
    _subject.close();
  }

  BehaviorSubject<CreateArticleResult> get subject => _subject;
}

final createArticleBloc = CreateArticleBloc();