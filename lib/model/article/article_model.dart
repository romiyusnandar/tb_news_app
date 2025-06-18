import 'dart:convert';

import 'package:my_berita/model/source/source_model.dart';

class Article {
  final Source source;
  final String? author;
  final String? content;
  final String description;
  final DateTime publishedAt;
  final String title;
  final String url;
  final String urlToImage;

  Article({
    required this.source,
    this.author,
    this.content,
    required this.description,
    required this.publishedAt,
    required this.title,
    required this.url,
    required this.urlToImage,
  });

  Article.fromJson(Map<String, dynamic> json)
      : source = Source.fromJson(json['source']),
        author = json['author'],
        content = json['content'] ?? '',
        description = json['description'] ?? '',
        publishedAt = DateTime.parse(json['publishedAt']),
        title = json['title'],
        url = json['url'],
        urlToImage = json['urlToImage'] ?? '';

  @override
  List<Object> get props => [
    source,
    author ?? '',
    content ?? '',
    description,
    publishedAt,
    title,
    url,
    urlToImage ?? ''
  ];
}

