import 'package:my_berita/model/article/article_model.dart';

class ArticleResponse {
  final List<Article> articles;
  final String error;

  ArticleResponse.fromJson(Map<String, dynamic> json)
  :   articles = (json['articles'] as List)
        .map((article) => Article.fromJson(article))
        .toList(),
    error = '';

  ArticleResponse.withError(String errorValue)
      : articles = [],
        error = errorValue;

}