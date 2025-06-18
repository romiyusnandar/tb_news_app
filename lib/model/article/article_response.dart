import 'package:my_berita/model/article/article_model.dart';

class ArticleResponse {
  final bool success;
  final String message;
  final List<Article> articles;
  final String error;

  ArticleResponse(this.success, this.message, this.articles, this.error);

  factory ArticleResponse.fromJson(Map<String, dynamic> json) {
    final articlesList = (json['data']['articles'] as List)
        .map((articleJson) => Article.fromJson(articleJson))
        .toList();

    return ArticleResponse(
      json['success'],
      json['message'],
      articlesList,
      '',
    );
  }

  factory ArticleResponse.withError(String errorValue) {
    return ArticleResponse(
      false,
      '',
      [],
      errorValue,
    );
  }
}